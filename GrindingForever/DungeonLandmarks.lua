local _, ns = ...
-- Positions measured on the cropped map artwork from the supplied screenshots.
-- Coordinates are fractions of the visible artwork, with the origin at top left.
ns.DungeonLandmarks = {
    ["Ragefire Chasm"] = {
        {"Entrance", .610, .075, "entrance"},
        {"Oggleflint", .562, .379},
        {"Taragaman the Hungerer", .407, .570},
        {"Jergosh the Invoker", .341, .814},
        {"Bazzalan", .424, .843},
        {"Maur Grimtotem", .619, .385, "quest", "Searching for the Lost Satchel: turn in here. Returning the Lost Satchel: starts here."},
    },
    ["Wailing Caverns"] = {
        {"Entrance", .465, .590, "entrance"},
        {"Lady Anacondra", .310, .431},
        {"Kresh", .386, .350},
        {"Lord Cobrahn", .156, .570},
        {"Verdan the Everliving", .546, .460},
        {"Lord Serpentis", .616, .535},
        {"Deviate Faerie Dragon", .581, .600},
        {"Lord Pythas", .622, .658},
        {"Skum", .623, .735},
        {"Mutanus the Devourer", .348, .130, "boss", "Drops Glowing Shard, which starts a quest."},
    },
    ["The Deadmines"] = {
        {"Entrance", .294, .135, "entrance"},
        {"Rhahk'Zor", .367, .610},
        {"Miner Johnson", .536, .519},
        {"Sneed's Shredder", .476, .864},
        {"Sneed", .536, .864},
        {"Gilnid", .123, .755, nil, nil, 2},
        {"Mr. Smite", .516, .170, nil, nil, 2},
        {"Captain Greenskin", .577, .351, nil, nil, 2},
        {"Edwin VanCleef", .606, .451, nil, nil, 2},
        {"Cookie", .667, .430, nil, nil, 2},
    },
}
