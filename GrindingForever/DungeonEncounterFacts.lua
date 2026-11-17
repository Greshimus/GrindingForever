local _, ns = ...
-- NPC levels matched by ID and name against the local Forever catalog.
-- QuestieDB Forever v1.0.14 (e19dfdf8528334ea63da0ecc4e291c134c0fc266).
-- A few missing levels are supplied by positive Everloot NPC sightings.
ns.DungeonEncounterFacts = {
    [639] = { name = "Edwin VanCleef", minLevel = 21, maxLevel = 21, levelSource = "QuestieDB Forever", rank = 2 },
    [642] = { name = "Sneed's Shredder", minLevel = 20, maxLevel = 20, levelSource = "QuestieDB Forever", rank = 1 },
    [643] = { name = "Sneed", minLevel = 20, maxLevel = 20, levelSource = "QuestieDB Forever", rank = 1 },
    [644] = { name = "Rhahk'Zor", minLevel = 19, maxLevel = 19, levelSource = "QuestieDB Forever", rank = 1 },
    [645] = { name = "Cookie", minLevel = 20, maxLevel = 20, levelSource = "QuestieDB Forever", rank = 1 },
    [646] = { name = "Mr. Smite", minLevel = 20, maxLevel = 20, levelSource = "QuestieDB Forever", rank = 1 },
    [647] = { name = "Captain Greenskin", minLevel = 20, maxLevel = 20, levelSource = "QuestieDB Forever", rank = 1 },
    [1663] = { name = "Dextren Ward", minLevel = 26, maxLevel = 26, levelSource = "QuestieDB Forever", rank = 1 },
    [1666] = { name = "Kam Deepfury", minLevel = 27, maxLevel = 27, levelSource = "QuestieDB Forever", rank = 1 },
    [1696] = { name = "Targorr the Dread", minLevel = 24, maxLevel = 24, levelSource = "QuestieDB Forever", rank = 1 },
    [1716] = { name = "Bazil Thredd", minLevel = 29, maxLevel = 29, levelSource = "QuestieDB Forever", rank = 1 },
    [1717] = { name = "Hamhock", minLevel = 28, maxLevel = 28, levelSource = "QuestieDB Forever", rank = 1 },
    [1720] = { name = "Bruegal Ironknuckle", minLevel = 26, maxLevel = 26, levelSource = "QuestieDB Forever", rank = 2 },
    [1763] = { name = "Gilnid", minLevel = 20, maxLevel = 20, levelSource = "QuestieDB Forever", rank = 1 },
    [1853] = { name = "Darkmaster Gandling", minLevel = 61, maxLevel = 61, levelSource = "QuestieDB Forever", rank = 1 },
    [2748] = { name = "Archaedas", minLevel = 47, maxLevel = 47, levelSource = "QuestieDB Forever", rank = 1 },
    [3586] = { name = "Miner Johnson", minLevel = 19, maxLevel = 19, levelSource = "QuestieDB Forever", rank = 2 },
    [3653] = { name = "Kresh", minLevel = 20, maxLevel = 20, levelSource = "QuestieDB Forever", rank = 1 },
    [3654] = { name = "Mutanus the Devourer", minLevel = 22, maxLevel = 22, levelSource = "QuestieDB Forever", rank = 1 },
    [3669] = { name = "Lord Cobrahn", minLevel = 20, maxLevel = 20, levelSource = "QuestieDB Forever", rank = 1 },
    [3670] = { name = "Lord Pythas", minLevel = 21, maxLevel = 21, levelSource = "QuestieDB Forever", rank = 1 },
    [3671] = { name = "Lady Anacondra", minLevel = 20, maxLevel = 20, levelSource = "QuestieDB Forever", rank = 1 },
    [3673] = { name = "Lord Serpentis", minLevel = 21, maxLevel = 21, levelSource = "QuestieDB Forever", rank = 1 },
    [3674] = { name = "Skum", minLevel = 21, maxLevel = 21, levelSource = "QuestieDB Forever", rank = 1 },
    [3872] = { name = "Deathsworn Captain", minLevel = 25, maxLevel = 25, levelSource = "QuestieDB Forever", rank = 2 },
    [3886] = { name = "Razorclaw the Butcher", minLevel = 22, maxLevel = 22, levelSource = "QuestieDB Forever", rank = 1 },
    [3887] = { name = "Baron Silverlaine", minLevel = 24, maxLevel = 24, levelSource = "QuestieDB Forever", rank = 1 },
    [3914] = { name = "Rethilgore", minLevel = 20, maxLevel = 20, levelSource = "QuestieDB Forever", rank = 1 },
    [3927] = { name = "Wolf Master Nandos", minLevel = 25, maxLevel = 25, levelSource = "QuestieDB Forever", rank = 1 },
    [3974] = { name = "Houndmaster Loksey", minLevel = 34, maxLevel = 34, levelSource = "QuestieDB Forever", rank = 1 },
    [3975] = { name = "Herod", minLevel = 40, maxLevel = 40, levelSource = "QuestieDB Forever", rank = 1 },
    [3976] = { name = "Scarlet Commander Mograine", minLevel = 42, maxLevel = 42, levelSource = "QuestieDB Forever", rank = 1 },
    [3977] = { name = "High Inquisitor Whitemane", minLevel = 42, maxLevel = 42, levelSource = "QuestieDB Forever", rank = 1 },
    [3983] = { name = "Interrogator Vishas", minLevel = 32, maxLevel = 32, levelSource = "QuestieDB Forever", rank = 1 },
    [4274] = { name = "Fenrus the Devourer", minLevel = 25, maxLevel = 25, levelSource = "QuestieDB Forever", rank = 1 },
    [4275] = { name = "Archmage Arugal", minLevel = 26, maxLevel = 26, levelSource = "QuestieDB Forever", rank = 1 },
    [4278] = { name = "Commander Springvale", minLevel = 24, maxLevel = 24, levelSource = "QuestieDB Forever", rank = 1 },
    [4279] = { name = "Odo the Blindwatcher", minLevel = 24, maxLevel = 24, levelSource = "QuestieDB Forever", rank = 1 },
    [4420] = { name = "Overlord Ramtusk", minLevel = 32, maxLevel = 32, levelSource = "QuestieDB Forever", rank = 1 },
    [4421] = { name = "Charlga Razorflank", minLevel = 33, maxLevel = 33, levelSource = "QuestieDB Forever", rank = 1 },
    [4422] = { name = "Agathelos the Raging", minLevel = 33, maxLevel = 33, levelSource = "QuestieDB Forever", rank = 1 },
    [4424] = { name = "Aggem Thorncurse", minLevel = 30, maxLevel = 30, levelSource = "QuestieDB Forever", rank = 1 },
    [4425] = { name = "Blind Hunter", minLevel = 32, maxLevel = 32, levelSource = "QuestieDB Forever", rank = 2 },
    [4428] = { name = "Death Speaker Jargba", minLevel = 30, maxLevel = 30, levelSource = "QuestieDB Forever", rank = 1 },
    [4542] = { name = "High Inquisitor Fairbanks", minLevel = 40, maxLevel = 40, levelSource = "QuestieDB Forever", rank = 1 },
    [4543] = { name = "Bloodmage Thalnos", minLevel = 34, maxLevel = 34, levelSource = "QuestieDB Forever", rank = 1 },
    [4627] = { name = "Arugal's Voidwalker", minLevel = 24, maxLevel = 25, levelSource = "QuestieDB Forever" },
    [4829] = { name = "Aku'mai", minLevel = 28, maxLevel = 28, levelSource = "QuestieDB Forever", rank = 1 },
    [4830] = { name = "Old Serra'kis", minLevel = 26, maxLevel = 26, levelSource = "QuestieDB Forever", rank = 1 },
    [4831] = { name = "Lady Sarevess", minLevel = 25, maxLevel = 25, levelSource = "QuestieDB Forever", rank = 1 },
    [4832] = { name = "Twilight Lord Kelris", minLevel = 27, maxLevel = 27, levelSource = "QuestieDB Forever", rank = 1 },
    [4842] = { name = "Earthcaller Halmgar", minLevel = 32, maxLevel = 32, levelSource = "QuestieDB Forever", rank = 2 },
    [4854] = { name = "Grimlok", minLevel = 45, maxLevel = 45, levelSource = "QuestieDB Forever", rank = 1 },
    [4887] = { name = "Ghamoo-ra", minLevel = 25, maxLevel = 25, levelSource = "QuestieDB Forever", rank = 1 },
    [5709] = { name = "Shade of Eranikus", minLevel = 55, maxLevel = 55, levelSource = "QuestieDB Forever", rank = 1 },
    [5710] = { name = "Jammal'an the Prophet", minLevel = 54, maxLevel = 54, levelSource = "QuestieDB Forever", rank = 1 },
    [5711] = { name = "Ogom the Wretched", minLevel = 53, maxLevel = 53, levelSource = "QuestieDB Forever", rank = 1 },
    [5719] = { name = "Morphaz", minLevel = 52, maxLevel = 52, levelSource = "QuestieDB Forever", rank = 1 },
    [5720] = { name = "Weaver", minLevel = 51, maxLevel = 51, levelSource = "QuestieDB Forever", rank = 1 },
    [5721] = { name = "Dreamscythe", minLevel = 53, maxLevel = 53, levelSource = "QuestieDB Forever", rank = 1 },
    [5722] = { name = "Hazzas", minLevel = 53, maxLevel = 53, levelSource = "QuestieDB Forever", rank = 1 },
    [5775] = { name = "Verdan the Everliving", minLevel = 21, maxLevel = 21, levelSource = "QuestieDB Forever", rank = 1 },
    [5912] = { name = "Deviate Faerie Dragon", minLevel = 20, maxLevel = 20, levelSource = "QuestieDB Forever", rank = 2 },
    [6168] = { name = "Roogug", minLevel = 28, maxLevel = 28, levelSource = "QuestieDB Forever", rank = 1 },
    [6228] = { name = "Dark Iron Ambassador", minLevel = 33, maxLevel = 33, levelSource = "QuestieDB Forever", rank = 2 },
    [6229] = { name = "Crowd Pummeler 9-60", minLevel = 32, maxLevel = 32, levelSource = "QuestieDB Forever", rank = 1 },
    [6235] = { name = "Electrocutioner 6000", minLevel = 32, maxLevel = 32, levelSource = "QuestieDB Forever", rank = 1 },
    [6243] = { name = "Gelihast", minLevel = 26, maxLevel = 26, levelSource = "QuestieDB Forever", rank = 1 },
    [6487] = { name = "Arcanist Doan", minLevel = 37, maxLevel = 37, levelSource = "QuestieDB Forever", rank = 1 },
    [6488] = { name = "Fallen Champion", minLevel = 33, maxLevel = 33, levelSource = "QuestieDB Forever", rank = 2 },
    [6489] = { name = "Ironspine", minLevel = 33, maxLevel = 33, levelSource = "QuestieDB Forever", rank = 2 },
    [6490] = { name = "Azshir the Sleepless", minLevel = 33, maxLevel = 33, levelSource = "QuestieDB Forever", rank = 2 },
    [6910] = { name = "Revelosh", minLevel = 40, maxLevel = 40, levelSource = "QuestieDB Forever", rank = 1 },
    [7079] = { name = "Viscous Fallout", minLevel = 30, maxLevel = 30, levelSource = "QuestieDB Forever", rank = 1 },
    [7206] = { name = "Ancient Stone Keeper", minLevel = 44, maxLevel = 44, levelSource = "QuestieDB Forever", rank = 1 },
    [7228] = { name = "Ironaya", minLevel = 40, maxLevel = 40, levelSource = "QuestieDB Forever", rank = 1 },
    [7267] = { name = "Chief Ukorz Sandscalp", minLevel = 48, maxLevel = 48, levelSource = "QuestieDB Forever", rank = 1 },
    [7271] = { name = "Witch Doctor Zum'rah", minLevel = 46, maxLevel = 46, levelSource = "QuestieDB Forever", rank = 1 },
    [7273] = { name = "Gahz'rilla", minLevel = 46, maxLevel = 46, levelSource = "QuestieDB Forever", rank = 1 },
    [7275] = { name = "Shadowpriest Sezz'ziz", minLevel = 47, maxLevel = 47, levelSource = "QuestieDB Forever", rank = 1 },
    [7291] = { name = "Galgann Firehammer", minLevel = 45, maxLevel = 45, levelSource = "QuestieDB Forever", rank = 1 },
    [7354] = { name = "Ragglesnout", minLevel = 40, maxLevel = 40, levelSource = "QuestieDB Forever", rank = 1 },
    [7355] = { name = "Tuten'kash", minLevel = 40, maxLevel = 40, levelSource = "QuestieDB Forever", rank = 1 },
    [7356] = { name = "Plaguemaw the Rotting", minLevel = 40, maxLevel = 40, levelSource = "QuestieDB Forever", rank = 1 },
    [7357] = { name = "Mordresh Fire Eye", minLevel = 39, maxLevel = 39, levelSource = "QuestieDB Forever", rank = 1 },
    [7358] = { name = "Amnennar the Coldbringer", minLevel = 41, maxLevel = 41, levelSource = "QuestieDB Forever", rank = 1 },
    [7361] = { name = "Grubbis", minLevel = 32, maxLevel = 32, levelSource = "QuestieDB Forever", rank = 1 },
    [7797] = { name = "Ruuzlu", minLevel = 46, maxLevel = 46, levelSource = "QuestieDB Forever", rank = 1 },
    [7800] = { name = "Mekgineer Thermaplugg", minLevel = 34, maxLevel = 34, levelSource = "QuestieDB Forever", rank = 1 },
    [8127] = { name = "Antu'sul", minLevel = 48, maxLevel = 48, levelSource = "QuestieDB Forever", rank = 1 },
    [8443] = { name = "Avatar of Hakkar", minLevel = 49, maxLevel = 50, levelSource = "QuestieDB Forever", rank = 1 },
    [8567] = { name = "Glutton", minLevel = 40, maxLevel = 40, levelSource = "QuestieDB Forever", rank = 1 },
    [8580] = { name = "Atal'alarion", minLevel = 50, maxLevel = 50, levelSource = "QuestieDB Forever", rank = 1 },
    [8923] = { name = "Panzor the Invincible", minLevel = 57, maxLevel = 57, levelSource = "QuestieDB Forever", rank = 2 },
    [8929] = { name = "Princess Moira Bronzebeard", minLevel = 58, maxLevel = 58, levelSource = "QuestieDB Forever", rank = 1 },
    [8983] = { name = "Golem Lord Argelmach", minLevel = 57, maxLevel = 57, levelSource = "QuestieDB Forever", rank = 1 },
    [9016] = { name = "Bael'Gar", minLevel = 54, maxLevel = 54, levelSource = "QuestieDB Forever", rank = 1 },
    [9017] = { name = "Lord Incendius", minLevel = 55, maxLevel = 55, levelSource = "QuestieDB Forever", rank = 1 },
    [9018] = { name = "High Interrogator Gerstahn", minLevel = 52, maxLevel = 52, levelSource = "QuestieDB Forever", rank = 1 },
    [9019] = { name = "Emperor Dagran Thaurissan", minLevel = 59, maxLevel = 59, levelSource = "QuestieDB Forever", rank = 1 },
    [9024] = { name = "Pyromancer Loregrain", minLevel = 52, maxLevel = 52, levelSource = "QuestieDB Forever", rank = 2 },
    [9025] = { name = "Lord Roccor", minLevel = 51, maxLevel = 51, levelSource = "QuestieDB Forever", rank = 2 },
    [9027] = { name = "Gorosh the Dervish", minLevel = 56, maxLevel = 56, levelSource = "QuestieDB Forever", rank = 1 },
    [9028] = { name = "Grizzle", minLevel = 54, maxLevel = 54, levelSource = "QuestieDB Forever", rank = 1 },
    [9029] = { name = "Eviscerator", minLevel = 54, maxLevel = 54, levelSource = "QuestieDB Forever", rank = 1 },
    [9030] = { name = "Ok'thor the Breaker", minLevel = 53, maxLevel = 53, levelSource = "QuestieDB Forever", rank = 1 },
    [9031] = { name = "Anub'shiah", minLevel = 54, maxLevel = 54, levelSource = "QuestieDB Forever", rank = 1 },
    [9032] = { name = "Hedrum the Creeper", minLevel = 53, maxLevel = 53, levelSource = "QuestieDB Forever", rank = 1 },
    [9033] = { name = "General Angerforge", minLevel = 57, maxLevel = 57, levelSource = "QuestieDB Forever", rank = 1 },
    [9041] = { name = "Warder Stilgiss", minLevel = 56, maxLevel = 56, levelSource = "QuestieDB Forever", rank = 2 },
    [9056] = { name = "Fineous Darkvire", minLevel = 54, maxLevel = 54, levelSource = "QuestieDB Forever", rank = 1 },
    [9156] = { name = "Ambassador Flamelash", minLevel = 57, maxLevel = 57, levelSource = "QuestieDB Forever", rank = 1 },
    [9196] = { name = "Highlord Omokk", minLevel = 59, maxLevel = 59, levelSource = "QuestieDB Forever", rank = 1 },
    [9217] = { name = "Spirestone Lord Magus", minLevel = 58, maxLevel = 58, levelSource = "QuestieDB Forever", rank = 2 },
    [9218] = { name = "Spirestone Battle Lord", minLevel = 58, maxLevel = 58, levelSource = "QuestieDB Forever", rank = 2 },
    [9219] = { name = "Spirestone Butcher", minLevel = 57, maxLevel = 57, levelSource = "QuestieDB Forever", rank = 2 },
    [9236] = { name = "Shadow Hunter Vosh'gajin", minLevel = 58, maxLevel = 58, levelSource = "QuestieDB Forever", rank = 1 },
    [9237] = { name = "War Master Voone", minLevel = 58, maxLevel = 58, levelSource = "QuestieDB Forever", rank = 1 },
    [9319] = { name = "Houndmaster Grebmar", minLevel = 52, maxLevel = 52, levelSource = "QuestieDB Forever", rank = 1 },
    [9499] = { name = "Plugger Spazzring", minLevel = 55, maxLevel = 55, levelSource = "QuestieDB Forever", rank = 1 },
    [9502] = { name = "Phalanx", minLevel = 55, maxLevel = 55, levelSource = "QuestieDB Forever", rank = 1 },
    [9537] = { name = "Hurley Blackbreath", minLevel = 55, maxLevel = 55, levelSource = "QuestieDB Forever", rank = 1 },
    [9543] = { name = "Ribbly Screwspigot", minLevel = 53, maxLevel = 53, levelSource = "QuestieDB Forever", rank = 1 },
    [9568] = { name = "Overlord Wyrmthalak", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [9596] = { name = "Bannok Grimaxe", minLevel = 59, maxLevel = 59, levelSource = "QuestieDB Forever", rank = 2 },
    [9718] = { name = "Ghok Bashguud", minLevel = 59, maxLevel = 59, levelSource = "QuestieDB Forever", rank = 2 },
    [9736] = { name = "Quartermaster Zigris", minLevel = 59, maxLevel = 59, levelSource = "QuestieDB Forever", rank = 2 },
    [9816] = { name = "Pyroguard Emberseer", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 3 },
    [9938] = { name = "Magmus", minLevel = 57, maxLevel = 57, levelSource = "QuestieDB Forever", rank = 1 },
    [10080] = { name = "Sandarr Dunereaver", minLevel = 45, maxLevel = 45, levelSource = "QuestieDB Forever", rank = 2 },
    [10081] = { name = "Dustwraith", minLevel = 45, maxLevel = 45, levelSource = "QuestieDB Forever", rank = 2 },
    [10082] = { name = "Zerillis", minLevel = 45, maxLevel = 45, levelSource = "QuestieDB Forever", rank = 2 },
    [10220] = { name = "Halycon", minLevel = 59, maxLevel = 59, levelSource = "QuestieDB Forever", rank = 1 },
    [10264] = { name = "Solakar Flamewreath", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [10268] = { name = "Gizrul the Slavener", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [10339] = { name = "Gyth", minLevel = 62, maxLevel = 62, levelSource = "QuestieDB Forever", rank = 1 },
    [10363] = { name = "General Drakkisath", minLevel = 62, maxLevel = 62, levelSource = "QuestieDB Forever", rank = 3 },
    [10376] = { name = "Crystal Fang", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 2 },
    [10393] = { name = "Skul", minLevel = 58, maxLevel = 58, levelSource = "QuestieDB Forever", rank = 2 },
    [10429] = { name = "Warchief Rend Blackhand", minLevel = 62, maxLevel = 62, levelSource = "QuestieDB Forever", rank = 3 },
    [10430] = { name = "The Beast", minLevel = 62, maxLevel = 62, levelSource = "QuestieDB Forever", rank = 3 },
    [10432] = { name = "Vectus", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [10433] = { name = "Marduk Blackpool", minLevel = 58, maxLevel = 58, levelSource = "QuestieDB Forever", rank = 1 },
    [10435] = { name = "Magistrate Barthilas", minLevel = 58, maxLevel = 58, levelSource = "QuestieDB Forever", rank = 1 },
    [10436] = { name = "Baroness Anastari", minLevel = 59, maxLevel = 59, levelSource = "QuestieDB Forever", rank = 1 },
    [10437] = { name = "Nerub'enkan", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [10438] = { name = "Maleki the Pallid", minLevel = 61, maxLevel = 61, levelSource = "QuestieDB Forever", rank = 1 },
    [10439] = { name = "Ramstein the Gorger", minLevel = 61, maxLevel = 61, levelSource = "QuestieDB Forever", rank = 1 },
    [10440] = { name = "Baron Rivendare", minLevel = 62, maxLevel = 62, levelSource = "QuestieDB Forever", rank = 1 },
    [10502] = { name = "Lady Illucia Barov", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [10503] = { name = "Jandice Barov", minLevel = 61, maxLevel = 61, levelSource = "QuestieDB Forever", rank = 1 },
    [10504] = { name = "Lord Alexei Barov", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [10505] = { name = "Instructor Malicia", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [10506] = { name = "Kirtonos the Herald", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [10507] = { name = "The Ravenian", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [10508] = { name = "Ras Frostwhisper", minLevel = 62, maxLevel = 62, levelSource = "QuestieDB Forever", rank = 1 },
    [10509] = { name = "Jed Runewatcher", minLevel = 59, maxLevel = 59, levelSource = "QuestieDB Forever", rank = 2 },
    [10516] = { name = "The Unforgiven", minLevel = 57, maxLevel = 57, levelSource = "QuestieDB Forever", rank = 1 },
    [10558] = { name = "Hearthsinger Forresten", minLevel = 57, maxLevel = 57, levelSource = "QuestieDB Forever", rank = 2 },
    [10584] = { name = "Urok Doomhowl", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 2 },
    [10596] = { name = "Mother Smolderweb", minLevel = 59, maxLevel = 59, levelSource = "QuestieDB Forever", rank = 1 },
    [10808] = { name = "Timmy the Cruel", minLevel = 58, maxLevel = 58, levelSource = "QuestieDB Forever", rank = 2 },
    [10809] = { name = "Stonespine", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 2 },
    [10811] = { name = "Archivist Galford", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [10813] = { name = "Balnazzar", minLevel = 62, maxLevel = 62, levelSource = "QuestieDB Forever", rank = 1 },
    [10899] = { name = "Goraluk Anvilcrack", minLevel = 61, maxLevel = 61, levelSource = "QuestieDB Forever", rank = 1 },
    [10901] = { name = "Lorekeeper Polkelt", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [10997] = { name = "Cannon Master Willey", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [11143] = { name = "Postmaster Malown", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [11261] = { name = "Doctor Theolen Krastinov", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [11467] = { name = "Tsu'zee", minLevel = 59, maxLevel = 59, levelSource = "QuestieDB Forever", rank = 1 },
    [11486] = { name = "Prince Tortheldrin", minLevel = 60, maxLevel = 61, levelSource = "QuestieDB Forever", rank = 1 },
    [11487] = { name = "Magister Kalendris", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [11488] = { name = "Illyanna Ravenoak", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [11489] = { name = "Tendris Warpwood", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [11490] = { name = "Zevrim Thornhoof", minLevel = 57, maxLevel = 57, levelSource = "QuestieDB Forever", rank = 1 },
    [11492] = { name = "Alzzin the Wildshaper", minLevel = 58, maxLevel = 58, levelSource = "QuestieDB Forever", rank = 1 },
    [11496] = { name = "Immol'thar", minLevel = 61, maxLevel = 61, levelSource = "QuestieDB Forever", rank = 1 },
    [11501] = { name = "King Gordok", minLevel = 61, maxLevel = 62, levelSource = "QuestieDB Forever", rank = 1 },
    [11502] = { name = "Ragnaros", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
    [11517] = { name = "Oggleflint", minLevel = 16, maxLevel = 16, levelSource = "QuestieDB Forever", rank = 1 },
    [11518] = { name = "Jergosh the Invoker", minLevel = 16, maxLevel = 16, levelSource = "QuestieDB Forever", rank = 1 },
    [11519] = { name = "Bazzalan", minLevel = 16, maxLevel = 16, levelSource = "QuestieDB Forever", rank = 1 },
    [11520] = { name = "Taragaman the Hungerer", minLevel = 16, maxLevel = 16, levelSource = "QuestieDB Forever", rank = 1 },
    [11583] = { name = "Nefarian", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
    [11622] = { name = "Rattlegore", minLevel = 61, maxLevel = 61, levelSource = "QuestieDB Forever", rank = 1 },
    [11981] = { name = "Flamegor", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
    [11982] = { name = "Magmadar", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
    [11983] = { name = "Firemaw", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
    [11988] = { name = "Golemagg the Incinerator", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
    [12017] = { name = "Broodlord Lashlayer", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
    [12018] = { name = "Majordomo Executus", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
    [12056] = { name = "Baron Geddon", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
    [12057] = { name = "Garr", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
    [12098] = { name = "Sulfuron Harbinger", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
    [12118] = { name = "Lucifron", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
    [12201] = { name = "Princess Theradras", minLevel = 51, maxLevel = 51, levelSource = "QuestieDB Forever", rank = 1 },
    [12203] = { name = "Landslide", minLevel = 50, maxLevel = 50, levelSource = "QuestieDB Forever", rank = 1 },
    [12225] = { name = "Celebras the Cursed", minLevel = 49, maxLevel = 49, levelSource = "QuestieDB Forever", rank = 1 },
    [12236] = { name = "Lord Vyletongue", minLevel = 47, maxLevel = 47, levelSource = "QuestieDB Forever", rank = 1 },
    [12237] = { name = "Meshlok the Harvester", minLevel = 48, maxLevel = 48, levelSource = "QuestieDB Forever", rank = 2 },
    [12258] = { name = "Razorlash", minLevel = 48, maxLevel = 48, levelSource = "QuestieDB Forever", rank = 1 },
    [12259] = { name = "Gehennas", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
    [12264] = { name = "Shazzrah", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
    [12435] = { name = "Razorgore the Untamed", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
    [12876] = { name = "Baron Aquanis", minLevel = 28, maxLevel = 28, levelSource = "QuestieDB Forever", rank = 1 },
    [12902] = { name = "Lorgus Jett", minLevel = 26, maxLevel = 26, levelSource = "QuestieDB Forever", rank = 1 },
    [13020] = { name = "Vaelastrasz the Corrupt", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
    [13280] = { name = "Hydrospawn", minLevel = 57, maxLevel = 57, levelSource = "QuestieDB Forever", rank = 1 },
    [13282] = { name = "Noxxion", minLevel = 48, maxLevel = 48, levelSource = "QuestieDB Forever", rank = 1 },
    [13596] = { name = "Rotgrip", minLevel = 50, maxLevel = 50, levelSource = "QuestieDB Forever", rank = 1 },
    [13601] = { name = "Tinkerer Gizlock", minLevel = 50, maxLevel = 50, levelSource = "QuestieDB Forever", rank = 1 },
    [14020] = { name = "Chromaggus", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
    [14321] = { name = "Guard Fengus", minLevel = 59, maxLevel = 59, levelSource = "QuestieDB Forever", rank = 1 },
    [14322] = { name = "Stomper Kreeg", minLevel = 59, maxLevel = 59, levelSource = "QuestieDB Forever", rank = 1 },
    [14323] = { name = "Guard Slip'kik", minLevel = 59, maxLevel = 59, levelSource = "QuestieDB Forever", rank = 1 },
    [14324] = { name = "Cho'Rush the Observer", minLevel = 60, maxLevel = 60, levelSource = "QuestieDB Forever", rank = 1 },
    [14325] = { name = "Captain Kromcrush", minLevel = 61, maxLevel = 61, levelSource = "QuestieDB Forever", rank = 1 },
    [14326] = { name = "Guard Mol'dar", minLevel = 59, maxLevel = 59, levelSource = "QuestieDB Forever", rank = 1 },
    [14327] = { name = "Lethtendris", minLevel = 57, maxLevel = 57, levelSource = "QuestieDB Forever", rank = 1 },
    [14506] = { name = "Lord Hel'nurath", minLevel = 62, maxLevel = 62, levelSource = "QuestieDB Forever", rank = 1 },
    [14601] = { name = "Ebonroc", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
    [16042] = { name = "Lord Valthalak", minLevel = 63, maxLevel = 63, levelSource = "QuestieDB Forever", rank = 3 },
}

-- Authored encounter notes based on WoW Forever game-file spells/encounters and published play.
-- https://undying.app/dungeons/shadowfang-keep
-- https://www.method.gg/wow-forever/dungeons/shadowfang-keep
-- https://undying.app/dungeons/ragefire-chasm
-- Arugal's reference HP is published for Forever but also reported for Classic. A live reading wins.
-- https://metaforge.app/wow-forever/database/creatures/archmage-arugal
-- Forever Dungeon Journal 2.0.8 reports different levels for these encounters.
-- Arugal's alternate value was specifically reported in game. Keep both pending reconciliation.
for id, level in pairs({ [4275] = 24, [7354] = 37, [8443] = 55, [9237] = 59, [16042] = 62 }) do
    local fact = ns.DungeonEncounterFacts[id]
    if fact then fact.alternateLevel = level end
end

local function encounter(id, health, abilities)
    local fact = ns.DungeonEncounterFacts[id] or {}
    fact.referenceHealth = health
    fact.mechanics = {}
    for _, ability in ipairs(abilities) do
        fact.mechanics[#fact.mechanics + 1] = { name = ability[1], description = ability[2] }
    end
    ns.DungeonEncounterFacts[id] = fact
end

encounter(3914, nil, {
    {"Soul Drain", "Drains health from a player. Interrupt the cast and clear the nearby adds."},
})
encounter(3886, nil, {
    {"Butcher Drain", "Watch for the drain and clear the nearby worgen so the tank can focus on Razorclaw."},
})
encounter(3887, nil, {
    {"Veil of Shadow", "Reduces healing received. Remove the curse from the tank if you can."},
})
encounter(4278, nil, {
    {"Holy Light", "Save an interrupt for the heal."},
    {"Hammer of Justice", "Stuns the target."},
    {"Divine Shield", "Grants temporary immunity. Use the break to deal with nearby adds."},
})
encounter(4279, nil, {
    {"Howling Rage", "Increases his damage. Kill the bats before committing to Odo."},
})
encounter(3872, nil, {
    {"Cleave and Hamstring", "This rare spawn can hit adjacent players and slow movement. Stand behind him when possible."},
})
encounter(4274, nil, {
    {"Toxic Saliva", "Poisons the target and drains mana. Cleanse the poison when possible."},
    {"Voidwalkers", "Watch for summoned adds and have the tank pick them up."},
})
encounter(3927, nil, {
    {"Call Bleak Worg / Call Lupine Horror", "Summons adds. Have the tank gather them before they reach the healer."},
})
encounter(4275, 6510, {
    {"Void Bolt", "Heavy Shadow damage. Use a wall or pillar to break line of sight."},
    {"Shadow Port", "Teleports around the room. Reposition so the tank and healer can still see each other."},
    {"Arugal's Curse", "Temporarily charms a party member. Control the ally until the curse ends."},
    {"Thundershock", "Hits and stuns nearby players. Ranged players should keep their distance."},
})
encounter(11517, nil, {
    {"Cleave", "Point Oggleflint away from the group and clear his nearby adds."},
})
encounter(11520, nil, {
    {"Fire Nova", "Damages players near Taragaman. Ranged players should stand back."},
    {"Uppercut", "Knocks the target back. Tank away from the edge of the lava."},
})
encounter(11518, nil, {
    {"Immolate", "Applies a Fire burn to the target."},
    {"Curse of Weakness", "Reduces the target's damage. Remove it if your group can."},
})
encounter(11519, nil, {
    {"Poison", "Deals Nature damage over time. Cleanse the tank when possible."},
    {"Sinister Strike", "A heavy melee hit. Clear the adds so the healer can focus on the tank."},
})

-- Forever encounter evidence exported from the local catalog.
local verified = {}

local function addVerified(dungeon, encounters)
    local byName = {}
    for _, encounter in ipairs(encounters) do
        byName[ns.DungeonNameKey(encounter.name)] = encounter
    end
    verified[ns.DungeonNameKey(dungeon)] = byName
end

function ns.GetDungeonEncounterVerifiedFacts(dungeon, boss, npcID)
    if not dungeon or not boss then return end
    local entries = verified[ns.DungeonNameKey(dungeon)]
    local entry = entries and entries[ns.DungeonNameKey(boss)]
    if entry and (not npcID or not entry.npcID or npcID == entry.npcID) then return entry end
end

addVerified("Alcaz Prison", {
    { name = "Blazeroar", npcID = 255702, mechanics = {
        { name = "Dragon transformation", description = "The prisoner Zarla Ober transforms into Blazeroar during the encounter.", source = "Mobalytics Forever Alcaz Prison encounter guide" },
        { name = "Fire damage resistance", description = "Fire attacks were reported ineffective. Use other damage schools if available.", source = "Mobalytics Forever Alcaz Prison encounter guide" },
    } },
    { name = "Katerina the Cleaner", npcID = 257016, mechanics = {
        { name = "Room fire", description = "Prepare for heavy group Fire damage. Leave the prisoners chained until the fight is over.", source = "Mobalytics Forever Alcaz Prison encounter guide" },
    } },
    { name = "Overseer Wrex", npcID = 255391, mechanics = {
        { name = "Room reinforcements", description = "Engaging Wrex draws in jailers and bounty hunters around him. Clear the area or pull him back so the group can control the adds.", source = "Mobalytics Forever Alcaz Prison encounter guide" },
    } },
    { name = "The Questioner", npcID = 256236, mechanics = {
        { name = "Drain Life", description = "Drains a player’s health and heals the Questioner. Interrupt the channel.", source = "Wowhead Forever Alcaz Prison encounter guide" },
        { name = "Rend", description = "Applies a bleed that continues dealing damage after the initial hit.", source = "Wowhead Forever Alcaz Prison encounter guide" },
    } },
    { name = "Tidemistress Ca'zass", npcID = 255997, mechanics = {
        { name = "Blizzard", description = "Move out of the targeted area while it is active.", source = "Mobalytics Forever Alcaz Prison encounter guide" },
        { name = "Naga Polymorph", description = "Her accompanying naga can polymorph party members. Interrupt those casts or kill the adds first.", source = "Mobalytics Forever Alcaz Prison encounter guide" },
    } },
})

addVerified("Blackfathom Deeps", {
    { name = "Aku'mai", npcID = 4829, mechanics = {
        { name = "Brazier waves", description = "After Kelris, activate one brazier at a time and defeat each wave to open the route to Aku'mai.", source = "Method Forever Blackfathom Deeps encounter guide" },
        { name = "Frenzied Rage", description = "The boss attacks faster when enraged. Be ready for heavier tank damage.", source = "Method Forever Blackfathom Deeps encounter guide" },
        { name = "Poison Cloud", description = "Leave the cloud to stop taking its Nature damage.", source = "Method Forever Blackfathom Deeps encounter guide" },
    } },
    { name = "Baron Aquanis", npcID = 12876, mechanics = {
        { name = "Fathom Stone", description = "A Horde player can summon this optional boss by looting the Fathom Stone. Clear the water nearby first.", source = "Undying Forever Blackfathom Deeps game-file and encounter guide" },
    } },
    { name = "Gelihast", npcID = 6243, mechanics = {
        { name = "Net", description = "Immobilizes the target. Pull nearby murlocs separately so the rooted player is easier to protect.", source = "Method Forever Blackfathom Deeps encounter guide" },
    } },
    { name = "Ghamoo-ra", npcID = 4887, mechanics = {
        { name = "High armor", description = "Physical attacks are less effective. Armor reduction helps melee and other physical damage dealers.", source = "Method Forever Blackfathom Deeps encounter guide" },
        { name = "Trample", description = "Damages players near Ghamoo-ra. Ranged players can stay back.", source = "Method Forever Blackfathom Deeps encounter guide" },
    } },
    { name = "Lady Sarevess", npcID = 4831, mechanics = {
        { name = "Forked Lightning", description = "Hits in front of her. Face her away from the rest of the party.", source = "Method Forever Blackfathom Deeps encounter guide" },
        { name = "Frost Nova", description = "Roots nearby players, after which Sarevess may move away and shoot. Free the tank if possible.", source = "Method Forever Blackfathom Deeps encounter guide" },
        { name = "Slow", description = "Applies a slow to a party member. Clear or control nearby naga before committing to her.", source = "Method Forever Blackfathom Deeps encounter guide" },
    } },
    { name = "Lorgus Jett", npcID = 12902, mechanics = {
        { name = "Lightning Bolt", description = "Interrupt the ranged Nature cast.", source = "Undying Forever Blackfathom Deeps game-file and encounter guide" },
        { name = "Lightning Shield", description = "Weapon attackers can take Nature damage while the shield is active. Remove the buff if possible.", source = "Undying Forever Blackfathom Deeps game-file and encounter guide" },
    } },
    { name = "Old Serra'kis", npcID = 4830, mechanics = {
        { name = "Underwater fight", description = "The fight takes place underwater. Start with a full breath bar or use water breathing.", source = "Method Forever Blackfathom Deeps encounter guide" },
    } },
    { name = "Twilight Lord Kelris", npcID = 4832, mechanics = {
        { name = "Mind Blast", description = "Kelris repeatedly hits his main target with Shadow damage. Save an interrupt for these casts.", source = "Method Forever Blackfathom Deeps encounter guide" },
        { name = "Sleep", description = "Can disable a party member, including the healer. Keep a second interrupt ready.", source = "Method Forever Blackfathom Deeps encounter guide" },
    } },
})

addVerified("Blackmaw Hold", {
    { name = "Bonesnout the Unbroken", npcID = 247198, mechanics = {
        { name = "Desecration", description = "Legashi Ritualists channel into Bonesnout. Control the casters before and during the pull.", source = "Undying live Forever Blackmaw Hold game files and encounter guide" },
        { name = "Profane Bulwark", description = "Active ritualists grant stacks that reduce damage to the boss. Stop the channels.", source = "Undying live Forever Blackmaw Hold game files and encounter guide" },
    } },
    { name = "Impaan the Imprisoner", npcID = 247206, mechanics = {
        { name = "Imp summons", description = "Pick up and kill the summoned imps as they appear.", source = "Undying live Forever Blackmaw Hold game files and encounter guide" },
        { name = "Impair", description = "Hits with Shadow damage and slows the target. Bring slow removal.", source = "Undying live Forever Blackmaw Hold game files and encounter guide" },
        { name = "Impalpable Shadowbolt", description = "Interrupt the stream of Shadow bolts when possible.", source = "Undying live Forever Blackmaw Hold game files and encounter guide" },
    } },
    { name = "Unbound Spirit", npcID = 247231, mechanics = {
        { name = "Profane Protection", description = "Profane Totems reduce the damage the spirit takes. Deal with the totems first.", source = "Undying live Forever Blackmaw Hold game files and encounter guide" },
        { name = "Purify", description = "Purify a Profane Totem before attacking it, then continue on the spirit.", source = "Undying live Forever Blackmaw Hold game files and encounter guide" },
    } },
    { name = "Varrox Bleakhoof", npcID = 247234, mechanics = {
        { name = "Crimson Wrest", description = "Draws players inward and temporarily hinders movement and actions. Spread when it ends.", source = "Undying live Forever Blackmaw Hold game files and encounter guide" },
        { name = "Nightmare Detonation", description = "Marked players explode and leave a Shadow pool. Separate and move out of pools.", source = "Undying live Forever Blackmaw Hold game files and encounter guide" },
    } },
    { name = "Withermaw", npcID = 247195, mechanics = {
        { name = "Lava pools", description = "Move the boss and party away from the pools.", source = "Undying live Forever Blackmaw Hold game files and encounter guide" },
        { name = "Writhing Mass", description = "Kill the summoned Flesh Maggots before their slime stacks on melee players.", source = "Undying live Forever Blackmaw Hold game files and encounter guide" },
    } },
})

addVerified("Blackrock Depths", {
    { name = "Ambassador Flamelash", npcID = 9156, mechanics = {
        { name = "Burning Spirit", description = "Spirits move toward Flamelash. Intercept them before they reach him.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Anub'shiah", npcID = 9031, mechanics = {
        { name = "Curse of Tongues", description = "Slows the target’s spellcasting.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Curse of Weakness", description = "Reduces the target’s physical damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Demon Armor", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Enveloping Web", description = "Restrains its target in a web.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Shadow Bolt", description = "Hurls a direct Shadow attack at a player.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Bael'Gar", npcID = 9016, mechanics = {
        { name = "Magma Splash", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Summon Spawn of Bael'Gar", description = "Summons reinforcements. Deals Fire damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Emperor Dagran Thaurissan", npcID = 9019, mechanics = {
        { name = "Avatar of Flame", description = "Temporarily grants magic immunity and adds Fire damage to melee strikes.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Hand of Thaurissan", description = "Deals Fire damage and stuns its target.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Ironfoe", description = "The Emperor can strike extra times with his hammer.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Eviscerator", npcID = 9029, mechanics = {
        { name = "Anti-Magic Shield", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Shadow Bolt Volley", description = "Deals Shadow damage to players in its area.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Vicious Rend", description = "Applies a bleed.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Fineous Darkvire", npcID = 9056, mechanics = {
        { name = "Devotion Aura", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Holy Light", description = "Restores health.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Holy Strike", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Kick", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Seal of Reckoning", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "General Angerforge", npcID = 9033, mechanics = {
        { name = "Sunder Armor", description = "Reduces the target’s armor.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Golem Lord Argelmach", npcID = 8983, mechanics = {
        { name = "Chain Lightning", description = "Lightning jumps between nearby targets.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Lightning Shield", description = "Can shock attackers who strike the shielded caster.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Shock", description = "Deals Nature damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Gorosh the Dervish", npcID = 9027, mechanics = {
        { name = "Bloodlust", description = "Increases the target’s attack speed.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Mortal Strike", description = "A heavy melee hit that reduces healing received.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Whirlwind", description = "Strikes nearby players in melee range.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Grizzle", npcID = 9028, mechanics = {
        { name = "Cleave", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Enrage", description = "Deals Physical damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Ground Tremor", description = "Disrupts players close to the boss.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Hedrum the Creeper", npcID = 9032, mechanics = {
        { name = "Baneful Poison", description = "Applies a poison to the target.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Paralyzing Poison", description = "Poison can incapacitate the affected player.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Web Explosion", description = "Throws webs around the caster.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "High Interrogator Gerstahn", npcID = 9018, mechanics = {
        { name = "Mana Burn", description = "Strips mana from a spellcaster. Interrupt the cast.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Psychic Scream", description = "Fears nearby players. Keep the pull clear of other packs.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Shadow Shield", description = "Absorbs incoming damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Shadow Word: Pain", description = "Applies periodic Shadow damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Houndmaster Grebmar", npcID = 9319, mechanics = {
        { name = "Bloodlust", description = "Increases the target’s attack speed.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Demoralizing Shout", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Pummel", description = "Deals damage. Interrupts the target’s cast.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Hurley Blackbreath", npcID = 9537, mechanics = {
        { name = "Drunken Rage", description = "Deals Physical damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Flame Breath", description = "A frontal Fire attack. Attack from the side or rear.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Lord Incendius", npcID = 9017, mechanics = {
        { name = "Curse of the Elemental Lord", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Fiery Burst", description = "Deals Fire damage to players in its area.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Fire Storm", description = "Deals periodic Fire damage to players in its area.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Mighty Blow", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Lord Roccor", npcID = 9025, mechanics = {
        { name = "Earth Shock", description = "Deals Nature damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Flame Shock", description = "Deals periodic Fire damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Ground Tremor", description = "Disrupts players close to the boss.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Magmus", npcID = 9938, mechanics = {
        { name = "Fiery Burst", description = "Deals Fire damage to players in its area.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "War Stomp", description = "Stuns nearby players.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Ok'thor the Breaker", npcID = 9030, mechanics = {
        { name = "Arcane Bolt", description = "Deals Arcane damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Arcane Explosion", description = "Bursts around the caster and hits nearby players.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Polymorph", description = "Temporarily transforms a player and prevents them from acting.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Slow", description = "Reduces the target’s speed.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Panzor the Invincible", npcID = 8923, mechanics = {
        { name = "Spell Reflection", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Phalanx", npcID = 9502, mechanics = {
        { name = "Fireball Volley", description = "Fires at multiple nearby targets.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Mighty Blow", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Thunderclap", description = "Deals Nature damage to players in its area.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Princess Moira Bronzebeard", npcID = 8929, mechanics = {
        { name = "Heal", description = "Restores an ally’s health. Interrupt the heal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Mind Blast", description = "Deals direct Shadow damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Power Word: Shield", description = "Places a damage-absorbing shield on an ally.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Renew", description = "Restores health over time.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Shadow Bolt", description = "Hurls a direct Shadow attack at a player.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Shadow Word: Pain", description = "Applies periodic Shadow damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Smite", description = "Deals direct Holy damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Pyromancer Loregrain", npcID = 9024, mechanics = {
        { name = "Fire Ward", description = "Absorbs Fire damage taken by the caster.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Flame Shock", description = "Deals periodic Fire damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Molten Blast", description = "Deals Fire damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Scorching Totem", description = "Summons reinforcements.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "The Seven", npcID = 9039, mechanics = {
        { name = "Anger'rel — Shield Block", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Anger'rel — Shield Wall", description = "Temporarily cuts the caster’s incoming damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Anger'rel — Sunder Armor", description = "Reduces the target’s armor.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Doom'rel — Banish", description = "Temporarily removes a susceptible target from the fight.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Doom'rel — Curse of Weakness", description = "Reduces the target’s physical damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Doom'rel — Demon Armor", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Doom'rel — Immolate", description = "Deals periodic Fire damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Doom'rel — Shadow Bolt Volley", description = "Deals Shadow damage to players in its area.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Doom'rel — Summon Voidwalkers", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Dope'rel — Backstab", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Dope'rel — Evasion", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Dope'rel — Gouge", description = "Deals damage. Stuns affected players.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Dope'rel — Rupture", description = "Deals periodic Physical damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Dope'rel — Sinister Strike", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Gloom'rel — Cleave", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Gloom'rel — Hamstring", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Gloom'rel — Mortal Strike", description = "A heavy melee hit that reduces healing received.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Gloom'rel — Recklessness", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Hate'rel — Mana Burn", description = "Strips mana from a spellcaster. Interrupt the cast.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Hate'rel — Shadow Bolt", description = "Hurls a direct Shadow attack at a player.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Hate'rel — Shadow Shield", description = "Absorbs incoming damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Seeth'rel — Cone of Cold", description = "Deals Frost damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Seeth'rel — Frost Armor", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Seeth'rel — Frost Nova", description = "Roots players near the caster.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Seeth'rel — Frost Ward", description = "Absorbs Frost damage taken by the caster.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Seeth'rel — Frostbolt", description = "Frost damage that slows its target.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Vile'rel — Heal", description = "Restores an ally’s health. Interrupt the heal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Vile'rel — Mind Blast", description = "Deals direct Shadow damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Vile'rel — Power Word: Shield", description = "Places a damage-absorbing shield on an ally.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Warder Stilgiss", npcID = 9041, mechanics = {
        { name = "Frost Armor", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Frost Nova", description = "Roots players near the caster.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Frost Ward", description = "Absorbs Frost damage taken by the caster.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Frostbolt", description = "Frost damage that slows its target.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
})

addVerified("City of Dalaran", {
    { name = "Arcane Anomaly", npcID = 245999, mechanics = {
        { name = "Arcane Bolt", description = "A heavy Arcane hit aimed at the tank.", source = "Method Forever City of Dalaran encounter guide" },
        { name = "Focal Blast", description = "A rotating Arcane beam can sweep in either direction. Stay clear of its path.", source = "Method Forever City of Dalaran encounter guide" },
    } },
    { name = "Arcanic Enigma", npcID = 246016, mechanics = {
        { name = "Manamorph", description = "Polymorphs a player. Dispel the effect if possible.", source = "Method Forever City of Dalaran encounter guide" },
        { name = "Silence", description = "Silences players near the boss. Casters should leave space.", source = "Method Forever City of Dalaran encounter guide" },
        { name = "Summon Manalings", description = "Brings in adds during the fight. Kill or control them before they build up.", source = "Method Forever City of Dalaran encounter guide" },
    } },
    { name = "Atrexis the Grave Knight", npcID = 247126, mechanics = {
        { name = "Disarm", description = "Disarms the tank. Keep incoming damage manageable by clearing nearby necromancers first.", source = "Method Forever City of Dalaran encounter guide" },
        { name = "Raise Dead", description = "Repeatedly brings in more enemies. Control the first waves and avoid being overwhelmed.", source = "Method Forever City of Dalaran encounter guide" },
        { name = "Thrash and Strike", description = "Atrexis can land several attacks close together. Keep the tank healthy.", source = "Method Forever City of Dalaran encounter guide" },
        { name = "Unholy Frenzy", description = "Buffs Atrexis and nearby allies. Expect more pressure while adds are active.", source = "Method Forever City of Dalaran encounter guide" },
    } },
    { name = "Fel Ancient", npcID = 246003, mechanics = {
        { name = "Barrier", description = "Talk to Grindle Firespark to make the boss reachable.", source = "Method Forever City of Dalaran encounter guide" },
        { name = "Entangle", description = "Roots and damages players. Free anyone caught in harmful ground.", source = "Method Forever City of Dalaran encounter guide" },
        { name = "Fel Timbers", description = "Leaves a damaging green pool. Move out immediately.", source = "Method Forever City of Dalaran encounter guide" },
    } },
    { name = "Lyn the Ignored", npcID = 247032, mechanics = {
        { name = "Curse of Thorns", description = "The cursed target takes damage for attacking. Remove the curse if possible.", source = "Method Forever City of Dalaran encounter guide" },
        { name = "Raise Dead", description = "Continually summons additional enemies. Keep them under control.", source = "Method Forever City of Dalaran encounter guide" },
        { name = "Shadow Bolt Volley", description = "Deals Shadow damage to the party. Heal through the group damage.", source = "Method Forever City of Dalaran encounter guide" },
        { name = "Tome of Dalaran", description = "Use the tome to summon this optional encounter.", source = "Method Forever City of Dalaran encounter guide" },
    } },
    { name = "Mana Devourer", npcID = 246008, mechanics = {
        { name = "Debilitate", description = "Damages the party and drains mana. Clear the room first so extra enemies do not prolong the fight.", source = "Method Forever City of Dalaran encounter guide" },
        { name = "Drain Vitality", description = "Deals Arcane damage over time to the main target.", source = "Method Forever City of Dalaran encounter guide" },
    } },
    { name = "Shade of the Archmage", npcID = 246020, mechanics = {
        { name = "Arcane Bolt", description = "A heavy Arcane hit aimed at the tank.", source = "Method Forever City of Dalaran encounter guide" },
        { name = "Arcane Explosion", description = "Damages players close to the Shade. Ranged players can stand back.", source = "Method Forever City of Dalaran encounter guide" },
        { name = "Bounding Mana", description = "Sends out an orb that returns to its starting point. Move the fight away from that path.", source = "Method Forever City of Dalaran encounter guide" },
        { name = "Mass Polymorph / Evocation", description = "At zero mana the Shade polymorphs the party and restores his mana before resuming the fight.", source = "Method Forever City of Dalaran encounter guide" },
    } },
    { name = "Unstable Sentinel", npcID = 246017, mechanics = {
        { name = "Arcing Smash", description = "Cleave hits players in front. Tank the sentinel facing away from the party.", source = "Method Forever City of Dalaran encounter guide" },
        { name = "Malfunction", description = "Pulses damage around the sentinel. Keep ranged players back and stun the boss before it starts if possible.", source = "Method Forever City of Dalaran encounter guide" },
    } },
})

addVerified("Dire Maul: East", {
    { name = "Alzzin the Wildshaper", npcID = 11492, mechanics = {
        { name = "Disarm", description = "Temporarily prevents the target from using its weapon.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Knock Away", description = "Deals melee damage and knocks its target away.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Mangle", description = "Applies periodic damage and slows the target.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Thorns", description = "Reflects Nature damage at attackers who hit the buffed target.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Vicious Bite", description = "A single-target bite that deals Physical damage.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Wild Regeneration", description = "Heals Alzzin over time. Interrupt or remove the effect if possible.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Hydrospawn", npcID = 13280, mechanics = {
        { name = "Hydrojet", description = "Knocks nearby players back and slows them.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Lethtendris", npcID = 14327, mechanics = {
        { name = "Curse of Thorns", description = "Curses a player so their attacks can cause damage back to them.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Curse of Tongues", description = "Slows the target's casting. Remove the curse from a key caster.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Immolate", description = "Deals Fire damage on application and continues burning the target.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Shadow Bolt Volley", description = "A volley of Shadow spells that damages nearby players.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Void Bolt", description = "A heavy single-target Shadow projectile.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Zevrim Thornhoof", npcID = 11490, mechanics = {
        { name = "Intense Pain", description = "Applies periodic Shadow damage to nearby players. A dispel can remove it.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Sacrifice", description = "Teleports one player to the altar and deals heavy damage. Focus healing on that player.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
})

addVerified("Dire Maul: North", {
    { name = "Captain Kromcrush", npcID = 14325, mechanics = {
        { name = "Intimidating Shout", description = "Fears nearby players while the primary target is held in terror.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Mortal Cleave", description = "Cleaves targets and makes subsequent healing less effective.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Retaliation", description = "Counterattacks players who strike him from the front in melee. Move behind him.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Cho'Rush the Observer", npcID = 14324, mechanics = {
        { name = "Heal", description = "Restores health to an ally. Interrupt the cast.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Mind Blast", description = "Deals Shadow damage to a single target. It can be interrupted.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Power Word: Shield", description = "Shields an ally from incoming damage.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Psychic Scream", description = "Fear scatters nearby players. Fight on cleared ground.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Guard Fengus", npcID = 14321, mechanics = {
        { name = "Enrage", description = "Raises the boss's melee pressure. The tank should plan for heavier hits.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Knock Away", description = "Deals melee damage and knocks its target away.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Shield Bash", description = "A shield strike that interrupts a spell. Keep casters out of melee reach.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Shield Charge", description = "Rushes a target and knocks it back.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Guard Mol'dar", npcID = 14326, mechanics = {
        { name = "Enrage", description = "Raises the boss's melee pressure. The tank should plan for heavier hits.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Knock Away", description = "Deals melee damage and knocks its target away.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Shield Bash", description = "A shield strike that interrupts a spell. Keep casters out of melee reach.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Shield Charge", description = "Rushes a target and knocks it back.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Guard Slip'kik", npcID = 14323, mechanics = {
        { name = "Enrage", description = "Raises the boss's melee pressure. The tank should plan for heavier hits.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Knock Away", description = "Deals melee damage and knocks its target away.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Shield Bash", description = "A shield strike that interrupts a spell. Keep casters out of melee reach.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Shield Charge", description = "Rushes a target and knocks it back.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "King Gordok", npcID = 11501, mechanics = {
        { name = "Berserker Charge", description = "Charges a player, dealing Physical damage and knocking them away.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Mortal Strike", description = "A heavy hit that temporarily reduces the healing the target receives.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Sunder Armor", description = "Applies a stacking reduction to the tank's armor.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "War Stomp", description = "Damages, knocks back, and stuns nearby players.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Stomper Kreeg", npcID = 14322, mechanics = {
        { name = "Enrage", description = "Raises the boss's melee pressure. The tank should plan for heavier hits.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "War Stomp", description = "Knocks back and stuns players nearby.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
})

addVerified("Dire Maul: West", {
    { name = "Illyanna Ravenoak", npcID = 11488, mechanics = {
        { name = "Aimed Shot", description = "A hard-hitting aimed ranged attack.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Concussive Shot", description = "Dazes its target and reduces movement speed.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Immolation Trap", description = "Leaves a trap that burns the first target to trigger it.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Volley", description = "Continually damages players in a targeted area. Move away from the spot.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Immol'thar", npcID = 11496, mechanics = {
        { name = "Enrage", description = "Raises the boss's melee pressure. The tank should plan for heavier hits.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Infected Bite", description = "Applies periodic Nature damage and makes the target take more Physical damage.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Trample", description = "Damages players within melee distance of the boss.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Lord Hel'nurath", npcID = 14506, mechanics = {
        { name = "Cripple", description = "Weakens the target and slows both movement and attacks.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Shadow Bolt Volley", description = "A Shadow volley that hits players near the caster.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Magister Kalendris", npcID = 11487, mechanics = {
        { name = "Dominate Mind", description = "Controls a player temporarily. Use crowd control to protect the group.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Mind Blast", description = "A single-target Shadow cast.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Mind Flay", description = "Channels Shadow damage and slows the target.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Shadow Word: Pain", description = "Applies a periodic Shadow damage effect.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Shadowform", description = "Increases Kalendris's Shadow damage and reduces the melee damage he takes.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Prince Tortheldrin", npcID = 11486, mechanics = {
        { name = "Arcane Blast", description = "An Arcane attack that knocks its target back.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Counterspell", description = "Interrupts the spell being cast and prevents it from being cast again briefly.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Tendris Warpwood", npcID = 11489, mechanics = {
        { name = "Entangle", description = "Roots a target and deals Nature damage over time.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Grasping Vines", description = "Vines knock nearby players down and root them.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Trample", description = "Damages players within melee distance of the boss.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Uppercut", description = "Knocks the target away with a melee blow.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Tsu'zee", npcID = 11467, mechanics = {
        { name = "Backstab", description = "A heavier melee strike from behind the target.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Blind", description = "Disorients the target. Taking damage ends the effect.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Gouge", description = "Briefly incapacitates a target facing the boss. Additional damage breaks it.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Sinister Strike", description = "An empowered melee strike.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
})

addVerified("Excavation Site: Wetlands", {
    { name = "Relic Guardian", npcID = 260326, mechanics = {
        { name = "Arcing Smash", description = "A frontal hit. Tank the guardian facing away from the group.", source = "Method Forever Excavation Site encounter guide" },
        { name = "Knockaway", description = "Throws its main target away and reduces their threat. Give the tank time to regain control.", source = "Method Forever Excavation Site encounter guide" },
        { name = "Thunderclap", description = "Slows the attacks of nearby players.", source = "Method Forever Excavation Site encounter guide" },
        { name = "Titan Control Panel", description = "Use the nearby panel to activate the guardian.", source = "Method Forever Excavation Site encounter guide" },
        { name = "War Stomp", description = "Knocks back and stuns players near the guardian. Ranged players can stay outside it.", source = "Method Forever Excavation Site encounter guide" },
    } },
    { name = "Saltspine", npcID = 260322, mechanics = {
        { name = "Dust Storm", description = "Interferes with the tank's ability to hold threat. Watch your threat and give the tank time to recover.", source = "Method Forever Excavation Site encounter guide" },
        { name = "Fatal Bite", description = "A dangerous bite aimed at Saltspine's main target.", source = "Method Forever Excavation Site encounter guide" },
        { name = "Tendon Rip", description = "Slows its target. Fight where a slowed tank will not pull another pack.", source = "Method Forever Excavation Site encounter guide" },
    } },
    { name = "Shadetooth", npcID = 260325, mechanics = {
        { name = "Enrage", description = "Shadetooth attacks faster and hits harder near the end. Save defensive tools for this phase.", source = "Method Forever Excavation Site encounter guide" },
        { name = "Rend", description = "Continues dealing damage to the tank after the hit.", source = "Method Forever Excavation Site encounter guide" },
        { name = "Terrifying Roar", description = "Fears players and can send them into hidden raptors. Clear the grass near the fight or prepare fear protection.", source = "Method Forever Excavation Site encounter guide" },
    } },
})

addVerified("Gnomeregan", {
    { name = "Crowd Pummeler 9-60", npcID = 6229, mechanics = {
        { name = "Arcing Smash", description = "A frontal strike. Keep the pummeler facing away from the party.", source = "Method Forever Gnomeregan encounter guide" },
        { name = "Crowd Pummel", description = "Throws nearby players back. Fight against a wall and keep away from ledges.", source = "Method Forever Gnomeregan encounter guide" },
        { name = "Trample", description = "Damages players near the boss. Ranged players can stand farther back.", source = "Method Forever Gnomeregan encounter guide" },
    } },
    { name = "Dark Iron Ambassador", npcID = 6228, mechanics = {
        { name = "Fire Shield II", description = "Hurts players who strike the shield with physical attacks.", source = "Method Forever Gnomeregan encounter guide" },
        { name = "Fireball", description = "A Fire cast aimed at the main target.", source = "Method Forever Gnomeregan encounter guide" },
        { name = "Summon Burning Servant", description = "Brings in a minion. Interrupt the summon if possible.", source = "Method Forever Gnomeregan encounter guide" },
    } },
    { name = "Electrocutioner 6000", npcID = 6235, mechanics = {
        { name = "Chain Bolt", description = "The bolt jumps between players. Spread where space allows.", source = "Method Forever Gnomeregan encounter guide" },
        { name = "Megavolt", description = "Damages players in front. Turn it away from the party.", source = "Method Forever Gnomeregan encounter guide" },
        { name = "Shock", description = "A heavy instant hit aimed at the tank.", source = "Method Forever Gnomeregan encounter guide" },
    } },
    { name = "Grubbis", npcID = 7361, mechanics = {
        { name = "Chomper", description = "Grubbis brings this crocolisk. Control the extra enemy and kill one target at a time.", source = "Method Forever Gnomeregan encounter guide" },
        { name = "Trogg waves", description = "Help Blastmaster Emi Shortfuse seal the two caves while fighting trogg waves. Grubbis appears near the end of the event.", source = "Method Forever Gnomeregan encounter guide" },
    } },
    { name = "Mekgineer Thermaplugg", npcID = 7800, mechanics = {
        { name = "Knock Away", description = "Reduces threat when players are knocked back. The tank should be ready to pick the boss back up.", source = "Method Forever Gnomeregan encounter guide" },
        { name = "Walking Bombs", description = "Bombs emerge from the pillars. Use the pillar buttons to shut off their source.", source = "Method Forever Gnomeregan encounter guide" },
    } },
    { name = "Viscous Fallout", npcID = 7079, mechanics = {
        { name = "Nature melee damage", description = "Its heavy melee hits deal Nature damage. Keep healing the tank and use stuns to make openings.", source = "Method Forever Gnomeregan encounter guide" },
    } },
})

addVerified("Hall of Thanes", {
    { name = "Durgen Dirgehammer", npcID = 261319, mechanics = {
        { name = "Intimidating Shout", description = "Fears nearby party members. Clear the surrounding room so feared players do not run into another pack.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Lesser Stone Golems", description = "Two golems pull with Durgen. Control them and kill them before focusing on the boss.", source = "Wowhead Forever Hall of Thanes encounter guide" },
        { name = "Rend", description = "Deals periodic Physical damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Faldrim Anvilmar", npcID = 261306, mechanics = {
        { name = "Anvilmar's Curse", description = "Turns a player's skin to stone and reduces attack speed. Remove the curse if your group can.", source = "Method Forever Hall of Thanes encounter guide" },
        { name = "Mind Blast", description = "Deals Shadow damage. Use an interrupt when available.", source = "Method Forever Hall of Thanes encounter guide" },
    } },
    { name = "Magmatus", npcID = 261316, mechanics = {
        { name = "Combust", description = "Magmatus triggers a burst of Fire damage. Move away from the affected area.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Fire Nova", description = "Deals Fire damage to players in its area.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Fire pulse", description = "Damages players close to Magmatus. Tank the elemental away from the group and kill its Dark Iron Summoner.", source = "Wowhead Forever Hall of Thanes encounter guide" },
    } },
    { name = "Plunder", npcID = 261311, mechanics = {
        { name = "Knock Away", description = "Pushes the affected player back.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Knockback", description = "Throws nearby players away. Pull the golem to a cleared tunnel or position against a wall so the knockback cannot reach more packs.", source = "Wowhead Forever Hall of Thanes encounter guide" },
    } },
})

addVerified("Krol'dok Stronghold", {
    { name = "Bossman Toof", npcID = 264773, mechanics = {
        { name = "Bridge waves", description = "Engaging the centurions begins recurring brute waves. Fight across the bridge and kill the shamans near Toof before they buff him.", source = "Method Forever Krol'dok Stronghold encounter guide" },
        { name = "Demoralizing Shout", description = "Reduces the attack power of nearby players.", source = "Method Forever Krol'dok Stronghold encounter guide" },
        { name = "Mortal Strike", description = "Reduces healing on the target after striking.", source = "Method Forever Krol'dok Stronghold encounter guide" },
        { name = "Thunderclap", description = "Slows attacks and movement around Toof.", source = "Method Forever Krol'dok Stronghold encounter guide" },
    } },
    { name = "Nar'gurk", npcID = 258964, mechanics = {
        { name = "Convert", description = "Mind controls a player until their health drops. Damage carefully to free the player without killing them.", source = "Method Forever Krol'dok Stronghold encounter guide" },
        { name = "Shadow Bolt Volley", description = "Deals Shadow damage to the party. Control surrounding enemies before the pull.", source = "Method Forever Krol'dok Stronghold encounter guide" },
    } },
    { name = "Overlord Mugg", npcID = 258968, mechanics = {
        { name = "Crushing Slam", description = "Mugg jumps to a ranged target, damages nearby players, and knocks them back. Spread to limit the impact.", source = "Method Forever Krol'dok Stronghold encounter guide" },
        { name = "Mugg's Fury", description = "Mugg changes from maces to heavier mauls. Clear the centurions early so the tank can handle the extra pressure.", source = "Method Forever Krol'dok Stronghold encounter guide" },
    } },
    { name = "Slavecrusher Grox", npcID = 258966, mechanics = {
        { name = "Bloodlust", description = "Speeds up Grox and nearby enemies.", source = "Method Forever Krol'dok Stronghold encounter guide" },
        { name = "Force Compliance", description = "Calls Redridge Prisoners into the fight. Clear space first and deal with any called prisoners.", source = "Method Forever Krol'dok Stronghold encounter guide" },
        { name = "Knockdown", description = "Stuns the tank. Heal before and during the stun.", source = "Method Forever Krol'dok Stronghold encounter guide" },
    } },
    { name = "Twilight Commander Zarmok", npcID = 258972, mechanics = {
        { name = "Enrage", description = "Makes attacks more dangerous at low health. Save defensives for the end.", source = "Method Forever Krol'dok Stronghold encounter guide" },
        { name = "Rending Whirl", description = "Damages melee players close to Zarmok. Stay back when possible.", source = "Method Forever Krol'dok Stronghold encounter guide" },
        { name = "Strike", description = "A heavy hit on the main target.", source = "Method Forever Krol'dok Stronghold encounter guide" },
    } },
    { name = "War Handler Ashka", npcID = 259281, mechanics = {
        { name = "Command: Kill!", description = "Snarlfang and Terrorhowl fixate on a party member. Stun or kill the pets to take pressure off that player.", source = "Method Forever Krol'dok Stronghold encounter guide" },
        { name = "Strike", description = "Deals damage to Ashka's main target.", source = "Method Forever Krol'dok Stronghold encounter guide" },
    } },
})

addVerified("Lower Blackrock Spire", {
    { name = "Gizrul the Slavener", npcID = 10268, mechanics = {
        { name = "Enrage", description = "Deals Physical damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Fatal Bite", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Infected Bite", description = "Deals periodic Nature damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Halycon", npcID = 10220, mechanics = {
        { name = "Rend", description = "Deals periodic Physical damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Thrash", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Highlord Omokk", npcID = 9196, mechanics = {
        { name = "Cleave", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Enrage", description = "Deals Physical damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Knock Away", description = "Pushes the affected player back.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Mother Smolderweb", npcID = 10596, mechanics = {
        { name = "Crystallize", description = "Stuns affected players.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Mother's Milk", description = "Restricts movement.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Summon Spire Spiderling", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Overlord Wyrmthalak", npcID = 9568, mechanics = {
        { name = "Cleave", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Demoralizing Shout", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Sweeping Slam", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Quartermaster Zigris", npcID = 9736, mechanics = {
        { name = "Drink Healing Potion", description = "Restores health.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Hooked Net", description = "Deals Physical damage to players in its area. Restricts movement.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Stun Bomb", description = "Deals damage to players in its area. Stuns affected players.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Shadow Hunter Vosh'gajin", npcID = 9236, mechanics = {
        { name = "Curse of Blood", description = "Deals Physical damage to players in its area.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Hex", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Urok Doomhowl", npcID = 10584, mechanics = {
        { name = "Intimidating Roar", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Rend", description = "Deals periodic Physical damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Strike", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "War Master Voone", npcID = 9237, mechanics = {
        { name = "Cleave", description = "Strikes an additional nearby enemy. Keep melee away from his front.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Mortal Strike", description = "A heavy melee hit that reduces healing received.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Pummel", description = "Deals damage. Interrupts the target’s cast.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Snap Kick", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Thrash", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Throw Axe", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Uppercut", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
})

addVerified("Maraudon", {
    { name = "Celebras the Cursed", npcID = 12225, mechanics = {
        { name = "Entangling Roots", description = "Spell 12747 was recorded directly from this boss as the combat-log source.", source = "WoWSims Forever #76 advanced combat log excerpt" },
    } },
    { name = "Landslide", npcID = 12203, mechanics = {
        { name = "Knock Away", description = "Knocks the target back. Tank near a wall to stay close.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Summon Shardlings", description = "Summons stone adds while stunning nearby players. The tank should collect the shardlings.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Trample", description = "Damages players within melee distance of the boss.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Lord Vyletongue", npcID = 12236, mechanics = {
        { name = "Blink", description = "Teleports the boss away and breaks immobilization. Move back into range.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Multi-Shot", description = "A ranged volley that hits several nearby targets.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Smoke Bomb", description = "Stuns nearby players with a smoke bomb.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Meshlok the Harvester", npcID = 12237, mechanics = {
        { name = "Earth Shock", description = "Deals Nature damage and interrupts spellcasting.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Strike", description = "An empowered melee hit.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "War Stomp", description = "Damages, knocks back, and stuns nearby players. Ranged can stay clear.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Noxxion", npcID = 13282, mechanics = {
        { name = "Toxic Volley", description = "Spell 21687 was recorded directly from this boss as the combat-log source.", source = "WoWSims Forever #76 advanced combat log excerpt" },
    } },
    { name = "Princess Theradras", npcID = 12201, mechanics = {
        { name = "Boulder", description = "Throws a boulder at a player at range.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Dust Field", description = "Deals damage and pushes nearby players away. Ranged players can stay out of reach.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Repulsive Gaze", description = "Fears nearby players. Fear Ward or Tremor Totem can help the group recover.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Razorlash", npcID = 12258, mechanics = {
        { name = "Cleave", description = "Hits the main target and nearby players. Stand away from the tank if you can.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Puncture", description = "Leaves a Physical damage-over-time effect on the target.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Rotgrip", npcID = 13596, mechanics = {
        { name = "Fatal Bite", description = "Drains health from the target and restores health to Rotgrip.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Puncture", description = "Leaves a Physical damage-over-time effect on the target.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Tinkerer Gizlock", npcID = 13601, mechanics = {
        { name = "Bomb", description = "Throws an explosive that damages players near the impact.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Goblin Dragon Gun", description = "Projects fire in a cone. Tank him facing away from the group.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Shoot", description = "Shoots a target for Physical damage.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
})

addVerified("Ragefire Chasm", {
    { name = "Bazzalan", npcID = 11519, mechanics = {
        { name = "Poison", description = "Deals Nature damage over time. Cleanse the tank when possible.", source = "Undying Forever encounter guide" },
        { name = "Sinister Strike", description = "A heavy melee hit. Clear the adds so the healer can focus on the tank.", source = "Undying Forever encounter guide" },
    } },
    { name = "Jergosh the Invoker", npcID = 11518, mechanics = {
        { name = "Curse of Weakness", description = "Reduces the target's damage. Remove it if your group can.", source = "Undying Forever encounter guide" },
        { name = "Immolate", description = "Applies a Fire burn to the target.", source = "Undying Forever encounter guide" },
    } },
    { name = "Oggleflint", npcID = 11517, mechanics = {
        { name = "Cleave", description = "Point Oggleflint away from the group and clear his nearby adds.", source = "Undying Forever encounter guide" },
    } },
    { name = "Taragaman the Hungerer", npcID = 11520, mechanics = {
        { name = "Fire Nova", description = "Damages players near Taragaman. Ranged players should stand back.", source = "Undying Forever encounter guide" },
        { name = "Uppercut", description = "Knocks the target back. Tank away from the edge of the lava.", source = "Undying Forever encounter guide" },
    } },
})

addVerified("Razorfen Downs", {
    { name = "Amnennar the Coldbringer", npcID = 7358, mechanics = {
        { name = "Frost Nova", description = "Spell 15531 was recorded directly from this boss as the combat-log source.", source = "WoWSims Forever #76 advanced combat log excerpt" },
        { name = "Frostbolt", description = "Spell 15530 was recorded directly from this boss as the combat-log source.", source = "WoWSims Forever #76 advanced combat log excerpt" },
        { name = "Summoned adds", description = "Additional enemies join as the encounter progresses. Have the tank collect them and decide as a party whether to kill them or focus on Amnennar.", source = "Mobalytics Forever Razorfen Downs encounter guide" },
    } },
    { name = "Glutton", npcID = 8567, mechanics = {
        { name = "Disease Cloud", description = "Stay away from the cloud when not tanking. Glutton's heavy melee hits require steady healing.", source = "Mobalytics Forever Razorfen Downs encounter guide" },
    } },
    { name = "Mordresh Fire Eye", npcID = 7357, mechanics = {
        { name = "Accompanying undead", description = "Mordresh can pull with the surrounding enemies. Control some of the adds and let the tank gather the rest before committing.", source = "Mobalytics Forever Razorfen Downs encounter guide" },
        { name = "Fire Nova", description = "Spell 12470 was recorded directly from this boss as the combat-log source.", source = "WoWSims Forever #76 advanced combat log excerpt" },
        { name = "Fireball", description = "Spell 12466 was recorded directly from this boss as the combat-log source.", source = "WoWSims Forever #76 advanced combat log excerpt" },
    } },
    { name = "Plaguemaw the Rotting", npcID = 7356, mechanics = {
        { name = "Putrid Stench", description = "Remove the debuff if the group has a dispel that works on it.", source = "Mobalytics Forever Razorfen Downs encounter guide" },
    } },
    { name = "Ragglesnout", npcID = 7354, mechanics = {
        { name = "Dominate Mind", description = "Can take control of a party member. Have crowd control ready.", source = "Mobalytics Forever Razorfen Downs encounter guide" },
        { name = "Healing casts", description = "Interrupt his healing to shorten the encounter.", source = "Mobalytics Forever Razorfen Downs encounter guide" },
        { name = "Shadow Word: Pain", description = "Spell 11639 was recorded directly from this boss as the combat-log source.", source = "WoWSims Forever #76 advanced combat log excerpt" },
    } },
    { name = "Tuten'kash", npcID = 7355, mechanics = {
        { name = "Spider waves", description = "Initiate the event then clear the spiders as they appear. Set the tank up before calling each wave.", source = "Mobalytics Forever Razorfen Downs encounter guide" },
        { name = "Virulent Poison", description = "Spell 12251 was recorded directly from this boss as the combat-log source.", source = "WoWSims Forever #76 advanced combat log excerpt" },
    } },
})

addVerified("Razorfen Kraul", {
    { name = "Agathelos the Raging", npcID = 4422, mechanics = {
        { name = "Enrage", description = "Increases pressure on the tank at low health. Be ready with healing and defensives.", source = "Method Forever Razorfen Kraul encounter guide" },
        { name = "Rushing Charge", description = "Charges the first player he sees. Let the tank make the pull.", source = "Method Forever Razorfen Kraul encounter guide" },
    } },
    { name = "Aggem Thorncurse", npcID = 4424, mechanics = {
        { name = "Chain Heal", description = "Heals Aggem or other enemies. Interrupt it when possible.", source = "Method Forever Razorfen Kraul encounter guide" },
        { name = "Summon Boar Spirit", description = "The tank should take control of the summoned boar.", source = "Method Forever Razorfen Kraul encounter guide" },
    } },
    { name = "Blind Hunter", npcID = 4425, mechanics = {
        { name = "Ravage", description = "Damages and stuns its main target.", source = "Method Forever Razorfen Kraul encounter guide" },
        { name = "Sonic Burst", description = "Silences nearby players. Keep casters back.", source = "Method Forever Razorfen Kraul encounter guide" },
    } },
    { name = "Charlga Razorflank", npcID = 4421, mechanics = {
        { name = "Chain Bolt", description = "Jumps through nearby players. Spread where space allows.", source = "Method Forever Razorfen Kraul encounter guide" },
        { name = "Purity", description = "Briefly prevents damage while she can still cast.", source = "Method Forever Razorfen Kraul encounter guide" },
        { name = "Renew", description = "Heals Charlga over time. Remove it if possible.", source = "Method Forever Razorfen Kraul encounter guide" },
    } },
    { name = "Death Speaker Jargba", npcID = 4428, mechanics = {
        { name = "Dominate Mind", description = "Takes control of a player. Use crowd control on the affected ally and avoid catching them in group damage.", source = "Method Forever Razorfen Kraul encounter guide" },
        { name = "Shadow Bolt", description = "Direct Shadow damage to the main target.", source = "Method Forever Razorfen Kraul encounter guide" },
    } },
    { name = "Earthcaller Halmgar", npcID = 4842, mechanics = {
        { name = "Earthbind Totem", description = "Slows players near the totem.", source = "Method Forever Razorfen Kraul encounter guide" },
        { name = "Lightning Bolt", description = "Ranged Nature damage aimed at the main target.", source = "Method Forever Razorfen Kraul encounter guide" },
        { name = "Summon Earth Rumbler", description = "Brings in an elemental. Let the tank collect it while the party is slowed.", source = "Method Forever Razorfen Kraul encounter guide" },
    } },
    { name = "Overlord Ramtusk", npcID = 4420, mechanics = {
        { name = "Thunderclap", description = "Damages and slows nearby players. Control the accompanying Spearhides if possible.", source = "Method Forever Razorfen Kraul encounter guide" },
    } },
    { name = "Roogug", npcID = 6168, mechanics = {
        { name = "Lightning Bolt", description = "A ranged Nature attack.", source = "Method Forever Razorfen Kraul encounter guide" },
        { name = "Summon Earth Rumbler", description = "Brings an elemental into the fight. Control or kill it before turning back to Roogug.", source = "Method Forever Razorfen Kraul encounter guide" },
    } },
})

addVerified("Ruins of Lordaeron", {
    { name = "Bjork", npcID = 256097, mechanics = {
        { name = "Anti-Magic Shield", description = "Briefly protects Bjork against magic. Use the pause to reposition or switch targets as needed.", source = "Method Forever Ruins of Lordaeron encounter guide" },
    } },
    { name = "Rath'mael", npcID = 250657, mechanics = {
        { name = "Fire Shield", description = "Spell 13376 was recorded directly from this boss as the combat-log source.", source = "WoWSims Forever #76 advanced combat log excerpt" },
        { name = "Flamestrike", description = "Leave the burning area as soon as it appears. A stun can stop the cast.", source = "Method Forever Ruins of Lordaeron encounter guide" },
    } },
    { name = "The Abandoned", npcID = 250631, mechanics = {
        { name = "Chilled", description = "Melee hits against the boss can chill the attacker.", source = "Method Forever Ruins of Lordaeron encounter guide" },
        { name = "Frost Nova", description = "Roots nearby players. Ranged players can keep clear.", source = "Method Forever Ruins of Lordaeron encounter guide" },
        { name = "Life Drain", description = "Targets the tank. A timely stun can interrupt the cast.", source = "Method Forever Ruins of Lordaeron encounter guide" },
        { name = "Market Square waves", description = "Moving into the square triggers waves from the statue. The Abandoned appears once the earlier waves are defeated.", source = "Method Forever Ruins of Lordaeron encounter guide" },
    } },
    { name = "The Baron", npcID = 250660, mechanics = {
        { name = "Knockout", description = "A heavy hit followed by a stun. Top up the tank before the hit lands.", source = "Method Forever Ruins of Lordaeron encounter guide" },
    } },
    { name = "Viktor the Vile", npcID = 256035, mechanics = {
        { name = "Chimney event", description = "Interact with the chimney southwest of Lordamere Overlook. Fight through the incoming waves until Viktor appears.", source = "Method Forever Ruins of Lordaeron encounter guide" },
        { name = "Leech Poison", description = "Drains the poisoned player's health. Cleanse the tank when possible.", source = "Method Forever Ruins of Lordaeron encounter guide" },
    } },
    { name = "Witherfang", npcID = 250483, mechanics = {
        { name = "Leech Poison", description = "Drains the poisoned player's health. Cleanse it and avoid pulling nearby spider packs.", source = "Method Forever Ruins of Lordaeron encounter guide" },
    } },
})

addVerified("Scarlet Monastery: Armory", {
    { name = "Herod", npcID = 3975, mechanics = {
        { name = "Rushing Charge", description = "Charges a player for a heavy hit.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
        { name = "Scarlet Trainees", description = "A group of trainees rushes the room after Herod dies. Give the tank a moment to gather them.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
        { name = "Whirlwind", description = "Deals heavy damage close to Herod. Step back until he stops spinning.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
    } },
})

addVerified("Scarlet Monastery: Cathedral", {
    { name = "High Inquisitor Fairbanks", npcID = 4542, mechanics = {
        { name = "Dispel Magic", description = "Can strip positive effects from the tank.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
        { name = "Heal", description = "Fairbanks tries to restore his health when low. Save an interrupt.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
        { name = "Sleep and Fear", description = "Disables players or sends them running. Clear the nearby area first.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
    } },
    { name = "High Inquisitor Whitemane", npcID = 3977, mechanics = {
        { name = "Deep Sleep", description = "Near half health Whitemane puts nearby players to sleep.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
        { name = "Holy Smite", description = "Deals Holy damage. Interrupt when possible.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
        { name = "Scarlet Resurrection", description = "Whitemane raises Mograine. The tank needs to pick him up again.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
    } },
    { name = "Scarlet Commander Mograine", npcID = 3976, mechanics = {
        { name = "Divine Shield", description = "Mograine temporarily protects himself from damage.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
        { name = "Hammer of Justice", description = "Stuns a player.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
        { name = "Lay on Hands", description = "Can restore Mograine's health. Be ready for the encounter to last longer.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
    } },
})

addVerified("Scarlet Monastery: Graveyard", {
    { name = "Azshir the Sleepless", npcID = 6490, mechanics = {
        { name = "Call of the Grave", description = "Deals Shadow damage when the effect expires. Heal players carrying it.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
        { name = "Soul Siphon", description = "Drains health from players. Interrupt the cast if possible.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
    } },
    { name = "Bloodmage Thalnos", npcID = 4543, mechanics = {
        { name = "Flame Shock", description = "Deals Fire damage on impact and continues to burn the target.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
        { name = "Flame Spike", description = "Creates a pillar of fire at the targeted location. Move out of it.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
        { name = "Shadow Bolt", description = "Deals Shadow damage to one player.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
    } },
    { name = "Fallen Champion", npcID = 6488, mechanics = {
        { name = "Cleave", description = "Can hit players in front of the boss. Stand behind him unless tanking.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
    } },
    { name = "Interrogator Vishas", npcID = 3983, mechanics = {
        { name = "Shadow Word: Pain", description = "Applies ongoing Shadow damage. Clear the other crusaders before engaging Vishas.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
    } },
    { name = "Ironspine", npcID = 6489, mechanics = {
        { name = "Curse of Weakness", description = "Weakens the target's damage. Remove the curse if possible.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
        { name = "Poison Cloud", description = "Damages players inside the cloud. Move Ironspine out so melee can follow safely.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
    } },
})

addVerified("Scarlet Monastery: Library", {
    { name = "Arcanist Doan", npcID = 6487, mechanics = {
        { name = "Arcane Bubble and Detonation", description = "Doan shields himself before a large explosion. Move away as soon as the shield appears.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
        { name = "Arcane Explosion", description = "Spell 9433 was recorded directly from this boss as the combat-log source.", source = "WoWSims Forever #76 advanced combat log excerpt" },
        { name = "Detonation", description = "Spell 9435 was recorded directly from this boss as the combat-log source.", source = "WoWSims Forever #76 advanced combat log excerpt" },
        { name = "Polymorph", description = "Temporarily disables a party member.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
        { name = "Silence", description = "Silences nearby players. Casters should keep their distance.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
    } },
    { name = "Houndmaster Loksey", npcID = 3974, mechanics = {
        { name = "Bloodlust", description = "Speeds up Loksey and his tracking hounds. Remove the buff if possible and kill the hounds first.", source = "WoW Forever Info Scarlet Monastery encounter guide" },
    } },
})

addVerified("Scholomance", {
    { name = "Darkmaster Gandling", npcID = 1853, mechanics = {
        { name = "Arcane Missiles", description = "Fires Arcane missiles at a target.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Curse of the Darkmaster", description = "Lowers the affected player's Strength and Stamina.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Shadow Portal", description = "Sends a player to another room; clear the enemies there to return.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Shadow Shield", description = "Absorbs damage and strikes back against melee attackers.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Doctor Theolen Krastinov", npcID = 11261, mechanics = {
        { name = "Enrage", description = "Enrages the boss, increasing melee pressure.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Knock Away", description = "Knocks back players close to the caster.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Rend", description = "Inflicts a bleed that continues after the hit.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Instructor Malicia", npcID = 10505, mechanics = {
        { name = "Call of the Grave", description = "Applies a delayed burst of Shadow damage.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Corruption", description = "Applies ongoing Shadow damage.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Heal", description = "Restores an ally's health. Interrupt the cast.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Renew", description = "Applies a heal over time.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Slow", description = "Slows nearby targets' movement and attacks.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Jandice Barov", npcID = 10503, mechanics = {
        { name = "Banish", description = "Temporarily removes a target from the fight and makes it immune to damage.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Curse of Blood", description = "Increases the Physical damage affected players take.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Summon Illusions", description = "Creates hostile copies of Jandice; be ready to control or clear them.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Kirtonos the Herald", npcID = 10506, mechanics = {
        { name = "Curse of Tongues", description = "Slows spellcasting. Remove from priority casters if possible.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Disarm", description = "Temporarily takes away the target's weapon.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Dominate Mind", description = "Mind-controls a player; use crowd control until it expires.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Pierce Armor", description = "Lowers the target's armor; watch for heavier melee hits.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Shadow Bolt Volley", description = "Deals Shadow damage to players around the boss.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Swoop", description = "Stuns and damages players in front of Kirtonos.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Wing Flap", description = "Knocks back players in front; tank facing away from the group.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Lady Illucia Barov", npcID = 10502, mechanics = {
        { name = "Curse of Agony", description = "Applies a Shadow-damage curse that ticks over time.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Dominate Mind", description = "Mind-controls a player; use crowd control until it expires.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Fear", description = "Forces a target to flee temporarily.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Shadow Shock", description = "Deals an instant burst of Shadow damage to its target.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Silence", description = "Prevents nearby players from casting spells.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Lord Alexei Barov", npcID = 10504, mechanics = {
        { name = "Immolate", description = "Deals Fire damage followed by a burn.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Unholy Aura", description = "Deals recurring Shadow damage to nearby players.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Veil of Shadow", description = "Reduces incoming healing. Remove the curse or plan defensive cooldowns.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Lorekeeper Polkelt", npcID = 10901, mechanics = {
        { name = "Corrosive Acid", description = "Lowers armor on nearby targets.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Noxious Catalyst", description = "Reduces the target's Nature resistance.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Volatile Infection", description = "An infected player damages nearby allies; spread or remove the effect.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Marduk Blackpool", npcID = 10433, mechanics = {
        { name = "Cleave", description = "Hits the target and a nearby player.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Defiling Aura", description = "Reduces nearby players' Shadow resistance over the course of the fight.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Shadow Shield", description = "Absorbs damage and strikes back against melee attackers.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Ras Frostwhisper", npcID = 10508, mechanics = {
        { name = "Chill Nova", description = "Deals Frost damage around the boss, knocking players back and slowing them.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Fear", description = "Forces a player to run in fear. Interrupt if possible.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Freeze", description = "Stuns the target and deals repeated Frost damage.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Frost Armor", description = "Raises the boss's armor and slows melee attackers.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Frostbolt Volley", description = "Hits nearby players with Frost damage and slows movement.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Knock Away", description = "Knocks back players close to the caster.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Rattlegore", npcID = 11622, mechanics = {
        { name = "Knock Away", description = "Hits and knocks back the target.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Strike", description = "Deals increased melee damage to the target.", source = "Wowhead Forever Dungeon Journal" },
        { name = "War Stomp", description = "Stuns and knocks back nearby players.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "The Ravenian", npcID = 10507, mechanics = {
        { name = "Cleave", description = "Hits the target and a nearby player.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Knock Away", description = "Knocks back players close to the caster.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Sundering Cleave", description = "Strikes multiple players and applies stacking armor reduction.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Trample", description = "Deals Physical damage to players close to the boss.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Vectus", npcID = 10432, mechanics = {
        { name = "Blast Wave", description = "Hits and slows players close to the boss.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Flamestrike", description = "Leaves damaging fire on the ground; move out.", source = "Wowhead Forever Dungeon Journal" },
    } },
})

addVerified("Shadowfang Keep", {
    { name = "Archmage Arugal", npcID = 4275, mechanics = {
        { name = "Arugal's Curse", description = "Temporarily charms a party member. Control the ally until the curse ends.", source = "Undying Forever encounter guide" },
        { name = "Shadow Port", description = "Teleports around the room. Reposition so the tank and healer can still see each other.", source = "Undying Forever encounter guide" },
        { name = "Thundershock", description = "Hits and stuns nearby players. Ranged players should keep their distance.", source = "Undying Forever encounter guide" },
        { name = "Void Bolt", description = "Heavy Shadow damage. Use a wall or pillar to break line of sight.", source = "Undying Forever encounter guide" },
    } },
    { name = "Baron Silverlaine", npcID = 3887, mechanics = {
        { name = "Veil of Shadow", description = "Reduces healing received. Remove the curse from the tank if you can.", source = "Undying Forever encounter guide" },
    } },
    { name = "Commander Springvale", npcID = 4278, mechanics = {
        { name = "Divine Shield", description = "Grants temporary immunity. Use the break to deal with nearby adds.", source = "Undying Forever encounter guide" },
        { name = "Hammer of Justice", description = "Stuns the target.", source = "Undying Forever encounter guide" },
        { name = "Holy Light", description = "Save an interrupt for the heal.", source = "Undying Forever encounter guide" },
    } },
    { name = "Deathsworn Captain", npcID = 3872, mechanics = {
        { name = "Cleave and Hamstring", description = "This rare spawn can hit adjacent players and slow movement. Stand behind him when possible.", source = "Undying Forever encounter guide" },
    } },
    { name = "Fel Steed / Shadow Charger", npcID = 3864, mechanics = {
        { name = "Fel Stomp", description = "A close-range stomp from the steed encounter.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Fenrus the Devourer", npcID = 4274, mechanics = {
        { name = "Toxic Saliva", description = "Poisons the target and drains mana. Cleanse the poison when possible.", source = "Undying Forever encounter guide" },
        { name = "Voidwalkers", description = "Watch for summoned adds and have the tank pick them up.", source = "Undying Forever encounter guide" },
    } },
    { name = "Odo the Blindwatcher", npcID = 4279, mechanics = {
        { name = "Howling Rage", description = "Increases his damage. Kill the bats before committing to Odo.", source = "Undying Forever encounter guide" },
    } },
    { name = "Razorclaw the Butcher", npcID = 3886, mechanics = {
        { name = "Butcher Drain", description = "Watch for the drain and clear the nearby worgen so the tank can focus on Razorclaw.", source = "Undying Forever encounter guide" },
    } },
    { name = "Rethilgore", npcID = 3914, mechanics = {
        { name = "Soul Drain", description = "Drains health from a player. Interrupt the cast and clear the nearby adds.", source = "Undying Forever encounter guide" },
    } },
    { name = "Wolf Master Nandos", npcID = 3927, mechanics = {
        { name = "Call Bleak Worg / Call Lupine Horror", description = "Summons adds. Have the tank gather them before they reach the healer.", source = "Undying Forever encounter guide" },
    } },
})

addVerified("Shaper's Terrace", {
    { name = "Bolt", npcID = 262081, mechanics = {
        { name = "Chain Lightning", description = "Spread out so lightning has fewer targets to jump to.", source = "ConquestCapped Forever Shaper’s Terrace launch run guide" },
        { name = "Nature immunity", description = "Nature damage will not hurt Bolt. Use another school or physical damage.", source = "ConquestCapped Forever Shaper’s Terrace launch run guide" },
    } },
    { name = "Cinder", npcID = 261974, mechanics = {
        { name = "Archival Panel", description = "Use the Archival Panel to spawn Cinder. Blizzard fixed this activation in the November 9 hotfix.", source = "Blizzard WoW Forever November 9 hotfix" },
        { name = "Fire damage", description = "Move out of fire. Fire resistance can reduce pressure while the full ability list is checked.", source = "Undying live Forever Shaper’s Terrace game files and encounter guide" },
        { name = "Red console", description = "Summoned with 15 Red Power Crystals. Clear nearby enemies before triggering the console.", source = "Undying live Forever Shaper’s Terrace game files and encounter guide" },
    } },
    { name = "Direhorn Matriarch", npcID = 262127, mechanics = {
        { name = "Charge", description = "Can rush distant players. Keep the ranged group in reasonable healing range.", source = "ConquestCapped Forever Shaper’s Terrace launch run guide" },
        { name = "Puncture", description = "Applies a bleed to the tank. Plan for damage after the hit.", source = "ConquestCapped Forever Shaper’s Terrace launch run guide" },
        { name = "Tail Lash", description = "Hits players behind her. Use the flanks.", source = "ConquestCapped Forever Shaper’s Terrace launch run guide" },
    } },
    { name = "Nanaya", npcID = 261809, mechanics = {
        { name = "Element shift", description = "Nanaya changes element at each quarter of her health. Prepare for changing damage schools.", source = "Undying live Forever Shaper’s Terrace game files and encounter guide" },
        { name = "Powerful Slam", description = "Stuns players close to Nanaya. Stay outside when possible.", source = "Undying live Forever Shaper’s Terrace game files and encounter guide" },
        { name = "Sonic Screech", description = "Step clear of the shockwave’s path.", source = "Undying live Forever Shaper’s Terrace game files and encounter guide" },
    } },
    { name = "Snowtalon", npcID = 262297, mechanics = {
        { name = "Cone of cold", description = "Avoid the area in front of the raptor.", source = "Undying live Forever Shaper’s Terrace game files and encounter guide" },
        { name = "Frost nova and root", description = "Prepare to free players who are rooted in a dangerous position.", source = "Undying live Forever Shaper’s Terrace game files and encounter guide" },
        { name = "Silencing crystals", description = "Move the fight away from the large blue crystals so they do not silence your casters.", source = "Undying live Forever Shaper’s Terrace game files and encounter guide" },
    } },
    { name = "Thunderhoof", npcID = 261812, mechanics = {
        { name = "Lightning cast", description = "Save an interrupt for the lightning cast.", source = "ConquestCapped Forever Shaper’s Terrace launch run guide" },
        { name = "Thunderclap", description = "Be ready for damage around the boss.", source = "ConquestCapped Forever Shaper’s Terrace launch run guide" },
    } },
    { name = "Titanosaur", npcID = 253201, mechanics = {
        { name = "Fear", description = "Can fear multiple party members. Bring a fear break or Tremor Totem.", source = "Undying live Forever Shaper’s Terrace game files and encounter guide" },
        { name = "Tail knockback", description = "The tail throws back players behind the boss. Position on its flanks.", source = "Undying live Forever Shaper’s Terrace game files and encounter guide" },
    } },
    { name = "Venomridge", npcID = 261813, mechanics = {
        { name = "Poison volley", description = "Poisons the group. Bring poison removal or Poison Cleansing Totem.", source = "ConquestCapped Forever Shaper’s Terrace launch run guide" },
        { name = "Stomp", description = "Damages melee around the boss. Spread so the group can move or recover.", source = "ConquestCapped Forever Shaper’s Terrace launch run guide" },
    } },
    { name = "Vitrix", npcID = 272561, mechanics = {
        { name = "Poison Shock", description = "Spread around the target to limit the number of people hit. Stuns can break up the damage.", source = "Undying live Forever Shaper’s Terrace game files and encounter guide" },
    } },
})

addVerified("Stratholme: Living", {
    { name = "Archivist Galford", npcID = 10811, mechanics = {
        { name = "Burning Winds", description = "Stuns the target while dealing periodic Fire damage.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Fire Nova", description = "Deals Fire damage to players near Galford.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Balnazzar", npcID = 10813, mechanics = {
        { name = "Banish", description = "Temporarily incapacitates a valid demon or elemental target and makes it immune to damage.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Crusader's Hammer", description = "Stuns players near Dathrohan.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Domination", description = "Mind-controls a player; control them until it ends.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Psychic Scream", description = "Fears players near the boss; ranged players can stay back.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Shadow Shock", description = "Deals Shadow damage around Balnazzar.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Sleep", description = "Puts a player to sleep. Taking damage wakes them.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Cannon Master Willey", npcID = 10997, mechanics = {
        { name = "Knock Away", description = "Hits and knocks back the target.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Summon Crimson Rifleman", description = "Calls a Crimson Rifleman into the fight.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Hearthsinger Forresten", npcID = 10558, mechanics = {
        { name = "Enchanting Lullaby", description = "Puts one player to sleep until the effect ends or damage wakes them.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Multi-Shot", description = "Hits the target and nearby players with a volley of missiles.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Postmaster Malown", npcID = 11143, mechanics = {
        { name = "Backhand", description = "Briefly stuns the target.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Curse of Tongues", description = "Slows the target's spellcasting.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Curse of Weakness", description = "Reduces the Physical damage dealt by affected players.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Fear", description = "Forces a target to flee temporarily.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Wailing Dead", description = "Nearby players can accumulate this attribute-reducing curse from the Undead Postmen; clear or control the adds.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Skul", npcID = 10393, mechanics = {
        { name = "Arcane Bolt", description = "Hurls an Arcane projectile at a player.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Frost Shock", description = "Deals Frost damage and briefly slows the target.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Frostbolt", description = "Deals Frost damage and slows the target.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "The Unforgiven", npcID = 10516, mechanics = {
        { name = "Frost Nova", description = "Deals Frost damage and roots players near the boss.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Timmy the Cruel", npcID = 10808, mechanics = {
        { name = "Enrage", description = "Timmy enrages; prepare for increased pressure.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Ravenous Claw", description = "Steals health from the target to heal Timmy.", source = "Wowhead Forever Dungeon Journal" },
    } },
})

addVerified("Stratholme: Undead", {
    { name = "Baron Rivendare", npcID = 10440, mechanics = {
        { name = "Cleave", description = "Strikes its target and a nearby player.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Mortal Strike", description = "A heavy weapon strike that temporarily reduces healing received.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Shadow Bolt", description = "Throws a Shadow projectile at the target.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Unholy Aura", description = "Deals recurring Shadow damage to nearby players.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Baroness Anastari", npcID = 10436, mechanics = {
        { name = "Banshee Curse", description = "Reduces nearby players' chance to hit.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Banshee Wail", description = "Deals Shadow damage to the target.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Possess", description = "Anastari possesses a player. Lower the possessed player's health until control breaks, then stop attacking them.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Magistrate Barthilas", npcID = 10435, mechanics = {
        { name = "Crowd Pummel", description = "Damages nearby players and can interrupt spellcasting.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Draining Blow", description = "Steals health from the target to heal Barthilas.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Furious Anger", description = "Magistrate Barthilas gains Furious Anger.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Mighty Blow", description = "Knocks back the target; tank with a safe landing spot behind you.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Maleki the Pallid", npcID = 10438, mechanics = {
        { name = "Drain Life", description = "Drains the target's health and restores Maleki's in return.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Frostbolt", description = "Deals Frost damage and slows the target.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Ice Tomb", description = "Freezes and incapacitates the target.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Nerub'enkan", npcID = 10437, mechanics = {
        { name = "Encasing Webs", description = "Roots the target and slows their attacks.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Pierce Armor", description = "Lowers the target's armor; watch for heavier melee hits.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Raise Undead Scarab", description = "Summons an undead scarab into the fight.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Ramstein the Gorger", npcID = 10439, mechanics = {
        { name = "Flurry", description = "Ramstein gains Flurry; the Journal lists this without a tooltip effect.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Knockout", description = "Knocks back and stuns the target.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Trample", description = "Deals melee damage to nearby players.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Stonespine", npcID = 10809, mechanics = {
        { name = "Vicious Rend", description = "Inflicts an ongoing Physical bleed.", source = "Wowhead Forever Dungeon Journal" },
    } },
})

addVerified("The Deadmines", {
    { name = "Captain Greenskin", npcID = 647, mechanics = {
        { name = "Cleave", description = "Hits players in front of Greenskin. Position him facing away from the group.", source = "Method Forever Deadmines encounter guide" },
        { name = "Poisoned Harpoon", description = "Applies poison to his main target.", source = "Method Forever Deadmines encounter guide" },
    } },
    { name = "Cookie", npcID = 645, mechanics = {
        { name = "Acid Splash", description = "Poisons Cookie's main target with ongoing Nature damage.", source = "Method Forever Deadmines encounter guide" },
        { name = "Cookie's Cooking", description = "Heals Cookie. Interrupt the cast when possible.", source = "Method Forever Deadmines encounter guide" },
    } },
    { name = "Edwin VanCleef", npcID = 639, mechanics = {
        { name = "Defias Blackguard reinforcements", description = "Starts with two guards and calls two more around half health. Clear the first pair before the call.", source = "Method Forever Deadmines encounter guide" },
        { name = "Thrash", description = "Can deliver extra melee attacks against the tank.", source = "Method Forever Deadmines encounter guide" },
    } },
    { name = "Gilnid", npcID = 1763, mechanics = {
        { name = "Molten Metal", description = "Damages and slows its target. A Paladin can remove the snare with Blessing of Freedom.", source = "Method Forever Deadmines encounter guide" },
    } },
    { name = "Miner Johnson", npcID = 3586, mechanics = {
        { name = "Pierce Armor", description = "Reduces his target's armor. Expect the tank to take larger physical hits.", source = "Method Forever Deadmines encounter guide" },
    } },
    { name = "Mr. Smite", npcID = 646, mechanics = {
        { name = "Smite Stomp", description = "Stuns nearby players while Smite changes weapons. Deal with the Blackguards before pushing those transitions.", source = "Method Forever Deadmines encounter guide" },
        { name = "Thrash", description = "Smite can land extra melee attacks. Keep the tank healthy after a weapon swap.", source = "Method Forever Deadmines encounter guide" },
    } },
    { name = "Rhahk'Zor", npcID = 644, mechanics = {
        { name = "Rhahk'Zor Slam", description = "Stuns its target. Control any accompanying Defias Watchmen so the tank takes less damage while stunned.", source = "Method Forever Deadmines encounter guide" },
    } },
    { name = "Sneed", npcID = 643, mechanics = {
        { name = "Disarm", description = "The pilot disarms his main target after leaving the Shredder.", source = "Method Forever Deadmines encounter guide" },
    } },
    { name = "Sneed's Shredder", npcID = 642, mechanics = {
        { name = "Distracting Pain", description = "The Shredder hits a player with this attack before its pilot emerges.", source = "Method Forever Deadmines encounter guide" },
        { name = "Sneed ejects", description = "Sneed leaves the shredder when its health reaches zero. The November 13 hotfix restored this transition when the shredder is stunned.", source = "Blizzard WoW Forever November 13 hotfix" },
        { name = "Sneed emerges", description = "Destroying the machine starts the second phase against its pilot. Keep the tank ready for Sneed.", source = "Method Forever Deadmines encounter guide" },
        { name = "Terrify", description = "Fear can send players into other goblins. Clear space around the machine before pulling.", source = "Method Forever Deadmines encounter guide" },
    } },
})

addVerified("The Drowned City", {
    { name = "Captain Dreadrise", npcID = 260042, mechanics = {
        { name = "Embrine", description = "Traps a player inside an Abyssal Bubble. Attack the bubble immediately to free them.", source = "Method Forever The Drowned City encounter guide" },
        { name = "Waterbolt Volley", description = "Hits the party. Save an interrupt for this cast.", source = "Method Forever The Drowned City encounter guide" },
    } },
    { name = "Deathless Marrow", npcID = 260202, mechanics = {
        { name = "Bloodbolt", description = "Inflicts damage on the party while waves of enemies arrive.", source = "Method Forever The Drowned City encounter guide" },
        { name = "Charge", description = "The Deathless Watcher uses Charge. The November 9 hotfix reduced its damage by 50%.", source = "Blizzard WoW Forever November 9 hotfix" },
        { name = "Damage taken stacks", description = "Add deaths can make the Marrow take more damage. Kill early waves, then kite or control the remaining adds while finishing the boss.", source = "Forever player report after clearing The Drowned City" },
        { name = "Fireball", description = "The Deathless Sorcerer casts Fireball. The November 9 hotfix reduced its damage by 25%.", source = "Blizzard WoW Forever November 9 hotfix" },
        { name = "Guardian and Sorcerer waves", description = "Adds spawn throughout the fight. Control excess enemies and keep damage on the Marrow. Guardians can stun with Shield Slam.", source = "Method Forever The Drowned City encounter guide" },
        { name = "Shield Slam", description = "The Deathless Guardian uses Shield Slam. The November 9 hotfix cut the frequency by about half.", source = "Blizzard WoW Forever November 9 hotfix" },
    } },
    { name = "Gill", npcID = 264177, mechanics = {
        { name = "Throw Dynamite", description = "Move away from the thrown bomb to avoid splash damage.", source = "Method Forever Drowned City encounter guide" },
    } },
    { name = "Min'loth the Serpent", npcID = 260274, mechanics = {
        { name = "Deluge", description = "Channels group damage late in the troll phase. Top up the party before the channel.", source = "Method Forever The Drowned City encounter guide" },
        { name = "Drench", description = "A heavy hit on the tank during the troll phase.", source = "Method Forever The Drowned City encounter guide" },
        { name = "Fear", description = "Targets a player during the serpent phase. Prepare fear protection.", source = "Method Forever The Drowned City encounter guide" },
        { name = "Poison Bolt Volley", description = "Poisons the party in the serpent phase. Prioritize cleansing.", source = "Method Forever The Drowned City encounter guide" },
        { name = "Serpent form", description = "Min'loth changes form and begins the second phase with a new health bar.", source = "Method Forever The Drowned City encounter guide" },
    } },
    { name = "Primeval Elemental", npcID = 263886, mechanics = {
        { name = "Freeze Water", description = "Interrupt the area cast to avoid damage and attack, casting, and movement slows.", source = "Method Forever Drowned City encounter guide" },
        { name = "Undying Offerings", description = "Kill the offerings in the underwater chamber to summon the elemental. Keep a route to air.", source = "Method Forever Drowned City encounter guide" },
        { name = "Waterbolt", description = "Targets the player holding threat. Interrupt the cast when available.", source = "Method Forever Drowned City encounter guide" },
    } },
    { name = "Var'Taka", npcID = 258924, mechanics = {
        { name = "Brinescale Priestesses", description = "Control or kill the two healers so they cannot restore Var'Taka's health.", source = "Method Forever The Drowned City encounter guide" },
        { name = "Cleave", description = "Hits in front of the boss. Face him away from the party.", source = "Method Forever The Drowned City encounter guide" },
        { name = "Harpoon", description = "Pulls a party member into melee range.", source = "Method Forever The Drowned City encounter guide" },
    } },
    { name = "Zul'Alai", npcID = 258905, mechanics = {
        { name = "Monstrous Slam", description = "Stuns players near the boss. Move away before the cast finishes.", source = "Method Forever The Drowned City encounter guide" },
        { name = "Rotted Strike", description = "Slows nearby players' movement and attacks. Free the tank when possible.", source = "Method Forever The Drowned City encounter guide" },
        { name = "Undying Oath", description = "At low health, Zul'Alai attacks faster and heals himself. Save damage and tank cooldowns.", source = "Method Forever The Drowned City encounter guide" },
    } },
})

addVerified("The Stockade", {
    { name = "Bazil Thredd", npcID = 1716, mechanics = {
        { name = "Smoke Bomb", description = "Stuns players near Bazil. Ranged players should stay outside it and be ready if he switches targets.", source = "Method Forever Stockade encounter guide" },
    } },
    { name = "Dextren Ward", npcID = 1663, mechanics = {
        { name = "Intimidating Shout", description = "Fears nearby players. Keep the fight away from uncleared cells or use Tremor Totem.", source = "Method Forever Stockade encounter guide" },
    } },
    { name = "Hamhock", npcID = 1717, mechanics = {
        { name = "Bloodlust", description = "Speeds up Hamhock and enemies near him. Clear nearby adds before they benefit.", source = "Method Forever Stockade encounter guide" },
        { name = "Chain Lightning", description = "Jumps between nearby players. Spread if the hallway allows.", source = "Method Forever Stockade encounter guide" },
    } },
    { name = "Kam Deepfury", npcID = 1666, mechanics = {
        { name = "Improved Blocking", description = "Temporarily blocks more physical hits.", source = "Method Forever Stockade encounter guide" },
        { name = "Shield Slam", description = "Stuns his main target.", source = "Method Forever Stockade encounter guide" },
    } },
    { name = "Targorr the Dread", npcID = 1696, mechanics = {
        { name = "Enrage", description = "Targorr becomes more dangerous at low health. Keep the tank healthy as the fight ends.", source = "Method Forever Stockade encounter guide" },
        { name = "Thrash", description = "Extra attacks can land on the tank. Split the nearby prisoners off when possible.", source = "Method Forever Stockade encounter guide" },
    } },
})

addVerified("The Temple of Atal'Hakkar", {
    { name = "Atal'alarion", npcID = 8580, mechanics = {
        { name = "Atal’ai Shrines", description = "Activate south, north, southwest, southeast, northwest, then northeast to summon the boss.", source = "Wowhead Forever Sunken Temple walkthrough" },
        { name = "Sweeping Slam", description = "Knocks players airborne. Tank near a wall and keep ranged players back.", source = "Wowhead Forever Sunken Temple walkthrough" },
    } },
    { name = "Avatar of Hakkar", npcID = 8443, mechanics = {
        { name = "Cause Insanity", description = "Briefly turns a player against their group. Control them until the effect ends.", source = "Wowhead Forever Sunken Temple walkthrough" },
        { name = "Curse of Tongues", description = "Slows casting. Remove it from vulnerable casters when possible.", source = "Wowhead Forever Sunken Temple walkthrough" },
        { name = "Eternal Flames", description = "Kill Bloodkeepers and spend their blood to put out all four braziers and summon the Avatar.", source = "Wowhead Forever Sunken Temple walkthrough" },
        { name = "Lash", description = "Be ready to protect the tank if Lash disables them.", source = "Wowhead Forever Sunken Temple walkthrough" },
    } },
    { name = "Dreamscythe", npcID = 5721, mechanics = {
        { name = "Acid Breath", description = "Frontal breath attack. Face the drake away from the group.", source = "Wowhead Forever Sunken Temple walkthrough" },
        { name = "Wing Flap", description = "Knockback. The tank can position with their back to a wall.", source = "Wowhead Forever Sunken Temple walkthrough" },
    } },
    { name = "Gasher", npcID = 5713, mechanics = {
        { name = "Dual Wield", description = "Gasher fights with a weapon in each hand. Watch for sustained melee damage.", source = "Wowhead Forever Temple walkthrough" },
    } },
    { name = "Hazzas", npcID = 5722, mechanics = {
        { name = "Acid Breath", description = "Frontal breath attack. Face the drake away from the group.", source = "Wowhead Forever Sunken Temple walkthrough" },
        { name = "Wing Flap", description = "Knockback. The tank can position with their back to a wall.", source = "Wowhead Forever Sunken Temple walkthrough" },
    } },
    { name = "Hukku", npcID = 5715, mechanics = {
        { name = "Curse of Blood", description = "Makes the target take additional Physical damage.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Jammal'an the Prophet", npcID = 5710, mechanics = {
        { name = "Flamestrike", description = "Leave the area hit by Flamestrike.", source = "Wowhead Forever Sunken Temple walkthrough" },
        { name = "Healing Wave", description = "Reserve an interrupt for the heal.", source = "Wowhead Forever Sunken Temple walkthrough" },
        { name = "Hex of Jammal'an", description = "Transforms a party member into a hostile Berserker. Spread out and control the affected ally.", source = "Wowhead Forever Sunken Temple walkthrough" },
    } },
    { name = "Loro", npcID = 5714, mechanics = {
        { name = "Shield Spike", description = "Loro uses Shield Spike; allow for damage on melee attacks.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Mijan", npcID = 5717, mechanics = {
        { name = "Healing Ward", description = "Places a ward that heals nearby allies; destroy it.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Healing Wave", description = "Heals an ally. Interrupt it when possible.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Renew", description = "Applies a heal over time.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Thorns Aura", description = "Striking affected defenders can deal Nature damage back to the attacker.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Morphaz", npcID = 5719, mechanics = {
        { name = "Acid Breath", description = "Frontal breath attack. Face the drake away from the group.", source = "Wowhead Forever Sunken Temple walkthrough" },
        { name = "Wing Flap", description = "Knockback. The tank can position with their back to a wall.", source = "Wowhead Forever Sunken Temple walkthrough" },
    } },
    { name = "Ogom the Wretched", npcID = 5711, mechanics = {
        { name = "Curse of Weakness", description = "Keep a curse removal available.", source = "Wowhead Forever Sunken Temple walkthrough" },
        { name = "Shadow Bolt", description = "Ogom casts Shadow bolts while fighting alongside Jammal’an. Focus him first if healing is tight.", source = "Wowhead Forever Sunken Temple walkthrough" },
        { name = "Shadow Word: Pain", description = "Applies periodic Shadow damage.", source = "Wowhead Forever Sunken Temple walkthrough" },
    } },
    { name = "Shade of Eranikus", npcID = 5709, mechanics = {
        { name = "Acid Breath", description = "Faces forward. Stay behind or to the side.", source = "Wowhead Forever Sunken Temple walkthrough" },
        { name = "Deep Slumber", description = "Sleeps the player at highest threat. Prepare for another player to take over briefly.", source = "Wowhead Forever Sunken Temple walkthrough" },
        { name = "Dragonkin reinforcements", description = "Clear the nearby dragonkin before engaging or Eranikus can call them into the fight.", source = "Wowhead Forever Sunken Temple walkthrough" },
        { name = "Thrash", description = "Extra melee swings can hurt the tank suddenly.", source = "Wowhead Forever Sunken Temple walkthrough" },
        { name = "War Stomp", description = "Stuns nearby players. Keep the healer and ranged attackers out of melee.", source = "Wowhead Forever Sunken Temple walkthrough" },
    } },
    { name = "Weaver", npcID = 5720, mechanics = {
        { name = "Acid Breath", description = "Frontal breath attack. Face the drake away from the group.", source = "Wowhead Forever Sunken Temple walkthrough" },
        { name = "Wing Flap", description = "Knockback. The tank can position with their back to a wall.", source = "Wowhead Forever Sunken Temple walkthrough" },
    } },
    { name = "Zolo", npcID = 5712, mechanics = {
        { name = "Atal'ai Skeleton Totem", description = "Drops a totem that periodically summons Atal'ai skeletons.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Chain Lightning", description = "Nature damage jumps from the initial target to nearby players. Spread out.", source = "Wowhead Forever Dungeon Journal" },
    } },
    { name = "Zul'Lor", npcID = 5716, mechanics = {
        { name = "Cleave", description = "A melee swing that also clips a nearby player.", source = "Wowhead Forever Dungeon Journal" },
        { name = "Frailty", description = "Reduces the attributes of nearby players.", source = "Wowhead Forever Dungeon Journal" },
    } },
})

addVerified("Uldaman", {
    { name = "Ancient Stone Keeper", npcID = 7206, mechanics = {
        { name = "Damage-over-time immunity", description = "Use direct hits on the construct and account for high armor.", source = "ClassicWoWForever Uldaman Forever encounter guide" },
        { name = "Sand Storm", description = "Leave the cloud to avoid its slow and silence.", source = "ClassicWoWForever Uldaman Forever encounter guide" },
    } },
    { name = "Archaedas", npcID = 2748, mechanics = {
        { name = "Awakened guardians", description = "Kill the early weak adds. At about 20%, finish Archaedas before the final elite wave overwhelms the group.", source = "ClassicWoWForever Uldaman Forever encounter guide" },
    } },
    { name = "Galgann Firehammer", npcID = 7291, mechanics = {
        { name = "Amplify Flames", description = "Dispel Fire-related effects when possible.", source = "ClassicWoWForever Uldaman Forever encounter guide" },
        { name = "Fire Shock and Fire Nova", description = "Expect Fire damage. Control the accompanying geologists and use Fire protection if available.", source = "ClassicWoWForever Uldaman Forever encounter guide" },
    } },
    { name = "Grimlok", npcID = 4854, mechanics = {
        { name = "Bloodlust and Shrink", description = "Be ready for heavier incoming damage while the group controls the linked enemies.", source = "ClassicWoWForever Uldaman Forever encounter guide" },
        { name = "Chain Bolt", description = "Spread the group to reduce chaining. Control an add while focusing Grimlok.", source = "ClassicWoWForever Uldaman Forever encounter guide" },
    } },
    { name = "Ironaya", npcID = 7228, mechanics = {
        { name = "Arcing Smash", description = "Keep the party away from her front.", source = "ClassicWoWForever Uldaman Forever encounter guide" },
        { name = "Damage-over-time immunity", description = "Switch to direct damage against Ironaya. Keep her facing away from the party.", source = "ClassicWoWForever Uldaman Forever encounter guide" },
        { name = "War Stomp and Knock Away", description = "Spread out and allow the tank to recover after a knockback.", source = "ClassicWoWForever Uldaman Forever encounter guide" },
    } },
    { name = "Revelosh", npcID = 6910, mechanics = {
        { name = "Chain Lightning", description = "Lightning jumps between nearby targets.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Lightning Bolt", description = "Deals Nature damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "The Lost Dwarves", npcID = 6906, mechanics = {
        { name = "Intercept", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Shield Slam", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
})

addVerified("Upper Blackrock Spire", {
    { name = "General Drakkisath", npcID = 10363, mechanics = {
        { name = "Cleave", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Conflagration", description = "Deals periodic Fire damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Flame Breath", description = "A frontal Fire attack. Attack from the side or rear.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Thunderclap", description = "Deals Nature damage to players in its area.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Goraluk Anvilcrack", npcID = 10899, mechanics = {
        { name = "Backhand", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Head Crack", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Heroic Strike", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Gyth", npcID = 10339, mechanics = {
        { name = "Corrosive Acid Breath", description = "A frontal acid breath. Keep the boss facing away from the group.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Flame Breath", description = "A frontal Fire attack. Attack from the side or rear.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Freeze", description = "Freezes a target in place.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Jed Runewatcher", npcID = 10509, mechanics = {
        { name = "Shield Bash", description = "Deals Physical damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Shield Charge", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Strike", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Pyroguard Emberseer", npcID = 9816, mechanics = {
        { name = "Fire Nova", description = "Deals Fire damage to players in its area.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Flame Buffet", description = "Deals Fire damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Solakar Flamewreath", npcID = 10264, mechanics = {
        { name = "War Stomp", description = "Stuns nearby players.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "The Beast", npcID = 10430, mechanics = {
        { name = "Berserker Charge", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Fire Blast", description = "Deals Fire damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Fireball", description = "Deals Fire damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Flamebreak", description = "Deals Fire damage to players in its area.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Immolate", description = "Deals periodic Fire damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Terrifying Roar", description = "Listed for this encounter in the Forever Dungeon Journal.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
    { name = "Warchief Rend Blackhand", npcID = 10429, mechanics = {
        { name = "Cleave", description = "Deals damage.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Thunderclap", description = "Deals Nature damage to players in its area.", source = "Wowhead Forever Dungeon Journal and game spell data" },
        { name = "Whirlwind", description = "Strikes nearby players in melee range.", source = "Wowhead Forever Dungeon Journal and game spell data" },
    } },
})

addVerified("Wailing Caverns", {
    { name = "Kresh", npcID = 3653, mechanics = {
        { name = "Daze", description = "Kresh's melee hits can leave players dazed.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
    } },
    { name = "Lady Anacondra", npcID = 3671, mechanics = {
        { name = "Healing Touch", description = "Restores health if allowed to finish. Interrupt it when Sleep is covered.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
        { name = "Lightning Bolt", description = "Deals Nature damage from range.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
        { name = "Sleep", description = "Can take any party member out of the fight, including the healer. Interrupt the cast.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
    } },
    { name = "Lord Cobrahn", npcID = 3669, mechanics = {
        { name = "Healing Touch", description = "Restores health. Stop the cast when an interrupt is available.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
        { name = "Lightning Bolt", description = "Cobrahn casts ranged Nature damage before transforming.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
        { name = "Sleep", description = "Interrupt this cast to keep its target in the fight.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
        { name = "Snake form", description = "At low health he switches to heavier melee attacks and stops using his earlier spells.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
    } },
    { name = "Lord Pythas", npcID = 3670, mechanics = {
        { name = "Healing Touch", description = "Interrupt the heal after covering Sleep.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
        { name = "Lightning Bolt", description = "Pythas attacks with ranged Nature damage.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
        { name = "Sleep", description = "Prevent the cast before it removes a player from the fight.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
        { name = "Thunder Clap", description = "Damages nearby players. Ranged players can stand back.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
    } },
    { name = "Lord Serpentis", npcID = 3673, mechanics = {
        { name = "Healing Touch", description = "Stop the heal. Separate nearby enemies before engaging if possible.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
        { name = "Sleep", description = "Stop the cast to keep the party active.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
    } },
    { name = "Mutanus the Devourer", npcID = 3654, mechanics = {
        { name = "Fear", description = "An instant fear can scatter players. Fight where movement will not pull other enemies.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
        { name = "Sleep", description = "Interrupt the sleep cast to keep its target available.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
        { name = "Thunder Clap", description = "A close-range burst that can stun. Ranged players should stand back.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
    } },
    { name = "Skum", npcID = 3674, mechanics = {
        { name = "Chain Lightning", description = "The bolt jumps between party members. Leave space between players who can spread.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
    } },
    { name = "Verdan the Everliving", npcID = 5775, mechanics = {
        { name = "Area root and knockdown", description = "Players close to Verdan can be rooted and knocked down. Keep ranged players back.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
        { name = "Heavy melee", description = "Verdan's melee swings put sustained pressure on the tank. Heal ahead of the next hit.", source = "Mobalytics Forever Wailing Caverns encounter guide" },
    } },
})

addVerified("Zul'Farrak", {
    { name = "Antu'sul", npcID = 8127, mechanics = {
        { name = "Antu'sul's Minion", description = "Basilisk reinforcements join the fight. Pick them up before they reach your healer.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Chain Lightning", description = "Lightning jumps between nearby targets. Spread out to limit its reach.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Earth Shock", description = "Hits with Nature damage and can interrupt the target's spell.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Earthgrab Totem", description = "Roots players near the totem. Destroy it quickly to regain room to move.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Flash Heal", description = "A fast single-target heal.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Healing Wave of Antu'sul", description = "Restores health to an ally. Use an interrupt if this cast starts.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Chief Ukorz Sandscalp", npcID = 7267, mechanics = {
        { name = "Berserker Stance", description = "Changes stance to gain rage from attacks.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Cleave", description = "A melee strike that also hits a target standing close to the tank.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Wide Slash", description = "Sweeps the area in front of the chief. Everyone except the tank stays off that side.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Gahz'rilla", npcID = 7273, mechanics = {
        { name = "Freeze Solid", description = "Freezes a player and deals periodic Frost damage. Dispel the Magic effect when possible.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Gahz'rilla Slam", description = "Launches nearby players into the air. Use the pool archway to limit the knock-up.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Icicle", description = "A Frost projectile that slows its target.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Ruuzlu", npcID = 7797, mechanics = {
        { name = "Cleave", description = "Hits his current target and another player standing near them. Face Ruuzlu away from the party.", source = "Mobalytics Forever Zul’Farrak launch guide; Wowhead Forever encounter spell data" },
    } },
    { name = "Shadowpriest Sezz'ziz", npcID = 7275, mechanics = {
        { name = "Heal", description = "Sezz'ziz restores health to an ally. Interrupt the cast.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Psychic Scream", description = "Fears nearby party members. Reposition on cleared ground if the group scatters.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Renew", description = "Applies a heal over time to an ally.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Shadow Bolt", description = "A single-target Shadow cast.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Witch Doctor Zum'rah", npcID = 7271, mechanics = {
        { name = "Healing Wave", description = "Heals the caster or an ally. Save an interrupt for it.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Shadow Bolt", description = "Fires a Shadow projectile at one target.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Shadow Bolt Volley", description = "The volley hits nearby party members with Shadow damage. Prioritize interrupting it.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Ward of Zum'rah", description = "A totem summons skeletons. Destroy the ward before it produces more adds.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
    { name = "Zerillis", npcID = 10082, mechanics = {
        { name = "Frost Shot", description = "A Frost shot that slows the target's movement.", source = "Wowhead Forever Dungeon Journal game spell data" },
        { name = "Net", description = "Roots a player in place. Pull the ranger around a corner if the group needs a safe position.", source = "Wowhead Forever Dungeon Journal game spell data" },
    } },
})
