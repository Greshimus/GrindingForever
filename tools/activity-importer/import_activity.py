"""Import explicit Grinding Forever observations from local saves and optional combat logs."""

import argparse
from collections import Counter
from contextlib import closing
import csv
from dataclasses import dataclass
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import sqlite3
import sys
import uuid


DEFAULT_WTF = Path("C:/World of Warcraft/_forever_/WTF")
DEFAULT_DB = Path("E:/GrindingForeverCatalog/forever.sqlite3")
MANAGED_BACKUP_OWNER = "grinding-forever-manual-activity-v1"
MANAGED_BACKUP_PREFIX = "gf-manual-activity-before-"
MANAGED_BACKUP_NAME = re.compile(r"gf-manual-activity-before-\d{8}T\d{6}-\d{6}Z-[0-9a-f]{32}\.sqlite3")
VARIABLE = "GrindingForeverLiveCharacterDB"
TOKEN = re.compile(r'\s+|--[^\n]*|"(?:[^"\\]|\\[\s\S])*"|[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?|[A-Za-z_]\w*|[{}\[\]=,;]')
LOG_LINE = re.compile(
    r"(?P<time>\d{1,2}/\d{1,2}(?:/\d{4})?\s+\d{1,2}:\d{2}:\d{2}\.\d+(?:[+-]\d{1,4})?)"
    r"\s+(?P<body>[A-Z_]+,.*)"
)
FOREVER_BUILD = re.compile(r"1\.60\.\d+(?:\.\d+)?")
NPC_GUID = re.compile(r"(?:Creature|Vehicle)-(?:\d+-){4}(\d+)-[0-9A-Fa-f]+")
OUTGOING = {
    "SPELL_CAST_START", "SPELL_CAST_SUCCESS", "SPELL_DAMAGE", "SPELL_PERIODIC_DAMAGE",
    "SPELL_AURA_APPLIED", "SPELL_AURA_REFRESH", "SPELL_SUMMON", "SPELL_HEAL",
}
SPELL_MISSES = {"SPELL_MISSED", "SPELL_PERIODIC_MISSED", "RANGE_MISSED", "DAMAGE_SHIELD_MISSED"}
PROFESSIONS = {"Fishing", "Herbalism", "Mining", "Skinning"}

# Each activity kind can retain only the fields the runtime supplies for that event.
ACTIVITY = {
    "login": ((), (), "client-session"),
    "trainer-observed": (("npcID",), (), "trainer-interaction"),
    "vendor-observed": (("npcID",), (), "vendor-interaction"),
    "loot": (("npcID", "itemID"), (), "npc-loot-offered"),
    "target-observed": (("npcID",), (), "selected-npc-stats"),
    "quest-objective": (("questID", "slot", "current"), ("required",), "quest-objective-snapshot"),
    "flight-master-observed": (("nodes",), (), "taxi-map-opened"),
    "flight-measured": (("seconds",), ("cost",), "measured-flight"),
    "quest-accepted": (("questID",), (), "quest-event"),
    "quest-turned-in": (("questID",), (), "quest-event"),
    "gathered-item": (("itemID",), ("quantity",), "loot-near-gather-cast"),
    "loot-message": (("itemID",), ("quantity",), "loot-message"),
    "gather-success": (("spellID",), (), "gather-cast"),
    "craft-completed": (("spellID",), (), "known-crafting-cast"),
}
SCHEMA = (
    """CREATE TABLE IF NOT EXISTS gf_activity_import (
        source_id TEXT NOT NULL,
        snapshot_sha256 TEXT NOT NULL,
        source_kind TEXT NOT NULL,
        imported_utc TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (source_id, snapshot_sha256)
    )""",
    """CREATE TABLE IF NOT EXISTS gf_activity_observation (
        observation_id TEXT PRIMARY KEY,
        source_id TEXT NOT NULL,
        snapshot_sha256 TEXT NOT NULL,
        record_locator TEXT NOT NULL,
        kind TEXT NOT NULL,
        evidence TEXT NOT NULL,
        observed_unix INTEGER,
        npc_id INTEGER,
        spell_id INTEGER,
        payload TEXT NOT NULL CHECK(json_valid(payload)),
        FOREIGN KEY(source_id, snapshot_sha256)
            REFERENCES gf_activity_import(source_id, snapshot_sha256)
    )""",
    """CREATE INDEX IF NOT EXISTS gf_activity_npc_spell
       ON gf_activity_observation(npc_id, spell_id, kind)""",
)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def canonical(data):
    return json.dumps(data, ensure_ascii=False, separators=(",", ":"), sort_keys=True, allow_nan=False)


def lua_string(token):
    output = bytearray()
    i = 1
    escapes = {"a": 7, "b": 8, "f": 12, "n": 10, "r": 13, "t": 9, "v": 11}
    while i < len(token) - 1:
        c = token[i]
        i += 1
        if c != "\\":
            output.extend(c.encode("utf-8"))
            continue
        c = token[i]
        if c.isascii() and c.isdigit():
            end = i + 1
            while end < min(i + 3, len(token) - 1) and token[end].isascii() and token[end].isdigit():
                end += 1
            output.append(int(token[i:end]))
            i = end
            continue
        i += 1
        if c == "\r" and token[i] == "\n":
            i += 1
        output.append(10 if c in "\r\n" else escapes[c] if c in escapes else ord(c))
    return output.decode("utf-8")


class SavedVariables:
    """Parse Lua's serialized scalar and table literals, without evaluating expressions."""

    def __init__(self, text):
        self.text = text
        self.offset = 0
        self.token = self._next()

    def _next(self):
        while self.offset < len(self.text):
            match = TOKEN.match(self.text, self.offset)
            if not match:
                raise ValueError(f"Unsupported SavedVariables token at offset {self.offset}")
            self.offset = match.end()
            token = match.group()
            if not token.isspace() and not token.startswith("--"):
                return token
        return None

    def take(self, expected=None):
        token = self.token
        if token is None or expected is not None and token != expected:
            raise ValueError(f"Invalid SavedVariables syntax at offset {self.offset}")
        self.token = self._next()
        return token

    def scalar(self, token):
        if token.startswith('"'):
            return lua_string(token)
        if token in ("true", "false", "nil"):
            return {"true": True, "false": False, "nil": None}[token]
        if token[0] in "+-.0123456789":
            return float(token) if any(c in token for c in ".eE") else int(token)
        raise ValueError(f"Non-literal SavedVariables value at offset {self.offset}")

    def table(self, depth):
        if depth > 64:
            raise ValueError("SavedVariables table nesting exceeds 64")
        result = {}
        index = 1
        while self.token != "}":
            if self.token == "[":
                self.take("[")
                key = self.scalar(self.take())
                if type(key) not in (str, int, float, bool):
                    raise ValueError(f"Invalid SavedVariables key at offset {self.offset}")
                self.take("]")
                self.take("=")
                value = self.value(depth)
            elif self.token is not None and self.token not in ("true", "false", "nil") and self.token[0].isalpha():
                key = self.take()
                self.take("=")
                value = self.value(depth)
            else:
                key, index = index, index + 1
                value = self.value(depth)
            result[key] = value
            if self.token in (",", ";"):
                self.take()
            elif self.token != "}":
                raise ValueError(f"Missing SavedVariables separator at offset {self.offset}")
        self.take("}")
        return result

    def value(self, depth=0):
        token = self.take()
        return self.table(depth + 1) if token == "{" else self.scalar(token)

    def parse(self):
        self.take(VARIABLE)
        self.take("=")
        self.take("{")
        result = self.table(1)
        if self.token == ";":
            self.take(";")
        if self.token is not None:
            raise ValueError("Unexpected trailing SavedVariables content")
        return result


@dataclass
class Snapshot:
    source_id: str
    sha256: str
    source_kind: str
    rows: list
    skipped: int = 0

    def add(self, locator, kind, evidence, payload, time=None, key=None):
        body = canonical(payload)
        identity = canonical([self.source_id, key or locator, kind, evidence, body])
        self.rows.append((digest(identity.encode("utf-8")), self.source_id, self.sha256, locator,
                          kind, evidence, time, payload.get("npcID"), payload.get("spellID"), body))


def scope(path, source_kind, root=None):
    path = path.resolve()
    location = path.relative_to(root.resolve()) if root and path.is_relative_to(root.resolve()) else path
    return digest((source_kind + "\0" + location.as_posix().casefold()).encode("utf-8"))


def check_read(path, before):
    after = path.stat()
    if (before.st_mtime_ns, before.st_size) != (after.st_mtime_ns, after.st_size):
        raise ValueError("Observation file changed during reading. Retry after the game finishes saving it.")


def numeric(value, lower=1, upper=100_000_000, integer=True):
    if type(value) not in (float, int) or not lower <= value <= upper:
        return None
    if integer:
        return int(value) if int(value) == value else None
    return value


def validated_activity(row):
    if not isinstance(row, dict) or not isinstance(row.get("kind"), str):
        return None
    kind = row["kind"]
    spec = ACTIVITY.get(kind)
    when = numeric(row.get("time"), 1, 2**53 - 1)
    if spec is None or when is None:
        return None
    required, optional, evidence = spec
    data = {}
    for field in required + optional:
        lo = 0 if field in {"current", "required", "nodes", "cost"} else 1
        value = numeric(row.get(field), lo, integer=field != "seconds")
        if value is not None:
            data[field] = value
        elif field in required:
            return None
    if kind == "target-observed":
        for field, minimum, maximum in (("level", 1, 255), ("maxHealth", 101, 2**53 - 1)):
            value = numeric(row.get(field), minimum, maximum)
            if value is not None:
                data[field] = value
        if "level" not in data and "maxHealth" not in data:
            return None
        build = numeric(row.get("build"))
        if build is not None:
            data["build"] = build
    if kind in {"gather-success", "gathered-item"}:
        profession = row.get("profession")
        if not isinstance(profession, str) or profession not in PROFESSIONS:
            return None
        data["profession"] = profession
    if kind == "login":
        for field in ("client", "build"):
            value = row.get(field)
            if type(value) is int:
                value = str(value)
            if isinstance(value, str) and re.fullmatch(r"\d{1,8}(?:\.\d{1,8}){0,3}", value):
                data[field] = value
        if "client" in data and not FOREVER_BUILD.fullmatch(data["client"]):
            return None
        if not data:
            return None
    position = row.get("position")
    if isinstance(position, dict):
        map_id = numeric(position.get("mapID"))
        if map_id is not None:
            data["position"] = {"mapID": map_id}
            x, y = (numeric(position.get(k), 0, 100, integer=False) for k in ("x", "y"))
            if x is not None and y is not None:
                data["position"].update(x=x, y=y, evidence="player-approach")
    data["time"] = when
    sequence = numeric(row.get("sequence"), 1, 2**53 - 1)
    if sequence is not None:
        data["sequence"] = sequence
    return kind, evidence, data, when, sequence


def saved_snapshot(path, root):
    before = path.stat()
    raw = path.read_bytes()
    check_read(path, before)
    source = Snapshot(scope(path, "saved-variables", root), digest(raw), "saved-variables", [])
    events = SavedVariables(raw.decode("utf-8-sig")).parse().get("events")
    if not isinstance(events, dict):
        return source
    for slot, row in events.items():
        if type(slot) is not int or not 1 <= slot <= 2000:
            source.skipped += 1
            continue
        record = validated_activity(row)
        if record is None:
            source.skipped += 1
            continue
        kind, evidence, payload, when, sequence = record
        locator = f"events[{slot}]"
        key = f"sequence:{sequence}" if sequence is not None else locator
        source.add(locator, kind, evidence, payload, when, key)
    return source


def npc(guid):
    match = NPC_GUID.fullmatch(guid)
    return int(match[1]) if match else None


def log_number(value, lo=1):
    return numeric(int(value, 0 if value.lower().startswith("0x") else 10), lo) if re.fullmatch(r"(?:\d{1,9}|0[xX][0-9a-fA-F]{1,8})", value) else None


def log_record(fields, timestamp, build, accepted):
    if len(fields) < 9:
        return None
    event = fields[0]
    if event not in OUTGOING | SPELL_MISSES | {"SWING_MISSED"}:
        return None
    source, target = npc(fields[1]), npc(fields[5])
    actor = source if event in OUTGOING else target
    if actor is None or accepted is not None and actor not in accepted:
        return None
    data = {"event": event, "npcID": actor, "logTimestamp": timestamp, "build": build}
    if event != "SWING_MISSED":
        if len(fields) < 12:
            return None
        spell = log_number(fields[9])
        if spell is None:
            return None
        data["spellID"] = spell
        school = log_number(fields[11], 0)
        if school is not None:
            data["schoolMask"] = school
    if event in OUTGOING:
        return "combat-spell", "npc-combat-event", data
    reason_index = 9 if event == "SWING_MISSED" else 12
    if len(fields) <= reason_index or fields[reason_index] not in {"IMMUNE", "RESIST"}:
        return None
    data["outcome"] = fields[reason_index]
    return "combat-hit-outcome", "npc-target-spell-outcome", data


def combat_snapshot(path, accepted):
    before = path.stat()
    accumulator = hashlib.sha256()
    source = Snapshot(scope(path, "combat-log"), "", "combat-log", [])
    results = []
    build = None
    headers = 0
    with path.open("rb") as r:
        for line, raw in enumerate(r, 1):
            accumulator.update(raw)
            text = raw.decode("utf-8-sig" if line == 1 else "utf-8", errors="replace").rstrip("\r\n")
            match = LOG_LINE.fullmatch(text)
            if not match:
                continue
            fields = next(csv.reader([match["body"]]))
            if fields[0] == "COMBAT_LOG_VERSION":
                headers += 1
                versions = fields[2::2]
                values = fields[3::2]
                build = dict(zip(versions, values)).get("BUILD_VERSION")
                if build is None or not FOREVER_BUILD.fullmatch(build):
                    raise ValueError("Combat log declares a non-Forever or missing client build")
            elif build:
                record = log_record(fields, match["time"], build, accepted)
                if record:
                    results.append((line, record))
    check_read(path, before)
    if not headers:
        raise ValueError("Combat log has no Forever COMBAT_LOG_VERSION/BUILD_VERSION header")
    source.sha256 = accumulator.hexdigest()
    for line, (kind, evidence, payload) in results:
        source.add(f"line:{line}", kind, evidence, payload)
    return source


def readonly(path):
    return sqlite3.connect(path.resolve().as_uri() + "?mode=ro", uri=True)


def new_records(db, snapshots):
    seen = set()
    candidates = []
    for snapshot in snapshots:
        for row in snapshot.rows:
            identity = row[0]
            if identity not in seen:
                seen.add(identity)
                candidates.append(row)
    if db is None or not db.execute(
        "SELECT 1 FROM sqlite_schema WHERE type='table' AND name='gf_activity_observation'"
    ).fetchone():
        return candidates
    existing = set()
    for i in range(0, len(candidates), 500):
        ids = [row[0] for row in candidates[i:i+500]]
        placeholders = ",".join("?" for _ in ids)
        existing.update(k for k, in db.execute(
            f"SELECT observation_id FROM gf_activity_observation WHERE observation_id IN ({placeholders})", ids))
    return [row for row in candidates if row[0] not in existing]


def linked(path):
    """Reject Windows reparse points as well as ordinary symlinks."""
    return path.is_symlink() or bool(getattr(path.lstat(), "st_file_attributes", 0) & 0x400)


def backup(database, directory, managed=False):
    directory.mkdir(parents=True, exist_ok=True)
    if managed and linked(directory):
        raise ValueError("Managed backup folder must not be a link or junction")
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S-%fZ")
    name = (f"{MANAGED_BACKUP_PREFIX}{timestamp}-{uuid.uuid4().hex}.sqlite3" if managed else
            f"{database.stem}-before-activity-{timestamp}.sqlite3")
    path = directory / name
    with path.open("xb"):
        pass
    try:
        with closing(readonly(database)) as source, closing(sqlite3.connect(path)) as target:
            source.backup(target)
    except BaseException:
        path.unlink(missing_ok=True)
        raise
    if managed:
        info = path.stat()
        marker = path.with_name(path.name + ".owned.json")
        # An individual ownership record avoids a shared mutable manifest. A crash
        # before this write leaves an unowned backup that cleanup will preserve.
        with marker.open("x", encoding="utf-8") as output:
            json.dump({"owner": MANAGED_BACKUP_OWNER, "database": str(database.resolve()),
                       "backup": path.name, "size": info.st_size, "mtime_ns": info.st_mtime_ns}, output)
            output.write("\n")
    return path


def prune_managed_backups(database, directory, keep):
    """Called only after a successful nonempty commit; preserve anything unowned or changed."""
    result = {"keep": keep, "removed": 0, "warnings": []}
    candidates = []
    try:
        root = directory.resolve()
        if linked(directory):
            result["warnings"].append("Managed backup folder is a link or junction; nothing removed.")
            return result
        markers = sorted(directory.glob(MANAGED_BACKUP_PREFIX + "*.sqlite3.owned.json"))
        for marker in markers:
            try:
                if linked(marker) or marker.resolve().parent != root:
                    raise ValueError("ownership record is a link or outside the backup folder")
                data = json.loads(marker.read_text(encoding="utf-8"))
                if not isinstance(data, dict) or data.get("owner") != MANAGED_BACKUP_OWNER:
                    continue
                if data.get("database") != str(database.resolve()):
                    continue
                name = data.get("backup")
                if not isinstance(name, str) or not MANAGED_BACKUP_NAME.fullmatch(name):
                    raise ValueError("invalid owned backup filename")
                path = directory / name
                if marker.name != name + ".owned.json" or linked(path) or path.resolve().parent != root:
                    raise ValueError("owned backup path does not match its record")
                info = path.stat()
                if not path.is_file() or (info.st_size, info.st_mtime_ns) != (data.get("size"), data.get("mtime_ns")):
                    raise ValueError("owned backup changed; preserved")
                candidates.append((name, path, marker, info.st_size, info.st_mtime_ns))
            except (OSError, ValueError) as exc:
                result["warnings"].append(f"Preserved {marker.name}: {exc}")
        for _, path, marker, size, mtime_ns in sorted(candidates, reverse=True)[keep:]:
            try:
                info = path.stat()
                if linked(path) or path.resolve().parent != root or (info.st_size, info.st_mtime_ns) != (size, mtime_ns):
                    raise ValueError("backup changed before cleanup; preserved")
                path.unlink()
                marker.unlink()
                result["removed"] += 1
            except (OSError, ValueError) as exc:
                result["warnings"].append(f"Could not finish removing {path.name}: {exc}")
    except OSError as exc:
        result["warnings"].append(f"Backup cleanup could not run: {exc}")
    return result


def apply(database, snapshots, backup_dir, managed=False, require_existing=False):
    database.parent.mkdir(parents=True, exist_ok=True)
    existed = database.exists()
    target = database.resolve().as_uri() + "?mode=rw" if require_existing else str(database)
    with closing(sqlite3.connect(target, timeout=10, uri=require_existing)) as db, db:
        db.execute("PRAGMA foreign_keys=ON")
        db.execute("BEGIN IMMEDIATE")
        rows = new_records(db, snapshots)
        if not rows:
            return 0, None
        backup_path = backup(database, backup_dir, managed=managed) if existed else None
        for statement in SCHEMA:
            db.execute(statement)
        kinds = {s.source_id: s.source_kind for s in snapshots}
        snapshots_used = {(row[1], row[2], kinds[row[1]]) for row in rows}
        db.executemany("INSERT OR IGNORE INTO gf_activity_import (source_id,snapshot_sha256,source_kind) VALUES (?,?,?)",
                       sorted(snapshots_used))
        db.executemany("INSERT INTO gf_activity_observation VALUES (?,?,?,?,?,?,?,?,?,?)", rows)
        if new_records(db, snapshots) or db.execute("PRAGMA foreign_key_check(gf_activity_observation)").fetchone():
            raise sqlite3.IntegrityError("Activity import verification failed; transaction rolled back")
        return len(rows), backup_path


def positive_arg(value):
    try:
        result = int(value)
    except ValueError as exc:
        raise argparse.ArgumentTypeError("Expected a positive integer NPC ID") from exc
    if numeric(result) is None:
        raise argparse.ArgumentTypeError("Expected a positive integer NPC ID")
    return result


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--database", type=Path, default=DEFAULT_DB)
    cli.add_argument("--wtf", type=Path, default=DEFAULT_WTF, help="WTF root used to discover per-character saves")
    cli.add_argument("--save", type=Path, action="append", help="Use this save instead of automatic discovery; repeatable")
    cli.add_argument("--no-saves", action="store_true", help="Import only the specified combat logs")
    cli.add_argument("--combat-log", type=Path, action="append", default=[],
                     help="Read an explicit Forever combat log; repeatable")
    scope_args = cli.add_mutually_exclusive_group()
    scope_args.add_argument("--npc-id", "--boss-id", type=positive_arg, action="append",
                            help="Only capture events involving these NPC IDs; repeatable")
    scope_args.add_argument("--all-npcs", action="store_true", help="Capture eligible events for every NPC in the supplied logs")
    cli.add_argument("--apply", action="store_true", help="Write observations to SQLite. Default is a read-only preview.")
    cli.add_argument("--backup-dir", type=Path, help="Existing catalog backup location; defaults to the database directory")
    cli.add_argument("--managed-backup-retention", type=int,
                     help="Keep this many workflow-owned backups after a successful changing import; requires --backup-dir")
    cli.add_argument("--require-existing-database", action="store_true", help="Refuse to create a missing catalog")
    args = cli.parse_args()
    if args.managed_backup_retention is not None and (not args.backup_dir or not 1 <= args.managed_backup_retention <= 100):
        cli.error("--managed-backup-retention requires --backup-dir and a count from 1 to 100")
    if args.no_saves and args.save:
        cli.error("--no-saves and --save cannot be combined")
    if args.combat_log and not (args.all_npcs or args.npc_id):
        cli.error("Specify --npc-id or --all-npcs when importing combat logs")
    if not args.combat_log and (args.all_npcs or args.npc_id):
        cli.error("--npc-id and --all-npcs require --combat-log")
    saves = [] if args.no_saves else args.save or sorted(args.wtf.glob("Account/**/SavedVariables/GrindingForever.lua"))
    try:
        if args.require_existing_database and not args.database.is_file():
            raise ValueError(f"Catalog not found: {args.database}. No new catalog was created.")
        if not args.no_saves and not saves:
            raise ValueError("No Grinding Forever character saves found. Use /reload or log out, then try again.")
        snapshots = [saved_snapshot(path, args.wtf) for path in saves]
        accepted = None if args.all_npcs else set(args.npc_id or [])
        snapshots.extend(combat_snapshot(path, accepted) for path in args.combat_log)
        if args.database.exists():
            with closing(readonly(args.database)) as db:
                pending = new_records(db, snapshots)
        else:
            pending = new_records(None, snapshots)
        report = {
            "mode": "apply" if args.apply else "dry-run",
            "files_checked": len(snapshots),
            "eligible_observations": sum(len(s.rows) for s in snapshots),
            "skipped_save_rows": sum(s.skipped for s in snapshots),
            "new_observations": len(pending),
            "pending_by_kind": dict(sorted(Counter(row[4] for row in pending).items())),
        }
        if args.apply and pending:
            report["new_observations"], prior = apply(
                args.database, snapshots, args.backup_dir or args.database.parent,
                managed=args.managed_backup_retention is not None, require_existing=args.require_existing_database)
            if prior:
                report["backup"] = str(prior)
            # apply() has left its transaction context, including COMMIT. A failed
            # or no-op import never reaches retention cleanup.
            if report["new_observations"] and args.managed_backup_retention is not None:
                report["backup_retention"] = prune_managed_backups(
                    args.database, args.backup_dir, args.managed_backup_retention)
        print(json.dumps(report, indent=2))
        return 0
    except (OSError, ValueError, csv.Error, sqlite3.Error) as exc:
        print(f"Import stopped: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
