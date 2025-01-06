-------------------------------------------------
-- Constants for Dicescript --
-------------------------------------------------

wuerfel = {
    ["Blue"] = {url = "https://steamusercontent-a.akamaihd.net/ugc/54703869594687615/D8B2DF946C1CE65F106BC7F4D430298EA1A39269/"},
    ["Red"] = {url = "https://steamusercontent-a.akamaihd.net/ugc/54703869594687980/354D8C97D55D65FF6F4E4395FD74344C6F7EBF3D/"},
    ["Yellow"] = {url = "https://steamusercontent-a.akamaihd.net/ugc/54703869594688067/0FA13342C866591E655237E4128DC74E0073998F/"},
    ["Green"] = {url = "https://steamusercontent-a.akamaihd.net/ugc/54703869594687800/DDFEE802900F1B56DB561DCC17CCF1BC5B6C0048/"},
    ["Grey"] = {url = "https://steamusercontent-a.akamaihd.net/ugc/54703869594687882/4C4ADFD6A168465D6C822FFCEB6F8877703B2203/"},
    ["Black"] = {url = "https://steamusercontent-a.akamaihd.net/ugc/54703869594687523/17B84A1DE9B57B974E52DA45B99EE4348D1B82B1/"},
    ["Brown"] = {url = "https://steamusercontent-a.akamaihd.net/ugc/54703869594687749/962D1DC2E14369E65DA5E6A0E766317FA42E36AB/"},
}

blueDiceIMGs = {
    "https://steamusercontent-a.akamaihd.net/ugc/54705153895630143/57EC980D6CCBC6C82234860E9DCB66AEFDEFEE71/",
    "https://steamusercontent-a.akamaihd.net/ugc/54705153895630250/9AAECAEF9F1634816794456E30FD1A4F7183FE79/",
    "https://steamusercontent-a.akamaihd.net/ugc/54705153895630325/1AC7B79914321C73DB000D4134DB121271FF0AEE/",
    "https://steamusercontent-a.akamaihd.net/ugc/54705153895630418/6367402C99CA8FCC5795CD549BB57A865FC135B7/",
    "https://steamusercontent-a.akamaihd.net/ugc/54705153895630485/BB3A4BE2748B34DBA5D2E0C42AF65E95ACDB4721/",
    "https://steamusercontent-a.akamaihd.net/ugc/54705153895630570/5E560D5179AD35864B41CB8C9E274B0B49EFEA9F/"
}


ref_Blue = {"3♥♥","6♥↯","2♥♥↯","5♥","4♥♥","❌❌X❌"}
ref_Red = {"♥♥","♥♥♥↯","♥♥","♥♥♥","♥♥","♥"}
ref_Yellow = {"2♥","♥♥↯","1♥","♥♥","♥↯","1↯"}
ref_Green = {"1↯","1♥↯","♥","♥↯","1♥","↯"}
ref_Grey = {"▼","▼▼▼","▼","▼▼","▼","-"}
ref_Black = {"▼▼","▼▼▼▼","▼▼","▼▼▼","▼▼","-"}
ref_Brown = {"-","▼▼","▼","-","-","▼"}

announce_singleLine = true
--If last player to click button before roll happens gets their name announced
announce_playerName = true
--If last player to click button before roll is used to color name/total/commas
announce_playerColor = false
--If individual results are displayed (true or false)
announce_each = true
--If dice are added together for announcement (true or false)
announce_total = false
--Choose what color the print results are Options:
    --"default" = All text is white
    --"player" = All text is color-coded to player that clicked roll last
    --"die" = Results are colored to match the die color
announce_color = "die"

allowedPlayerColors = {Red = true, Green = true, Yellow = true, Blue = true}
allowedDMColor = {White = true}

isRolling = false
rollingDone = false
diceCount = 0
maxDice = 7
diceResults = {}

