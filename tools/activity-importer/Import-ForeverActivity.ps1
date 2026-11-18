[CmdletBinding()]
param(
    [string]$Database,
    [string]$Wtf = 'C:\World of Warcraft\_forever_\WTF',
    [string]$PythonPath
)

$ErrorActionPreference = 'Stop'
$importExitCode = 1
$importMutex = $null
$importLocked = $false

try {
    if (-not $Database) {
        $Database = Join-Path (Split-Path -Parent $PSScriptRoot) 'forever.sqlite3'
    }
    if (-not (Test-Path -LiteralPath $Database -PathType Leaf)) {
        throw "Catalog not found: $Database. No new catalog was created."
    }
    $Database = (Resolve-Path -LiteralPath $Database).ProviderPath
    $importer = Join-Path $PSScriptRoot 'import_activity.py'
    if (-not (Test-Path -LiteralPath $importer -PathType Leaf)) {
        throw "Importer not found: $importer"
    }

    $importMutex = [System.Threading.Mutex]::new($false, 'Local\GrindingForeverManualActivityImport')
    try { $importLocked = $importMutex.WaitOne(0) }
    catch [System.Threading.AbandonedMutexException] { $importLocked = $true }
    if (-not $importLocked) {
        throw 'Another activity import is already running. Let it finish, then try again.'
    }

    if ($PythonPath) {
        if (-not (Test-Path -LiteralPath $PythonPath -PathType Leaf)) {
            throw "Python not found: $PythonPath"
        }
        $python = $PythonPath
    } else {
        $python = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
        if (-not (Test-Path -LiteralPath $python -PathType Leaf)) {
            $python = $null
            $onPath = Get-Command python.exe -CommandType Application -ErrorAction SilentlyContinue
            if ($onPath -and $onPath.Source -notmatch '\\Microsoft\\WindowsApps\\python(?:3)?\.exe$') {
                $python = $onPath.Source
            }
            if (-not $python) {
                $runtimes = Get-ChildItem -Path 'C:\Program Files\WindowsApps\OpenAI.CodexPrimaryRuntime*' -Directory -ErrorAction SilentlyContinue |
                    Sort-Object Name -Descending
                foreach ($runtime in $runtimes) {
                    $candidate = Join-Path $runtime.FullName 'dependencies\python\python.exe'
                    if (Test-Path -LiteralPath $candidate -PathType Leaf) { $python = $candidate; break }
                }
            }
        }
        if (-not $python) { throw 'An existing Python runtime could not be found. No software was installed.' }
    }

    $backupFolder = Join-Path (Split-Path -Parent $Database) 'activity-backups'
    $importArguments = @($importer, '--database', $Database, '--wtf', $Wtf,
        '--apply', '--require-existing-database', '--backup-dir', $backupFolder,
        '--managed-backup-retention', '2')
    Write-Host 'Importing saved Grinding Forever activity...'
    Write-Host 'This reads the most recent /reload or logout save.'
    Write-Host ''
    $ErrorActionPreference = 'Continue'
    $importOutput = & $python @importArguments 2>&1
    $pythonExitCode = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    if ($pythonExitCode -ne 0) {
        throw (($importOutput | ForEach-Object { [string]$_ }) -join [Environment]::NewLine)
    }
    $report = (($importOutput | ForEach-Object { [string]$_ }) -join [Environment]::NewLine) | ConvertFrom-Json
    if ($report.mode -ne 'apply') { throw 'The importer did not confirm apply mode. Review the result before retrying.' }

    if ($report.new_observations -gt 0) {
        Write-Host ("SUCCESS: Imported {0:N0} new observations." -f $report.new_observations) -ForegroundColor Green
    } elseif ($report.eligible_observations -gt 0) {
        Write-Host 'ALREADY IMPORTED: No new eligible observations.' -ForegroundColor Green
    } else {
        Write-Host 'NO ELIGIBLE OBSERVATIONS: Nothing was added.' -ForegroundColor Yellow
    }
    Write-Host ("Checked {0} save file(s)." -f $report.files_checked)
    Write-Host ("Skipped validation rows: {0}." -f $report.skipped_save_rows)
    if ($report.skipped_save_rows -gt 0) {
        Write-Host 'Those rows remain in the game save. Valid observations were handled separately.' -ForegroundColor Yellow
    }
    if ($report.backup) { Write-Host ("Recovery backup: {0}" -f $report.backup) }
    if ($report.backup_retention) {
        foreach ($warning in $report.backup_retention.warnings) {
            Write-Host ("IMPORT COMMITTED; BACKUP CLEANUP WARNING: {0}" -f $warning) -ForegroundColor Yellow
        }
        if (-not $report.backup_retention.warnings) {
            Write-Host 'Managed recovery backups: keeping up to the two newest.'
        }
    }
    Write-Host ("Catalog: {0}" -f $Database)
    $importExitCode = 0
} catch {
    Write-Host 'IMPORT FAILED: A completed result was not confirmed. Review the details before retrying.' -ForegroundColor Red
    Write-Host ([string]$_.Exception.Message)
    Write-Host 'If the game was saving or the catalog was busy, wait for it to finish and try again.'
} finally {
    if ($importLocked) { $importMutex.ReleaseMutex() }
    if ($importMutex) { $importMutex.Dispose() }
}

exit $importExitCode
