-- Silence hub V36 - WH1T3 GUI V12 (LocalScript)  -  NEON UI OVERHAUL
-- V12: animated gradient border + rainbow mode, shimmering title, glowing tab indicator,
--      page slide-in, button ripples + press effect, richer toasts with timer bars,
--      floating sparkles, profile card, gradient loading bar. (V11 stuff is still in here.)
-- V11: 6 new screen effects (snow, leaves, rain, ghosts, embers, lightning), blood moon tint,
--      reminder timer, server info, settings backup, daily streak, new what's-new popup.
--      (all V11 code is in the block marked "V11 BIG UPDATE", read the comments to learn!)
-- V10: NEW badges, sort buttons, tab counts, Notes tab, hide-after-run, FOV + FPS boost,
--      debug info, shuffle + resume music, 3 new colors, friendlier errors, translations.
-- (Previous header below)
-- Doors Modes Hub V36 (LocalScript) - FINAL POLISH
-- V36 polish: duplicate-run protection and a bounded client performance test.
-- New in V36: smarter script runner (no more UI freezes + error toasts), Most Used,
-- run-last-script, search by creator, Tools tab (Anti-AFK, rejoin, executor check),
-- live FPS/ping/session stats, 5 accent colors, polished Updates tab.
-- 300+ scripts in tabs, search (per tab + across everything), favorites,
-- recently run, 🎵 music player (paste ANY audio id inside the hub),
-- saved playlist, saved settings, random mode, confirm switch.
-- Nothing needs editing: just run it. (Everything saves to your executor's
-- workspace folder if it supports writefile.)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GUI_NAME = "Silence hub V36 - WH1T3 GUI V12"

-- "hub" is a small toolbox your buttons can use, e.g. hub.notify("Hi!")
-- (it gets filled in further down, after the UI exists)
local hub = { player = player }

--==================================================================
-- ✏️  EDIT THIS PART  ✏️   (buttons, credits, descriptions)
--
-- Every button is a table with these fields:
--   name        = text shown on the button
--   description = what shows when you tap the three dots
--   confirm     = true  -> asks "Are you sure?" before running
--   confirmText = (optional) your own "are you sure" message
--   icon        = (optional) emoji shown before the name
--   run         = the code that runs when the button is pressed
--
-- To add a button: copy one block, paste it under the last one
-- (don't forget the comma after the closing brace!), change the text.
--==================================================================

-- Name shown in the title bar and on the loading screen
local HUB_TITLE = "Silence hub V36 - WH1T3 GUI V12"

-- Keys that show/hide the hub (the floating 🎃 always works too).
-- Want the old key back? Use:  { Enum.KeyCode.RightShift, Enum.KeyCode.F }
local TOGGLE_KEYS = { Enum.KeyCode.RightShift }


-- Messages printed in the Roblox chat when the hub finishes loading
local CHAT_ANNOUNCE = true
local CHAT_MESSAGES = {
	"<b><font color='rgb(180, 0, 255)'>Silence Hub & WH1T3 GUI V12 Loaded!</font></b>",
	"<b><font color='rgb(180, 0, 255)'>Made By Rip_Silence (#idkman06483) & WH1T3 (#relayhost) </font></b>",
	"<b><font color='rgb(180, 0, 255)'>Credit to WH1T3 For the GUI & Credit to RealblueYT for The Sign Text In Chat</font></b>",
}

--==================================================================
-- 💖 SECRET UNLOCK  (hidden: only you know how to open it)
--   1. Deploy key-server-worker.js on Cloudflare (steps are inside that file).
--   2. Paste your worker link below, ending in /check?key=
--   3. Make keys in YOUR browser with the worker's /generate?admin=... link.
-- The key is NEVER saved: closing or re-running the hub locks it again,
-- and every key from the worker works one time only (unless you change that).
-- Leave url = "" and the secret does not exist at all.
--==================================================================
local SECRET = {
	url = "https://helloworld.munizaga-daniel-s.workers.dev/check?key=", -- your key worker (never put the admin link here)
	taps = 7, -- tap/click the hub title this many times in a row to open the key box
	tabName = "💖 Secret",
	-- Loading-screen pictures. Each one is "rbxassetid://123", a number, or a direct
	-- https link to a .png/.jpg (needs an executor with writefile + getcustomasset).
	-- Keep them SFW: Roblox moderation and your players will thank you.
	images = {
		-- "rbxassetid://0000000000",
		-- "https://example.com/my-art.png",
	},
	-- Extra buttons inside the secret tab (same idea as normal buttons, no saving/"most used").
	-- The secret tab always talks uwu. Femboy mode (toggle inside the tab) uwu-ifies + recolors the WHOLE hub.
	buttons = {
		{
			name = "Headpats 🐾",
			description = "Give da hub a headpat. Wepwace me with youw weaw secwet GUI stuff.",
			run = function()
				hub.notify("*puwws* thank u fow da headpats >w<", 3)
			end,
		},
		{
			name = "Fwoof da hub 🦊",
			description = "Vewy impowtant button.",
			run = function()
				hub.notify("fwoofed uwu 💖", 3)
			end,
		},
	},
}

-- Big intro text over Doors' own menu (does nothing outside Doors)
local SHOW_DOORS_INTRO = true
local DOORS_INTRO_TEXT = "⭐Silence hub V36⭐"

-- Scripts that get a 🆕 badge (and show up in Home > NEW SCRIPTS). Use the exact script name.
-- Next update: clear this list and add the new names.
local NEW_SCRIPTS = {
	["Endless Mode (eliazbp92)"] = true,
	["Old Seek"] = true,
	["A-60 (Chaos Entity)"] = true,
	["Impossible Mode V1.8 (Alpha)"] = true,
	["Noise (Glitch Version Included)"] = true,
	["Purple Shakelight (All Rifts)"] = true,
	["Twinkhook Hub"] = true,
	["Hardcore Mode (VERY OLD)"] = true,
	["Gradish Mode"] = true,
	["Hardcore Mode (Retake Plus)"] = true,
	["Honcho Spawner"] = true,
	["Glitch Crucifix Effect (EPILEPSY WARNING)"] = true,
}

--==================================================================
-- 🎵 BACKGROUND MUSIC  (you DON'T need to edit this: paste IDs in the Music tab!)
-- Each track needs ONE of these:
--   id   = a Roblox audio id (number or "rbxassetid://123")
--   url  = a direct link to an .mp3/.ogg (downloaded + played via your executor)
--   file = a file already inside your executor's workspace folder
-- Add as many tracks as you like, the ⏮ / ⏭ buttons cycle them.
--==================================================================
local MUSIC_AUTOPLAY = true -- start the music when the hub finishes loading
local MUSIC_VOLUME = 50     -- 0 to 100
local MUSIC_TRACKS = {
	-- { name = "Spooky Theme", id = 1234567890 },
	-- { name = "Creepy Piano", url = "https://example.com/creepy-piano.mp3" },
	-- { name = "My Song",      file = "HalloweenHub/song.mp3" },
}

--==================================================================
-- 📜 SCRIPT TABS  (all the scripts from Testing.txt)
-- Each tab has a list of buttons. Same fields as described above:
--   name, description, subtitle (small text under the name),
--   confirm / confirmText, run = function() ... end
-- To add a script: copy a block, paste it in the right tab, edit it.
--==================================================================
local SCRIPT_TABS = {
	{
		name = "🔪 Modes",
		section = "Have Fun With These Modes",
		buttons = {
			{
				name = "Forgotten Mode",
				subtitle = "Working Perfectly",
				description = "Working Perfectly",
				run = function()
loadstring(game:HttpGet("https://pastebin.com/raw/Wy7PSxjz"))()
				end,
			},
			{
				name = "Creepy Mode",
				subtitle = "Made by DripCapyBara",
				description = "Made by DripCapyBara",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/DripCapybara/Doors-Modes/refs/heads/main/CreepyMode/ObfuscatedMain.lua"))()
				end,
			},
			{
				name = "Combined Mode (Fixed)",
				subtitle = "Fixed By Gab",
				description = "Fixed By Gab",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/ItzzGabbbb/TheCombined/refs/heads/main/CombinedModeFixedWAAAAAAAAAAAAAAAAAAAAAAAAAAAAA.lua"))()
				end,
			},
			{
				name = "Ultra Hard Mode (UPDATED)",
				subtitle = "Made By Zunxd",
				description = "Made By Zunxd",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Junxd-03/UltraHardModeUpdate/refs/heads/main/UltraHardMode.lua"))()
				end,
			},
			{
				name = "Laver Mode (Recreated)",
				subtitle = "Recreated By Guestly (Celestian)",
				description = "Recreated By Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Not-Guestly/Modes/refs/heads/main/Laver-Mode-Remake"))()
				end,
			},
			{
				name = "Hazy Mode (Recreated)",
				subtitle = "Recreated by Guestly (Celestian)",
				description = "Recreated by Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/GuestlyTheGreatestGuest/Modes/refs/heads/main/Hazy-Mode-Recreated-made-by-Guestly-(Celestian)-on-Discord"))()
				end,
			},
			{
				name = "Dark Mode (Fixed)",
				subtitle = "Fixed By Gab",
				description = "Fixed By Gab",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/ItzzGabbbb/-/refs/heads/main/Dark%20Mode%20Fixed.lua"))()
				end,
			},
			{
				name = "Part Mode",
				subtitle = "Made By Guestly (Celestian)",
				description = "Made By Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Not-Guestly/Modes/refs/heads/main/Parts-Mode"))()
				end,
			},
			{
				name = "Void Mode",
				subtitle = "Credit to Minh_Dcord",
				description = "Credit to Minh_Dcord",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/minh-scripter/doors_void/refs/heads/main/Doors_Void_Mode.txt"))()
				end,
			},
			{
				name = "Null Mode",
				subtitle = "Made by RealblueYT & LDLT_Legacy",
				description = "Made by RealblueYT & LDLT_Legacy",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rrealblueyt-oss/Null-mode/refs/heads/main/Null%20mode%20alpha%20by%20RealblueYT%20and%20LDLT_legacy"))()
				end,
			},
			{
				name = "Cazy Mode",
				subtitle = "Made By RealblueYT",
				description = "Made By RealblueYT",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/realbluedeptrainhat/Cazy-mode/refs/heads/main/cazy-mode%20.txt", true))()
				end,
			},
			{
				name = "Fear Mode V2",
				subtitle = "Made By Reboundplayz",
				description = "Made By Reboundplayz",
				run = function()
loadstring(game:HttpGet("https://github.com/reboundplayz/Doors-Fixed-Modes/raw/refs/heads/main/Doors%20Fear%20Mode"))()
				end,
			},
			{
				name = "Corrupted Mode",
				subtitle = "Made by Junin_320hy",
				description = "Made by Junin_320hy",
				run = function()
loadstring(game:HttpGet("https://github.com/junin724/Doors-modes/raw/refs/heads/main/Corrupted%20mode%20By%20me"))()
				end,
			},
			{
				name = "Fog Mode (Released)",
				subtitle = "Made By Vuivuiviu2",
				description = "Made By Vuivuiviu2",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Ganyu06112/Fog-Mode/refs/heads/main/Fog-Mode.lua"))()
				end,
			},
			{
				name = "Impossible+ Mode V1.8 (Reworked)",
				subtitle = "Made By Guestly (Celestian), Rip Voorpro's Impossible Mode",
				description = "Made By Guestly (Celestian), Rip Voorpro's Impossible Mode",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Outernal/Doors/refs/heads/main/Impossible-Mode-Plus"))()
				end,
			},
			{
				name = "Hallucination Mode (Easy Version)",
				subtitle = "Credit to Guestly (Celestian)",
				description = "Credit to Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/GuestlyTheGreatestGuest/Modes/refs/heads/main/Hallucination-Mode-(Easy-Version)-Made-by-Celestian-on-Discord"))()
				end,
			},
			{
				name = "Immersive Mode (Fixed)",
				subtitle = "Made by LocalPlayer",
				description = "Made by LocalPlayer",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Guestly-Alt/Scripts/refs/heads/main/fixedImmkersivemodeabitbutbyes"))()
				end,
			},
			{
				name = "Nightmare Mode",
				subtitle = "Made by Kodbol & Remade by Reboundplayz",
				description = "Made by Kodbol & Remade by Reboundplayz",
				run = function()
loadstring(game:HttpGet("https://pastebin.com/raw/YbkbZ3fp"))()
				end,
			},
			{
				name = "Insanitas Mode",
				subtitle = "Made by Guestly (Celestian) & Vuivuiviu2",
				description = "Made by Guestly (Celestian) & Vuivuiviu2",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/GuestlyTheGreatestGuest/Modes/refs/heads/main/Insanitas-Mode-Made-By-Guestly-And-Vuivuiviu2"))()
				end,
			},
			{
				name = "Bissastant Mode",
				subtitle = "Made by Guestly (Celestian)",
				description = "Made by Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Guestly-Alt/Scripts/refs/heads/main/Bissastant-Mode"))()
				end,
			},
			{
				name = "Inferno Mode",
				subtitle = "Made by Anctarus7105",
				description = "Made by Anctarus7105",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Anctarus7105/My-Modes/refs/heads/main/Inferno.lua"))()
				end,
			},
			{
				name = "Horror Mode (Fixed)",
				subtitle = "Original Credit to Chrono and Credit to THE_LOSTW3R for fixing it",
				description = "Original Credit to Chrono and Credit to THE_LOSTW3R for fixing it",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/thelostw3r/Mods/main/HorrorMode.lua"))()
				end,
			},
			{
				name = "Crazy Mode",
				subtitle = "Credit to Guestly (Celestian)",
				description = "Credit to Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/lynguyen26031993-design/-u/refs/heads/main/crazy-mode"))()
				end,
			},
			{
				name = "Roomy Mode",
				subtitle = "Made by FenzerPlayerPressure",
				description = "Made by FenzerPlayerPressure",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/FenzerPlayerPressure/SubVersions/refs/heads/main/Roomy%20Mode.lua"))()
				end,
			},
			{
				name = "Scary Mode",
				subtitle = "Made by Rip_Silence",
				description = "Made by Rip_Silence",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/Scary%20Mode"))()
				end,
			},
			{
				name = "Draco Mode V2",
				subtitle = "Made by Rip_Silence",
				description = "Made by Rip_Silence",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/Draco%20Mode%20(Fully%20Completed)"))()
				end,
			},
			{
				name = "Baller Mode",
				subtitle = "Made by Zunxd",
				description = "Made by Zunxd",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Junbbinopro/Baller-mode/refs/heads/main/Mode"))()
				end,
			},
			{
				name = "Critazy Mode",
				subtitle = "Made by RealblueYT",
				description = "Made by RealblueYT",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rrealblueyt-oss/Critazy-mode-/refs/heads/main/Critazy%20mode.LocalPlayer"))()
				end,
			},
			{
				name = "Ringer Mode",
				subtitle = "Made by Chu be te liet",
				description = "Made by Chu be te liet",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/chubeteliet-cpu/Ringer-doors/refs/heads/main/RINGER-DOORS-NEW!", true))()
				end,
			},
			{
				name = "Devil Mode (Fixed)",
				subtitle = "Fixed by Smile & Tuffmu Chicken Boy🔥",
				description = "Fixed by Smile & Tuffmu Chicken Boy🔥",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/datdoors/Devilmodefixed.main/refs/heads/main/Devilmodefixed"))()
				end,
			},
			{
				name = "Rooms Mode",
				subtitle = "Made by Gab",
				description = "Made by Gab",
				run = function()
loadstring(game:HttpGet("https://pastebin.com/raw/WLjeQQWm"))()
				end,
			},
			{
				name = "AyZen Mode",
				subtitle = "Made by Anctarus7105",
				description = "Made by Anctarus7105",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Anctarus7105/My-Modes/refs/heads/main/AyZen%20Mode/Mode.lua"))()
				end,
			},
			{
				name = "Strange Mode",
				subtitle = "Made By Guestly (Celestian)",
				description = "Made By Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Not-Guestly/Modes/refs/heads/main/Strange-Mode"))()
				end,
			},
			{
				name = "Anarchy Mode",
				subtitle = "Released By Anctarus7105",
				description = "Released By Anctarus7105",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Anctarus7105/Recreated-modes/refs/heads/main/Anarchy%20Release"))()
				end,
			},
			{
				name = "Extreme Mode (Recreated)",
				subtitle = "Recreated by Guestly (Celestian)",
				description = "Recreated by Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/GuestlyTheGreatestGuest/Modes/refs/heads/main/Extreme-Mode-Recreated-made-by-Guestly"))()
				end,
			},
			{
				name = "Chaos + Recall Mode",
				subtitle = "Made by Anctarus7105 & Aboba288-Abobic",
				description = "Made by Anctarus7105 & Aboba288-Abobic",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Anctarus7105/Recreated-modes/refs/heads/main/Chaos%20Recall%20V1.0"))()
				end,
			},
			{
				name = "Stingray Mode",
				subtitle = "Made by Anzor",
				description = "Made by Anzor",
				run = function()
loadstring(game:HttpGet('https://raw.githubusercontent.com/Anzor5458/Doors-stingray-mod/refs/heads/main/Anzor'))()
				end,
			},
			{
				name = "Medium Mode",
				subtitle = "Made by someone that idk",
				description = "Made by someone that idk",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/Medium-Mode-Made-by-someone-that-idk"))()
				end,
			},
			{
				name = "Insane Mode",
				subtitle = "Made by TheDarkMan & Recreated By Guestly (Celestian)",
				description = "Made by TheDarkMan & Recreated By Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Not-Guestly/Modes/refs/heads/main/Insane-Mode"))()
				end,
			},
			{
				name = "Arctic Mode",
				subtitle = "Made by Guestly (Celestian)",
				description = "Made by Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Not-Guestly/Modes/refs/heads/main/Arctic-Mode-(Beta)-By-Guestly-And-Vuivuiviu2"))()
				end,
			},
			{
				name = "Hardcore Mode (But Bad)",
				subtitle = "Made by RipperHC",
				description = "Made by RipperHC",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/KendrickFan59/privatev2/refs/heads/main/efdff"))()
				end,
			},
			{
				name = "Ringer Mode (Remake)",
				subtitle = "Remaked by RealblueYT",
				description = "Remaked by RealblueYT",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/realbluedeptrai/Ringer-mode/refs/heads/main/ringer%20mode%20remake", true))()
				end,
			},
			{
				name = "Voidness Mode V2",
				subtitle = "Made by Guestly (Celestian) & Vuivuiviu2 & Voorpr0",
				description = "Made by Guestly (Celestian) & Vuivuiviu2 & Voorpr0",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Not-Guestly/Modes/refs/heads/main/Voidness-Mode-Made-By-Guestly-Vuivuiviu2-And-Voorpr0", true))()
				end,
			},
			{
				name = "Forbidden Mode (Recreated)",
				subtitle = "Credit to Noah and Recreated By Guestly (Celestian)",
				description = "Credit to Noah and Recreated By Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/GuestlyTheGreatestGuest/Modes/refs/heads/main/Forbidden-Mode-recreated-by-Guestly"))()
				end,
			},
			{
				name = "Lunacy Mode V6 (Recreated)",
				subtitle = "Made by Guestly & Vuivuiviu2 & Nowhywhat & VoorPr0",
				description = "Made by Guestly & Vuivuiviu2 & Nowhywhat & VoorPr0",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nowhywhat/Cooking/main/LunacyMode.lua"))()
				end,
			},
			{
				name = "Fragmented Mode V5",
				subtitle = "Credit to Nhankgnew",
				description = "Credit to Nhankgnew",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/talales/Nhankg./refs/heads/main/the%20fragments%20v5"))()
				end,
			},
			{
				name = "Degenerate Mode (Reposted)",
				subtitle = "Made by Guestly (Celestian)",
				description = "Made by Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Not-Guestly/Modes/refs/heads/main/Degenerate-Mode-Reposted"))()
				end,
			},
			{
				name = "Hardcore Mode (Fixed)",
				subtitle = "Made By Noonie & Ping and Credit to THE_LOSTW3R for fixing the Hardcore Mode",
				description = "Made By Noonie & Ping and Credit to THE_LOSTW3R for fixing the Hardcore Mode",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/thelostw3r/Mods/main/HardcoreMode.lua"))()
				end,
			},
			{
				name = "Mayhem Mode",
				subtitle = "Working Perfectly",
				description = "Working Perfectly",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/localplayerr/Doors-stuff/refs/heads/main/Mayhem%20mode%20recreate/Code"))()
				end,
			},
			{
				name = "Endless Mode (Fixed)",
				subtitle = "Made by DripCapybara & Fixed By Gab",
				description = "Made by DripCapybara & Fixed By Gab",
				run = function()
loadstring(game:HttpGet("https://pastefy.app/EnSmizjL/raw"))()
				end,
			},
			{
				name = "Hollow Mode",
				subtitle = "Made by someone that idk",
				description = "Made by someone that idk",
				run = function()
loadstring(game:HttpGet("https://rawscripts.net/raw/DOORS-DAILY-RUNS-Hollow-Mode-91878"))()
				end,
			},
			{
				name = "Glassy Mode",
				subtitle = "Made by Guestly",
				description = "Made by Guestly",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/lynguyen26031993-design/-u/refs/heads/main/Glassy%20Mode"))()
				end,
			},
			{
				name = "Zombie Mode",
				subtitle = "Made by Grampy",
				description = "Made by Grampy",
				run = function()
loadstring(game:HttpGet('https://raw.githubusercontent.com/GrampyMods/ZombieMode/refs/heads/main/mode'))()
				end,
			},
			{
				name = "Hardcore Mode (Re-Remastered)",
				description = "Loads and runs Hardcore Mode (Re-Remastered).",
				run = function()
local url = "https://raw.githubusercontent.com/GuestlyTheGreatestGuest/Modes/main/Hardcore-Mode-Re-Remastered-Made-By-Guestly-Vuivuiviu2-Nowhywhat-Voorpr0"

local ok, err = pcall(function()
loadstring(game:HttpGet(url, true))()
end)

if not ok then
warn("[Loadstring Error]", err)
else
print("[Loaded Successfully]")
end
				end,
			},
			{
				name = "Gab's Fragmented Mode (Kinda Broken)",
				subtitle = "Made By Gab",
				description = "Made By Gab",
				run = function()
loadstring(game:HttpGet("https://pastebin.com/raw/nMgH5Jwa"))()
				end,
			},
			{
				name = "Immersive Mode (Remake)",
				subtitle = "Remake by RealblueYT",
				description = "Remake by RealblueYT",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rrealblueyt-oss/immersive-remake/refs/heads/main/Immersive-remake-loaded-localplayer-Origin-script.lua"))()
				end,
			},
			{
				name = "Ultra Hard Mode V3 (Remake)",
				subtitle = "Remake by RealblueYT",
				description = "Remake by RealblueYT",
				run = function()
loadstring(game:HttpGet("https://arch-http.vercel.app/files/projecthradmodv3"))()
				end,
			},
			{
				name = "Fragmented Mode V4 (Fixed)",
				subtitle = "Made By Jabiss",
				description = "Made By Jabiss",
				run = function()
loadstring(game:HttpGet("https://glot.io/snippets/h81q93s9qb/raw/main.lua"))()
				end,
			},
			{
				name = "Plamen6789's Hardcore Mode (Remake)",
				subtitle = "Remaked By Zunxd",
				description = "Remaked By Zunxd",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Junbbinopro/Hardcore-mode/refs/heads/main/hardcore.lua"))()
				end,
			},
			{
				name = "Insanity Mode (Reworked)",
				subtitle = "Credit to Kotyara19k & ReboundPlayz & Voorpr0",
				description = "Credit to Kotyara19k & ReboundPlayz & Voorpr0",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Anctarus7105/Recreated-modes/refs/heads/main/Insanity%20Reworked%201.3"))()
				end,
			},
			{
				name = "Stalker Mode (???)",
				subtitle = "Made by Leo -LDX-",
				description = "Made by Leo -LDX-",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/leonardocostagaucheuroleonardo-sketch/Stalkermodofc/refs/heads/main/README.md"))()
				end,
			},
			{
				name = "Fear Mode (Remake)",
				subtitle = "Remaked by RealblueYT",
				description = "Remaked by RealblueYT",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rrealblueyt-oss/Fearmode-/refs/heads/main/Fearmodereamake.txt"))()
				end,
			},
			{
				name = "Meme Mode",
				subtitle = "Made by Chu be te liet",
				description = "Made by Chu be te liet",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/chubeteliet-cpu/meme-mode-m-p/refs/heads/main/Meme-mode-ma-hoa", true))()
				end,
			},
			{
				name = "Christmas Mode",
				subtitle = "Credit to Chill Guy",
				description = "Credit to Chill Guy",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Idk-lol2/xmasmode/refs/heads/main/xmasmode.txt"))()
				end,
			},
			{
				name = "Hardcore Mode V4 (Old Version)",
				subtitle = "Made by Noonie & Ping",
				description = "Made by Noonie & Ping",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/localplayerr/Doors-stuff/refs/heads/main/Hardcore%20v4%20recreate/main%20code"))()
				end,
			},
			{
				name = "Impossible Mode (Remake)",
				subtitle = "Remaked by RealblueYT & Smile",
				description = "Remaked by RealblueYT & Smile",
				run = function()
loadstring(game:HttpGet("https://arch-http.vercel.app/files/Projectimpossiblebyrealblueytandsmile"))()
				end,
			},
			{
				name = "Schizophrenia Mode",
				subtitle = "Made by GroxMC (Fake)",
				description = "Made by GroxMC (Fake)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/tranthienhao872-ship-it/Mode/refs/heads/main/Mode%20doors%20test"))()
				end,
			},
			{
				name = "Fragmented Mode V4 (Remake)",
				subtitle = "Remaked by RealblueYT",
				description = "Remaked by RealblueYT",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rrealblueyt-oss/fragmented-v4-fixe/refs/heads/main/fragmentedv4fixed.lua"))()
				end,
			},
			{
				name = "Ultimate Nightmare Mode V8.2",
				subtitle = "Credit to Tuffmu Chicken Boy",
				description = "Credit to Tuffmu Chicken Boy",
				run = function()
loadstring(game:HttpGet("https://arch-http.vercel.app/files/ByTuffmuScriptVersion8.2UltimateNightmareMode.txt"))()
				end,
			},
			{
				name = "Impossible Mode (Re-Degenerate)",
				subtitle = "Made by Guestly (Celestian)",
				description = "Made by Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Not-Guestly/Modes/refs/heads/main/Impossible-Mode-Re-Degenerate-Made-By-Guestly"))()
				end,
			},
			{
				name = "Gab's Hardcore Mode (MultiPlayer)",
				subtitle = "Made By Gab",
				description = "Made By Gab",
				run = function()
loadstring(game:HttpGet("https://pastebin.com/raw/b9jTt9zi"))()
				end,
			},
			{
				name = "Gab's Hardcore Mode (SinglePlayer)",
				subtitle = "Made by Gab",
				description = "Made by Gab",
				run = function()
loadstring(game:HttpGet("https://pastebin.com/raw/jTrCetvx"))()
				end,
			},
			{
				name = "Silence Mode V3",
				subtitle = "Made By Rip_Silence",
				description = "Made By Rip_Silence",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/Silence%20Mode"))()
				end,
			},
			{
				name = "Degenerate Mode (Darkness Version)",
				subtitle = "Credit to Guestly (Celestian)",
				description = "Credit to Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/GuestlyTheGreatestGuest/Modes/refs/heads/main/Darkness-Degenerate-Mode-Made-By-Guestly"))()
				end,
			},
			{
				name = "Cizinuness Mode",
				subtitle = "Created by Guestly (Celestian)",
				description = "Created by Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/GuestlyTheGreatestGuest/Modes/refs/heads/main/Cizinuness-Mode-Made-By-Guestly", true))()
				end,
			},
			{
				name = "Suggestion Mode",
				subtitle = "Made By Guestly (Celestian)",
				description = "Made By Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Not-Guestly/Modes/refs/heads/main/Suggestions-Mode"))()
				end,
			},
			{
				name = "Dreamcore Mode",
				subtitle = "Made by Guestly & VoorPr0",
				description = "Made by Guestly & VoorPr0",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/GuestlyTheGreatestGuest/Modes/refs/heads/main/Dreamcore-Mode-Made-by-Guestly-and-Voorpr0"))()
				end,
			},
			{
				name = "Cataclysm Mode",
				subtitle = "Made by Guestly (Celestian) & Vuivuiviu3",
				description = "Made by Guestly (Celestian) & Vuivuiviu3",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/GuestlyTheGreatestGuest/Modes/refs/heads/main/Cataclysm-Mode-made-by-Guestly-and-Vuivuiviu3"))()
				end,
			},
			{
				name = "Sadness Mode",
				subtitle = "Credit to someone that idk",
				description = "Credit to someone that idk",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/LLGCAllIWantIsYou/urban-broccoli/refs/heads/main/SadnessMode.lua"))()
				end,
			},
			{
				name = "Hazy Mode + Extreme Mode (Combined)",
				subtitle = "Credit to Guestly (Celestian)",
				description = "Credit to Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/GuestlyTheGreatestGuest/Modes/refs/heads/main/Hazy%2BExtreme-Mode-made-by-Guestly-on-Discord"))()
				end,
			},
			{
				name = "Hardcore Mode (Reworker)",
				subtitle = "Made by RealblueYT",
				description = "Made by RealblueYT",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rrealblueyt-oss/Hradcore-by-noonies-remakes/refs/heads/main/Hradcore%20reworker%20by%20RealblueYT%20chubeteliet%20LDLT_legacy"))()
				end,
			},
			{
				name = "Fragmented Mode V4 (Not Official)",
				subtitle = "Credit to someone that idk",
				description = "Credit to someone that idk",
				run = function()
loadstring(game:HttpGet("https://glot.io/snippets/h7zlma80wm/raw/Main.java"))()
				end,
			},
			{
				name = "Terror Mode",
				subtitle = "Working Perfectly",
				description = "Working Perfectly",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Teilsthebfdifan/Modhub-assets/refs/heads/main/TerrorModeOBF.lua"))()
				end,
			},
			{
				name = "Hardcore Mode (Remake)",
				subtitle = "Remake by Junin_320hy",
				description = "Remake by Junin_320hy",
				run = function()
loadstring(game:HttpGet("https://github.com/junin724/Doors-modes/raw/refs/heads/main/Hardcore%2520mode%2520remake"))()
				end,
			},
			{
				name = "Endless Mode (Remake)",
				subtitle = "Remaked by Chu be te liet",
				description = "Remaked by Chu be te liet",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/binhlforsaken156-sys/Enless-mode-remake/refs/heads/main/Endless-remake-by-chubeteliet.txt", true))()
				end,
			},
			{
				name = "Fear Mode (Re-Remastered)",
				subtitle = "Credit to RealblueYT",
				description = "Credit to RealblueYT",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rrealblueyt-oss/Fear-mode-re_remastere/refs/heads/main/obfuscated_script-1769600892332.lua.txt"))()
				end,
			},
			{
				name = "Hallucination Mode (Hard Version)",
				subtitle = "Credit to Guestly (Celestian)",
				description = "Credit to Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/GuestlyTheGreatestGuest/Modes/refs/heads/main/Hallucination-Mode-(Hard-Version)-Made-by-Celestian-On-Discord"))()
				end,
			},
			{
				name = "Cataclysmic Mode",
				subtitle = "Credit to Guestly & Vuivuiviu4",
				description = "Credit to Guestly & Vuivuiviu4",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/GuestlyTheGreatestGuest/Modes/refs/heads/main/Cataclysmic-Mode-Made-by-Guestly-and-Vuivuiviu4"))()
				end,
			},
			{
				name = "White Haze Mode",
				subtitle = "Made by Minh_DCord",
				description = "Made by Minh_DCord",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/White%20Haze%20Mode"))()
				end,
			},
			{
				name = "Chaos Mode V1 (Hardcore Version)",
				subtitle = "Credit to DJ SD (Tunder8401) & Rip_Silence",
				description = "Credit to DJ SD (Tunder8401) & Rip_Silence",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Chaos-Mode-Hardcore-Version/refs/heads/main/Chaos%20Mode%20V1%20(Hardcore%20Version)"))()
				end,
			},
			{
				name = "The Mines Mode",
				subtitle = "Made by Gab",
				description = "Made by Gab",
				run = function()
loadstring(game:HttpGet("https://pastebin.com/raw/Hgn6DarS"))()
				end,
			},
			{
				name = "Difficulty Mode",
				subtitle = "Made by eoyoustme",
				description = "Made by eoyoustme",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/41450088/refs/heads/main/Difficulty%20mode%20fix"))()
				end,
			},
			{
				name = "Psychotic Mode",
				subtitle = "Made by someone that idk",
				description = "Made by someone that idk",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Drop56796/Psychotic-mode/main/monste%20and%20Door%20Sounds.lua"))()
				end,
			},
			{
				name = "Darkness Mode",
				subtitle = "Made by Chu be te liet",
				description = "Made by Chu be te liet",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/chubeteliet-cpu/Darkness-mode/refs/heads/main/Darkness%20mode%20rework", true))()
				end,
			},
			{
				name = "Stryker Mode",
				subtitle = "Made by Rip_Silence",
				description = "Made by Rip_Silence",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/Stryker-Mode-(Fully-Completed)"))()
				end,
			},
			{
				name = "Impossible Mode (Alpha)",
				subtitle = "Made by RealBlueYT",
				description = "Made by RealBlueYT",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/realbluedeptrainhat/Impossible-alpha-/refs/heads/main/impossible%20alpha.txt", true))()
				end,
			},
			{
				name = "Endless Mode (eliazbp92)",
				description = "Loads and runs Endless Mode (eliazbp92).",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eliazbp92-collab/Endless-mode/refs/heads/main/Script.lua"))()
				end,
			},
			{
				name = "Hardcore Mode (VERY OLD)",
				subtitle = "⚠️ Very very very old, may not work on Hotel+",
				description = "A VERY VERY VERY old Hardcore Mode. It's old as hell and might not work on Hotel+.",
				confirm = true,
				confirmText = "⚠️ This Hardcore Mode is VERY VERY VERY old. It's old asf and maybe won't work on Hotel+. Run it anyway?",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/jackpetersmithwarr-collab/DoorsHardmodeold/main/MAINSCRIPT"))()
				end,
			},
			{
				name = "Gradish Mode",
				description = "Loads and runs Gradish Mode.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/J63633S/Gradish-mode/main/Main%20script."))()
				end,
			},
			{
				name = "Hardcore Mode (Retake Plus)",
				description = "Loads and runs Hardcore Mode (Retake Plus).",
				run = function()
loadstring(game:HttpGet("https://github.com/tranthienhao872-ship/Hardcore-Retake/raw/refs/heads/main/Plus%20again"))()
				end,
			},
		},
	},
	{
		name = "💎 Extra",
		section = "Very Cool Things",
		buttons = {
			{
				name = "Floor 2 Theme Map",
				subtitle = "Updated by Zunxd",
				description = "Updated by Zunxd",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Junxd-03/Floor-2/refs/heads/main/New"))()
				end,
			},
			{
				name = "Fog Map",
				subtitle = "???",
				description = "???",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Junbbinopro/Fog-doors/refs/heads/main/Fogg"))()
				end,
			},
			{
				name = "Demon Map (Red Map)",
				subtitle = "666 666 666",
				description = "666 666 666",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/Monoxide/refs/heads/main/DEMON"))()
				end,
			},
			{
				name = "Rust Map",
				subtitle = "Made by RealblueYT",
				description = "Made by RealblueYT",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rrealblueyt-oss/Rust-maps/refs/heads/main/Rustmapuptdate.txt"))()
				end,
			},
			{
				name = "Knob Farm",
				subtitle = "Made by Vynixius",
				description = "Made by Vynixius",
				run = function()
getgenv().Config = {
    MinContainers = 10,
    MinCoins = 50,
    UseLockpick = false,
    UseRobuxKnobsBoost = false
}
loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/6e87698669de88a8f81d6348ce368b73.lua"))()
				end,
			},
			{
				name = "Verity Script",
				subtitle = "Made by ItzzGabbbb (Minecraft Mod btw)",
				description = "Made by ItzzGabbbb (Minecraft Mod btw)",
				run = function()
loadstring(game:HttpGet("https://pastefy.app/sqdSTwKt/raw"))()
				end,
			},
			{
				name = "Rainbow Room",
				subtitle = "Credit to UnknownReturnz for giving me this script",
				description = "Credit to UnknownReturnz for giving me this script",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/TestingAcc12312390/Doors-Hub/refs/heads/main/Rainbow-Room"))()
				end,
			},
			{
				name = "Script Mode V1 (Released)",
				subtitle = "Made By Munciseek",
				description = "Made By Munciseek",
				run = function()
loadstring(game:HttpGet("https://illunox.qzz.io/api/scripts/42b63e919ea74a999f2fec6ffdc02de1"))()
				end,
			},
			{
				name = "Generator Hard Mode",
				subtitle = "Made by Indexell",
				description = "Made by Indexell",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/IdkMyNameLoll/PublicScripts/refs/heads/main/HardGenIThinkReupload"))()
				end,
			},
			{
				name = "Chill Light (READ THE DESCRIPTION)",
				subtitle = "You need to die first and then you can see the chill light",
				description = "You need to die first and then you can see the chill light",
				run = function()
loadstring(game:HttpGet('https://pastebin.com/raw/nCYbqkAb'))()
				end,
			},
			{
				name = "Shaders (Working)",
				description = "Loads and runs Shaders (Working).",
				run = function()
loadstring(game:HttpGet('https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/cd.lua'))()
				end,
			},
			{
				name = "Keyboard (Working)",
				description = "Loads and runs Keyboard (Working).",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/GGH52lan/GGH52lan/main/keyboard.txt"))()
				end,
			},
			{
				name = "Client Performance Test (Safe)",
				subtitle = "Runs a short, bounded responsiveness check",
				description = "A safe alternative to the old infinite print loop. It never intentionally freezes the client.",
				confirm = true,
				confirmText = "Run a short performance check? It will print a small result to the console.",
				run = function()
					local started = os.clock()
					local checksum = 0
					for i = 1, 20000 do
						checksum += i % 97
					end
					print(("[DoorsModesHub] Safe test completed in %.4fs (checksum %d)"):format(os.clock() - started, checksum))
				end,
			},
			{
				name = "Disconnect Game (READ THE DESCRIPTION)",
				subtitle = "If u executed this, you are the only one who got disconnected",
				description = "If u executed this, you are the only one who got disconnected",
				confirm = true,
				confirmText = "This will kick YOU from the game. Are you sure? 🚪",
				run = function()
game.Players.LocalPlayer:Kick("Why do you even execute this bro?")
				end,
			},
			{
				name = "Sprint Stamina V5",
				description = "Loads and runs Sprint Stamina V5.",
				run = function()
_G.msrhyan_config_sprint = {
timetospeedexpire = 25, -- TIME TO EXPIRE STAMINA ( 0 = INFINITE )
cooldowntime = 5,
sprintspeed = 50,
speedapplytime = 0.3,
speedremovetime = 0.5,
staminarecovertime = 10,
effectfadetime = 0.2,
showstaminamessages = true,
customstaminamessage = "SUA STAMINA ACABOU, AGUARDE %ds!",
enableeffects = true,
effectcolor = {100, 200, 255},
staminabarcolor = {0, 162, 255},
sprintfov = 120,
normalfov = 70,
usewhileloading = false,
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/Sc-Rhyan57/MsProject/refs/heads/main/projects/DOORS-SPRINT.lua"))()
				end,
			},
			{
				name = "IndiHome Script (Troll)",
				subtitle = "Made By OG Hunger (New)",
				description = "Made By OG Hunger (New)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/Hardcore/refs/heads/main/IndiHome"))()
				end,
			},
			{
				name = "Hotel- Gui (Only Works In Hotel-)",
				subtitle = "Made by someone that idk",
				description = "Made by someone that idk",
				run = function()
loadstring(game:HttpGet("https://pastebin.com/raw/En0eCsJd"))()
				end,
			},
			{
				name = "Simple Script Loader",
				subtitle = "Credit to someone that idk",
				description = "Credit to someone that idk",
				run = function()
loadstring(game:HttpGet("https://rawscripts.net/raw/DOORS-DAILY-RUNS-Simple-Script-Loader-92632"))()
				end,
			},
			{
				name = "Dev Admin Panel (Need Admin Panel)",
				subtitle = "Credit to someone that idk",
				description = "Credit to someone that idk",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/SHRTRYScriptMANhere/DoorsDevPanel/refs/heads/main/devpanel.lua",true))()
				end,
			},
			{
				name = "Viridis Rift",
				subtitle = "Made By Guestly (Celestian)",
				description = "Made By Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Guestly-Alt/Scripts/refs/heads/main/Viridis-Rift"))()
				end,
			},
			{
				name = "Glitch Rift",
				subtitle = "Made By Guestly (Celestian)",
				description = "Made By Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Guestly-Alt/Scripts/refs/heads/main/Glitch-Rift"))()
				end,
			},
			{
				name = "Mischievous Rift",
				subtitle = "Made By Guestly (Celestian)",
				description = "Made By Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Guestly-Alt/Scripts/refs/heads/main/Mischievous-Rift"))()
				end,
			},
			{
				name = "Add Secret Entity",
				subtitle = "Credit to Rip_Silence",
				description = "Credit to Rip_Silence",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/Him-Entity-Main.lua"))()
				end,
			},
			{
				name = "Game File Logger",
				subtitle = "Made By Guestly (Celestian)",
				description = "Made By Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Not-Guestly/Scripts/refs/heads/main/Game-Files-Logger"))()
				end,
			},
			{
				name = "Door Display",
				subtitle = "Credit to Lucas",
				description = "Credit to Lucas",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/LukeLor/LukeLor/refs/heads/main/DoorDisplay.lua"))()
				end,
			},
			{
				name = "Helpful Rush",
				subtitle = "Credit to Lucas",
				description = "Credit to Lucas",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/LukeLor/LukeLor/refs/heads/main/Helpful%20Rush.lua"))()
				end,
			},
			{
				name = "Helping Jack (Only Works On Hotel-)",
				subtitle = "Made by Anctarus7105",
				description = "Made by Anctarus7105",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Anctarus7105/Random-Files/refs/heads/main/HelpingJack.lua"))()
				end,
			},
			{
				name = "Snare Blocker",
				subtitle = "Credit to Lucas",
				description = "Credit to Lucas",
				run = function()
workspace.DescendantAdded:Connect(function(Object)
if Object.Name == "Snare" and Object:FindFirstChild("Snare") then
print("snare")
local ds = coroutine.create(function()
while task.wait() do
if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Object.Hitbox.Position).Magnitude < 8 and Object.Hitbox.CanTouch == true then
Object.Hitbox.CanTouch = false

local lock = game:GetObjects("rbxassetid://134623425206809")[1]
lock.Parent = workspace
local newlock = lock.Lock
newlock.ParticleEmitter.Enabled = true
newlock.Parent = Object.Hitbox
lock:Destroy()

local effects= game:GetObjects("rbxassetid://107175245956530")[1] -- Curious: 82037744082799
effects.Parent = workspace
for _, effecth in effects:GetChildren() do
print( effecth.Name)
effecth.Parent = Object.Snare.Holes
print("Parented: "..effecth.Name)

end

effects:Destroy()
game:GetService("TweenService"):Create(Object.Snare.Holes, TweenInfo.new(0), {Color = Color3.fromRGB(0,0,0)}):Play()
game:GetService("TweenService"):Create(Object.Snare.Holes, TweenInfo.new(0.25), {Color = Color3.fromRGB(100, 146, 219)}):Play()--Curious: 248, 217, 109
task.wait(0.1)
newlock.ParticleEmitter.Texture = "rbxassetid://135389918701762"
task.wait(0.1)
newlock.ParticleEmitter.Texture = "rbxassetid://75134945132260"
task.wait(0.1)
newlock.ParticleEmitter.Texture = "rbxassetid://113033745280657"
task.wait(0.1)
newlock.ParticleEmitter.Texture = "rbxassetid://92040110017917"
task.wait(0.1)
newlock.ParticleEmitter.Texture = "rbxassetid://109471683017650"
task.wait(0.1)
newlock.ParticleEmitter.Texture = "rbxassetid://92040110017917"
task.wait(0.1)
newlock.ParticleEmitter.Texture = "rbxassetid://109471683017650"
print("vfx finished")
end
end
end)
coroutine.resume(ds)
end
end)
				end,
			},
			{
				name = "Speedrun Timer",
				subtitle = "Credit to Iliankvth",
				description = "Credit to Iliankvth",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Iliankytb/Iliankytb/main/SpeedrunTimer"))()
				end,
			},
			{
				name = "THE OVERDOORS V2.5 (Remake)",
				subtitle = "Remake by RealblueYT",
				description = "Remake by RealblueYT",
				run = function()
loadstring(game:HttpGet("https://arch-http.vercel.app/files/Projectoverdoors" ))()
				end,
			},
			{
				name = "c00lkidd Seek Chase (READ THE DESCRIPTION)",
				subtitle = "Execute this script and then go to the seek chase",
				description = "Execute this script and then go to the seek chase",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/IdkMyNameLoll/PublicScripts/refs/heads/main/c00lkiddSeek"))()
				end,
			},
			{
				name = "Abrisam's Sprint Bar",
				subtitle = "Credit to Abrisam",
				description = "Credit to Abrisam",
				run = function()
loadstring(game:HttpGet("https://pastebin.com/raw/MgWAd5WQ"))()
				end,
			},
			{
				name = "The Lost Mines",
				subtitle = "Credit to Cosplayer",
				description = "Credit to Cosplayer",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/TestingAcc12312390/Other-Modes-Script/refs/heads/main/The-Lost-Mines"))()
				end,
			},
			{
				name = "Script Mode (Remake)",
				subtitle = "Made by Reboundplayz",
				description = "Made by Reboundplayz",
				run = function()
loadstring(game:HttpGet("https://github.com/reboundplayz/Doors-Fixed-Modes/raw/refs/heads/main/Script%20Mode"))()
				end,
			},
			{
				name = "THE OVERDOORS (Final Version)",
				subtitle = "Credit to Chu be te liet",
				description = "Credit to Chu be te liet",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/chubeteliet-cpu/OVERDOORS-rework-ver/refs/heads/main/OVERDOORS%20entity%20finale%20upd", true))()
				end,
			},
			{
				name = "Purple Shakelight (All Rifts)",
				description = "Loads and runs Purple Shakelight (All Rifts).",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/lukahudeev-sys/Purple-shakelight/refs/heads/main/all%20rifts"))()
				end,
			},
		},
	},
	{
		name = "🌹 OG Modes",
		section = "Only works in Super Hard Mode",
		buttons = {
			{
				name = "Hardcore Mode [OG]",
				subtitle = "OG Mode",
				description = "OG Mode",
				run = function()
loadstring(game:HttpGet("https://pastebin.com/raw/hsrvGG1d"))()
				end,
			},
			{
				name = "Fear Mode [OG]",
				subtitle = "OG Mode",
				description = "OG Mode",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/cool59572/freestuff/main/Fear_mode_multiplayer.lua"))()
				end,
			},
			{
				name = "Impossible Mode [OG]",
				subtitle = "OG Mode",
				description = "OG Mode",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Ukazix/impossible-mode/refs/heads/main/Protected_79.lua.txt", true))()
				end,
			},
		},
	},
	{
		name = "📄 Hubs",
		section = "Enjoy these scripts",
		buttons = {
			{
				name = "Nullfire Script",
				description = "Loads and runs Nullfire Script.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/TeamNullFire/NullFire/main/loader.lua"))()
				end,
			},
			{
				name = "Rapture Hub Doors🚪 V1.2",
				description = "Loads and runs Rapture Hub Doors🚪 V1.2.",
				run = function()
--[[
WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet("https://raw.githubusercontent.com/RaptureOfc/Rapture-Doors-Released-1.0-New/refs/heads/main/Doors%20Release%20Rapture"))()
				end,
			},
			{
				name = "Ms Paint V4",
				description = "Loads and runs Ms Paint V4.",
				run = function()
loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/002c19202c9946e6047b0c6e0ad51f84.lua"))()
				end,
			},
			{
				name = "Ms Doors",
				description = "Loads and runs Ms Doors.",
				run = function()
loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Msdoors-By-Rhyan57-54579"))()
				end,
			},
			{
				name = "Hardcore Mode ESP",
				subtitle = "It may help u know when hardcore entity is coming",
				description = "It may help u know when hardcore entity is coming",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Qiwikox12/stubrawl/refs/heads/main/DoorsHardcoreESP.txt", true))()
				end,
			},
			{
				name = "Script Packs",
				description = "Loads and runs Script Packs.",
				run = function()
loadstring(game:HttpGet("https://pastebin.com/raw/Piw5bqGq", true))()
				end,
			},
			{
				name = "LolHax Hub",
				description = "Loads and runs LolHax Hub.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Robloxexploiterz/Release-Lolhax/refs/heads/main/LX%20Doors%20v3.lua"))()
				end,
			},
			{
				name = "Sexsation - Doors (Free)",
				description = "Loads and runs Sexsation - Doors (Free).",
				run = function()
loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/730854e5b6499ee91deb1080e8e12ae3.lua"))()
				end,
			},
			{
				name = "Abyssal Hub",
				subtitle = "Credit to FireBacon & wop2p",
				description = "Credit to FireBacon & wop2p",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/therealcookiemonsterof1966/AbysallContinued/main/Games/Doors/Main.luau"))()
				end,
			},
			{
				name = "Vynixius",
				description = "Loads and runs Vynixius.",
				run = function()
loadstring(game:HttpGet("https://vynixius.win/loader.luau", true))()
				end,
			},
			{
				name = "Astral Hub",
				subtitle = "Oogway",
				description = "Oogway",
				run = function()
loadstring(game:HttpGet("https://pastebin.com/raw/8cKJvTwg", true))()
				end,
			},
			{
				name = "LHKing Hub",
				subtitle = "LHking123456",
				description = "LHking123456",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/LHking123456/Dhjfdr9hk/refs/heads/main/Doors", true))()
				end,
			},
			{
				name = "HubHubHub",
				description = "Loads and runs HubHubHub.",
				run = function()
loadstring(game:HttpGet("https://rawscripts.net/raw/DOORS-DAILY-RUNS-HubHubHub-92582"))()
				end,
			},
			{
				name = "Joy Hub",
				description = "Loads and runs Joy Hub.",
				run = function()
loadstring(game:HttpGet("https://rawscripts.net/raw/DOORS-DAILY-RUNS-Joy-hub-93382"))()
				end,
			},
			{
				name = "Doors Hub + Editor (Beta)",
				subtitle = "Made By Loper367",
				description = "Made By Loper367",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/razumenkonikita9-cmyk/Doors-hub-Editor/refs/heads/main/D.lua"))()
				end,
			},
			{
				name = "Guestly's Doors Modes Hub V3",
				subtitle = "Credit to Guestly (Celestian)",
				description = "Credit to Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Not-Guestly/Modes/refs/heads/main/GUESTLY-DOORS-MODE-HUB"))()
				end,
			},
			{
				name = "Guestly's New Doors Modes Hub",
				subtitle = "Made by Guestly (Celestian)",
				description = "Made by Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Not-Guestly/Modes/refs/heads/main/DOORS-MODES-HUB"))()
				end,
			},
			{
				name = "Eukard's Doors Modes Hub",
				subtitle = "Made By Eukard",
				description = "Made By Eukard",
				run = function()
loadstring(game:HttpGet('https://raw.githubusercontent.com/Aboba228-Abobic/Eukard-s-Hub/refs/heads/main/EukardsHub'))()
				end,
			},
			{
				name = "Grampy's Doors Modes Hub",
				subtitle = "Made by Grampy",
				description = "Made by Grampy",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/GrampyMods/doorsmodshub/refs/heads/main/script"))()
				end,
			},
			{
				name = "Doors Modes Hub V1 (Oldest Version??)",
				subtitle = "Oldest Version Of Doors Modes Hub???",
				description = "Oldest Version Of Doors Modes Hub???",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/Unknown"))()
				end,
			},
			{
				name = "AmadeyHunter's Doors Utilities Hub Reorganized V20?",
				subtitle = "Credit to AmadeyHunter",
				description = "Credit to AmadeyHunter",
				run = function()
loadstring(game:HttpGet("https://github.com/AmadeyHunter/BackUp/raw/refs/heads/main/Doors-Utilities-Hub-Reorganized-V20"))()
				end,
			},
			{
				name = "Anctarus7105's Hub V3.5",
				subtitle = "Credit to Anctarus7105",
				description = "Credit to Anctarus7105",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Anctarus7105/My-creations/refs/heads/main/Anctarus7105'sHubV3.5"))()
				end,
			},
			{
				name = "Twinkhook Hub",
				subtitle = "Better than Abyssal Hub • has God Mode",
				description = "Another version of the hub, better than the Abyssal Hub, and it has god mode.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/sillyleo67/Doors/refs/heads/main/Twinkhook.lua"))()
				end,
			},
		},
	},
	{
		name = "😈 Legacy",
		section = "Only works in Hotel-",
		buttons = {
			{
				name = "Hardcore Mode (Legacy)",
				subtitle = "Fixed By THE_LOSTW3R",
				description = "Fixed By THE_LOSTW3R",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/thelostw3r/Mods/main/HardcoreMode%5BLEGACY%5D.lua"))()
				end,
			},
			{
				name = "Impossible Mode (Legacy)",
				subtitle = "Made by reboundplayz",
				description = "Made by reboundplayz",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/Impossible-Mode-Legacy-Made-by-reboundplayz"))()
				end,
			},
			{
				name = "Mayhem Mode (Legacy)",
				subtitle = "Made By ItzzGabbbb",
				description = "Made By ItzzGabbbb",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/ItzzGabbbb/MayhemModeLegacy1.0/refs/heads/main/DoorsMayhemModeLegacy.lua"))()
				end,
			},
			{
				name = "Fear Mode (Legacy)",
				subtitle = "Made by reboundplayz",
				description = "Made by reboundplayz",
				run = function()
loadstring(game:HttpGet("https://github.com/reboundplayz/Doors-Fixed-Modes/raw/refs/heads/main/Fear%20Mode%20LEGACY"))()
				end,
			},
		},
	},
	{
		name = "⚠️ Entities",
		section = "Custom Entity Spawner",
		buttons = {
			{
				name = "Hardcore A-60 Spawner",
				description = "Loads and runs Hardcore A-60 Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Idk-lol2/a-60aa/refs/heads/main/---%3D%3D%3D%3D%3D%3D%20a-60%20agresiv%20spawner%20%3D%3D%3D%3D%3D%3D---.txt"))()
				end,
			},
			{
				name = "Him Spawner",
				description = "Loads and runs Him Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/Idk"))()
				end,
			},
			{
				name = "Hungered Spawner",
				description = "Loads and runs Hungered Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Junbbinopro/Hungerd/refs/heads/main/Entity"))()
				end,
			},
			{
				name = "Munci Spawner",
				description = "Loads and runs Munci Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Junbbinopro/Munci-entity/refs/heads/main/Munci-20"))()
				end,
			},
			{
				name = "Torment Spawner (READ THE DESCRIPTION)",
				subtitle = "Execute Torment Spawner at door 0 and open the next door",
				description = "Execute Torment Spawner at door 0 and open the next door",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/ohh/refs/heads/main/Torment12"))()
				end,
			},
			{
				name = "Trauma Spawner",
				description = "Loads and runs Trauma Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Junbbinopro/Trauma-entity/refs/heads/main/Trauma"))()
				end,
			},
			{
				name = "Disturbance Spawner (READ THE DESCRIPTION)",
				subtitle = "Execute Disturbance Spawner at door 0 and open the next door",
				description = "Execute Disturbance Spawner at door 0 and open the next door",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/talales/Nhankg.-/refs/heads/main/intro%20fragmented"))()
				end,
			},
			{
				name = "Obsession Spawner (READ THE DESCRIPTION)",
				subtitle = "Execute Obsession Spawner at door 0 and open the next door",
				description = "Execute Obsession Spawner at door 0 and open the next door",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Drop56796/Mayhem-mode-enity/main/Hard%20Obsession.lua"))()
				end,
			},
			{
				name = "Hardcore Dread Spawner (Remake)",
				description = "Loads and runs Hardcore Dread Spawner (Remake).",
				run = function()
loadstring(game:HttpGet("https://github.com/reboundplayz/Doors-Fixed-Modes/raw/refs/heads/main/Dread%20Remake"))()
				end,
			},
			{
				name = "Twister Spawner (Phase 1)",
				description = "Loads and runs Twister Spawner (Phase 1).",
				run = function()
loadstring(game:HttpGet("https://pastefy.app/7jJP8zZb/raw"))()
				end,
			},
			{
				name = "Questioner Spawner",
				description = "Loads and runs Questioner Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Custom-Entity/refs/heads/main/Questioner-Entity"))()
				end,
			},
			{
				name = "Terrorist Spawner",
				description = "Loads and runs Terrorist Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Drop56796/Spawn-terrorist/main/Spawn.lua"))()
				end,
			},
			{
				name = "Silence Spawner",
				description = "Loads and runs Silence Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/Silence%20Entity"))()
				end,
			},
			{
				name = "Defrost Spawner",
				description = "Loads and runs Defrost Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/Custom-Entity/refs/heads/main/Defrost"))()
				end,
			},
			{
				name = "Smiler Spawner (Remake)",
				description = "Loads and runs Smiler Spawner (Remake).",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rrealblueyt-oss/Smiler/refs/heads/main/Smi6"))()
				end,
			},
			{
				name = "Rebound Spawner (Remake)",
				description = "Loads and runs Rebound Spawner (Remake).",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rrealblueyt-oss/Rebound-/refs/heads/main/Rebound"))()
				end,
			},
			{
				name = "Deer God Spawner (Remake)",
				description = "Loads and runs Deer God Spawner (Remake).",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/back/refs/heads/main/Deer%20God"))()
				end,
			},
			{
				name = "Cease Spawner",
				description = "Loads and runs Cease Spawner.",
				run = function()
loadstring(game:HttpGet("https://pastefy.app/ofutwkjb/raw"))()
				end,
			},
			{
				name = "WH1T3 Spawner (Remake)",
				description = "Loads and runs WH1T3 Spawner (Remake).",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/Impossible/refs/heads/main/Wh1t3"))()
				end,
			},
			{
				name = "Giggle Spawner",
				subtitle = "Only spawn 1 Giggle each room",
				description = "Only spawn 1 Giggle each room",
				run = function()
getgenv().GIGGLE_SPAWN_CONFIG = {
Damage = 6,
AttackingTime = math.random(7, 10), -- The time giggle will be attacking for.
FallSpeed = 3, -- Speed for when giggle spawns, can be mininum 2 and how high you want

Stunnable = true, -- If set to true, Giggle will be stunnable with glowstick
StunTime = 5, -- The time giggle will be stun for

RagdollThrowForce = 50, -- The Ragdoll's Force when its thrown
RagdollDissapears = true, -- If set to true the ragdoll will dissapear once giggle finishes attacking.

RoomSpawning = {
Enabled = true -- If set to false, giggle will spawn around the player.
},

PlayerSpawning = { -- This table will be used if Room Spawning is Disabled
MinRadius = -20, -- The minimum distance giggle can spawn from the player.
MaxRadius = 20. -- The maximum distance giggle can spawn from the player.
},

SpawningKey = { -- Key for Spawning
Enabled = false, -- If enabled once the key is pressed, giggle will spawn.
Key = "G" -- Key that is used for spawning giggle
}
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/DripCapybara/Test/refs/heads/main/Doors/GiggleSpawn.lua"))()
				end,
			},
			{
				name = "Obsession Spawner (Remake)",
				description = "Loads and runs Obsession Spawner (Remake).",
				run = function()
loadstring(game:HttpGet("https://pastefy.app/xlnpKWXo/raw"))()
				end,
			},
			{
				name = "A-100 Spawner",
				description = "Loads and runs A-100 Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/Impossible/refs/heads/main/A-100"))()
				end,
			},
			{
				name = "A-75 Spawner",
				description = "Loads and runs A-75 Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eliazbp92-collab/Rooms-low-detailed-mode-doors/refs/heads/main/A-75"))()
				end,
			},
			{
				name = "Daze Spawner",
				description = "Loads and runs Daze Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/ohh/refs/heads/main/Daze11"))()
				end,
			},
			{
				name = "God Spawner",
				subtitle = "Made by ItzzGabbbb",
				description = "Made by ItzzGabbbb",
				run = function()
loadstring(game:HttpGet("https://pastefy.app/lAn7TCVE/raw"))()
				end,
			},
			{
				name = "R-40 Spawner",
				description = "Loads and runs R-40 Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/ItzzGabbbb/R-40-Spawner-Fixed/refs/heads/main/Doors%20Entity%20R-40.txt"))()
				end,
			},
			{
				name = "Draft Spawner",
				description = "Loads and runs Draft Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/ohh/refs/heads/main/Draft1"))()
				end,
			},
			{
				name = "Fluster Spawner",
				description = "Loads and runs Fluster Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/talales/Nhankg./refs/heads/main/Fluster"))()
				end,
			},
			{
				name = "Angler Spawner",
				description = "Loads and runs Angler Spawner.",
				run = function()
loadstring(game:HttpGet("https://pastebin.com/raw/GQCHNZE1"))()
				end,
			},
			{
				name = "Monoxide Spawner",
				description = "Loads and runs Monoxide Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/back/refs/heads/main/Monoxide1"))()
				end,
			},
			{
				name = "Depthter Spawner",
				description = "Loads and runs Depthter Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/back/refs/heads/main/Depthter"))()
				end,
			},
			{
				name = "Blink Spawner",
				description = "Loads and runs Blink Spawner.",
				run = function()
loadstring(game:HttpGet("https://github.com/PABMAXICHAC/doors-monsters-scripts/raw/main/blinkcrux"))()
				end,
			},
			{
				name = "Dozer Spawner",
				description = "Loads and runs Dozer Spawner.",
				run = function()
--[[
WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
_G.dozerSpawnerSettings = {
dozerSpawnCD = 1,
ticksBeforeChecking = 10,
tomorrowTexts = 10,
SpawnerSettings = {
SpawnByUser = false, --set to true if you want to spawn Dozer
SpawnKeybind = Enum.KeyCode.Z,

SpawnRandomSettings = {
MathRandomSpawn1 = 10,
MathRandomSpawn2 = 15
}
}
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/IdkMyNameLoll/34921473024732147312483297412/refs/heads/main/dozerspawner"))()
				end,
			},
			{
				name = "Conjoinment Spawner",
				description = "Loads and runs Conjoinment Spawner.",
				run = function()
loadstring(game:HttpGet("https://github.com/reboundplayz/Doors-Fixed-Modes/raw/refs/heads/main/Conjoinment%20Spawner"))()
				end,
			},
			{
				name = "Grudge Spawner",
				description = "Loads and runs Grudge Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/arkanzulfadliputra-oss/Entities-Models/refs/heads/main/Mod/Entity/With%20Jumpscare/Grudge.lua"))()
				end,
			},
			{
				name = "Cease (But Bad) Spawner",
				description = "Loads and runs Cease (But Bad) Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/KendrickFan59/privatev2/refs/heads/main/ceaser"))()
				end,
			},
			{
				name = "Virus Spawner",
				subtitle = "Entity Model Made by ItzzGabbb",
				description = "Entity Model Made by ItzzGabbb",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/TestingAcc12312390/Private-Entity/refs/heads/main/Virus-Entity"))()
				end,
			},
			{
				name = "Fear Spawner",
				description = "Loads and runs Fear Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Custom-Entity/refs/heads/main/Fear-Nightmare-Mode"))()
				end,
			},
			{
				name = "350 Spawner",
				description = "Loads and runs 350 Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Junbbinopro/350-entity/refs/heads/main/350"))()
				end,
			},
			{
				name = "G-95 Spawner",
				description = "Loads and runs G-95 Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Junbbinopro/G-95-v2/refs/heads/main/Entity"))()
				end,
			},
			{
				name = "B ∆ B Spawner",
				description = "Loads and runs B ∆ B Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/TestingAcc12312390/Private-Entity/refs/heads/main/B_%E2%88%86_B-Entity-Fixed"))()
				end,
			},
			{
				name = "Hiss Spawner",
				description = "Loads and runs Hiss Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rrealblueyt-oss/Hiss/refs/heads/main/obfuscated_script-1769948042346.lua.txt"))()
				end,
			},
			{
				name = "B-444 Spawner",
				subtitle = "Made by ItzzGabbbb",
				description = "Made by ItzzGabbbb",
				run = function()
loadstring(game:HttpGet("https://pastefy.app/9dkXpSyy/raw"))()
				end,
			},
			{
				name = "A-185 Spawner",
				description = "Loads and runs A-185 Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/TestingAcc12312390/Private-Entity/refs/heads/main/A-185-Entity-Made-By-Someone"))()
				end,
			},
			{
				name = "Ruinator Spawner",
				description = "Loads and runs Ruinator Spawner.",
				run = function()
loadstring(game:HttpGet("https://pastefy.app/zlwFiRuW/raw"))()
				end,
			},
			{
				name = "Trollface Spawner",
				description = "Loads and runs Trollface Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/TestingAcc12312390/Private-Entity/refs/heads/main/Trollface-Entity"))()
				end,
			},
			{
				name = "Rebound Spawner (READ THE DESCRIPTION)",
				subtitle = "Execute Rebound Spawner at door 0 and open the next door",
				description = "Execute Rebound Spawner at door 0 and open the next door",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/ohh/refs/heads/main/Rebound"))()
				end,
			},
			{
				name = "Running Fredbear Spawner",
				description = "Loads and runs Running Fredbear Spawner.",
				run = function()
loadstring(game:HttpGet("https://pastebin.com/raw/wbEc0ThZ"))()
				end,
			},
			{
				name = "Ripper Spawner (Remake)",
				description = "Loads and runs Ripper Spawner (Remake).",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rrealblueyt-oss/Ripperr/refs/heads/main/Ripperremake.lua"))()
				end,
			},
			{
				name = "Frostbite Spawner (Remake)",
				description = "Loads and runs Frostbite Spawner (Remake).",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/back/refs/heads/main/Frostbite1"))()
				end,
			},
			{
				name = "Pim Spawner",
				description = "Loads and runs Pim Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/TestingAcc12312390/Private-Entity/refs/heads/main/Pim-Entitiy-Made-By-TheDarkMan1334-And-Remastered-By-Me"))()
				end,
			},
			{
				name = "A-60 Spawner (Remake)",
				description = "Loads and runs A-60 Spawner (Remake).",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/A-60%20Spawner"))()
				end,
			},
			{
				name = "Ch4s3r_Thre4t Spawner",
				description = "Loads and runs Ch4s3r_Thre4t Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/TestingAcc12312390/Private-Entity/refs/heads/main/Ch4s3r_Thre4t-Entity"))()
				end,
			},
			{
				name = "Cease Spawner (Remake)",
				description = "Loads and runs Cease Spawner (Remake).",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/Cease-Spawner-(Remake)"))()
				end,
			},
			{
				name = "Z-88 Spawner",
				subtitle = "Credit to Burgerware",
				description = "Credit to Burgerware",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/TestingAcc12312390/Private-Entity/refs/heads/main/Z-88-Entity-Made-By-Burgerware"))()
				end,
			},
			{
				name = "Null Spawner",
				description = "Loads and runs Null Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/41450088/refs/heads/main/Null"))()
				end,
			},
			{
				name = "Fear Spawner (Remake)",
				description = "Loads and runs Fear Spawner (Remake).",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/nightmare/refs/heads/main/Fear"))()
				end,
			},
			{
				name = "Distort Spawner",
				description = "Loads and runs Distort Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/localplayerr/Doors-stuff/refs/heads/main/Immersive%20mode/Distort"))()
				end,
			},
			{
				name = "Fabric Spawner",
				description = "Loads and runs Fabric Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/localplayerr/Doors-stuff/refs/heads/main/Immersive%20mode/Fabricility"))()
				end,
			},
			{
				name = "Black Spawner",
				description = "Loads and runs Black Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Junbbinopro/Black-smile/refs/heads/main/Black"))()
				end,
			},
			{
				name = "Claim Spawner",
				description = "Loads and runs Claim Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/Doors-Mode-Remakes/refs/heads/main/Claim.lua"))()
				end,
			},
			{
				name = "Death Spawner",
				description = "Loads and runs Death Spawner.",
				run = function()
loadstring(game:HttpGet("https://github.com/reboundplayz/Doors-Fixed-Modes/raw/refs/heads/main/death"))()
				end,
			},
			{
				name = "Moriarty Spawner",
				description = "Loads and runs Moriarty Spawner.",
				run = function()
loadstring(game:HttpGet("https://github.com/reboundplayz/Doors-Fixed-Modes/raw/refs/heads/main/moriarty"))()
				end,
			},
			{
				name = "Chaotic Spawner",
				description = "Loads and runs Chaotic Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/J63633S/Laver-mode/refs/heads/main/Chaotic"))()
				end,
			},
			{
				name = "Corrode Spawner",
				description = "Loads and runs Corrode Spawner.",
				run = function()
loadstring(game:HttpGet("https://github.com/reboundplayz/Doors-Fixed-Modes/raw/refs/heads/main/corrode"))()
				end,
			},
			{
				name = "Classio-Reboundier Spawner",
				description = "Loads and runs Classio-Reboundier Spawner.",
				run = function()
loadstring(game:HttpGet("https://github.com/reboundplayz/Doors-Fixed-Modes/raw/refs/heads/main/classicorebuondier"))()
				end,
			},
			{
				name = "Dread Spawner (READ THE DESCRIPTION)",
				subtitle = "Execute Dread Spawner at door 0 and open the next door",
				description = "Execute Dread Spawner at door 0 and open the next door",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/talales/Nhankg_/refs/heads/main/intro%20fragmented"))()
				end,
			},
			{
				name = "Ripper Spawner (Made by Gab)",
				description = "Loads and runs Ripper Spawner (Made by Gab).",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/ItzzGabbbb/RipperSpawner/refs/heads/main/RipperEntityFromHardcoreMode.lua"))()
				end,
			},
			{
				name = "Bluyer Spawner",
				description = "Loads and runs Bluyer Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Junbbinopro/Bluyer-entity/refs/heads/main/Bluyer"))()
				end,
			},
			{
				name = "Shocker Spawner",
				description = "Loads and runs Shocker Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Junbbinopro/Shocker-entity/refs/heads/main/Shocker"))()
				end,
			},
			{
				name = "Depth Spawner",
				description = "Loads and runs Depth Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Junbbinopro/Depth-v2/refs/heads/main/Entity"))()
				end,
			},
			{
				name = "Surge Spawner",
				description = "Loads and runs Surge Spawner.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Junbbinopro/Surge-entity/refs/heads/main/Surge"))()
				end,
			},
			{
				name = "Entity Spawner Hub",
				description = "Loads and runs Entity Spawner Hub.",
				run = function()
loadstring(game:HttpGet('https://raw.githubusercontent.com/plamen6789/UtilitiesHub/main/UtilitiesGUI'))()
				end,
			},
			{
				name = "Old Seek",
				description = "Loads and runs Old Seek.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/StovenChaos/Doors/refs/heads/main/Old%20seek.lua"))()
				end,
			},
			{
				name = "A-60 (Chaos Entity)",
				description = "Loads and runs A-60 (Chaos Entity).",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Custom-Entity/refs/heads/main/A-60-Chaos-Entity"))()
				end,
			},
			{
				name = "Noise (Glitch Version Included)",
				description = "Loads and runs Noise (Glitch Version Included).",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Outernal/Doors/refs/heads/main/Noise(IncludeGlitchVersion)"))()
				end,
			},
			{
				name = "Honcho Spawner",
				subtitle = "By Pepo Mods",
				description = "By Pepo Mods",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/bonellocristian78-lab/Gradish-Mode/main/Honcho.lua"))()
				end,
			},
		},
	},
	{
		name = "✨ Items",
		section = "Enjoy these custom items",
		buttons = {
			{
				name = "Guiding Candle (UPDATED)",
				subtitle = "Fixed by Junbbinopro",
				description = "Fixed by Junbbinopro",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Junbbinopro/Guiding-light-candle/refs/heads/main/Candle"))()
				end,
			},
			{
				name = "Golden Gummy Flashlight",
				description = "Loads and runs Golden Gummy Flashlight.",
				run = function()
loadstring(game:HttpGet(("https://raw.githubusercontent.com/aadyian9000/the-thing/main/GoldenGummyFlashlight.lua"),true))()
				end,
			},
			{
				name = "Black Hole (OVERPOWERED)",
				description = "Loads and runs Black Hole (OVERPOWERED).",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/iimateiYT/Scripts/main/Black%20Hole.lua"))()
				end,
			},
			{
				name = "Scroll Of Sevenless",
				description = "Loads and runs Scroll Of Sevenless.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Ahma174/Tool/refs/heads/main/Doors%20Scroll%20Of%20Sevenless.lua"))()
				end,
			},
			{
				name = "Spear (Minecraft Item)",
				subtitle = "Made by Nowhywhats",
				description = "Made by Nowhywhats",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/Spear-Minecraft-Item-Made-By-Nowhywhat"))()
				end,
			},
			{
				name = "Curious Candle",
				subtitle = "Made by Kodbol",
				description = "Made by Kodbol",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/kodbolx/kodbolhub/refs/heads/main/curiouscandle.lua"))()
				end,
			},
			{
				name = "Ambush Plushie",
				description = "Loads and runs Ambush Plushie.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/TestingAcc12312390/Plushie-Item/refs/heads/main/Ambush-Plushie"))()
				end,
			},
			{
				name = "Rush Plushie",
				description = "Loads and runs Rush Plushie.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eliazbp92-collab/Plushie1/refs/heads/main/Rush"))()
				end,
			},
			{
				name = "Gubby Tool",
				subtitle = "Made by Indexell",
				description = "Made by Indexell",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/IdkMyNameLoll/PublicScripts/refs/heads/main/IsThatAGubbyTool"))()
				end,
			},
			{
				name = "Crucifix",
				subtitle = "Made by PenguinManiack",
				description = "Made by PenguinManiack",
				run = function()
loadstring(game:HttpGet('https://raw.githubusercontent.com/PenguinManiack/Crucifix/main/Crucifix.lua'))()
				end,
			},
			{
				name = "Grenade",
				description = "Loads and runs Grenade.",
				run = function()
loadstring(game:HttpGet("https://pastebin.com/raw/zeFBYYy9", true))()
				end,
			},
			{
				name = "Infinite Vitamins",
				description = "Loads and runs Infinite Vitamins.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/MrNeRD0/Doors-Hack/refs/heads/main/Inf_Vitamins.lua"))()
				end,
			},
			{
				name = "Moon Jug (Fixed)",
				subtitle = "Can be helpful sometimes",
				description = "Can be helpful sometimes",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Guestly-Alt/Scripts/refs/heads/main/MoonJug"))()
				end,
			},
			{
				name = "Luger Pistol",
				description = "Loads and runs Luger Pistol.",
				run = function()
loadstring(game:HttpGet("https://pastebin.com/raw/WcYCnACD"))()
				end,
			},
			{
				name = "Rocket Launcher",
				description = "Loads and runs Rocket Launcher.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/persopoiu/scripts/refs/heads/main/RocketLauncher/script.lua"))()
				end,
			},
			{
				name = "Flashlight V1",
				description = "Loads and runs Flashlight V1.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/binhlforsaken156-sys/Flash-light/refs/heads/main/Flash-light-V1", true))()
				end,
			},
			{
				name = "Lucky Block",
				description = "Loads and runs Lucky Block.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/NTTTTTTTT/upload/refs/heads/main/content/5d91c0185bdc4dd5b80c84c50d8ba78e_obf.lua",true))()
				end,
			},
			{
				name = "Spiral Bottle",
				description = "Loads and runs Spiral Bottle.",
				run = function()
loadstring(game:HttpGet('https://gist.githubusercontent.com/IdkMyNameLoll/8b05c837bea9effac2554340465b4be1/raw/3f3be0ee72e7f153db39a16a40fa63dce6cde72d/SpiralBottle'))()
				end,
			},
			{
				name = "Foundation Crucifix",
				subtitle = "It can crucify any object you just need to click on any object",
				description = "It can crucify any object you just need to click on any object",
				run = function()
_G.CR_Uses = 1000000
_G.CR_IsCurious = false
_G.CR_HoldKeyRequired = "false"

loadstring(game:HttpGet("https://raw.githubusercontent.com/IdkMyNameLoll/PublicScripts/refs/heads/main/crucifix_E_A_A"))()
				end,
			},
			{
				name = "A-60 Plushie",
				description = "Loads and runs A-60 Plushie.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/TestingAcc12312390/Plushie-Item/refs/heads/main/A-60-Plushie"))()
				end,
			},
			{
				name = "A-90 Plushie",
				description = "Loads and runs A-90 Plushie.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eliazbp92-collab/Plushie1/refs/heads/main/A-90"))()
				end,
			},
			{
				name = "Lucky Cookie",
				description = "Loads and runs Lucky Cookie.",
				run = function()
loadstring(game:HttpGet("https://pastefy.app/TefMKs39/raw"))()
				end,
			},
			{
				name = "Guiding Flashlight",
				description = "Loads and runs Guiding Flashlight.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/binhlforsaken156-sys/Guiding-flash-light/refs/heads/main/Guiding-flash-light.lua", true))()
				end,
			},
			{
				name = "Viridislight Jug",
				description = "Loads and runs Viridislight Jug.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Not-Guestly/Scripts/refs/heads/main/Viridislight-Jug"))()
				end,
			},
			{
				name = "Jeff's Tip Jar",
				description = "Loads and runs Jeff's Tip Jar.",
				run = function()
loadstring(game:HttpGet("https://pastebin.com/raw/Hsuiugnr"))()
				end,
			},
			{
				name = "Troll Crucifix",
				description = "Loads and runs Troll Crucifix.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/TestingAcc12312390/Other-Item-Scripts/refs/heads/main/Troll-Crucifix"))()
				end,
			},
			{
				name = "Moonlight Bottle",
				description = "Loads and runs Moonlight Bottle.",
				run = function()
loadstring(game:HttpGet('https://gist.githubusercontent.com/IdkMyNameLoll/04d7dd5e02688624b958b8c2604b924c/raw/9e86b34249f44ed2dd433176e67daaf3db30cde8/MoonBottle'))()
				end,
			},
			{
				name = "Shedletsky Egg (Eggletsky)",
				description = "Loads and runs Shedletsky Egg (Eggletsky).",
				run = function()
--[[
WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local tool = game:GetObjects("rbxassetid://74933357788345")[1]
tool.Parent = player:WaitForChild("Backpack")

local animationId = "rbxassetid://6516424098"
local animTrack

tool.Equipped:Connect(function()
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

if animTrack then
animTrack:Stop(0)
animTrack:Destroy()
animTrack = nil
end

local animation = Instance.new("Animation")
animation.AnimationId = animationId

animTrack = animator:LoadAnimation(animation)
animTrack.Priority = Enum.AnimationPriority.Action4
animTrack.Looped = true
animTrack:Play(0, 1, 1)
animTrack:AdjustWeight(1)
end)

tool.Unequipped:Connect(function()
if animTrack then
animTrack:Stop(0)
animTrack:Destroy()
animTrack = nil
end
end)
				end,
			},
			{
				name = "Viridis Lighter (Need Lighter)",
				description = "Loads and runs Viridis Lighter (Need Lighter).",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/kodbolx/kodbolhub/refs/heads/main/Items/Viridis%20lighter.lua"))()
				end,
			},
			{
				name = "Lantern Item",
				description = "Loads and runs Lantern Item.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Junbbinopro/Item/refs/heads/main/lantern"))()
				end,
			},
			{
				name = "Spiral Jug (Fixed)",
				description = "Loads and runs Spiral Jug (Fixed).",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Guestly-Alt/Scripts/refs/heads/main/Spiral-Jug"))()
				end,
			},
			{
				name = "Flame Thrower",
				subtitle = "Credit to JohnyGaming#2917",
				description = "Credit to JohnyGaming#2917",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/JohnyGamingLUA/FlamethrowerDOORS/main/obfuscated.lua"))()
				end,
			},
			{
				name = "Grass Tablet",
				description = "Loads and runs Grass Tablet.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Matthew201322/Doors-Scriptee/refs/heads/main/grass%20tablet.lua"))()
				end,
			},
			{
				name = "Seek Plushie",
				description = "Loads and runs Seek Plushie.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/Seek-Plushie"))()
				end,
			},
			{
				name = "Screech Plushie",
				description = "Loads and runs Screech Plushie.",
				run = function()
loadstring(game:HttpGet("https://pastebin.com/raw/CRYiKPZX"))()
				end,
			},
			{
				name = "Viridislight Bottle",
				description = "Loads and runs Viridislight Bottle.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Not-Guestly/Scripts/refs/heads/main/Viridislight-Bottle"))()
				end,
			},
			{
				name = "Purple Shakelight",
				description = "Loads and runs Purple Shakelight.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/thelostw3r/Scripts/refs/heads/main/PurpleFlashlight.lua"))()
				end,
			},
			{
				name = "Forsaken Tools",
				description = "Loads and runs Forsaken Tools.",
				run = function()
loadstring(game:HttpGet("https://rawscripts.net/raw/DOORS-DAILY-RUNS-forsaken-useless-tool-pack-94779"))()
				end,
			},
			{
				name = "Maxwell Tool",
				description = "Loads and runs Maxwell Tool.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/CastiSeek/Maxwell-the-cat-script/refs/heads/main/main.lua"))()
				end,
			},
			{
				name = "Rebound Plushie",
				description = "Loads and runs Rebound Plushie.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/TestingAcc12312390/Plushie-Item/refs/heads/main/Rebound-Plushie"))()
				end,
			},
			{
				name = "Magic Book",
				description = "Loads and runs Magic Book.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/skkenrgjt/HAHAHAH/refs/heads/main/MagicRunner"))()
				end,
			},
			{
				name = "Admin Slap",
				subtitle = "Made by Guestly (Celestian)",
				description = "Made by Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/GuestlyTheGreatestGuest/Scripts/refs/heads/main/Admin-Slap-For-DOORS-made-by-Celestian-(Guestly)-on-Discord"))()
				end,
			},
			{
				name = "Seek Gun",
				description = "Loads and runs Seek Gun.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/persopoiu/scripts/main/seekgun.lua"))()
				end,
			},
			{
				name = "NVCS-3000",
				description = "Loads and runs NVCS-3000.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/thelostw3r/Scripts/main/NVCS-3000.lua"))()
				end,
			},
			{
				name = "M249 Gun",
				description = "Loads and runs M249 Gun.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/hi822010/Extras-Gliese-Hub-Doors/refs/heads/main/M249"))()
				end,
			},
			{
				name = "AK-47 Gun",
				description = "Loads and runs AK-47 Gun.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/ItzzGabbbb/AK47Fixed/refs/heads/main/Ak47ByPenguinManiackFixedByGab.lua"))()
				end,
			},
			{
				name = "Tool Giver V3 | Doors",
				subtitle = "Darli17",
				description = "Darli17",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Darli17/Entities/refs/heads/main/Tools", true))()
				end,
			},
			{
				name = "RobHub X Item Giver",
				description = "Loads and runs RobHub X Item Giver.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Darli17/DOORS-REBOUNCES/refs/heads/main/main-ig"))()
				end,
			},
			{
				name = "Barrel Of Starlight",
				description = "Loads and runs Barrel Of Starlight.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/notpoiu/Scripts/refs/heads/main/StarJug.lua"))()
				end,
			},
			{
				name = "Mischievous Crucifix",
				description = "Loads and runs Mischievous Crucifix.",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Teilsthebfdifan/Modhub-assets/refs/heads/main/MischievousV2Test.lua"))()
				end,
			},
			{
				name = "Size Stick (UPDATED)",
				description = "Loads and runs Size Stick (UPDATED).",
				run = function()
loadstring(game:HttpGet("https://pastefy.app/dy85jtB6/raw"))()
				end,
			},
			{
				name = "Glitch Crucifix Effect (EPILEPSY WARNING)",
				subtitle = "⚠️ Epilepsy warning • does NOT give you a crucifix",
				description = "EPILEPSY WARNING. Adds a glitch effect to the crucifix. Does NOT give you a crucifix, but applies the effect if you get one.",
				confirm = true,
				confirmText = "⚠️ EPILEPSY WARNING: this adds a glitch effect to the crucifix. Don't run it if flashing or glitchy effects can affect you. It does NOT give you a crucifix. Run it anyway?",
				run = function()
loadstring(game:HttpGet("https://pastefy.app/ptp98dnD/raw"))()
				end,
			},
		},
	},
	{
		name = "💔 Modes 2",
		section = "Second section of modes",
		buttons = {
			{
				name = "Hardcore Mode (Remastered)",
				subtitle = "Credit to someone that idk",
				description = "Credit to someone that idk",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/daiayday/HardcoreRemastered/refs/heads/main/obf_L6zO2N0sG5ehDHd56JBc5z70TZ2piVOvIqsgE88741HXGrwv7E4qd6c8axu8z4oh.lua.txt"))()
				end,
			},
			{
				name = "Fragmented Mode (Recreation??)",
				subtitle = "Recreation By THE_LOSTW3R",
				description = "Recreation By THE_LOSTW3R",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/thelostw3r/Mods/refs/heads/main/FragmentedModeRemake.lua"))()
				end,
			},
			{
				name = "Impossible Mode (Remastered)",
				subtitle = "Made by Neko tiv (Chu be te liet) & RealblueYT",
				description = "Made by Neko tiv (Chu be te liet) & RealblueYT",
				run = function()
loadstring(game:HttpGet("https://pastefy.app/iH9k0iU9/raw"))()
				end,
			},
			{
				name = "Laver Mode V2.1 (Fixed)",
				subtitle = "Fixed By Reboundplayz",
				description = "Fixed By Reboundplayz",
				run = function()
loadstring(game:HttpGet("https://github.com/reboundplayz/Doors-Fixed-Modes/raw/refs/heads/main/laver%20mode"))()
				end,
			},
			{
				name = "Nightmare Mode V2",
				subtitle = "Made By Kodbol & Asif",
				description = "Made By Kodbol & Asif",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kodbol/Doors/refs/heads/main/Nightmare%20Mode/Main.lua"))()
				end,
			},
			{
				name = "Hardcore Mode (Revisited)",
				subtitle = "Made by Reboundplayz",
				description = "Made by Reboundplayz",
				run = function()
loadstring(game:HttpGet("https://github.com/reboundplayz/Doors-Fixed-Modes/raw/refs/heads/main/hc%20revisited"))()
				end,
			},
			{
				name = "Rooms Low Detailed Mode",
				subtitle = "Made by Rebound",
				description = "Made by Rebound",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eliazbp92-collab/Rooms-low-detailed-mode-doors/refs/heads/main/Script"))()
				end,
			},
			{
				name = "Extremely Mode",
				subtitle = "Made by OG Hunger (New) & Thanhpok",
				description = "Made by OG Hunger (New) & Thanhpok",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/Extremely/refs/heads/main/Extremely%20Mode"))()
				end,
			},
			{
				name = "Terminated Mode",
				subtitle = "Made By UnknownReturnz",
				description = "Made By UnknownReturnz",
				run = function()
loadstring(game:HttpGet("https://pastefy.app/hT2Q5AKa/raw"))()
				end,
			},
			{
				name = "Chaos Mode V1",
				subtitle = "Credit to DJ SD (Tunder8401)",
				description = "Credit to DJ SD (Tunder8401)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Tunder8401/Doors-Modes/refs/heads/main/Chaos%20Mode"))()
				end,
			},
			{
				name = "Eyes Mode (Gamble)",
				subtitle = "Made By Guestly, also get rare eyes to get a CW",
				description = "Made By Guestly, also get rare eyes to get a CW",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Guestly-Alt/Scripts/refs/heads/main/EYES-MODE"))()
				end,
			},
			{
				name = "Snuffer Mode",
				subtitle = "Made By Anctarus7105",
				description = "Made By Anctarus7105",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Anctarus7105/My-Modes/refs/heads/main/SnufferV1.lua"))()
				end,
			},
			{
				name = "Blackout Mode",
				subtitle = "Made By Rip_Silence",
				description = "Made By Rip_Silence",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/Blackout-Mode-Main.lua"))()
				end,
			},
			{
				name = "Unhinged Mode",
				subtitle = "Made By Rip_Silence",
				description = "Made By Rip_Silence",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/Unhinged-Mode-Main.lua"))()
				end,
			},
			{
				name = "Ghostly Mode",
				subtitle = "Made By Anctarus7105",
				description = "Made By Anctarus7105",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Anctarus7105/My-Modes/refs/heads/main/Ghostly.lua"))()
				end,
			},
			{
				name = "Infection Mode",
				subtitle = "Made By Leo -LXD-",
				description = "Made By Leo -LXD-",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/TestingAcc12312390/Doors-Hub/refs/heads/main/Infection-Mode-Made-By-Leo"))()
				end,
			},
			{
				name = "Dormant Mode",
				subtitle = "Made By Idk.chud",
				description = "Made By Idk.chud",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/TestingAcc12312390/Other-Modes-Script/refs/heads/main/Dormant-Mode-Made-By-Chud"))()
				end,
			},
			{
				name = "Mega Hard Mode",
				subtitle = "Made By UnknownReturnz",
				description = "Made By UnknownReturnz",
				run = function()
loadstring(game:HttpGet("https://pastefy.app/jGU3jxSe/raw"))()
				end,
			},
			{
				name = "Broken Mode (Fixed)",
				subtitle = "Made by TheDarkMan1334",
				description = "Made by TheDarkMan1334",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/Broken-Mode-V1.8-Fixed-Version"))()
				end,
			},
			{
				name = "Mayhem Mode (Remake)",
				subtitle = "Made By OG Hunger (New)",
				description = "Made By OG Hunger (New)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/Mayhem-Remake/refs/heads/main/Mayhem%20Remake"))()
				end,
			},
			{
				name = "Grace Mode (Remake)",
				subtitle = "Credit to someone that idk",
				description = "Credit to someone that idk",
				run = function()
loadstring(game:HttpGet("https://github.com/IdkMyNameLoll/PublicScripts/raw/refs/heads/main/DoorsXGrace.lua", true))()
				end,
			},
			{
				name = "Super Crazy Mode",
				subtitle = "Credit to Dt_roblx doors:))",
				description = "Credit to Dt_roblx doors:))",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme2/dm123/refs/heads/main/super%20crazy%20mode"))()
				end,
			},
			{
				name = "Dark Passage Mode",
				subtitle = "Made By Rebound",
				description = "Made By Rebound",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eliazbp92-collab/Dark-passage-mode/refs/heads/main/Script"))()
				end,
			},
			{
				name = "Hardcore Mode (Retake)",
				subtitle = "Made by Purple Hatso",
				description = "Made by Purple Hatso",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/Hardcore-Mode-(Retake)"))()
				end,
			},
			{
				name = "Impossible Mode V2 (Remastered)",
				subtitle = "Made By RealblueYT",
				description = "Made By RealblueYT",
				run = function()
loadstring(game:HttpGet("https://pastefy.app/NLdC5hRo/raw"))()
				end,
			},
			{
				name = "Fragmented Mode (Reignited)",
				subtitle = "Made by OG Hunger (New)",
				description = "Made by OG Hunger (New)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eoyoustme/Fragmentend-Reiginited/refs/heads/main/Fragmented%20Reiginited"))()
				end,
			},
			{
				name = "Hardcore Reignited Mode (Recreated)",
				subtitle = "Credit to Guestly (Celestian)",
				description = "Credit to Guestly (Celestian)",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Guestly-Alt/Scripts/refs/heads/main/Hardcore-Reignited-(Recreated)"))()
				end,
			},
			{
				name = "Negative Mode",
				subtitle = "Made by Rebound",
				description = "Made by Rebound",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/eliazbp92-collab/WHAT-IS-A-SOILD-OCTO-ROTRAY-PHONE-/refs/heads/main/Script"))()
				end,
			},
			{
				name = "Mental Mode",
				subtitle = "Made By TheLastOne",
				description = "Made By TheLastOne",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/TheLastOne5778/Read/refs/heads/main/Mental%20Mode"))()
				end,
			},
			{
				name = "Abyss Mode",
				subtitle = "Made By Grampy",
				description = "Made By Grampy",
				run = function()
loadstring(game:HttpGet('https://raw.githubusercontent.com/GrampyMods/AbyssMode/refs/heads/main/mainfile'))()
				end,
			},
			{
				name = "Ice Mode",
				subtitle = "Made by RealblueYT",
				description = "Made by RealblueYT",
				run = function()
loadstring(game:HttpGet("https://pastefy.app/vpHzXSDy/raw"))()
				end,
			},
			{
				name = "Super Packed Mode",
				subtitle = "Credit to Zunxd",
				description = "Credit to Zunxd",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Junbbinopro/Doors-sieu-don-mode/refs/heads/main/Modeee"))()
				end,
			},
			{
				name = "Hardcore Mode (Degenerate)",
				subtitle = "Made by RealblueYT",
				description = "Made by RealblueYT",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rrealblueyt-oss/Hardcore-degenerate/refs/heads/main/hardcore%20degenerate.txt"))()
				end,
			},
			{
				name = "Fragmented Mode Alpha (Recreation)",
				subtitle = "Made by Hello Im Rippah",
				description = "Made by Hello Im Rippah",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/brylesantos38-cell/FragmentedModeAlphaRecreation/refs/heads/main/obfuscated_script-1783648290063.lua.txt"))()
				end,
			},
			{
				name = "Hallucination Mode (IMPOSSIBLE VERSION⚠️⚠️⚠️)",
				subtitle = "Credit to Guestly (Celestian) and Rip_Silence",
				description = "Credit to Guestly (Celestian) and Rip_Silence",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Hallucination-Mode-SUPER-IMPOSSIBLE-/refs/heads/main/Hallucination%20Mode%20(IMPOSSIBLE)"))()
				end,
			},
			{
				name = "Improbable Mode Final Version (IMPOSSIBLE⚠️⚠️⚠️)",
				subtitle = "Credits to Chu be the liet & AmadeyHunter & Rip_Silence",
				description = "Credits to Chu be the liet & AmadeyHunter & Rip_Silence",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Doors-Modes/refs/heads/main/Improbable-Mode-Final-Version"))()
				end,
			},
			{
				name = "Impossible Mode V1.8 (Alpha)",
				subtitle = "⚠️ Kinda broken • Credit to Oof",
				description = "Impossible Mode V1.8 (Alpha) by Oof. Heads up: this one is kinda broken, so some parts may not work right.",
				confirm = true,
				confirmText = "⚠️ This mode is kinda broken (alpha version). Some things may not work right. Run it anyway?",
				run = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/NTTTTTTTT/upload/refs/heads/main/content/eaeb44fe563342b38ab1f6ee9735e584_obf.lua", true))()
				end,
			},
		},
	},
}

local UPDATE_LOGS = {
	"1. Updated Hardcore Reignited Mode (Recreated) In Modes 2 Section",
	"2. Updated WH1T3 Spawner (Remake) In Entity Spawner Section",
	"3. Updated Broken Mode (Fixed) In Modes 2 Section",
	"4. Replaced Furry Mode (Remake) With Stalker Mode",
	"5. Added Twister Spawner (Phase 1) In Entity Spawner Section",
	"6. Added A-100 Spawner In Entity Spawner Section",
	"7. Added Obsession Spawner (Remake) In Entity Spawner Section",
	"8. Added A-75 Spawner In Entity Spawner Section",
	"9. Added Rooms Low Detailed Mode In Modes 2 Section",
	"10. Replaced Scamer Mode With Zombie Mode In Modes Section",
	"11. Added A-60 Plushie In Custom Item Section",
	"12. Added A-185 Spawner In Entity Spawner Section",
	"13. Added Rebound Plushie In Custom Item Section",
	"14. Added A-90 Plushie In Custom Item Section",
	"15. Replaced Lunacy Mode (Remake) With Schizophrenia Mode",
	"16. Added Ambush Plushie In Custom Item Section",
	"17. Added Rush Plushie In Custom Item Section",
	"18. Added Pim Spawner In Entity Spawner Section",
	"19. Added Rainbow Room In Extra Section",
	"20. Added Negative Mode In Modes 2 Section",
	"21. Added Dark Passage Mode In Modes 2 Section",
	"22. Added Doors Hub + Editor (Beta) In Other Script Section",
	"23. Added Questioner Spawner In Entity Spawner Section",
	"24. Added Terminated Mode In Modes 2 Section",
	"25. Added Impossible Mode V2 (Remastered) In Modes 2 Section",
	"26. Added B ∆ B Spawner In Entity Spawner Section",
	"27. Added Snuffer Mode In Modes 2 Section",
	"28. Added Ch4s3r_Thre4t Spawner In Entity Spawner Section",
	"29. Added Mayhem Mode (Remake) In Modes 2 Section",
	"30. Added Dormant Mode In Modes 2 Section",
	"31. Added Mayhem Mode (Legacy) In Legacy Mode Section",
	"32. Added Ghostly Mode In Modes 2 Section",
	"33. Added Mega Hard Mode In Modes 2 Section",
	"34. Added Maxwell Tool In Custom Item Section",
	"35. Added Troll Crucifix In Custom Item Section",
	"36. Big update, WH1T3 (relayhost) Helped on changing the whole GUI,Removed Locked/Deleted scripts (Fear Mode, Hard Mode, Water Rises Mode, Furry Mode),new Tools tab, Most Used, Script of the day, smarter script runner, mobile support (on-screen buttons) + keybinds you can turn on/off, languages (English, Español, Português, Français), Added Endless Mode (eliazbp92) In Modes Section, Old Seek + A-60 (Chaos Entity) In Entity Spawner Section, and Impossible Mode V1.8 (Alpha) In Modes 2 Section",
	"37. Added Noise (Glitch Version Included) In Entity Spawner Section, Purple Shakelight (All Rifts) In Extra Section, Twinkhook Hub (God Mode) In Hubs Section",
	"38. Added Honcho Spawner In Entity Spawner Section, Glitch Crucifix Effect In Custom Item Section, Hardcore Mode (VERY OLD), Gradish Mode and Hardcore Mode (Retake Plus) In Modes Section",
	"39. GUI V10: NEW badges, sort buttons, tab counts, Notes tab, hide hub after running, FOV slider + FPS boost, debug info, shuffle + resume music, 3 new colors, friendlier errors, all translated"
}
-- People shown in the "Credits" tab
-- (subtitle = short line under the name, description = shown in the details)
local CREDITS = {
	{
		name = "Silence",
		icon = "👑",
		subtitle = "Hub creator (Rip_Silence)",
		description = "Creator of the Doors Modes Hub and very cool guy.",
	},
	{
		name = "Greed_GamingMobile",
		icon = "💡",
		subtitle = "Inspiration",
		description = "This hub is inspired from Greed_GamingMobile's hub.",
	},
	{
		name = "RealblueYT",
		icon = "📝",
		subtitle = "Sign text in chat",
		description = "Credit to RealblueYT for the sign text in chat.",
	},
	{
		name = "WH1T3 (GUI Creator)",
		icon = "👁️",
		subtitle = "Created the hub's GUI",
		description = "Creator and designer of the Halloween-themed GUI of the Doors Modes Hub.",
	},
	{
		name = "WH1T3 (V36 GUI Update)",
		icon = "🚀",
		subtitle = "Directed the GUI changes of V36",
		description = "Asked for and directed the V36 GUI upgrades: Tools tab, Most Used, Panic button and mobile controls.",
	},
	{
		name = "WH1T3 (Mobile Support)",
		icon = "📱",
		subtitle = "Pushed for phone & tablet support",
		description = "Made sure the hub works well on phones: on-screen buttons that replace the keybinds.",
	},
	{
		name = "Incognito",
		icon = "❤️",
		subtitle = "Helper of some code of the GUI/HUB",
		description = "A helper that makes the code behind some things of the GUI, likes pumpkins. 🎃",
	},
	{
		name = "You!",
		icon = "🫵",
		subtitle = "Thanks for executing the hub",
		description = "Credit to You! (For Executing My Hub)",
	},
}

--==================================================================
-- (You can stop editing here, the rest is the engine.)
--==================================================================

-- SAVED DATA (favorites, playlist, settings). Needs writefile/readfile;
-- without them everything still works, it just isn't remembered.
local HttpService = game:GetService("HttpService")
local SAVE_FILE = "HalloweenHub_v6_save.json"
local saved = {
	favorites = {},
	playlist = {},
	notifications = true,
	confirm = false,
	loop = true,
	runs = {},
	accent = "Pumpkin",
	antiAfk = true,
	keybinds = true,
	sort = "default",
	autoHide = false,
	shuffle = false,
	notes = "",
	streak = 0,
	bestStreak = 0,
	lastDay = "",
	rainbow = false,
	sparkles = true,
}

-- Load only recognized fields and validate their types. A corrupted or
-- manually edited save file should never replace settings with bad values.
pcall(function()
	if isfile and readfile and isfile(SAVE_FILE) then
		local ok, data = pcall(function()
			return HttpService:JSONDecode(readfile(SAVE_FILE))
		end)

		if ok and type(data) == "table" then
			if type(data.favorites) == "table" then
				saved.favorites = data.favorites
			end
			if type(data.playlist) == "table" then
				saved.playlist = data.playlist
			end
			if type(data.notifications) == "boolean" then
				saved.notifications = data.notifications
			end
			if type(data.confirm) == "boolean" then
				saved.confirm = data.confirm
			end
			if type(data.loop) == "boolean" then
				saved.loop = data.loop
			end
			if type(data.runs) == "table" then
				for k, v in pairs(data.runs) do
					if type(k) == "string" and type(v) == "number" then
						saved.runs[k] = v
					end
				end
			end
			if type(data.lang) == "string" then
				saved.lang = data.lang
			end
			if type(data.keybinds) == "boolean" then
				saved.keybinds = data.keybinds
			end
			if type(data.quickBar) == "boolean" then
				saved.quickBar = data.quickBar
			end
			if type(data.accent) == "string" then
				saved.accent = data.accent
			end
			if type(data.antiAfk) == "boolean" then
				saved.antiAfk = data.antiAfk
			end
			if type(data.sort) == "string" then
				saved.sort = data.sort
			end
			if type(data.autoHide) == "boolean" then
				saved.autoHide = data.autoHide
			end
			if type(data.shuffle) == "boolean" then
				saved.shuffle = data.shuffle
			end
			if type(data.autoplay) == "boolean" then
				saved.autoplay = data.autoplay
			end
			if type(data.seenV12) == "boolean" then
				saved.seenV12 = data.seenV12
			end
			if type(data.rainbow) == "boolean" then
				saved.rainbow = data.rainbow
			end
			if type(data.sparkles) == "boolean" then
				saved.sparkles = data.sparkles
			end
			if type(data.seenV11) == "boolean" then
				saved.seenV11 = data.seenV11
			end
			if type(data.streak) == "number" then
				saved.streak = math.max(0, math.floor(data.streak))
			end
			if type(data.bestStreak) == "number" then
				saved.bestStreak = math.max(0, math.floor(data.bestStreak))
			end
			if type(data.lastDay) == "string" then
				saved.lastDay = data.lastDay:sub(1, 10)
			end
			if type(data.seenV10) == "boolean" then
				saved.seenV10 = data.seenV10
			end
			if type(data.notes) == "string" then
				saved.notes = data.notes:sub(1, 4000)
			end
			if type(data.volume) == "number" then
				saved.volume = math.clamp(data.volume, 0, 100)
			end
			if type(data.last) == "table" then
				saved.last = data.last
			end
		end
	end
end)

local function saveData()
	pcall(function()
		if writefile then
			writefile(SAVE_FILE, HttpService:JSONEncode(saved))
		end
	end)
end

local saveToken = 0
local function saveSoon() -- for sliders: saves 1s after you stop moving
	saveToken += 1
	local mine = saveToken
	task.delay(1, function()
		if mine == saveToken then
			saveData()
		end
	end)
end

-- LANGUAGES (English, Spanish, Portuguese, French). Settings > Language to change it.
-- First run uses your Roblox language automatically. Script names stay as they are.
local LANGS = {
	{ code = "en", name = "English" },
	{ code = "es", name = "Español" },
	{ code = "pt", name = "Português" },
	{ code = "fr", name = "Français" },
}
local TRANSLATIONS = {
	es = {
		["🏠 Home"] = "🏠 Inicio",
		["⭐ Favorites"] = "⭐ Favoritos",
		["🔎 Search"] = "🔎 Buscar",
		["🎵 Music"] = "🎵 Música",
		["🎃 Effects"] = "🎃 Efectos",
		["🧰 Tools"] = "🧰 Herramientas",
		["⚙️ Settings"] = "⚙️ Ajustes",
		["📜 Updates"] = "📜 Novedades",
		["😄 Credits"] = "😄 Créditos",
		["🔪 Modes"] = "🔪 Modos",
		["🌹 OG Modes"] = "🌹 Modos OG",
		["😈 Legacy"] = "😈 Clásicos",
		["⚠️ Entities"] = "⚠️ Entidades",
		["✨ Items"] = "✨ Objetos",
		["💔 Modes 2"] = "💔 Modos 2",
		["Have Fun With These Modes"] = "Diviértete con estos modos",
		["Very Cool Things"] = "Cosas muy geniales",
		["Only works in Super Hard Mode"] = "Solo funciona en Super Hard Mode",
		["Enjoy these scripts"] = "Disfruta estos scripts",
		["Only works in Hotel-"] = "Solo funciona en Hotel-",
		["Custom Entity Spawner"] = "Spawner de entidades personalizadas",
		["Enjoy these custom items"] = "Disfruta estos objetos personalizados",
		["Second section of modes"] = "Segunda sección de modos",
		["WELCOME"] = "BIENVENIDO",
		["✨ SCRIPT OF THE DAY"] = "✨ SCRIPT DEL DÍA",
		["⭐ FAVORITES"] = "⭐ FAVORITOS",
		["🔥 MOST USED"] = "🔥 MÁS USADOS",
		["🕘 RECENTLY RUN"] = "🕘 EJECUTADOS RECIENTEMENTE",
		["NOW PLAYING"] = "REPRODUCIENDO",
		["PLAY ANY AUDIO ID"] = "REPRODUCE CUALQUIER ID DE AUDIO",
		["SETTINGS"] = "AJUSTES",
		["📻 YOUR PLAYLIST"] = "📻 TU PLAYLIST",
		["SPOOKY STUFF"] = "COSAS TERRORÍFICAS",
		["SESSION"] = "SESIÓN",
		["EXECUTOR CHECK"] = "REVISIÓN DEL EXECUTOR",
		["DATA"] = "DATOS",
		["UI"] = "INTERFAZ",
		["CONTROLS (PC + MOBILE)"] = "CONTROLES (PC + MÓVIL)",
		["LOOK"] = "APARIENCIA",
		["THE TEAM"] = "EL EQUIPO",
		["WHAT'S NEW IN V36"] = "NOVEDADES DE LA V36",
		["SCRIPT UPDATE LOG"] = "REGISTRO DE ACTUALIZACIONES",
		["the 🎃 button"] = "el botón 🎃",
		["Hey %s! %d scripts loaded. Tap the 🎃 or press %s to show/hide. Search all scripts in 🔎, keep your best ones in ⭐, and paste any audio ID in 🎵."] = "¡Hola %s! %d scripts cargados. Toca la 🎃 o presiona %s para mostrar/ocultar. Busca todos los scripts en 🔎, guarda los mejores en ⭐ y pega cualquier ID de audio en 🎵.",
		["Session"] = "Sesión",
		["📈 All-time scripts run: %d"] = "📈 Scripts ejecutados en total: %d",
		["Nothing here yet. Tap the ⋮ on any script and choose ⭐ Favorite."] = "Aún no hay nada. Toca los ⋮ de un script y elige ⭐ Favorito.",
		["Your top scripts show up here after you run a few."] = "Tus scripts más usados aparecerán aquí cuando ejecutes algunos.",
		["Scripts you run show up here."] = "Los scripts que ejecutes aparecerán aquí.",
		["Type at least 2 letters to search every tab at once."] = "Escribe al menos 2 letras para buscar en todas las pestañas a la vez.",
		["Nothing found for \"%s\"."] = "No se encontró nada para \"%s\".",
		["Showing the first 40. Type more letters to narrow it down."] = "Mostrando los primeros 40. Escribe más letras para filtrar.",
		["🔍 Search %d scripts or creators..."] = "🔍 Buscar entre %d scripts o creadores...",
		["🔎 Search all %d scripts or creators..."] = "🔎 Buscar en los %d scripts o creadores...",
		["Loading %d scripts..."] = "Cargando %d scripts...",
		["Ran %dx"] = "Ejecutado %dx",
		["Nothing selected yet.\nPaste an audio ID below and tap Play."] = "Nada seleccionado aún.\nPega un ID de audio abajo y toca Reproducir.",
		["🎵 Paste audio ID or link..."] = "🎵 Pega un ID o enlace de audio...",
		["▶ Play"] = "▶ Reproducir",
		["💾 Save"] = "💾 Guardar",
		["Background music"] = "Música de fondo",
		["Turns the music on or off. The 🎵 button in the title bar does the same thing."] = "Activa o desactiva la música. El botón 🎵 de la barra superior hace lo mismo.",
		["Loop this song"] = "Repetir esta canción",
		["ON = the song repeats forever. OFF = it moves on to the next song in your playlist when it ends."] = "ON = la canción se repite siempre. OFF = pasa a la siguiente de tu playlist al terminar.",
		["Music volume"] = "Volumen de la música",
		["How loud the music is (0 = silent, 100 = max)."] = "Qué tan fuerte suena la música (0 = silencio, 100 = máx.).",
		["Where to get IDs: Creator Store > Audio, open a song and copy the number (or the whole link) from the page. Some audio is private and won't play. Tap 💾 Save to keep a song in 📻 Playlist."] = "Dónde conseguir IDs: Creator Store > Audio, abre una canción y copia el número (o el enlace completo) de la página. Algunos audios son privados y no suenan. Toca 💾 Guardar para guardar una canción en 📻 Playlist.",
		["Empty. Play an ID in the 🎵 tab, then tap 💾 Save."] = "Vacía. Reproduce un ID en la pestaña 🎵 y toca 💾 Guardar.",
		["Tap the song to play it. Use Remove to delete it from your playlist."] = "Toca la canción para reproducirla. Usa Quitar para borrarla de tu playlist.",
		["🗑 Remove"] = "🗑 Quitar",
		["Removed from playlist"] = "Quitada de la playlist",
		["Floating bats"] = "Murciélagos flotantes",
		["Little bats fly across your screen. Purely decoration."] = "Pequeños murciélagos vuelan por tu pantalla. Solo decoración.",
		["Pumpkin rain"] = "Lluvia de calabazas",
		["Makes pumpkins fall from the top of the screen for a few seconds."] = "Hace caer calabazas desde arriba de la pantalla unos segundos.",
		["Stops Roblox from kicking you for being idle (20 min). Great for long runs. Saved."] = "Evita que Roblox te expulse por inactividad (20 min). Ideal para partidas largas. Se guarda.",
		["Panic (hide everything)"] = "Pánico (ocultar todo)",
		["Instantly hides the hub and the pumpkin and stops the music. Press it again, the End key, or tap the faint dot in the top-left corner to bring everything back."] = "Oculta al instante el hub y la calabaza y detiene la música. Púlsalo otra vez, usa la tecla End o toca el puntito tenue de la esquina superior izquierda para volver a mostrar todo.",
		["Rejoin server"] = "Reentrar al servidor",
		["Teleports you back into this same game."] = "Te teletransporta de nuevo a este mismo juego.",
		["Rejoin this game? You'll leave the current server."] = "¿Reentrar a este juego? Saldrás del servidor actual.",
		["Copies the place id and this server's job id (needs setclipboard)."] = "Copia el place id y el job id de este servidor (necesita setclipboard).",
		["📋 Copied!"] = "📋 ¡Copiado!",
		["FPS cap"] = "Límite de FPS",
		["Changes your max FPS (needs setfpscap)."] = "Cambia tu máximo de FPS (necesita setfpscap).",
		["If a script button fails, check the ❌ above first."] = "Si un script falla, revisa primero las ❌ de arriba.",
		["Reset favorites & stats"] = "Borrar favoritos y estadísticas",
		["Clears your favorites and the Most used counters. Playlist and settings stay."] = "Borra tus favoritos y los contadores de Más usados. La playlist y los ajustes se mantienen.",
		["Clear all favorites and run counts?"] = "¿Borrar todos los favoritos y contadores?",
		["🧹 Cleared"] = "🧹 Borrado",
		["Notifications"] = "Notificaciones",
		["Turns the little popup messages in the corner on or off."] = "Activa o desactiva los mensajitos de la esquina.",
		["Confirm before running"] = "Confirmar antes de ejecutar",
		["When ON, every script button asks 'Are you sure?' before it runs. Handy to avoid misclicks on a phone."] = "Si está ON, cada botón de script pregunta '¿Seguro?' antes de ejecutarse. Útil para evitar toques por error en el celular.",
		["Window size %"] = "Tamaño de ventana %",
		["Makes the whole hub bigger or smaller (up to 130% so it is easier to tap on phones)."] = "Hace todo el hub más grande o pequeño (hasta 130% para tocar más fácil en celulares).",
		["Keybinds (PC)"] = "Atajos de teclado (PC)",
		["Keyboard shortcuts: %s = show/hide, End = panic, Right Ctrl = run last script, Insert = music on/off. Turn OFF if you don't use a keyboard."] = "Atajos: %s = mostrar/ocultar, End = pánico, Ctrl derecho = ejecutar el último script, Insert = música on/off. Desactívalo si no usas teclado.",
		["On-screen buttons (mobile)"] = "Botones en pantalla (móvil)",
		["Shows a small draggable bar with 🚨 panic, 🔁 run last script and 🎵 music, so phone and tablet players don't need the keybinds. ON by default on phones."] = "Muestra una barrita arrastrable con 🚨 pánico, 🔁 último script y 🎵 música, para que en celular y tablet no necesiten atajos. ON por defecto en celulares.",
		["Accent color"] = "Color de acento",
		["Cycles the hub colors: Pumpkin, Blood, Toxic, Ghost, Gold, Sakura, Void, Mint. It's saved and shows up the next time you run the hub."] = "Cambia los colores del hub: Pumpkin, Blood, Toxic, Ghost, Gold, Sakura, Void, Mint. Se guarda y se aplica la próxima vez que ejecutes el hub.",
		["🎨 %s selected. Re-run the hub to apply it."] = "🎨 %s elegido. Ejecuta el hub otra vez para aplicarlo.",
		["Language"] = "Idioma",
		["Changes the hub language: English, Español, Português, Français. It's saved and shows up the next time you run the hub."] = "Cambia el idioma del hub: English, Español, Português, Français. Se guarda y se aplica la próxima vez que ejecutes el hub.",
		["🌐 %s selected. Re-run the hub to apply it."] = "🌐 %s elegido. Ejecuta el hub otra vez para aplicarlo.",
		["Reset positions"] = "Restablecer posiciones",
		["Puts the hub back in the middle of the screen and the pumpkin back on the left."] = "Vuelve a poner el hub en el centro de la pantalla y la calabaza a la izquierda.",
		["Close UI"] = "Cerrar UI",
		["Closes the hub completely (it asks you first)."] = "Cierra el hub por completo (te pregunta antes).",
		["Random mode"] = "Modo aleatorio",
		["Picks a random mode from the Modes tabs and asks before running it."] = "Elige un modo al azar de las pestañas de Modos y pregunta antes de ejecutarlo.",
		["Say boo"] = "Decir boo",
		["Shows a spooky popup. A good first button to test."] = "Muestra un aviso tenebroso. Un buen primer botón para probar.",
		["Boo! 👻"] = "¡Bu! 👻",
		["Run last script again"] = "Ejecutar el último script otra vez",
		["Runs the last script you ran in this session again."] = "Vuelve a ejecutar el último script de esta sesión.",
		["Nothing run yet 👻"] = "Aún no ejecutaste nada 👻",
		["About V10"] = "Acerca de V10",
		["Version info for the hub."] = "Información de versión del hub.",
		["Tap the 🎃 to show/hide, 🚨 = panic"] = "Toca la 🎃 para mostrar/ocultar, 🚨 = pánico",
		["Show/hide:"] = "Mostrar/ocultar:",
		["Panic:"] = "Pánico:",
		["Hub by Rip_Silence, GUI by WH1T3. Thanks for using the hub!"] = "Hub de Rip_Silence, GUI de WH1T3. ¡Gracias por usar el hub!",
		["Run it?"] = "¿Ejecutarlo?",
		["Run!"] = "¡Ejecutar!",
		["Close"] = "Cerrar",
		["Cancel"] = "Cancelar",
		["Execute"] = "Ejecutar",
		["Stay"] = "Quedarme",
		["Are you sure? ⚠️"] = "¿Seguro? ⚠️",
		["Are you sure you want to execute %s?"] = "¿Seguro que quieres ejecutar %s?",
		["Leaving so soon? 💀"] = "¿Ya te vas? 💀",
		["Are you sure you want to close the hub?"] = "¿Seguro que quieres cerrar el hub?",
		["No description yet."] = "Aún sin descripción.",
		["Type:"] = "Tipo:",
		["Role:"] = "Rol:",
		["Asks before running:"] = "Pregunta antes de ejecutar:",
		["Yes"] = "Sí",
		["Button"] = "Botón",
		["Credit"] = "Crédito",
		["Toggle"] = "Interruptor",
		["Slider"] = "Deslizador",
		["⚠️ Script error (see console)"] = "⚠️ Error de script (mira la consola)",
		["Minimized. Tap 🎃 to bring the hub back."] = "Minimizado. Toca 🎃 para volver a mostrar el hub.",
		["⚠️ Couldn't load \"%s\" (bad id / url / file?)"] = "⚠️ No se pudo cargar \"%s\" (¿id / url / archivo incorrecto?)",
		["🎵 Paste an audio ID in the Music tab first."] = "🎵 Primero pega un ID de audio en la pestaña Música.",
		["🎵 Now playing: %s"] = "🎵 Reproduciendo: %s",
		["⚠️ This song won't load. Wrong id, or the audio is private."] = "⚠️ Esta canción no carga. ID incorrecto o audio privado.",
		["📻 Playlist is empty. Play an ID, then tap 💾 Save."] = "📻 La playlist está vacía. Reproduce un ID y toca 💾 Guardar.",
		["🎵 That doesn't look like an audio ID."] = "🎵 Eso no parece un ID de audio.",
		["⚠️ That ID is not an audio asset."] = "⚠️ Ese ID no es un audio.",
		["🎵 Loading %s..."] = "🎵 Cargando %s...",
		["🎵 Nothing to save yet. Play an ID first."] = "🎵 Aún no hay nada que guardar. Reproduce un ID primero.",
		["📻 Already in your playlist."] = "📻 Ya está en tu playlist.",
		["📻 Saved: %s"] = "📻 Guardado: %s",
		["Removed from favorites"] = "Quitado de favoritos",
		["⭐ Added to favorites"] = "⭐ Añadido a favoritos",
		["💔 Unfavorite"] = "💔 Quitar favorito",
		["⭐ Favorite"] = "⭐ Favorito",
		["▶ Loading %s..."] = "▶ Cargando %s...",
		["✅ %s loaded (%.1fs)"] = "✅ %s cargado (%.1fs)",
		["⚠️ %s failed: %s"] = "⚠️ %s falló: %s",
		["Welcome, %s! 🎃"] = "¡Bienvenido, %s! 🎃",
		["Summoning ghosts..."] = "Invocando fantasmas...",
		["Carving pumpkins..."] = "Tallando calabazas...",
		["Brewing potions..."] = "Preparando pociones...",
		["Waking the skeletons..."] = "Despertando esqueletos...",
		["Unlocking %d scripts..."] = "Desbloqueando %d scripts...",
		["Almost ready..."] = "Casi listo...",
		["Tip: tap the 🎃 to hide the hub"] = "Consejo: toca la 🎃 para ocultar el hub",
		["Tip: press %s or tap the 🎃 to hide the hub"] = "Consejo: presiona %s o toca la 🎃 para ocultar el hub",
		["Tap a name or its three dots to see more."] = "Toca un nombre o sus tres puntos para ver más.",
		["🌐 Languages: English, Español, Português, Français"] = "🌐 Idiomas: English, Español, Português, Français",
		["📱 Mobile mode: draggable on-screen buttons that replace the keybinds"] = "📱 Modo móvil: botones arrastrables en pantalla que reemplazan los atajos",
		["⌨️ More keybinds (End, Right Ctrl, Insert) + toggles in Settings"] = "⌨️ Más atajos (End, Ctrl derecho, Insert) + switches en Ajustes",
		["🔍 Window size now goes up to 130% for phones"] = "🔍 El tamaño de ventana llega hasta 130% para celulares",
		["🚨 Panic button / End key hides everything instantly"] = "🚨 Botón de pánico / tecla End oculta todo al instante",
		["ℹ️ About V36 popup on Home"] = "ℹ️ Ventana «Acerca de V36» en Inicio",
		["🧹 Removed locked / deleted scripts for a cleaner list"] = "🧹 Se quitaron scripts bloqueados/eliminados para una lista más limpia",
		["✨ Script of the day + 📈 all-time run counter on Home"] = "✨ Script del día + 📈 contador total en Inicio",
		["🚀 Scripts now load in the background, so the hub never freezes"] = "🚀 Los scripts cargan en segundo plano, así el hub no se congela",
		["✅ Success / ⚠️ error popups for every script you run"] = "✅ Avisos de éxito / ⚠️ error por cada script que ejecutes",
		["🔥 Most used scripts + 🔁 Run last script again"] = "🔥 Scripts más usados + 🔁 Ejecutar el último otra vez",
		["🔎 Search by script name OR creator (try \"Guestly\")"] = "🔎 Busca por nombre de script O creador (prueba \"Guestly\")",
		["🧰 New Tools tab: Anti-AFK, rejoin, copy IDs, FPS cap"] = "🧰 Nueva pestaña Herramientas: Anti-AFK, reentrar, copiar IDs, límite de FPS",
		["🩺 Executor check: see which functions your executor supports"] = "🩺 Revisión del executor: mira qué funciones soporta",
		["📊 Live FPS, ping and session timer on Home"] = "📊 FPS, ping y tiempo de sesión en vivo en Inicio",
		["🎨 5 accent colors in Settings"] = "🎨 5 colores de acento en Ajustes",
		["🎵 Music player, 📻 playlist, ⭐ favorites and 🎲 random mode"] = "🎵 Reproductor, 📻 playlist, ⭐ favoritos y 🎲 modo aleatorio",
		["📝 Notes"] = "📝 Notas",
		["↕ Default"] = "↕ Original",
		["🆕 Newest"] = "🆕 Nuevos",
		["↕ Sorting: %s"] = "↕ Orden: %s",
		["🆕 NEW SCRIPTS"] = "🆕 SCRIPTS NUEVOS",
		["Every new script has a 🆕 in front of its name."] = "Cada script nuevo lleva un 🆕 delante del nombre.",
		["MY NOTES"] = "MIS NOTAS",
		["Write anything here: ideas, audio IDs, script names. It saves automatically."] = "Escribe lo que quieras: ideas, IDs de audio, nombres de scripts. Se guarda solo.",
		["📝 Type your notes here..."] = "📝 Escribe tus notas aquí...",
		["Copy notes"] = "Copiar notas",
		["Copies all your notes (needs setclipboard)."] = "Copia todas tus notas (necesita setclipboard).",
		["Clear notes"] = "Borrar notas",
		["Deletes everything you wrote in Notes."] = "Borra todo lo que escribiste en Notas.",
		["Delete all your notes?"] = "¿Borrar todas tus notas?",
		["Hide hub after running a script"] = "Ocultar el hub al ejecutar un script",
		["After you run a script the hub hides itself so you can see the game. Bring it back with the 🎃, your key or the quick bar."] = "Al ejecutar un script el hub se oculta para que veas el juego. Vuelve con el 🎃, tu tecla o la barra rápida.",
		["Copy my favorites list"] = "Copiar mi lista de favoritos",
		["Copies the names of all your favorite scripts so you can share them (needs setclipboard)."] = "Copia los nombres de tus scripts favoritos para compartirlos (necesita setclipboard).",
		["Nothing to copy yet ⭐"] = "Aún no hay nada que copiar ⭐",
		["VISUALS"] = "VISUALES",
		["Field of view"] = "Campo de visión",
		["Changes your camera field of view (the game may reset it). Use Reset FOV to go back."] = "Cambia el campo de visión de tu cámara (el juego puede reiniciarlo). Usa Reset FOV para volver.",
		["Reset FOV"] = "Restablecer FOV",
		["Puts your camera field of view back to what it was when the hub started."] = "Devuelve el campo de visión al valor que tenía cuando se inició el hub.",
		["FPS boost"] = "Impulso de FPS",
		["Turns off shadows and lowers graphics quality for more FPS. Turn it OFF to restore your old settings."] = "Desactiva las sombras y baja la calidad gráfica para ganar FPS. Apágalo para restaurar tu configuración.",
		["🚀 FPS boost ON"] = "🚀 Impulso de FPS ACTIVADO",
		["FPS boost OFF"] = "Impulso de FPS desactivado",
		["Copy debug info"] = "Copiar info de depuración",
		["Copies your executor, language and hub version so you can paste it when reporting a bug (no personal info). Needs setclipboard."] = "Copia tu executor, idioma y versión del hub para pegarlo al reportar un error (sin datos personales). Necesita setclipboard.",
		["Reset EVERYTHING"] = "Restablecer TODO",
		["Wipes ALL saved data: favorites, stats, playlist, notes and settings. Re-run the hub afterwards."] = "Borra TODOS los datos guardados: favoritos, estadísticas, playlist, notas y ajustes. Vuelve a ejecutar el hub después.",
		["Wipe ALL saved data? This can't be undone."] = "¿Borrar TODOS los datos guardados? No se puede deshacer.",
		["🧹 Everything reset. Re-run the hub."] = "🧹 Todo restablecido. Vuelve a ejecutar el hub.",
		["⭐ Favorites: %d  •  ▶ This session: %d"] = "⭐ Favoritos: %d  •  ▶ En esta sesión: %d",
		["The script link is dead (404). It may have been deleted."] = "El enlace del script está caído (404). Puede que lo hayan borrado.",
		["Your executor blocked the download."] = "Tu executor bloqueó la descarga.",
		["The download timed out. Try again."] = "La descarga tardó demasiado. Inténtalo de nuevo.",
		["Your executor doesn't support loadstring."] = "Tu executor no soporta loadstring.",
		["Shuffle"] = "Aleatorio",
		["ON = the next song is picked at random. Works with the ⏭ / ⏮ buttons and when a song ends (Loop OFF)."] = "ON = la siguiente canción se elige al azar. Funciona con ⏭ / ⏮ y cuando acaba una canción (Loop OFF).",
		["Resume music on start"] = "Reanudar música al iniciar",
		["ON = your last song starts playing when the hub opens. Turn OFF if you want silence at the start."] = "ON = tu última canción suena al abrir el hub. Apágalo si quieres silencio al empezar.",
		["WHAT'S NEW IN V10"] = "NOVEDADES DE LA V10",
		["EARLIER UPDATES"] = "ACTUALIZACIONES ANTERIORES",
		["🎃 What's new in V10"] = "🎃 Novedades de la V10",
		["Awesome!"] = "¡Genial!",
		["🆕 NEW badges on new scripts + a New section on Home"] = "🆕 Insignias NUEVO en scripts recientes + sección Nuevos en Inicio",
		["↕ Sort button in every tab: Default, A→Z, Z→A, Newest"] = "↕ Botón de orden en cada pestaña: Original, A→Z, Z→A, Nuevos",
		["🔢 Script counts on every tab"] = "🔢 Cantidad de scripts en cada pestaña",
		["📝 Notes tab (saved automatically)"] = "📝 Pestaña de Notas (se guarda sola)",
		["🙈 Option to hide the hub after you run a script"] = "🙈 Opción para ocultar el hub al ejecutar un script",
		["🔭 FOV slider + 🚀 FPS boost in Tools"] = "🔭 Control de FOV + 🚀 impulso de FPS en Herramientas",
		["🐞 Copy debug info button for bug reports"] = "🐞 Botón para copiar info de depuración al reportar errores",
		["🔀 Shuffle + resume-on-start for the music player"] = "🔀 Modo aleatorio y reanudar al iniciar en el reproductor de música",
		["🎨 3 new accent colors: Sakura, Void, Mint"] = "🎨 3 colores nuevos: Sakura, Void, Mint",
		["💬 Friendlier error messages when a script fails"] = "💬 Mensajes de error más claros cuando falla un script",
		["📋 Copy your favorites list"] = "📋 Copia tu lista de favoritos",
		["🧹 Reset everything button (Tools > Data)"] = "🧹 Botón para restablecer todo (Herramientas > Datos)",
	},
	pt = {
		["🏠 Home"] = "🏠 Início",
		["⭐ Favorites"] = "⭐ Favoritos",
		["🔎 Search"] = "🔎 Buscar",
		["🎵 Music"] = "🎵 Música",
		["🎃 Effects"] = "🎃 Efeitos",
		["🧰 Tools"] = "🧰 Ferramentas",
		["⚙️ Settings"] = "⚙️ Config.",
		["📜 Updates"] = "📜 Novidades",
		["😄 Credits"] = "😄 Créditos",
		["🔪 Modes"] = "🔪 Modos",
		["🌹 OG Modes"] = "🌹 Modos OG",
		["😈 Legacy"] = "😈 Legado",
		["⚠️ Entities"] = "⚠️ Entidades",
		["✨ Items"] = "✨ Itens",
		["💔 Modes 2"] = "💔 Modos 2",
		["Have Fun With These Modes"] = "Divirta-se com estes modos",
		["Very Cool Things"] = "Coisas muito legais",
		["Only works in Super Hard Mode"] = "Só funciona no Super Hard Mode",
		["Enjoy these scripts"] = "Aproveite estes scripts",
		["Only works in Hotel-"] = "Só funciona no Hotel-",
		["Custom Entity Spawner"] = "Spawner de entidades personalizadas",
		["Enjoy these custom items"] = "Aproveite estes itens personalizados",
		["Second section of modes"] = "Segunda seção de modos",
		["WELCOME"] = "BEM-VINDO",
		["✨ SCRIPT OF THE DAY"] = "✨ SCRIPT DO DIA",
		["⭐ FAVORITES"] = "⭐ FAVORITOS",
		["🔥 MOST USED"] = "🔥 MAIS USADOS",
		["🕘 RECENTLY RUN"] = "🕘 EXECUTADOS RECENTEMENTE",
		["NOW PLAYING"] = "TOCANDO AGORA",
		["PLAY ANY AUDIO ID"] = "TOQUE QUALQUER ID DE ÁUDIO",
		["SETTINGS"] = "CONFIGURAÇÕES",
		["📻 YOUR PLAYLIST"] = "📻 SUA PLAYLIST",
		["SPOOKY STUFF"] = "COISAS ASSUSTADORAS",
		["SESSION"] = "SESSÃO",
		["EXECUTOR CHECK"] = "VERIFICAÇÃO DO EXECUTOR",
		["DATA"] = "DADOS",
		["UI"] = "INTERFACE",
		["CONTROLS (PC + MOBILE)"] = "CONTROLES (PC + CELULAR)",
		["LOOK"] = "APARÊNCIA",
		["THE TEAM"] = "A EQUIPE",
		["WHAT'S NEW IN V36"] = "NOVIDADES DA V36",
		["SCRIPT UPDATE LOG"] = "REGISTRO DE ATUALIZAÇÕES",
		["the 🎃 button"] = "o botão 🎃",
		["Hey %s! %d scripts loaded. Tap the 🎃 or press %s to show/hide. Search all scripts in 🔎, keep your best ones in ⭐, and paste any audio ID in 🎵."] = "Oi %s! %d scripts carregados. Toque na 🎃 ou pressione %s para mostrar/ocultar. Procure todos os scripts em 🔎, guarde os melhores em ⭐ e cole qualquer ID de áudio em 🎵.",
		["Session"] = "Sessão",
		["📈 All-time scripts run: %d"] = "📈 Scripts executados no total: %d",
		["Nothing here yet. Tap the ⋮ on any script and choose ⭐ Favorite."] = "Nada aqui ainda. Toque nos ⋮ de um script e escolha ⭐ Favoritar.",
		["Your top scripts show up here after you run a few."] = "Seus scripts mais usados aparecem aqui depois que você executar alguns.",
		["Scripts you run show up here."] = "Os scripts que você executar aparecem aqui.",
		["Type at least 2 letters to search every tab at once."] = "Digite pelo menos 2 letras para buscar em todas as abas ao mesmo tempo.",
		["Nothing found for \"%s\"."] = "Nada encontrado para \"%s\".",
		["Showing the first 40. Type more letters to narrow it down."] = "Mostrando os 40 primeiros. Digite mais letras para filtrar.",
		["🔍 Search %d scripts or creators..."] = "🔍 Buscar entre %d scripts ou criadores...",
		["🔎 Search all %d scripts or creators..."] = "🔎 Buscar nos %d scripts ou criadores...",
		["Loading %d scripts..."] = "Carregando %d scripts...",
		["Ran %dx"] = "Executado %dx",
		["Nothing selected yet.\nPaste an audio ID below and tap Play."] = "Nada selecionado ainda.\nCole um ID de áudio abaixo e toque em Tocar.",
		["🎵 Paste audio ID or link..."] = "🎵 Cole um ID ou link de áudio...",
		["▶ Play"] = "▶ Tocar",
		["💾 Save"] = "💾 Salvar",
		["Background music"] = "Música de fundo",
		["Turns the music on or off. The 🎵 button in the title bar does the same thing."] = "Liga ou desliga a música. O botão 🎵 da barra de título faz o mesmo.",
		["Loop this song"] = "Repetir esta música",
		["ON = the song repeats forever. OFF = it moves on to the next song in your playlist when it ends."] = "ON = a música repete para sempre. OFF = passa para a próxima da sua playlist ao terminar.",
		["Music volume"] = "Volume da música",
		["How loud the music is (0 = silent, 100 = max)."] = "Quão alta é a música (0 = mudo, 100 = máx.).",
		["Where to get IDs: Creator Store > Audio, open a song and copy the number (or the whole link) from the page. Some audio is private and won't play. Tap 💾 Save to keep a song in 📻 Playlist."] = "Onde achar IDs: Creator Store > Áudio, abra uma música e copie o número (ou o link inteiro) da página. Alguns áudios são privados e não tocam. Toque em 💾 Salvar para guardar uma música na 📻 Playlist.",
		["Empty. Play an ID in the 🎵 tab, then tap 💾 Save."] = "Vazia. Toque um ID na aba 🎵 e depois em 💾 Salvar.",
		["Tap the song to play it. Use Remove to delete it from your playlist."] = "Toque na música para tocar. Use Remover para tirá-la da playlist.",
		["🗑 Remove"] = "🗑 Remover",
		["Removed from playlist"] = "Removida da playlist",
		["Floating bats"] = "Morcegos voando",
		["Little bats fly across your screen. Purely decoration."] = "Pequenos morcegos voam pela tela. Só decoração.",
		["Pumpkin rain"] = "Chuva de abóboras",
		["Makes pumpkins fall from the top of the screen for a few seconds."] = "Faz abóboras caírem do topo da tela por alguns segundos.",
		["Stops Roblox from kicking you for being idle (20 min). Great for long runs. Saved."] = "Impede que o Roblox te expulse por inatividade (20 min). Ótimo para partidas longas. Fica salvo.",
		["Panic (hide everything)"] = "Pânico (esconder tudo)",
		["Instantly hides the hub and the pumpkin and stops the music. Press it again, the End key, or tap the faint dot in the top-left corner to bring everything back."] = "Esconde na hora o hub e a abóbora e para a música. Aperte de novo, use a tecla End ou toque no pontinho fraco no canto superior esquerdo para tudo voltar.",
		["Rejoin server"] = "Reentrar no servidor",
		["Teleports you back into this same game."] = "Te teleporta de volta para este mesmo jogo.",
		["Rejoin this game? You'll leave the current server."] = "Reentrar neste jogo? Você sairá do servidor atual.",
		["Copies the place id and this server's job id (needs setclipboard)."] = "Copia o place id e o job id deste servidor (precisa de setclipboard).",
		["📋 Copied!"] = "📋 Copiado!",
		["FPS cap"] = "Limite de FPS",
		["Changes your max FPS (needs setfpscap)."] = "Muda seu máximo de FPS (precisa de setfpscap).",
		["If a script button fails, check the ❌ above first."] = "Se um script falhar, veja primeiro os ❌ acima.",
		["Reset favorites & stats"] = "Limpar favoritos e estatísticas",
		["Clears your favorites and the Most used counters. Playlist and settings stay."] = "Apaga seus favoritos e os contadores de Mais usados. Playlist e configurações ficam.",
		["Clear all favorites and run counts?"] = "Limpar todos os favoritos e contadores?",
		["🧹 Cleared"] = "🧹 Limpo",
		["Notifications"] = "Notificações",
		["Turns the little popup messages in the corner on or off."] = "Liga ou desliga as mensagens pequenas no canto.",
		["Confirm before running"] = "Confirmar antes de executar",
		["When ON, every script button asks 'Are you sure?' before it runs. Handy to avoid misclicks on a phone."] = "Se ON, cada botão de script pergunta 'Tem certeza?' antes de executar. Útil para evitar toques sem querer no celular.",
		["Window size %"] = "Tamanho da janela %",
		["Makes the whole hub bigger or smaller (up to 130% so it is easier to tap on phones)."] = "Deixa o hub todo maior ou menor (até 130% para tocar mais fácil no celular).",
		["Keybinds (PC)"] = "Atalhos de teclado (PC)",
		["Keyboard shortcuts: %s = show/hide, End = panic, Right Ctrl = run last script, Insert = music on/off. Turn OFF if you don't use a keyboard."] = "Atalhos: %s = mostrar/ocultar, End = pânico, Ctrl direito = executar o último script, Insert = música on/off. Desligue se não usa teclado.",
		["On-screen buttons (mobile)"] = "Botões na tela (celular)",
		["Shows a small draggable bar with 🚨 panic, 🔁 run last script and 🎵 music, so phone and tablet players don't need the keybinds. ON by default on phones."] = "Mostra uma barrinha arrastável com 🚨 pânico, 🔁 último script e 🎵 música, para quem joga no celular ou tablet não precisar dos atalhos. ON por padrão no celular.",
		["Accent color"] = "Cor de destaque",
		["Cycles the hub colors: Pumpkin, Blood, Toxic, Ghost, Gold, Sakura, Void, Mint. It's saved and shows up the next time you run the hub."] = "Muda as cores do hub: Pumpkin, Blood, Toxic, Ghost, Gold, Sakura, Void, Mint. Fica salvo e vale na próxima vez que executar o hub.",
		["🎨 %s selected. Re-run the hub to apply it."] = "🎨 %s escolhido. Execute o hub de novo para aplicar.",
		["Language"] = "Idioma",
		["Changes the hub language: English, Español, Português, Français. It's saved and shows up the next time you run the hub."] = "Muda o idioma do hub: English, Español, Português, Français. Fica salvo e vale na próxima vez que executar o hub.",
		["🌐 %s selected. Re-run the hub to apply it."] = "🌐 %s escolhido. Execute o hub de novo para aplicar.",
		["Reset positions"] = "Redefinir posições",
		["Puts the hub back in the middle of the screen and the pumpkin back on the left."] = "Coloca o hub de volta no meio da tela e a abóbora à esquerda.",
		["Close UI"] = "Fechar UI",
		["Closes the hub completely (it asks you first)."] = "Fecha o hub por completo (pergunta antes).",
		["Random mode"] = "Modo aleatório",
		["Picks a random mode from the Modes tabs and asks before running it."] = "Escolhe um modo aleatório das abas de Modos e pergunta antes de executar.",
		["Say boo"] = "Dizer boo",
		["Shows a spooky popup. A good first button to test."] = "Mostra um aviso assustador. Um bom primeiro botão para testar.",
		["Boo! 👻"] = "Buu! 👻",
		["Run last script again"] = "Executar o último script de novo",
		["Runs the last script you ran in this session again."] = "Executa de novo o último script desta sessão.",
		["Nothing run yet 👻"] = "Nada executado ainda 👻",
		["About V10"] = "Sobre a V10",
		["Version info for the hub."] = "Informações de versão do hub.",
		["Tap the 🎃 to show/hide, 🚨 = panic"] = "Toque na 🎃 para mostrar/ocultar, 🚨 = pânico",
		["Show/hide:"] = "Mostrar/ocultar:",
		["Panic:"] = "Pânico:",
		["Hub by Rip_Silence, GUI by WH1T3. Thanks for using the hub!"] = "Hub de Rip_Silence, GUI de WH1T3. Obrigado por usar o hub!",
		["Run it?"] = "Executar?",
		["No"] = "Não",
		["Run!"] = "Executar!",
		["Close"] = "Fechar",
		["Cancel"] = "Cancelar",
		["Execute"] = "Executar",
		["Stay"] = "Ficar",
		["Are you sure? ⚠️"] = "Tem certeza? ⚠️",
		["Are you sure you want to execute %s?"] = "Tem certeza que quer executar %s?",
		["Leaving so soon? 💀"] = "Já vai embora? 💀",
		["Are you sure you want to close the hub?"] = "Tem certeza que quer fechar o hub?",
		["No description yet."] = "Sem descrição ainda.",
		["Type:"] = "Tipo:",
		["Role:"] = "Função:",
		["Asks before running:"] = "Pergunta antes de executar:",
		["Yes"] = "Sim",
		["Button"] = "Botão",
		["Credit"] = "Crédito",
		["Toggle"] = "Interruptor",
		["Slider"] = "Controle deslizante",
		["⚠️ Script error (see console)"] = "⚠️ Erro de script (veja o console)",
		["Minimized. Tap 🎃 to bring the hub back."] = "Minimizado. Toque na 🎃 para trazer o hub de volta.",
		["⚠️ Couldn't load \"%s\" (bad id / url / file?)"] = "⚠️ Não foi possível carregar \"%s\" (id / url / arquivo errado?)",
		["🎵 Paste an audio ID in the Music tab first."] = "🎵 Cole primeiro um ID de áudio na aba Música.",
		["🎵 Now playing: %s"] = "🎵 Tocando agora: %s",
		["⚠️ This song won't load. Wrong id, or the audio is private."] = "⚠️ Esta música não carrega. ID errado ou áudio privado.",
		["📻 Playlist is empty. Play an ID, then tap 💾 Save."] = "📻 A playlist está vazia. Toque um ID e depois em 💾 Salvar.",
		["🎵 That doesn't look like an audio ID."] = "🎵 Isso não parece um ID de áudio.",
		["⚠️ That ID is not an audio asset."] = "⚠️ Esse ID não é um áudio.",
		["🎵 Loading %s..."] = "🎵 Carregando %s...",
		["🎵 Nothing to save yet. Play an ID first."] = "🎵 Nada para salvar ainda. Toque um ID primeiro.",
		["📻 Already in your playlist."] = "📻 Já está na sua playlist.",
		["📻 Saved: %s"] = "📻 Salvo: %s",
		["Removed from favorites"] = "Removido dos favoritos",
		["⭐ Added to favorites"] = "⭐ Adicionado aos favoritos",
		["💔 Unfavorite"] = "💔 Desfavoritar",
		["⭐ Favorite"] = "⭐ Favoritar",
		["▶ Loading %s..."] = "▶ Carregando %s...",
		["✅ %s loaded (%.1fs)"] = "✅ %s carregado (%.1fs)",
		["⚠️ %s failed: %s"] = "⚠️ %s falhou: %s",
		["Welcome, %s! 🎃"] = "Bem-vindo, %s! 🎃",
		["Summoning ghosts..."] = "Invocando fantasmas...",
		["Carving pumpkins..."] = "Esculpindo abóboras...",
		["Brewing potions..."] = "Preparando poções...",
		["Waking the skeletons..."] = "Acordando os esqueletos...",
		["Unlocking %d scripts..."] = "Desbloqueando %d scripts...",
		["Almost ready..."] = "Quase pronto...",
		["Tip: tap the 🎃 to hide the hub"] = "Dica: toque na 🎃 para esconder o hub",
		["Tip: press %s or tap the 🎃 to hide the hub"] = "Dica: pressione %s ou toque na 🎃 para esconder o hub",
		["Tap a name or its three dots to see more."] = "Toque em um nome ou nos três pontos para ver mais.",
		["🌐 Languages: English, Español, Português, Français"] = "🌐 Idiomas: English, Español, Português, Français",
		["📱 Mobile mode: draggable on-screen buttons that replace the keybinds"] = "📱 Modo celular: botões arrastáveis na tela que substituem os atalhos",
		["⌨️ More keybinds (End, Right Ctrl, Insert) + toggles in Settings"] = "⌨️ Mais atalhos (End, Ctrl direito, Insert) + chaves em Configurações",
		["🔍 Window size now goes up to 130% for phones"] = "🔍 O tamanho da janela vai até 130% para celulares",
		["🚨 Panic button / End key hides everything instantly"] = "🚨 Botão de pânico / tecla End esconde tudo na hora",
		["ℹ️ About V36 popup on Home"] = "ℹ️ Janela «Sobre a V36» no Início",
		["🧹 Removed locked / deleted scripts for a cleaner list"] = "🧹 Scripts bloqueados/removidos foram retirados para uma lista mais limpa",
		["✨ Script of the day + 📈 all-time run counter on Home"] = "✨ Script do dia + 📈 contador total no Início",
		["🚀 Scripts now load in the background, so the hub never freezes"] = "🚀 Os scripts carregam em segundo plano, então o hub não trava",
		["✅ Success / ⚠️ error popups for every script you run"] = "✅ Avisos de sucesso / ⚠️ erro para cada script que você executar",
		["🔥 Most used scripts + 🔁 Run last script again"] = "🔥 Scripts mais usados + 🔁 Executar o último de novo",
		["🔎 Search by script name OR creator (try \"Guestly\")"] = "🔎 Busque por nome do script OU criador (tente \"Guestly\")",
		["🧰 New Tools tab: Anti-AFK, rejoin, copy IDs, FPS cap"] = "🧰 Nova aba Ferramentas: Anti-AFK, reentrar, copiar IDs, limite de FPS",
		["🩺 Executor check: see which functions your executor supports"] = "🩺 Verificação do executor: veja quais funções ele suporta",
		["📊 Live FPS, ping and session timer on Home"] = "📊 FPS, ping e tempo de sessão ao vivo no Início",
		["🎨 5 accent colors in Settings"] = "🎨 5 cores de destaque em Configurações",
		["🎵 Music player, 📻 playlist, ⭐ favorites and 🎲 random mode"] = "🎵 Player de música, 📻 playlist, ⭐ favoritos e 🎲 modo aleatório",
		["📝 Notes"] = "📝 Notas",
		["↕ Default"] = "↕ Padrão",
		["🆕 Newest"] = "🆕 Novos",
		["↕ Sorting: %s"] = "↕ Ordem: %s",
		["🆕 NEW SCRIPTS"] = "🆕 SCRIPTS NOVOS",
		["Every new script has a 🆕 in front of its name."] = "Cada script novo tem um 🆕 na frente do nome.",
		["MY NOTES"] = "MINHAS NOTAS",
		["Write anything here: ideas, audio IDs, script names. It saves automatically."] = "Escreva o que quiser: ideias, IDs de áudio, nomes de scripts. Salva sozinho.",
		["📝 Type your notes here..."] = "📝 Escreva suas notas aqui...",
		["Copy notes"] = "Copiar notas",
		["Copies all your notes (needs setclipboard)."] = "Copia todas as suas notas (precisa de setclipboard).",
		["Clear notes"] = "Apagar notas",
		["Deletes everything you wrote in Notes."] = "Apaga tudo o que você escreveu em Notas.",
		["Delete all your notes?"] = "Apagar todas as suas notas?",
		["Hide hub after running a script"] = "Esconder o hub ao executar um script",
		["After you run a script the hub hides itself so you can see the game. Bring it back with the 🎃, your key or the quick bar."] = "Ao executar um script o hub se esconde para você ver o jogo. Volte com o 🎃, sua tecla ou a barra rápida.",
		["Copy my favorites list"] = "Copiar minha lista de favoritos",
		["Copies the names of all your favorite scripts so you can share them (needs setclipboard)."] = "Copia os nomes dos seus scripts favoritos para compartilhar (precisa de setclipboard).",
		["Nothing to copy yet ⭐"] = "Ainda não há nada para copiar ⭐",
		["VISUALS"] = "VISUAIS",
		["Field of view"] = "Campo de visão",
		["Changes your camera field of view (the game may reset it). Use Reset FOV to go back."] = "Muda o campo de visão da câmera (o jogo pode redefinir). Use Reset FOV para voltar.",
		["Reset FOV"] = "Redefinir FOV",
		["Puts your camera field of view back to what it was when the hub started."] = "Volta o campo de visão ao valor de quando o hub iniciou.",
		["FPS boost"] = "Boost de FPS",
		["Turns off shadows and lowers graphics quality for more FPS. Turn it OFF to restore your old settings."] = "Desativa sombras e reduz a qualidade gráfica para mais FPS. Desligue para restaurar suas configurações.",
		["🚀 FPS boost ON"] = "🚀 Boost de FPS LIGADO",
		["FPS boost OFF"] = "Boost de FPS desligado",
		["Copy debug info"] = "Copiar info de depuração",
		["Copies your executor, language and hub version so you can paste it when reporting a bug (no personal info). Needs setclipboard."] = "Copia seu executor, idioma e versão do hub para colar ao reportar um erro (sem dados pessoais). Precisa de setclipboard.",
		["Reset EVERYTHING"] = "Redefinir TUDO",
		["Wipes ALL saved data: favorites, stats, playlist, notes and settings. Re-run the hub afterwards."] = "Apaga TODOS os dados salvos: favoritos, estatísticas, playlist, notas e configurações. Execute o hub de novo depois.",
		["Wipe ALL saved data? This can't be undone."] = "Apagar TODOS os dados salvos? Isso não pode ser desfeito.",
		["🧹 Everything reset. Re-run the hub."] = "🧹 Tudo redefinido. Execute o hub de novo.",
		["⭐ Favorites: %d  •  ▶ This session: %d"] = "⭐ Favoritos: %d  •  ▶ Nesta sessão: %d",
		["The script link is dead (404). It may have been deleted."] = "O link do script está morto (404). Pode ter sido apagado.",
		["Your executor blocked the download."] = "Seu executor bloqueou o download.",
		["The download timed out. Try again."] = "O download demorou demais. Tente de novo.",
		["Your executor doesn't support loadstring."] = "Seu executor não suporta loadstring.",
		["Shuffle"] = "Aleatório",
		["ON = the next song is picked at random. Works with the ⏭ / ⏮ buttons and when a song ends (Loop OFF)."] = "ON = a próxima música é escolhida ao acaso. Funciona com ⏭ / ⏮ e quando a música termina (Loop OFF).",
		["Resume music on start"] = "Retomar música ao iniciar",
		["ON = your last song starts playing when the hub opens. Turn OFF if you want silence at the start."] = "ON = sua última música toca ao abrir o hub. Desligue se quiser silêncio no início.",
		["WHAT'S NEW IN V10"] = "NOVIDADES DA V10",
		["EARLIER UPDATES"] = "ATUALIZAÇÕES ANTERIORES",
		["🎃 What's new in V10"] = "🎃 Novidades da V10",
		["Awesome!"] = "Show!",
		["🆕 NEW badges on new scripts + a New section on Home"] = "🆕 Selos NOVO nos scripts recentes + seção Novos no Início",
		["↕ Sort button in every tab: Default, A→Z, Z→A, Newest"] = "↕ Botão de ordem em cada aba: Padrão, A→Z, Z→A, Novos",
		["🔢 Script counts on every tab"] = "🔢 Quantidade de scripts em cada aba",
		["📝 Notes tab (saved automatically)"] = "📝 Aba de Notas (salva sozinha)",
		["🙈 Option to hide the hub after you run a script"] = "🙈 Opção de esconder o hub ao executar um script",
		["🔭 FOV slider + 🚀 FPS boost in Tools"] = "🔭 Controle de FOV + 🚀 boost de FPS em Ferramentas",
		["🐞 Copy debug info button for bug reports"] = "🐞 Botão para copiar info de depuração ao reportar erros",
		["🔀 Shuffle + resume-on-start for the music player"] = "🔀 Modo aleatório e retomar ao iniciar no player de música",
		["🎨 3 new accent colors: Sakura, Void, Mint"] = "🎨 3 novas cores: Sakura, Void, Mint",
		["💬 Friendlier error messages when a script fails"] = "💬 Mensagens de erro mais claras quando um script falha",
		["📋 Copy your favorites list"] = "📋 Copie sua lista de favoritos",
		["🧹 Reset everything button (Tools > Data)"] = "🧹 Botão para redefinir tudo (Ferramentas > Dados)",
	},
	fr = {
		["🏠 Home"] = "🏠 Accueil",
		["⭐ Favorites"] = "⭐ Favoris",
		["🔎 Search"] = "🔎 Recherche",
		["🎵 Music"] = "🎵 Musique",
		["🎃 Effects"] = "🎃 Effets",
		["🧰 Tools"] = "🧰 Outils",
		["⚙️ Settings"] = "⚙️ Réglages",
		["📜 Updates"] = "📜 Nouveautés",
		["😄 Credits"] = "😄 Crédits",
		["🌹 OG Modes"] = "🌹 Modes OG",
		["😈 Legacy"] = "😈 Anciens",
		["⚠️ Entities"] = "⚠️ Entités",
		["✨ Items"] = "✨ Objets",
		["Have Fun With These Modes"] = "Amuse-toi avec ces modes",
		["Very Cool Things"] = "Des trucs super cool",
		["Only works in Super Hard Mode"] = "Fonctionne uniquement en Super Hard Mode",
		["Enjoy these scripts"] = "Profite de ces scripts",
		["Only works in Hotel-"] = "Fonctionne uniquement dans Hotel-",
		["Custom Entity Spawner"] = "Spawner d'entités personnalisées",
		["Enjoy these custom items"] = "Profite de ces objets personnalisés",
		["Second section of modes"] = "Deuxième section de modes",
		["WELCOME"] = "BIENVENUE",
		["✨ SCRIPT OF THE DAY"] = "✨ SCRIPT DU JOUR",
		["⭐ FAVORITES"] = "⭐ FAVORIS",
		["🔥 MOST USED"] = "🔥 LES PLUS UTILISÉS",
		["🕘 RECENTLY RUN"] = "🕘 LANCÉS RÉCEMMENT",
		["NOW PLAYING"] = "EN LECTURE",
		["PLAY ANY AUDIO ID"] = "JOUE N'IMPORTE QUEL ID AUDIO",
		["SETTINGS"] = "RÉGLAGES",
		["📻 YOUR PLAYLIST"] = "📻 TA PLAYLIST",
		["SPOOKY STUFF"] = "TRUCS EFFRAYANTS",
		["EXECUTOR CHECK"] = "TEST DE L'EXECUTOR",
		["DATA"] = "DONNÉES",
		["UI"] = "INTERFACE",
		["CONTROLS (PC + MOBILE)"] = "COMMANDES (PC + MOBILE)",
		["LOOK"] = "APPARENCE",
		["THE TEAM"] = "L'ÉQUIPE",
		["WHAT'S NEW IN V36"] = "NOUVEAUTÉS DE LA V36",
		["SCRIPT UPDATE LOG"] = "JOURNAL DES MISES À JOUR",
		["the 🎃 button"] = "le bouton 🎃",
		["Hey %s! %d scripts loaded. Tap the 🎃 or press %s to show/hide. Search all scripts in 🔎, keep your best ones in ⭐, and paste any audio ID in 🎵."] = "Salut %s ! %d scripts chargés. Touche la 🎃 ou appuie sur %s pour afficher/masquer. Cherche tous les scripts dans 🔎, garde les meilleurs dans ⭐ et colle n'importe quel ID audio dans 🎵.",
		["📈 All-time scripts run: %d"] = "📈 Scripts lancés au total : %d",
		["Nothing here yet. Tap the ⋮ on any script and choose ⭐ Favorite."] = "Rien ici pour l'instant. Touche les ⋮ d'un script et choisis ⭐ Favori.",
		["Your top scripts show up here after you run a few."] = "Tes scripts les plus utilisés apparaîtront ici après quelques lancements.",
		["Scripts you run show up here."] = "Les scripts que tu lances apparaissent ici.",
		["Type at least 2 letters to search every tab at once."] = "Tape au moins 2 lettres pour chercher dans tous les onglets à la fois.",
		["Nothing found for \"%s\"."] = "Rien trouvé pour « %s ».",
		["Showing the first 40. Type more letters to narrow it down."] = "Affichage des 40 premiers. Tape plus de lettres pour affiner.",
		["🔍 Search %d scripts or creators..."] = "🔍 Chercher parmi %d scripts ou créateurs...",
		["🔎 Search all %d scripts or creators..."] = "🔎 Chercher dans les %d scripts ou créateurs...",
		["Loading %d scripts..."] = "Chargement de %d scripts...",
		["Ran %dx"] = "Lancé %dx",
		["Nothing selected yet.\nPaste an audio ID below and tap Play."] = "Rien de sélectionné.\nColle un ID audio ci-dessous et appuie sur Lecture.",
		["🎵 Paste audio ID or link..."] = "🎵 Colle un ID ou lien audio...",
		["▶ Play"] = "▶ Lecture",
		["💾 Save"] = "💾 Sauver",
		["Background music"] = "Musique de fond",
		["Turns the music on or off. The 🎵 button in the title bar does the same thing."] = "Active ou coupe la musique. Le bouton 🎵 de la barre de titre fait pareil.",
		["Loop this song"] = "Répéter ce morceau",
		["ON = the song repeats forever. OFF = it moves on to the next song in your playlist when it ends."] = "ON = le morceau se répète sans fin. OFF = passe au suivant de ta playlist à la fin.",
		["Music volume"] = "Volume de la musique",
		["How loud the music is (0 = silent, 100 = max)."] = "Volume de la musique (0 = muet, 100 = max).",
		["Where to get IDs: Creator Store > Audio, open a song and copy the number (or the whole link) from the page. Some audio is private and won't play. Tap 💾 Save to keep a song in 📻 Playlist."] = "Où trouver des IDs : Creator Store > Audio, ouvre un son et copie le numéro (ou le lien complet) de la page. Certains audios sont privés et ne se lisent pas. Touche 💾 Sauver pour garder un morceau dans 📻 Playlist.",
		["Empty. Play an ID in the 🎵 tab, then tap 💾 Save."] = "Vide. Joue un ID dans l'onglet 🎵, puis touche 💾 Sauver.",
		["Tap the song to play it. Use Remove to delete it from your playlist."] = "Touche le morceau pour le jouer. Utilise Retirer pour le supprimer de ta playlist.",
		["🗑 Remove"] = "🗑 Retirer",
		["Removed from playlist"] = "Retiré de la playlist",
		["Floating bats"] = "Chauves-souris volantes",
		["Little bats fly across your screen. Purely decoration."] = "De petites chauves-souris volent sur ton écran. Simple décoration.",
		["Pumpkin rain"] = "Pluie de citrouilles",
		["Makes pumpkins fall from the top of the screen for a few seconds."] = "Fait tomber des citrouilles du haut de l'écran pendant quelques secondes.",
		["Stops Roblox from kicking you for being idle (20 min). Great for long runs. Saved."] = "Empêche Roblox de t'expulser pour inactivité (20 min). Idéal pour les longues parties. Sauvegardé.",
		["Panic (hide everything)"] = "Panique (tout cacher)",
		["Instantly hides the hub and the pumpkin and stops the music. Press it again, the End key, or tap the faint dot in the top-left corner to bring everything back."] = "Cache instantanément le hub et la citrouille et coupe la musique. Appuie à nouveau, utilise la touche End ou touche le petit point discret en haut à gauche pour tout réafficher.",
		["Rejoin server"] = "Rejoindre le serveur",
		["Teleports you back into this same game."] = "Te téléporte de nouveau dans ce même jeu.",
		["Rejoin this game? You'll leave the current server."] = "Rejoindre ce jeu ? Tu quitteras le serveur actuel.",
		["Copies the place id and this server's job id (needs setclipboard)."] = "Copie le place id et le job id de ce serveur (nécessite setclipboard).",
		["📋 Copied!"] = "📋 Copié !",
		["FPS cap"] = "Limite de FPS",
		["Changes your max FPS (needs setfpscap)."] = "Change ton maximum de FPS (nécessite setfpscap).",
		["If a script button fails, check the ❌ above first."] = "Si un script échoue, regarde d'abord les ❌ ci-dessus.",
		["Reset favorites & stats"] = "Effacer favoris et stats",
		["Clears your favorites and the Most used counters. Playlist and settings stay."] = "Efface tes favoris et les compteurs « Les plus utilisés ». La playlist et les réglages restent.",
		["Clear all favorites and run counts?"] = "Effacer tous les favoris et compteurs ?",
		["🧹 Cleared"] = "🧹 Effacé",
		["Turns the little popup messages in the corner on or off."] = "Active ou désactive les petits messages dans le coin.",
		["Confirm before running"] = "Confirmer avant de lancer",
		["When ON, every script button asks 'Are you sure?' before it runs. Handy to avoid misclicks on a phone."] = "Si ON, chaque bouton de script demande « Tu es sûr ? » avant de se lancer. Pratique pour éviter les faux appuis sur mobile.",
		["Window size %"] = "Taille de la fenêtre %",
		["Makes the whole hub bigger or smaller (up to 130% so it is easier to tap on phones)."] = "Agrandit ou réduit tout le hub (jusqu'à 130 % pour toucher plus facilement sur mobile).",
		["Keybinds (PC)"] = "Raccourcis clavier (PC)",
		["Keyboard shortcuts: %s = show/hide, End = panic, Right Ctrl = run last script, Insert = music on/off. Turn OFF if you don't use a keyboard."] = "Raccourcis : %s = afficher/masquer, End = panique, Ctrl droit = relancer le dernier script, Insert = musique on/off. Désactive si tu n'utilises pas de clavier.",
		["On-screen buttons (mobile)"] = "Boutons à l'écran (mobile)",
		["Shows a small draggable bar with 🚨 panic, 🔁 run last script and 🎵 music, so phone and tablet players don't need the keybinds. ON by default on phones."] = "Affiche une petite barre déplaçable avec 🚨 panique, 🔁 dernier script et 🎵 musique, pour que les joueurs mobile/tablette n'aient pas besoin des raccourcis. ON par défaut sur mobile.",
		["Accent color"] = "Couleur d'accent",
		["Cycles the hub colors: Pumpkin, Blood, Toxic, Ghost, Gold, Sakura, Void, Mint. It's saved and shows up the next time you run the hub."] = "Change les couleurs du hub : Pumpkin, Blood, Toxic, Ghost, Gold, Sakura, Void, Mint. Sauvegardé, appliqué au prochain lancement du hub.",
		["🎨 %s selected. Re-run the hub to apply it."] = "🎨 %s choisi. Relance le hub pour l'appliquer.",
		["Language"] = "Langue",
		["Changes the hub language: English, Español, Português, Français. It's saved and shows up the next time you run the hub."] = "Change la langue du hub : English, Español, Português, Français. Sauvegardé, appliqué au prochain lancement du hub.",
		["🌐 %s selected. Re-run the hub to apply it."] = "🌐 %s choisi. Relance le hub pour l'appliquer.",
		["Reset positions"] = "Réinitialiser les positions",
		["Puts the hub back in the middle of the screen and the pumpkin back on the left."] = "Remet le hub au centre de l'écran et la citrouille à gauche.",
		["Close UI"] = "Fermer l'UI",
		["Closes the hub completely (it asks you first)."] = "Ferme complètement le hub (il demande confirmation).",
		["Random mode"] = "Mode aléatoire",
		["Picks a random mode from the Modes tabs and asks before running it."] = "Choisit un mode au hasard dans les onglets Modes et demande avant de le lancer.",
		["Say boo"] = "Dire bouh",
		["Shows a spooky popup. A good first button to test."] = "Affiche un message effrayant. Un bon premier bouton pour tester.",
		["Boo! 👻"] = "Bouh ! 👻",
		["Run last script again"] = "Relancer le dernier script",
		["Runs the last script you ran in this session again."] = "Relance le dernier script lancé durant cette session.",
		["Nothing run yet 👻"] = "Rien lancé pour l'instant 👻",
		["About V10"] = "À propos de la V10",
		["Version info for the hub."] = "Infos de version du hub.",
		["Tap the 🎃 to show/hide, 🚨 = panic"] = "Touche la 🎃 pour afficher/masquer, 🚨 = panique",
		["Show/hide:"] = "Afficher/masquer :",
		["Panic:"] = "Panique :",
		["Hub by Rip_Silence, GUI by WH1T3. Thanks for using the hub!"] = "Hub de Rip_Silence, GUI de WH1T3. Merci d'utiliser le hub !",
		["Run it?"] = "Le lancer ?",
		["No"] = "Non",
		["Run!"] = "Lancer !",
		["Close"] = "Fermer",
		["Cancel"] = "Annuler",
		["Execute"] = "Lancer",
		["Stay"] = "Rester",
		["Are you sure? ⚠️"] = "Tu es sûr ? ⚠️",
		["Are you sure you want to execute %s?"] = "Tu veux vraiment lancer %s ?",
		["Leaving so soon? 💀"] = "Tu pars déjà ? 💀",
		["Are you sure you want to close the hub?"] = "Tu veux vraiment fermer le hub ?",
		["No description yet."] = "Pas encore de description.",
		["Type:"] = "Type :",
		["Role:"] = "Rôle :",
		["Asks before running:"] = "Demande avant de lancer :",
		["Yes"] = "Oui",
		["Button"] = "Bouton",
		["Credit"] = "Crédit",
		["Toggle"] = "Interrupteur",
		["Slider"] = "Curseur",
		["⚠️ Script error (see console)"] = "⚠️ Erreur de script (voir la console)",
		["Minimized. Tap 🎃 to bring the hub back."] = "Réduit. Touche 🎃 pour réafficher le hub.",
		["⚠️ Couldn't load \"%s\" (bad id / url / file?)"] = "⚠️ Impossible de charger « %s » (mauvais id / url / fichier ?)",
		["🎵 Paste an audio ID in the Music tab first."] = "🎵 Colle d'abord un ID audio dans l'onglet Musique.",
		["🎵 Now playing: %s"] = "🎵 En lecture : %s",
		["⚠️ This song won't load. Wrong id, or the audio is private."] = "⚠️ Ce morceau ne charge pas. Mauvais ID ou audio privé.",
		["📻 Playlist is empty. Play an ID, then tap 💾 Save."] = "📻 La playlist est vide. Joue un ID puis touche 💾 Sauver.",
		["🎵 That doesn't look like an audio ID."] = "🎵 Ça ne ressemble pas à un ID audio.",
		["⚠️ That ID is not an audio asset."] = "⚠️ Cet ID n'est pas un audio.",
		["🎵 Loading %s..."] = "🎵 Chargement de %s...",
		["🎵 Nothing to save yet. Play an ID first."] = "🎵 Rien à sauvegarder. Joue d'abord un ID.",
		["📻 Already in your playlist."] = "📻 Déjà dans ta playlist.",
		["📻 Saved: %s"] = "📻 Sauvé : %s",
		["Removed from favorites"] = "Retiré des favoris",
		["⭐ Added to favorites"] = "⭐ Ajouté aux favoris",
		["💔 Unfavorite"] = "💔 Retirer des favoris",
		["⭐ Favorite"] = "⭐ Favori",
		["▶ Loading %s..."] = "▶ Chargement de %s...",
		["✅ %s loaded (%.1fs)"] = "✅ %s chargé (%.1fs)",
		["⚠️ %s failed: %s"] = "⚠️ %s a échoué : %s",
		["Welcome, %s! 🎃"] = "Bienvenue, %s ! 🎃",
		["Summoning ghosts..."] = "Invocation des fantômes...",
		["Carving pumpkins..."] = "Sculpture des citrouilles...",
		["Brewing potions..."] = "Préparation des potions...",
		["Waking the skeletons..."] = "Réveil des squelettes...",
		["Unlocking %d scripts..."] = "Déverrouillage de %d scripts...",
		["Almost ready..."] = "Presque prêt...",
		["Tip: tap the 🎃 to hide the hub"] = "Astuce : touche la 🎃 pour cacher le hub",
		["Tip: press %s or tap the 🎃 to hide the hub"] = "Astuce : appuie sur %s ou touche la 🎃 pour cacher le hub",
		["Tap a name or its three dots to see more."] = "Touche un nom ou ses trois points pour en voir plus.",
		["🌐 Languages: English, Español, Português, Français"] = "🌐 Langues : English, Español, Português, Français",
		["📱 Mobile mode: draggable on-screen buttons that replace the keybinds"] = "📱 Mode mobile : boutons déplaçables à l'écran qui remplacent les raccourcis",
		["⌨️ More keybinds (End, Right Ctrl, Insert) + toggles in Settings"] = "⌨️ Plus de raccourcis (End, Ctrl droit, Insert) + options dans Réglages",
		["🔍 Window size now goes up to 130% for phones"] = "🔍 La taille de la fenêtre va jusqu'à 130 % pour mobile",
		["🚨 Panic button / End key hides everything instantly"] = "🚨 Bouton panique / touche End cache tout instantanément",
		["ℹ️ About V36 popup on Home"] = "ℹ️ Fenêtre « À propos de la V36 » sur l'accueil",
		["🧹 Removed locked / deleted scripts for a cleaner list"] = "🧹 Scripts verrouillés/supprimés retirés pour une liste plus propre",
		["✨ Script of the day + 📈 all-time run counter on Home"] = "✨ Script du jour + 📈 compteur total sur l'accueil",
		["🚀 Scripts now load in the background, so the hub never freezes"] = "🚀 Les scripts se chargent en arrière-plan, le hub ne gèle plus",
		["✅ Success / ⚠️ error popups for every script you run"] = "✅ Messages de succès / ⚠️ erreur pour chaque script lancé",
		["🔥 Most used scripts + 🔁 Run last script again"] = "🔥 Scripts les plus utilisés + 🔁 Relancer le dernier",
		["🔎 Search by script name OR creator (try \"Guestly\")"] = "🔎 Cherche par nom de script OU créateur (essaie « Guestly »)",
		["🧰 New Tools tab: Anti-AFK, rejoin, copy IDs, FPS cap"] = "🧰 Nouvel onglet Outils : Anti-AFK, rejoindre, copier les IDs, limite de FPS",
		["🩺 Executor check: see which functions your executor supports"] = "🩺 Test de l'executor : vois quelles fonctions il supporte",
		["📊 Live FPS, ping and session timer on Home"] = "📊 FPS, ping et durée de session en direct sur l'accueil",
		["🎨 5 accent colors in Settings"] = "🎨 5 couleurs d'accent dans Réglages",
		["🎵 Music player, 📻 playlist, ⭐ favorites and 🎲 random mode"] = "🎵 Lecteur, 📻 playlist, ⭐ favoris et 🎲 mode aléatoire",
		["📝 Notes"] = "📝 Notes",
		["↕ Default"] = "↕ Défaut",
		["🆕 Newest"] = "🆕 Récents",
		["↕ Sorting: %s"] = "↕ Tri : %s",
		["🆕 NEW SCRIPTS"] = "🆕 NOUVEAUX SCRIPTS",
		["Every new script has a 🆕 in front of its name."] = "Chaque nouveau script a un 🆕 devant son nom.",
		["MY NOTES"] = "MES NOTES",
		["Write anything here: ideas, audio IDs, script names. It saves automatically."] = "Écris ce que tu veux : idées, IDs audio, noms de scripts. Sauvegarde automatique.",
		["📝 Type your notes here..."] = "📝 Écris tes notes ici...",
		["Copy notes"] = "Copier les notes",
		["Copies all your notes (needs setclipboard)."] = "Copie toutes tes notes (nécessite setclipboard).",
		["Clear notes"] = "Effacer les notes",
		["Deletes everything you wrote in Notes."] = "Supprime tout ce que tu as écrit dans Notes.",
		["Delete all your notes?"] = "Supprimer toutes tes notes ?",
		["Hide hub after running a script"] = "Cacher le hub après un script",
		["After you run a script the hub hides itself so you can see the game. Bring it back with the 🎃, your key or the quick bar."] = "Après un script, le hub se cache pour que tu voies le jeu. Reviens avec le 🎃, ta touche ou la barre rapide.",
		["Copy my favorites list"] = "Copier ma liste de favoris",
		["Copies the names of all your favorite scripts so you can share them (needs setclipboard)."] = "Copie les noms de tes scripts favoris pour les partager (nécessite setclipboard).",
		["Nothing to copy yet ⭐"] = "Rien à copier pour l'instant ⭐",
		["VISUALS"] = "VISUELS",
		["Field of view"] = "Champ de vision",
		["Changes your camera field of view (the game may reset it). Use Reset FOV to go back."] = "Change le champ de vision de ta caméra (le jeu peut le réinitialiser). Utilise Reset FOV pour revenir.",
		["Reset FOV"] = "Réinitialiser le FOV",
		["Puts your camera field of view back to what it was when the hub started."] = "Remet le champ de vision à sa valeur au lancement du hub.",
		["FPS boost"] = "Boost de FPS",
		["Turns off shadows and lowers graphics quality for more FPS. Turn it OFF to restore your old settings."] = "Désactive les ombres et baisse la qualité graphique pour plus de FPS. Désactive pour tout restaurer.",
		["🚀 FPS boost ON"] = "🚀 Boost de FPS ACTIVÉ",
		["FPS boost OFF"] = "Boost de FPS désactivé",
		["Copy debug info"] = "Copier les infos de debug",
		["Copies your executor, language and hub version so you can paste it when reporting a bug (no personal info). Needs setclipboard."] = "Copie ton executor, ta langue et la version du hub pour les coller dans un rapport de bug (aucune donnée perso). Nécessite setclipboard.",
		["Reset EVERYTHING"] = "TOUT réinitialiser",
		["Wipes ALL saved data: favorites, stats, playlist, notes and settings. Re-run the hub afterwards."] = "Efface TOUTES les données : favoris, stats, playlist, notes et réglages. Relance le hub ensuite.",
		["Wipe ALL saved data? This can't be undone."] = "Effacer TOUTES les données ? Action irréversible.",
		["🧹 Everything reset. Re-run the hub."] = "🧹 Tout est réinitialisé. Relance le hub.",
		["⭐ Favorites: %d  •  ▶ This session: %d"] = "⭐ Favoris : %d  •  ▶ Cette session : %d",
		["The script link is dead (404). It may have been deleted."] = "Le lien du script est mort (404). Il a peut-être été supprimé.",
		["Your executor blocked the download."] = "Ton executor a bloqué le téléchargement.",
		["The download timed out. Try again."] = "Le téléchargement a expiré. Réessaie.",
		["Your executor doesn't support loadstring."] = "Ton executor ne supporte pas loadstring.",
		["Shuffle"] = "Aléatoire",
		["ON = the next song is picked at random. Works with the ⏭ / ⏮ buttons and when a song ends (Loop OFF)."] = "ON = la chanson suivante est choisie au hasard. Marche avec ⏭ / ⏮ et à la fin d'une chanson (Loop OFF).",
		["Resume music on start"] = "Reprendre la musique au lancement",
		["ON = your last song starts playing when the hub opens. Turn OFF if you want silence at the start."] = "ON = ta dernière chanson démarre à l'ouverture du hub. Désactive pour le silence au démarrage.",
		["WHAT'S NEW IN V10"] = "NOUVEAUTÉS DE LA V10",
		["EARLIER UPDATES"] = "MISES À JOUR PRÉCÉDENTES",
		["🎃 What's new in V10"] = "🎃 Nouveautés de la V10",
		["Awesome!"] = "Génial !",
		["🆕 NEW badges on new scripts + a New section on Home"] = "🆕 Badges NOUVEAU sur les scripts récents + section Nouveautés sur l'accueil",
		["↕ Sort button in every tab: Default, A→Z, Z→A, Newest"] = "↕ Bouton de tri dans chaque onglet : Défaut, A→Z, Z→A, Récents",
		["🔢 Script counts on every tab"] = "🔢 Nombre de scripts sur chaque onglet",
		["📝 Notes tab (saved automatically)"] = "📝 Onglet Notes (sauvegarde automatique)",
		["🙈 Option to hide the hub after you run a script"] = "🙈 Option pour cacher le hub après un script",
		["🔭 FOV slider + 🚀 FPS boost in Tools"] = "🔭 Curseur de FOV + 🚀 boost de FPS dans Outils",
		["🐞 Copy debug info button for bug reports"] = "🐞 Bouton pour copier les infos de debug lors d'un bug",
		["🔀 Shuffle + resume-on-start for the music player"] = "🔀 Lecture aléatoire et reprise au lancement pour le lecteur de musique",
		["🎨 3 new accent colors: Sakura, Void, Mint"] = "🎨 3 nouvelles couleurs : Sakura, Void, Mint",
		["💬 Friendlier error messages when a script fails"] = "💬 Messages d'erreur plus clairs quand un script échoue",
		["📋 Copy your favorites list"] = "📋 Copie ta liste de favoris",
		["🧹 Reset everything button (Tools > Data)"] = "🧹 Bouton pour tout réinitialiser (Outils > Données)",
	},
}
local langCode = saved.lang
if langCode == nil then
	local okL, localeId = pcall(function()
		return game:GetService("LocalizationService").RobloxLocaleId
	end)
	langCode = okL and tostring(localeId):sub(1, 2):lower() or "en"
end
if langCode ~= "en" and not TRANSLATIONS[langCode] then
	langCode = "en"
end
-- Add-ons can set HubHooks.textFilter = function(text) ... end to restyle every piece of UI text.
local HubHooks = { textFilter = nil }

local function T(text, code)
	if type(text) ~= "string" then
		return text
	end
	local tr = TRANSLATIONS[code or langCode]
	local res = (tr and tr[text]) or text
	if HubHooks.textFilter then
		local okF, out = pcall(HubHooks.textFilter, res)
		if okF and type(out) == "string" then
			return out
		end
	end
	return res
end
local function TL(code, key, ...)
	local okF, out = pcall(string.format, T(key, code), ...)
	return okF and out or key
end
local function TF(key, ...)
	return TL(langCode, key, ...)
end

local keyNames = {}
for _, k in ipairs(TOGGLE_KEYS) do
	table.insert(keyNames, k.Name)
end
-- true on phones/tablets without a keyboard
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local TOGGLE_KEY_TEXT = (#keyNames > 0 and not isMobile) and table.concat(keyNames, " / ") or T("the 🎃 button")

-- Remove ANY old copies (older versions or a previous run of this script)
local OLD_NAMES = { "HalloweenHub", "HalloweenHubV2", "HalloweenHubV3", "HalloweenHubV4", "HalloweenHubV5", "Silence hub V36. WH1T3 hub V6", "DoorsModesHubV37", "DoorsModesHubV36", "Silence hub V36 - WH1T3 GUI V7.5", "Silence hub V36 - WH1T3 GUI V10", "Silence hub V36 - WH1T3 GUI V11", GUI_NAME }
for _, child in ipairs(playerGui:GetChildren()) do
	if table.find(OLD_NAMES, child.Name) then
		child:Destroy()
	end
end

----------------------------------------------------------------
-- THEME + HELPERS
----------------------------------------------------------------
local THEME = {
	bg = Color3.fromRGB(16, 11, 22),
	panel = Color3.fromRGB(30, 21, 42),
	panelLight = Color3.fromRGB(46, 33, 64),
	orange = Color3.fromRGB(255, 128, 0),
	purple = Color3.fromRGB(150, 70, 210),
	text = Color3.fromRGB(240, 230, 220),
	muted = Color3.fromRGB(165, 150, 180),
	danger = Color3.fromRGB(200, 50, 60),
}

-- Accent color presets (Settings > Accent color). Applied when the hub starts.
local ACCENTS = {
	{ name = "Pumpkin", main = Color3.fromRGB(255, 128, 0), alt = Color3.fromRGB(150, 70, 210) },
	{ name = "Blood", main = Color3.fromRGB(235, 45, 65), alt = Color3.fromRGB(130, 25, 70) },
	{ name = "Toxic", main = Color3.fromRGB(80, 255, 120), alt = Color3.fromRGB(30, 140, 100) },
	{ name = "Ghost", main = Color3.fromRGB(100, 195, 255), alt = Color3.fromRGB(110, 90, 230) },
	{ name = "Gold", main = Color3.fromRGB(255, 205, 70), alt = Color3.fromRGB(200, 120, 40) },
	{ name = "Sakura", main = Color3.fromRGB(255, 130, 190), alt = Color3.fromRGB(170, 70, 140) },
	{ name = "Void", main = Color3.fromRGB(175, 125, 255), alt = Color3.fromRGB(70, 45, 120) },
	{ name = "Mint", main = Color3.fromRGB(70, 235, 190), alt = Color3.fromRGB(25, 120, 125) },
}
local accentIndex = 1
for i, a in ipairs(ACCENTS) do
	if a.name == saved.accent then
		accentIndex = i
	end
end
THEME.orange = ACCENTS[accentIndex].main
THEME.purple = ACCENTS[accentIndex].alt

-- make("Frame", { Size = ..., ... }, parent) -> creates, sets props, parents LAST
local function make(class, props, parent)
	local obj = Instance.new(class)
	if obj:IsA("GuiObject") then
		obj.BorderSizePixel = 0
	end
	if obj:IsA("GuiButton") then
		obj.AutoButtonColor = false
	end
	for prop, value in pairs(props) do
		obj[prop] = value
	end
	obj.Parent = parent
	return obj
end

local function tween(obj, time, props, style, dir)
	local t = TweenService:Create(
		obj,
		TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
		props
	)
	t:Play()
	return t
end

local function pulse(obj, prop, toValue, time)
	TweenService:Create(
		obj,
		TweenInfo.new(time or 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ [prop] = toValue }
	):Play()
end

local function corner(obj, radius)
	return make("UICorner", { CornerRadius = UDim.new(0, radius) }, obj)
end

local function stroke(obj, color, thickness)
	return make("UIStroke", {
		Color = color,
		Thickness = thickness,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, obj)
end

local layoutCounter = 0
local function nextOrder()
	layoutCounter += 1
	return layoutCounter
end

-- Fades a frame and everything inside it
local function fadeOut(root, time)
	local info = TweenInfo.new(time)
	local function go(obj)
		if obj:IsA("GuiObject") then
			TweenService:Create(obj, info, { BackgroundTransparency = 1 }):Play()
		end
		if obj:IsA("TextLabel") or obj:IsA("TextButton") then
			TweenService:Create(obj, info, { TextTransparency = 1 }):Play()
		end
		if obj:IsA("UIStroke") then
			TweenService:Create(obj, info, { Transparency = 1 }):Play()
		end
	end
	go(root)
	for _, d in ipairs(root:GetDescendants()) do
		go(d)
	end
end

-- Global connections get cleaned up when the UI is destroyed
local connections = {}
local function track(conn)
	table.insert(connections, conn)
	return conn
end

local gui = make("ScreenGui", {
	Name = GUI_NAME,
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 100,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui) -- change this parent if your hub loads differently

gui.Destroying:Connect(function()
	for _, c in ipairs(connections) do
		c:Disconnect()
	end
end)

----------------------------------------------------------------
-- EVERYTHING BELOW RUNS INSIDE pcall:
-- if anything errors, the UI removes itself (no stuck boxes)
-- and the error is printed.
----------------------------------------------------------------
local ok, err = pcall(function()
	-- Layer order: effects 1 < window 5 < pumpkin 10 < toasts 50 < loading 100
	local effectsLayer = make("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 1,
	}, gui)

	------------------------------------------------------------
	-- TOASTS
	------------------------------------------------------------
	local notificationsEnabled = saved.notifications ~= false

	local toastHolder = make("Frame", {
		Size = UDim2.new(0, 260, 1, -30),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 12),
		BackgroundTransparency = 1,
		ZIndex = 50,
	}, gui)
	make("UIListLayout", {
		Padding = UDim.new(0, 6),
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, toastHolder)

	local function notify(text, duration)
		if not notificationsEnabled then
			return
		end
		local slot = make("Frame", {
			Size = UDim2.fromOffset(250, 44),
			BackgroundTransparency = 1,
			LayoutOrder = nextOrder(),
		}, toastHolder)
		local toast = make("Frame", {
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.new(1.4, 0, 0, 0),
			BackgroundColor3 = THEME.panel,
		}, slot)
		corner(toast, 8)
		stroke(toast, THEME.orange, 1)
		make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -24, 1, 0),
			Position = UDim2.fromOffset(16, 0),
			Text = T(text),
			TextColor3 = THEME.text,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextWrapped = true,
		}, toast)

		-- V12: glowing accent bar on the left + a timer bar that shrinks until the toast leaves
		toast.ClipsDescendants = true
		local accentBar = make("Frame", {
			Size = UDim2.new(0, 4, 1, 0),
			BackgroundColor3 = THEME.orange,
		}, toast)
		local timerBar = make("Frame", {
			Size = UDim2.new(1, 0, 0, 2),
			Position = UDim2.new(0, 0, 1, -2),
			BackgroundColor3 = THEME.purple,
		}, toast)
		tween(timerBar, duration or 2.5, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
		tween(toast, 0.3, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)
		task.delay(duration or 2.5, function()
			tween(toast, 0.25, { Position = UDim2.new(1.4, 0, 0, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			task.wait(0.3)
			slot:Destroy()
		end)
	end
	hub.notify = notify -- now your buttons can call hub.notify("text")

	-- Runs a callback safely: one broken button can't break the whole UI
	local function safeCall(fn, ...)
		local success, e = pcall(fn, ...)
		if not success then
			warn("[HalloweenHub] callback error:", e)
			notify("⚠️ Script error (see console)")
		end
	end

	------------------------------------------------------------
	-- DRAGGING (mouse + touch). A short tap counts as a click.
	------------------------------------------------------------
	local function makeDraggable(handle, target, onTap, onDrop)
		local dragging, moved = false, false
		local dragStart, startPos

		handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging, moved = true, false
				dragStart = input.Position
				startPos = target.Position
			end
		end)
		track(UserInputService.InputChanged:Connect(function(input)
			if not dragging then
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch then
				local delta = input.Position - dragStart
				if delta.Magnitude > 6 then
					moved = true
				end
				if moved then
					target.Position = UDim2.new(
						startPos.X.Scale, startPos.X.Offset + delta.X,
						startPos.Y.Scale, startPos.Y.Offset + delta.Y
					)
				end
			end
		end))
		track(UserInputService.InputEnded:Connect(function(input)
			if not dragging then
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
				if moved then
					if onDrop then
						onDrop()
					end
				elseif onTap then
					onTap()
				end
			end
		end))
	end

	------------------------------------------------------------
	-- WINDOW (sized to fit your screen)
	------------------------------------------------------------
	local BASE_W, BASE_H = 470, 300

	local screen = gui.AbsoluteSize
	if screen.X < 100 or screen.Y < 100 then
		local cam = workspace.CurrentCamera
		screen = cam and cam.ViewportSize or Vector2.new(800, 450)
	end
	local fit = math.clamp(math.min(screen.X * 0.9 / BASE_W, screen.Y * 0.75 / BASE_H), 0.5, 1)
	local userScale = 1
	local function targetScale()
		return fit * userScale
	end

	local window = make("Frame", {
		Size = UDim2.fromOffset(BASE_W, BASE_H),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = THEME.bg,
		Visible = false,
		ZIndex = 5,
	}, gui)
	corner(window, 12)
	local uiScale = make("UIScale", { Scale = 0.7 }, window)

	-- V12: soft dark-to-lighter background so the window isn't one flat color
	make("UIGradient", {
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(190, 165, 215)),
		Rotation = 90,
	}, window)

	-- V12: border made of a color gradient that spins around the window.
	-- Rainbow mode (Settings) swaps the colors for a cycling rainbow.
	local borderStroke = stroke(window, Color3.new(1, 1, 1), 2.5)
	local function accentSequence()
		return ColorSequence.new({
			ColorSequenceKeypoint.new(0, THEME.orange),
			ColorSequenceKeypoint.new(0.5, THEME.purple),
			ColorSequenceKeypoint.new(1, THEME.orange),
		})
	end
	local borderGrad = make("UIGradient", { Color = accentSequence() }, borderStroke)
	local rainbowOn = saved.rainbow == true
	local rainbowHue = 0
	local function setRainbow(on)
		rainbowOn = on
		if not on then
			borderGrad.Color = accentSequence()
		end
	end
	track(RunService.Heartbeat:Connect(function(dt)
		if not window.Visible then
			return -- no point animating a hidden window
		end
		borderGrad.Rotation = (borderGrad.Rotation + dt * 70) % 360
		if rainbowOn then
			rainbowHue = (rainbowHue + dt * 0.2) % 1
			borderGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(rainbowHue, 0.85, 1)),
				ColorSequenceKeypoint.new(0.5, Color3.fromHSV((rainbowHue + 0.33) % 1, 0.85, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV((rainbowHue + 0.66) % 1, 0.85, 1)),
			})
		end
	end))

	-- V12: tiny glowing dots drifting up behind everything (Settings > Background sparkles)
	local sparklesOn = saved.sparkles ~= false
	local sparkLayer = make("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 5,
	}, window)
	for _ = 1, 14 do
		task.spawn(function()
			local d = make("Frame", {
				Size = UDim2.fromOffset(math.random(3, 6), math.random(3, 6)),
				Position = UDim2.fromScale(0, 1.1),
				BackgroundColor3 = math.random() < 0.5 and THEME.orange or THEME.purple,
				BackgroundTransparency = 1,
			}, sparkLayer)
			corner(d, 3)
			task.wait(math.random() * 4)
			while window:IsDescendantOf(game) do
				if sparklesOn and window.Visible then
					local x = math.random()
					local dur = math.random(40, 90) / 10
					d.Position = UDim2.fromScale(x, 1.02)
					tween(d, dur * 0.2, { BackgroundTransparency = 0.5 })
					tween(d, dur, {
						Position = UDim2.fromScale(math.clamp(x + (math.random() - 0.5) * 0.1, 0, 1), -0.05),
					}, Enum.EasingStyle.Linear)
					task.wait(dur * 0.8)
					tween(d, dur * 0.2, { BackgroundTransparency = 1 })
					task.wait(dur * 0.2)
				else
					task.wait(0.5)
				end
			end
			d:Destroy()
		end)
	end

	local topBar = make("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = THEME.panel,
	}, window)
	corner(topBar, 12)
	make("Frame", {
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 1, -12),
		BackgroundColor3 = THEME.panel,
	}, topBar)

	local titleLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -150, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		Text = "🎃 " .. HUB_TITLE,
		TextColor3 = Color3.new(1, 1, 1), -- the gradient below supplies the color
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, topBar)
	-- V12: a bright "shine" sweeps across the title forever
	local titleGrad = make("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, THEME.orange),
			ColorSequenceKeypoint.new(0.4, THEME.orange),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 245, 225)),
			ColorSequenceKeypoint.new(0.6, THEME.orange),
			ColorSequenceKeypoint.new(1, THEME.orange),
		}),
		Offset = Vector2.new(-1, 0),
	}, titleLabel)
	TweenService:Create(
		titleGrad,
		TweenInfo.new(2.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
		{ Offset = Vector2.new(1, 0) }
	):Play()

	local function topButton(text, xOffset, color)
		local b = make("TextButton", {
			Size = UDim2.fromOffset(28, 28),
			Position = UDim2.new(1, xOffset, 0, 4),
			BackgroundColor3 = color,
			Text = text,
			TextColor3 = THEME.text,
			Font = Enum.Font.GothamBold,
			TextSize = 16,
		}, topBar)
		corner(b, 8)
		return b
	end
	local minBtn = topButton("-", -68, THEME.purple)
	local closeBtn = topButton("X", -34, THEME.danger)
	local musicBtn = topButton("🎵", -102, THEME.panelLight)

	local body = make("Frame", {
		Size = UDim2.new(1, 0, 1, -36),
		Position = UDim2.fromOffset(0, 36),
		BackgroundTransparency = 1,
	}, window)

	local tabList = make("ScrollingFrame", {
		Size = UDim2.new(0, 124, 1, -14),
		Position = UDim2.fromOffset(8, 6),
		BackgroundTransparency = 1,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = THEME.orange,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, body)
	make("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, tabList)

	local pageArea = make("Frame", {
		Size = UDim2.new(1, -148, 1, -14),
		Position = UDim2.fromOffset(140, 6),
		BackgroundColor3 = THEME.panel,
	}, body)
	corner(pageArea, 10)

	------------------------------------------------------------
	-- DIALOG (one reusable popup: details, confirmations, close)
	------------------------------------------------------------
	local overlay = make("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.4,
		Active = true, -- blocks clicks from reaching the window underneath
		Visible = false,
		ZIndex = 20,
	}, window)
	corner(overlay, 12)

	local dialog = make("Frame", {
		Size = UDim2.fromOffset(330, 190),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = THEME.panel,
	}, overlay)
	corner(dialog, 12)
	local dialogStroke = stroke(dialog, THEME.purple, 2)
	local dialogScale = make("UIScale", { Scale = 1 }, dialog)

	local dialogTitle = make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -20, 0, 36),
		Position = UDim2.fromOffset(10, 6),
		Text = "",
		TextColor3 = THEME.orange,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, dialog)

	-- scrolls if the text is long
	local bodyScroll = make("ScrollingFrame", {
		Size = UDim2.new(1, -24, 1, -96),
		Position = UDim2.fromOffset(12, 44),
		BackgroundTransparency = 1,
		ScrollBarThickness = 2,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, dialog)
	local dialogBody = make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -6, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		TextColor3 = THEME.text,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	}, bodyScroll)

	local function dialogButton()
		local b = make("TextButton", {
			Size = UDim2.new(0.5, -15, 0, 32),
			BackgroundColor3 = THEME.purple,
			Text = "",
			TextColor3 = THEME.text,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
		}, dialog)
		corner(b, 8)
		return b
	end
	local btnA, btnB = dialogButton(), dialogButton()
	local callbackA, callbackB

	btnA.MouseButton1Click:Connect(function()
		overlay.Visible = false
		if callbackA then
			safeCall(callbackA)
		end
	end)
	btnB.MouseButton1Click:Connect(function()
		overlay.Visible = false
		if callbackB then
			safeCall(callbackB)
		end
	end)

	-- opts = { title, body, accent, a = {text, color, callback}, b = {text, color, callback} }
	-- If you only give "a", it becomes one wide button.
	local function showDialog(opts)
		dialogStroke.Color = opts.accent or THEME.purple
		dialogTitle.Text = T(opts.title or "")
		dialogBody.Text = T(opts.body or "")
		bodyScroll.CanvasPosition = Vector2.new(0, 0)

		btnA.Text = T(opts.a[1])
		btnA.BackgroundColor3 = opts.a[2] or THEME.purple
		callbackA = opts.a[3]

		if opts.b then
			btnA.Size = UDim2.new(0.5, -15, 0, 32)
			btnA.Position = UDim2.new(0, 10, 1, -42)
			btnB.Visible = true
			btnB.Position = UDim2.new(0.5, 5, 1, -42)
			btnB.Text = T(opts.b[1])
			btnB.BackgroundColor3 = opts.b[2] or THEME.danger
			callbackB = opts.b[3]
		else
			btnA.Size = UDim2.new(1, -20, 0, 32)
			btnA.Position = UDim2.new(0, 10, 1, -42)
			btnB.Visible = false
			callbackB = nil
		end

		overlay.Visible = true
		dialogScale.Scale = 0.85
		tween(dialogScale, 0.2, { Scale = 1 }, Enum.EasingStyle.Back)
	end

	-- The popup behind every three-dots button
	local function showDetails(def, kind)
		local text = T(def.description or "No description yet.")
		text ..= "\n\n" .. T("Type:") .. " " .. T(kind)
		if def.subtitle and kind == "Credit" then
			text ..= "\n" .. T("Role:") .. " " .. T(def.subtitle)
		end
		if kind == "Button" then
			text ..= "\n" .. T("Asks before running:") .. " " .. (def.confirm and T("Yes") or T("No"))
		end
		local extra = def.getExtra and def.getExtra()
		showDialog({
			title = (def.icon and (def.icon .. " ") or "") .. T(def.name),
			body = text,
			accent = THEME.purple,
			a = { "Close", THEME.purple },
			b = extra,
		})
	end

	------------------------------------------------------------
	-- OPEN / CLOSE (minimize = hide into the pumpkin)
	------------------------------------------------------------
	local isOpen = false

	local function setOpen(open)
		if open == isOpen then
			return
		end
		isOpen = open
		if open then
			window.Visible = true
			uiScale.Scale = targetScale() * 0.7
			tween(uiScale, 0.3, { Scale = targetScale() }, Enum.EasingStyle.Back)
		else
			tween(uiScale, 0.2, { Scale = 0.05 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			task.delay(0.22, function()
				if not isOpen then
					window.Visible = false
				end
			end)
		end
	end

	local function askToClose()
		showDialog({
			title = "Leaving so soon? 💀",
			body = "Are you sure you want to close the hub?",
			accent = THEME.danger,
			a = { "Stay", THEME.purple },
			b = { "Close", THEME.danger, function()
				setOpen(false)
				task.wait(0.3)
				gui:Destroy()
			end },
		})
	end

	makeDraggable(topBar, window)
	closeBtn.MouseButton1Click:Connect(askToClose)
	minBtn.MouseButton1Click:Connect(function()
		setOpen(false)
		notify("Minimized. Tap 🎃 to bring the hub back.")
	end)

	------------------------------------------------------------
	-- BACKGROUND MUSIC
	------------------------------------------------------------
	local MarketplaceService = game:GetService("MarketplaceService")

	local musicOn = false
	local musicVolume = math.clamp(saved.volume or MUSIC_VOLUME, 0, 100)
	local loopTrack = saved.loop ~= false
	local shuffleOn = saved.shuffle == true
	local autoplayOn = saved.autoplay
	if autoplayOn == nil then
		autoplayOn = MUSIC_AUTOPLAY
	end
	local playToken = 0
	local musicToggleSet -- filled in when the Music tab is built
	local musicListeners = {} -- called whenever the song / play state changes
	local nowLabel -- the "Now playing" label (Music tab)

	local playlist = {}
	for _, t in ipairs(MUSIC_TRACKS) do
		table.insert(playlist, t)
	end
	for _, t in ipairs(saved.playlist) do
		table.insert(playlist, t)
	end
	local current = (type(saved.last) == "table" and saved.last) or playlist[1]
	local loadedTrack = nil

	local sound = make("Sound", {
		Name = "HubMusic",
		Looped = loopTrack,
		Volume = musicVolume / 100,
	}, gui) -- lives inside the hub, so closing the hub stops the music

	local function fireMusicChanged()
		for _, fn in ipairs(musicListeners) do
			task.spawn(fn)
		end
	end

	local function updateMusicButton()
		tween(musicBtn, 0.15, {
			BackgroundColor3 = musicOn and THEME.orange or THEME.panelLight,
		})
	end

	local function trackName(t)
		return (t and t.name) or "Unknown song"
	end

	local function sameTrack(a, b)
		return a ~= nil and b ~= nil
			and tostring(a.id) == tostring(b.id)
			and tostring(a.url) == tostring(b.url)
			and tostring(a.file) == tostring(b.file)
	end

	local function indexOfTrack(t)
		for i, other in ipairs(playlist) do
			if sameTrack(other, t) then
				return i
			end
		end
		return nil
	end

	-- Turns a track entry into something Sound.SoundId understands
	local function resolveTrack(track)
		if track.id and tostring(track.id) ~= "" and tostring(track.id) ~= "0" then
			local id = tostring(track.id)
			if not id:find("rbxasset") and not id:find("http") then
				id = "rbxassetid://" .. id
			end
			return id
		end

		local getAsset = getcustomasset or getsynasset
		if getAsset and writefile and isfile then
			local path = track.file
			if track.url then
				local safeName = tostring(track.name or "track"):gsub("%W", "_")
				path = path or ("HalloweenHub_" .. safeName .. ".mp3")
				if not isfile(path) then
					writefile(path, game:HttpGet(track.url))
				end
			end
			if path and isfile(path) then
				return getAsset(path)
			end
		end
		return nil
	end

	local function ensureTrack()
		if loadedTrack == current then
			return true
		end
		local okRes, soundId = pcall(resolveTrack, current)
		if not okRes or not soundId then
			notify(TF("⚠️ Couldn't load \"%s\" (bad id / url / file?)", trackName(current)), 4)
			return false
		end
		sound:Stop()
		sound.SoundId = soundId
		loadedTrack = current
		return true
	end

	local function setMusic(on)
		if on then
			if not current then
				notify("🎵 Paste an audio ID in the Music tab first.", 3.5)
				on = false
			elseif not ensureTrack() then
				on = false
			else
				sound:Play()
				notify(TF("🎵 Now playing: %s", trackName(current)), 2.5)

				-- warn if Roblox refuses to load it (private audio / wrong id)
				playToken += 1
				local myToken = playToken
				task.delay(8, function()
					if myToken == playToken and musicOn and sound.Parent and not sound.IsLoaded then
						notify("⚠️ This song won't load. Wrong id, or the audio is private.", 4.5)
					end
				end)
			end
		else
			playToken += 1
			sound:Pause()
		end
		musicOn = on
		updateMusicButton()
		if musicToggleSet then
			musicToggleSet(on)
		end
		fireMusicChanged()
		return on
	end

	local function playTrack(track)
		current = track
		loadedTrack = nil
		saved.last = { name = track.name, id = track.id, url = track.url, file = track.file }
		saveData()
		sound:Stop()
		setMusic(true)
	end

	local function stepTrack(dir)
		if #playlist == 0 then
			notify("📻 Playlist is empty. Play an ID, then tap 💾 Save.", 3.5)
			return
		end
		local i = indexOfTrack(current) or (dir > 0 and 0 or 1)
		if shuffleOn and #playlist > 1 then
			local r = i
			while r == i do
				r = math.random(#playlist)
			end
			i = r
		else
			i = (i - 1 + dir) % #playlist + 1
		end
		playTrack(playlist[i])
	end

	-- Paste an id, a "rbxassetid://..." or a Creator Store link
	local function playById(text)
		local digits = tostring(text or ""):match("%d+")
		if not digits or #digits < 5 then
			notify("🎵 That doesn't look like an audio ID.", 3)
			return
		end
		local name = "ID " .. digits
		local okInfo, info = pcall(function()
			return MarketplaceService:GetProductInfo(tonumber(digits))
		end)
		if okInfo and type(info) == "table" then
			if info.AssetTypeId and info.AssetTypeId ~= 3 then
				notify("⚠️ That ID is not an audio asset.", 3.5)
				return
			end
			if info.Name then
				name = info.Name
			end
		end
		notify(TF("🎵 Loading %s...", name), 2)
		playTrack({ name = name, id = digits })
	end

	local function saveCurrentToPlaylist()
		if not current then
			notify("🎵 Nothing to save yet. Play an ID first.", 3)
			return
		end
		if indexOfTrack(current) then
			notify("📻 Already in your playlist.", 2)
			return
		end
		local entry = { name = current.name, id = current.id, url = current.url, file = current.file }
		table.insert(playlist, entry)
		table.insert(saved.playlist, entry)
		saveData()
		notify(TF("📻 Saved: %s", trackName(entry)), 2.5)
		fireMusicChanged()
	end

	local function removeFromPlaylist(track)
		local i = indexOfTrack(track)
		if i then
			table.remove(playlist, i)
		end
		for j, t in ipairs(saved.playlist) do
			if sameTrack(t, track) then
				table.remove(saved.playlist, j)
				break
			end
		end
		saveData()
		fireMusicChanged()
	end

	local function setLoop(on)
		loopTrack = on
		sound.Looped = on
		saved.loop = on
		saveData()
	end

	sound.Ended:Connect(function() -- only fires when "Loop" is off
		if musicOn and not loopTrack then
			stepTrack(1)
		end
	end)

	local function fmtTime(s)
		s = math.max(0, math.floor(s or 0))
		return string.format("%d:%02d", s // 60, s % 60)
	end

	local function nowPlayingText()
		if not current then
			return T("Nothing selected yet.\nPaste an audio ID below and tap Play.")
		end
		local line = (musicOn and "▶ " or "⏸ ") .. trackName(current)
		if sound.IsLoaded and sound.TimeLength > 0 then
			line ..= "\n" .. fmtTime(sound.TimePosition) .. " / " .. fmtTime(sound.TimeLength)
		end
		return line
	end

	task.spawn(function()
		while gui.Parent do
			if nowLabel and nowLabel.Parent then
				nowLabel.Text = nowPlayingText()
			end
			task.wait(0.5)
		end
	end)

	musicBtn.MouseButton1Click:Connect(function()
		setMusic(not musicOn)
	end)
	------------------------------------------------------------
	-- TABS + COMPONENTS
	------------------------------------------------------------
	local pages = {}
	local tabButtons = {}
	local staleTabs, sortRebuilders = {}, {}
	local builders = {}          -- script tabs fill themselves the first time you open them
	local refreshers = {}        -- pages that rebuild every time you open them
	local confirmScripts = saved.confirm == true -- Settings > "Confirm before running"
	local recent = {}            -- last scripts you ran (this session)

	local function pushRecent(def)
		for i = #recent, 1, -1 do
			if recent[i].key == def.key then
				table.remove(recent, i)
			end
		end
		table.insert(recent, 1, def)
		while #recent > 10 do
			table.remove(recent)
		end
	end

	-- Runs a script button WITHOUT freezing the hub, counts it for "Most used",
	-- and tells you if it worked or failed.
	-- Turns ugly executor errors into something a human can read
	local function friendlyError(msg)
		local low = msg:lower()
		if low:find("http 404", 1, true) or low:find("404 (not found)", 1, true) then
			return T("The script link is dead (404). It may have been deleted.")
		elseif low:find("http requests are not enabled", 1, true) then
			return T("Your executor blocked the download.")
		elseif low:find("timed out", 1, true) then
			return T("The download timed out. Try again.")
		elseif low:find("loadstring", 1, true) and low:find("nil value", 1, true) then
			return T("Your executor doesn't support loadstring.")
		end
		return msg:sub(1, 100)
	end

	local activeScripts = {} -- prevent accidental double-taps from starting duplicates
	local function runScript(def)
		if activeScripts[def.key] then
			notify(TF("⏳ %s is already running.", def.name), 2.5)
			return
		end
		activeScripts[def.key] = true
		notify(TF("▶ Loading %s...", def.name), 2)
		pushRecent(def)
		hub.lastRun = def
		hub.sessionRuns = (hub.sessionRuns or 0) + 1
		if saved.autoHide then
			setOpen(false)
		end
		saved.runs[def.key] = (saved.runs[def.key] or 0) + 1
		saveSoon()
		task.spawn(function()
			local t0 = os.clock()
			local success, e = xpcall(def.run, function(err)
				return debug.traceback(tostring(err), 2)
			end)
			activeScripts[def.key] = nil
			if success then
				notify(TF("✅ %s finished starting (%.1fs)", def.name, os.clock() - t0), 2.5)
			else
				warn("[DoorsModesHub] " .. def.name .. " failed:\n" .. tostring(e))
				notify(TF("⚠️ %s failed: %s", def.name, friendlyError(tostring(e))), 5)
			end
		end)
	end

	local tabInds = {} -- V12: the little glowing bar on the left of the active tab
	local activePageName = nil
	local function showPage(name)
		for pageName, page in pairs(pages) do
			local active = (pageName == name)
			if active and not page.Visible then
				-- V12: new page slides up into place
				page.Position = UDim2.fromOffset(6, 24)
				tween(page, 0.3, { Position = UDim2.fromOffset(6, 6) }, Enum.EasingStyle.Quint)
			end
			page.Visible = active
			tween(tabButtons[pageName], 0.15, {
				BackgroundColor3 = active and THEME.purple or THEME.bg,
				TextColor3 = active and Color3.new(1, 1, 1) or THEME.text,
			})
			local ind = tabInds[pageName]
			if ind then
				tween(ind, 0.25, { Size = UDim2.fromOffset(4, active and 20 or 0) }, Enum.EasingStyle.Back)
			end
		end
		activePageName = name
		local build = builders[name]
		if build then
			builders[name] = nil
			task.spawn(build)
		end
		local stale = staleTabs[name]
		if stale then
			staleTabs[name] = nil
			local rebuild = sortRebuilders[name]
			if rebuild then
				rebuild()
			end
		end
		local refresh = refreshers[name]
		if refresh then
			task.spawn(refresh)
		end
	end

	local function createTab(name)
		local btn = make("TextButton", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = THEME.bg,
			Text = T(name),
			TextColor3 = THEME.text,
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextTruncate = Enum.TextTruncate.AtEnd,
			LayoutOrder = nextOrder(),
		}, tabList)
		corner(btn, 8)
		local ind = make("Frame", {
			Size = UDim2.fromOffset(4, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 3, 0.5, 0),
			BackgroundColor3 = THEME.orange,
		}, btn)
		corner(ind, 2)
		tabInds[name] = ind
		btn.MouseEnter:Connect(function()
			if activePageName ~= name then
				tween(btn, 0.12, { BackgroundColor3 = THEME.panelLight })
			end
		end)
		btn.MouseLeave:Connect(function()
			if activePageName ~= name then
				tween(btn, 0.12, { BackgroundColor3 = THEME.bg })
			end
		end)

		local page = make("ScrollingFrame", {
			Size = UDim2.new(1, -12, 1, -12),
			Position = UDim2.fromOffset(6, 6),
			BackgroundTransparency = 1,
			ScrollBarImageColor3 = THEME.orange,
			ScrollBarThickness = 3,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
		}, pageArea)
		make("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, page)

		pages[name] = page
		tabButtons[name] = btn
		btn.MouseButton1Click:Connect(function()
			showPage(name)
		end)
		return page
	end

	local function addSection(page, text)
		local label = make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20),
			Text = T(text),
			TextColor3 = THEME.purple,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = nextOrder(),
		}, page)
		-- V12: thin fading line under every section title
		local line = make("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, -1),
			BackgroundColor3 = THEME.orange,
		}, label)
		make("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2),
				NumberSequenceKeypoint.new(1, 1),
			}),
		}, line)
		return label
	end

	local function addLabel(page, text, height, color)
		return make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, height or 40),
			Text = T(text),
			TextColor3 = color or THEME.text,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			LayoutOrder = nextOrder(),
		}, page)
	end

	-- The three-dots button (drawn with 3 little circles, so no font issues)
	local function addDots(parent, def, kind, position)
		local b = make("TextButton", {
			Size = UDim2.fromOffset(28, 30),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = position,
			BackgroundTransparency = 1,
			Text = "",
		}, parent)

		local dots = {}
		for i = 1, 3 do
			local d = make("Frame", {
				Size = UDim2.fromOffset(4, 4),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, (i - 2) * 7),
				BackgroundColor3 = THEME.muted,
			}, b)
			corner(d, 2)
			dots[i] = d
		end
		b.MouseEnter:Connect(function()
			for _, d in ipairs(dots) do
				tween(d, 0.12, { BackgroundColor3 = THEME.orange })
			end
		end)
		b.MouseLeave:Connect(function()
			for _, d in ipairs(dots) do
				tween(d, 0.12, { BackgroundColor3 = THEME.muted })
			end
		end)
		b.MouseButton1Click:Connect(function()
			showDetails(def, kind)
		end)
		return b
	end

	local function hoverEffect(row)
		local rowStroke = row:FindFirstChildOfClass("UIStroke")
		local rowScale = make("UIScale", { Scale = 1 }, row)
		row.ClipsDescendants = true -- keeps the ripple inside the button
		row.MouseEnter:Connect(function()
			tween(row, 0.15, { BackgroundColor3 = THEME.panelLight })
			if rowStroke then
				tween(rowStroke, 0.15, { Color = THEME.orange })
			end
		end)
		row.MouseLeave:Connect(function()
			tween(row, 0.15, { BackgroundColor3 = THEME.bg })
			tween(rowScale, 0.1, { Scale = 1 })
			if rowStroke then
				tween(rowStroke, 0.15, { Color = THEME.purple })
			end
		end)
		-- V12: press squish + a ripple that grows from where you clicked/tapped
		row.MouseButton1Down:Connect(function(x, y)
			tween(rowScale, 0.08, { Scale = 0.97 })
			pcall(function()
				local s = uiScale.Scale
				local rel = Vector2.new(x, y) - row.AbsolutePosition
				local ripple = make("Frame", {
					Size = UDim2.fromOffset(0, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromOffset(rel.X / s, rel.Y / s),
					BackgroundColor3 = THEME.orange,
					BackgroundTransparency = 0.65,
				}, row)
				corner(ripple, 999)
				local size = math.max(row.AbsoluteSize.X / s, 80) * 1.6
				tween(ripple, 0.5, {
					Size = UDim2.fromOffset(size, size),
					BackgroundTransparency = 1,
				})
				task.delay(0.55, function()
					ripple:Destroy()
				end)
			end)
		end)
		row.MouseButton1Up:Connect(function()
			tween(rowScale, 0.15, { Scale = 1 }, Enum.EasingStyle.Back)
		end)
	end

	-- BUTTON: def = { name, description, confirm, confirmText, icon, subtitle, run }
	-- (no "run" = just opens the details, used by the Credits tab)
	local function addButton(page, def)
		local hasSub = def.subtitle ~= nil
		local kind = def.kind or (def.run and "Button" or "Info")

		local row = make("TextButton", {
			Size = UDim2.new(1, 0, 0, hasSub and 46 or 36),
			BackgroundColor3 = THEME.bg,
			Text = "",
			LayoutOrder = nextOrder(),
		}, page)
		corner(row, 8)
		stroke(row, THEME.purple, 1)

		make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -48, 0, hasSub and 24 or 36),
			Position = UDim2.fromOffset(12, hasSub and 4 or 0),
			Text = (def.icon and (def.icon .. "  ") or "") .. T(def.name),
			TextColor3 = THEME.orange,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, row)
		if hasSub then
			make("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -48, 0, 18),
				Position = UDim2.fromOffset(12, 24),
				Text = T(def.subtitle),
				TextColor3 = THEME.muted,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, row)
		end

		addDots(row, def, kind, UDim2.new(1, -6, 0.5, 0))
		hoverEffect(row)

		if def.script and not def.getExtra then
			def.getExtra = function()
				local fav = saved.favorites[def.key] == true
				return {
					fav and "💔 Unfavorite" or "⭐ Favorite",
					THEME.orange,
					function()
						saved.favorites[def.key] = (not fav) or nil
						saveData()
						notify(fav and "Removed from favorites" or "⭐ Added to favorites", 2)
					end,
				}
			end
		end

		local function runIt()
			if def.script then
				runScript(def)
			else
				def.run()
			end
		end

		row.MouseButton1Click:Connect(function()
			if not def.run then
				showDetails(def, kind)
			elseif def.confirm or (def.script and confirmScripts) then
				showDialog({
					title = "Are you sure? ⚠️",
					body = def.confirmText or TF("Are you sure you want to execute %s?", def.name),
					accent = THEME.orange,
					a = { "Cancel", THEME.panelLight },
					b = { "Execute", THEME.orange, runIt },
				})
			else
				safeCall(runIt)
			end
		end)
		return row
	end

	-- TOGGLE: def = { name, description, icon, default, onChange }
	local function addToggle(page, def)
		local state = def.default or false

		local row = make("TextButton", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = THEME.bg,
			Text = "",
			LayoutOrder = nextOrder(),
		}, page)
		corner(row, 8)

		make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -100, 1, 0),
			Position = UDim2.fromOffset(12, 0),
			Text = (def.icon and (def.icon .. "  ") or "") .. T(def.name),
			TextColor3 = THEME.text,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, row)

		local switch = make("Frame", {
			Size = UDim2.fromOffset(40, 20),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -42, 0.5, 0),
			BackgroundColor3 = THEME.panelLight,
		}, row)
		corner(switch, 10)

		local knob = make("Frame", {
			Size = UDim2.fromOffset(16, 16),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 2, 0.5, 0),
			BackgroundColor3 = THEME.text,
		}, switch)
		corner(knob, 8)

		local function render()
			tween(switch, 0.15, { BackgroundColor3 = state and THEME.orange or THEME.panelLight })
			tween(knob, 0.15, {
				Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			})
		end
		render()

		addDots(row, def, "Toggle", UDim2.new(1, -6, 0.5, 0))
		hoverEffect(row)

		row.MouseButton1Click:Connect(function()
			state = not state
			render()
			if def.onChange then
				safeCall(def.onChange, state)
			end
		end)
		return row, function(newState) -- lets other code flip the switch silently
			state = newState
			render()
		end
	end

	-- SLIDER: def = { name, description, icon, min, max, default, onChange }
	local function addSlider(page, def)
		local min, max = def.min, def.max
		local value = def.default or min

		local row = make("Frame", {
			Size = UDim2.new(1, 0, 0, 52),
			BackgroundColor3 = THEME.bg,
			LayoutOrder = nextOrder(),
		}, page)
		corner(row, 8)

		make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -110, 0, 24),
			Position = UDim2.fromOffset(12, 4),
			Text = (def.icon and (def.icon .. "  ") or "") .. T(def.name),
			TextColor3 = THEME.text,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, row)

		local valueLabel = make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(50, 24),
			Position = UDim2.new(1, -92, 0, 4),
			Text = tostring(value),
			TextColor3 = THEME.orange,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Right,
		}, row)

		addDots(row, def, "Slider", UDim2.new(1, -6, 0, 18))

		-- Big invisible hit area so it's easy to grab on a phone
		local hit = make("TextButton", {
			Size = UDim2.new(1, -24, 0, 22),
			Position = UDim2.fromOffset(12, 28),
			BackgroundTransparency = 1,
			Text = "",
		}, row)

		local bar = make("Frame", {
			Size = UDim2.new(1, 0, 0, 8),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			BackgroundColor3 = THEME.panelLight,
		}, hit)
		corner(bar, 4)

		local fill = make("Frame", {
			Size = UDim2.fromScale((value - min) / (max - min), 1),
			BackgroundColor3 = THEME.orange,
		}, bar)
		corner(fill, 4)

		local sliding = false
		local function update(x)
			if bar.AbsoluteSize.X <= 0 then
				return
			end
			local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			value = math.floor(min + (max - min) * rel + 0.5)
			fill.Size = UDim2.fromScale(rel, 1)
			valueLabel.Text = tostring(value)
			if def.onChange then
				safeCall(def.onChange, value)
			end
		end

		hit.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				sliding = true
				update(input.Position.X)
			end
		end)
		track(UserInputService.InputChanged:Connect(function(input)
			if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				update(input.Position.X)
			end
		end))
		track(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				sliding = false
			end
		end))
		return row
	end

	------------------------------------------------------------
	-- SORTING: a button next to every search box cycles Default / A→Z / Z→A / Newest
	local SORT_MODES = {
		{ id = "default", label = "↕ Default" },
		{ id = "az", label = "A→Z" },
		{ id = "za", label = "Z→A" },
		{ id = "new", label = "🆕 Newest" },
	}
	local sortMode = "default"
	for _, m in ipairs(SORT_MODES) do
		if m.id == saved.sort then
			sortMode = m.id
		end
	end
	local sortButtons = {}

	local function currentSortLabel()
		for _, m in ipairs(SORT_MODES) do
			if m.id == sortMode then
				return m.label
			end
		end
		return SORT_MODES[1].label
	end

	local function cycleSort()
		local idx = 1
		for i, m in ipairs(SORT_MODES) do
			if m.id == sortMode then
				idx = i
			end
		end
		sortMode = SORT_MODES[idx % #SORT_MODES + 1].id
		saved.sort = sortMode
		saveData()
		for _, b in ipairs(sortButtons) do
			b.Text = T(currentSortLabel())
		end
		for name in pairs(sortRebuilders) do
			staleTabs[name] = true
		end
		notify(TF("↕ Sorting: %s", T(currentSortLabel())), 1.5)
	end

	-- SCRIPT TAB: a tab with a search box + sort button + all its script buttons.
	-- Buttons are created the first time you open the tab (keeps startup fast).
	local function createScriptTab(tabDef)
		local page = createTab(tabDef.name)
		tabButtons[tabDef.name].Text = T(tabDef.name) .. "  " .. #tabDef.buttons
		local rows = {}
		local query = ""
		local built, building = false, false

		local top = make("Frame", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
			LayoutOrder = 0,
		}, page)

		local box = make("TextBox", {
			Size = UDim2.new(1, -74, 1, 0),
			BackgroundColor3 = THEME.bg,
			PlaceholderText = TF("🔍 Search %d scripts or creators...", #tabDef.buttons),
			PlaceholderColor3 = THEME.muted,
			Text = "",
			TextColor3 = THEME.text,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, top)
		corner(box, 8)
		stroke(box, THEME.purple, 1)
		make("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, box)

		local sortBtn = make("TextButton", {
			Size = UDim2.fromOffset(68, 30),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			BackgroundColor3 = THEME.panelLight,
			Text = T(currentSortLabel()),
			TextColor3 = THEME.text,
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, top)
		corner(sortBtn, 8)
		table.insert(sortButtons, sortBtn)

		local function matches(lowerName)
			return query == "" or lowerName:find(query, 1, true) ~= nil
		end

		box:GetPropertyChangedSignal("Text"):Connect(function()
			query = box.Text:lower()
			for _, entry in ipairs(rows) do
				entry.row.Visible = matches(entry.name)
			end
		end)

		addSection(page, tabDef.section)

		local function orderedList()
			local list = table.clone(tabDef.buttons)
			if sortMode == "az" then
				table.sort(list, function(a, b)
					return a.name:lower() < b.name:lower()
				end)
			elseif sortMode == "za" then
				table.sort(list, function(a, b)
					return a.name:lower() > b.name:lower()
				end)
			elseif sortMode == "new" then
				local n = #list
				for i = 1, math.floor(n / 2) do
					list[i], list[n - i + 1] = list[n - i + 1], list[i]
				end
			end
			return list
		end

		local function buildRows()
			if building then
				return
			end
			building = true
			for _, entry in ipairs(rows) do
				entry.row:Destroy()
			end
			rows = {}
			local loadingLabel = addLabel(page, TF("Loading %d scripts...", #tabDef.buttons), 20, THEME.muted)
			for i, def in ipairs(orderedList()) do
				def.script = true
				local row = addButton(page, def)
				local lowerName = def.hay or def.name:lower()
				row.Visible = matches(lowerName)
				table.insert(rows, { row = row, name = lowerName })
				if i % 12 == 0 then
					task.wait() -- let the game breathe while we build
				end
			end
			loadingLabel:Destroy()
			built = true
			building = false
		end

		sortBtn.MouseButton1Click:Connect(function()
			cycleSort()
			staleTabs[tabDef.name] = nil
			if built then
				task.spawn(buildRows)
			end
		end)
		sortRebuilders[tabDef.name] = function()
			if built then
				task.spawn(buildRows)
			end
		end
		builders[tabDef.name] = buildRows
	end

	------------------------------------------------------------
	-- FLOATING PUMPKIN (tap = show/hide, drag = move)
	------------------------------------------------------------
	local PUMPKIN_HOME = UDim2.fromOffset(14, math.floor(screen.Y / 2) - 26)

	local pumpkin = make("TextButton", {
		Size = UDim2.fromOffset(52, 52),
		Position = PUMPKIN_HOME,
		BackgroundColor3 = THEME.panel,
		Text = "🎃",
		TextSize = 28,
		Font = Enum.Font.GothamBold,
		Visible = false,
		ZIndex = 10,
	}, gui)
	corner(pumpkin, 26)
	pulse(stroke(pumpkin, THEME.orange, 2), "Color", THEME.purple, 1.2)

	local function clampToScreen(obj)
		local size = obj.AbsoluteSize
		local pos = obj.AbsolutePosition
		local x = math.clamp(pos.X, 6, math.max(6, gui.AbsoluteSize.X - size.X - 6))
		local y = math.clamp(pos.Y, 6, math.max(6, gui.AbsoluteSize.Y - size.Y - 6))
		tween(obj, 0.2, { Position = UDim2.fromOffset(x, y) })
	end

	makeDraggable(pumpkin, pumpkin, function()
		setOpen(not isOpen)
	end, function()
		clampToScreen(pumpkin)
	end)

	local ready = false

	-- KEYBINDS (PC) + ON-SCREEN BUTTONS (mobile). Both can be turned on/off in Settings.
	local keybindsOn = saved.keybinds ~= false
	local quickBarOn = saved.quickBar
	if quickBarOn == nil then
		quickBarOn = isMobile -- phones get the buttons automatically
	end
	local PANIC_KEY = Enum.KeyCode.End
	local RUN_LAST_KEY = Enum.KeyCode.RightControl
	local MUSIC_KEY = Enum.KeyCode.Insert

	local function runLast()
		if hub.lastRun then
			runScript(hub.lastRun)
		else
			notify("Nothing run yet 👻", 2)
		end
	end

	-- Tiny faint dot that only exists while PANIC is on, so touch players can bring everything back
	local panicDot = make("TextButton", {
		Size = UDim2.fromOffset(28, 28),
		Position = UDim2.fromOffset(8, 8),
		BackgroundColor3 = THEME.panel,
		BackgroundTransparency = 0.8,
		Text = "·",
		TextColor3 = THEME.text,
		TextTransparency = 0.4,
		TextSize = 20,
		Font = Enum.Font.GothamBold,
		Visible = false,
		ZIndex = 60,
	}, gui)
	corner(panicDot, 14)

	-- Floating quick bar: 🚨 panic, 🔁 run last script, 🎵 music (drag it anywhere)
	local quickBar = make("Frame", {
		Size = UDim2.fromOffset(158, 48),
		Position = UDim2.new(0, 14, 0, math.floor(screen.Y / 2) + 40),
		BackgroundColor3 = THEME.panel,
		Visible = false,
		ZIndex = 10,
	}, gui)
	corner(quickBar, 14)
	pulse(stroke(quickBar, THEME.orange, 2), "Color", THEME.purple, 1.4)
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
	}, quickBar)
	local function quickButton(text, callback)
		local b = make("TextButton", {
			Size = UDim2.fromOffset(42, 38),
			BackgroundColor3 = THEME.panelLight,
			Text = text,
			TextSize = 20,
			TextColor3 = THEME.text,
			Font = Enum.Font.GothamBold,
			ZIndex = 11,
		}, quickBar)
		corner(b, 10)
		b.MouseButton1Click:Connect(function()
			safeCall(callback)
		end)
	end

	local function updateQuickBar()
		quickBar.Visible = quickBarOn and pumpkin.Visible
	end
	pumpkin:GetPropertyChangedSignal("Visible"):Connect(updateQuickBar)
	makeDraggable(quickBar, quickBar, nil, function()
		clampToScreen(quickBar)
	end)

	-- PANIC: hides the hub, pumpkin and quick bar and stops the music. Press again to bring it back.
	local panicHidden = false
	local function panicToggle()
		panicHidden = not panicHidden
		panicDot.Visible = panicHidden
		if panicHidden then
			setOpen(false)
			pcall(setMusic, false)
			pumpkin.Visible = false
		else
			pumpkin.Visible = true
			setOpen(true)
		end
	end
	panicDot.MouseButton1Click:Connect(panicToggle)

	quickButton("🚨", panicToggle)
	quickButton("🔁", runLast)
	quickButton("🎵", function()
		setMusic(not musicOn)
	end)
	track(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not ready or not keybindsOn then
			return
		end
		if input.KeyCode == PANIC_KEY then
			panicToggle()
		elseif panicHidden then
			return
		elseif table.find(TOGGLE_KEYS, input.KeyCode) then
			setOpen(not isOpen)
		elseif input.KeyCode == RUN_LAST_KEY then
			runLast()
		elseif input.KeyCode == MUSIC_KEY then
			pcall(setMusic, not musicOn)
		end
	end))

	------------------------------------------------------------
	-- PAGES
	------------------------------------------------------------
	-- NOTES (saved automatically)
	------------------------------------------------------------
	do
		addSection(notesTab, "MY NOTES")
		addLabel(notesTab, "Write anything here: ideas, audio IDs, script names. It saves automatically.", 36, THEME.muted)
		local notesBox = make("TextBox", {
			Size = UDim2.new(1, 0, 0, 170),
			BackgroundColor3 = THEME.bg,
			PlaceholderText = T("📝 Type your notes here..."),
			PlaceholderColor3 = THEME.muted,
			Text = saved.notes or "",
			TextColor3 = THEME.text,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			MultiLine = true,
			TextWrapped = true,
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			LayoutOrder = nextOrder(),
		}, notesTab)
		corner(notesBox, 8)
		stroke(notesBox, THEME.purple, 1)
		make("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		}, notesBox)
		notesBox.FocusLost:Connect(function()
			saved.notes = notesBox.Text:sub(1, 4000)
			saveData()
		end)
		addButton(notesTab, {
			name = "Copy notes",
			icon = "📋",
			description = "Copies all your notes (needs setclipboard).",
			run = function()
				saved.notes = notesBox.Text:sub(1, 4000)
				if setclipboard then
					setclipboard(saved.notes)
					notify("📋 Copied!", 2)
				else
					notify(saved.notes, 6)
				end
			end,
		})
		addButton(notesTab, {
			name = "Clear notes",
			icon = "🧹",
			description = "Deletes everything you wrote in Notes.",
			confirm = true,
			confirmText = "Delete all your notes?",
			run = function()
				notesBox.Text = ""
				saved.notes = ""
				saveData()
				notify("🧹 Cleared", 2)
			end,
		})
	end

	------------------------------------------------------------
	-- One flat list of every script (ids are used for favorites)
	local ALL_SCRIPTS = {}
	for _, tabDef in ipairs(SCRIPT_TABS) do
		for _, def in ipairs(tabDef.buttons) do
			def.script = true
			def.tab = tabDef.name
			def.key = tabDef.name .. "|" .. def.name
			def.hay = (def.name .. " " .. (def.subtitle or "")):lower()
			if NEW_SCRIPTS[def.name] and not def.icon then
				def.icon = "🆕"
			end
			table.insert(ALL_SCRIPTS, def)
		end
	end
	local totalScripts = #ALL_SCRIPTS

	-- Empties a page (keeps its layout + optional search box)
	local function clearPage(page, keep)
		for _, child in ipairs(page:GetChildren()) do
			if not child:IsA("UIListLayout") and child ~= keep then
				child:Destroy()
			end
		end
	end

	local function makeSearchBox(page, placeholder)
		local box = make("TextBox", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = THEME.bg,
			PlaceholderText = placeholder,
			PlaceholderColor3 = THEME.muted,
			Text = "",
			TextColor3 = THEME.text,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 0,
		}, page)
		corner(box, 8)
		stroke(box, THEME.purple, 1)
		make("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, box)
		return box
	end

	-- Tab order = the order you see on the left
	local homeTab = createTab("🏠 Home")
	local favTab = createTab("⭐ Favorites")
	local searchTab = createTab("🔎 Search")
	for _, tabDef in ipairs(SCRIPT_TABS) do
		createScriptTab(tabDef)
	end
	local musicTab = createTab("🎵 Music")
	local playlistTab = createTab("📻 Playlist")
	local notesTab = createTab("📝 Notes")
	local effectsTab = createTab("🎃 Effects")
	local toolsTab = createTab("🧰 Tools")
	local settingsTab = createTab("⚙️ Settings")
	local updatesTab = createTab("📜 Updates")
	local creditsTab = createTab("😄 Credits")

	-- HOME
	addSection(homeTab, "WELCOME")
	addLabel(
		homeTab,
		TF("Hey %s! %d scripts loaded. Tap the 🎃 or press %s to show/hide. Search all scripts in 🔎, keep your best ones in ⭐, and paste any audio ID in 🎵.", player.DisplayName, totalScripts, TOGGLE_KEY_TEXT),
		100
	)
	local fpsLabel = addLabel(homeTab, "FPS: ...", 20, THEME.muted)
	addButton(homeTab, {
		name = "Random mode",
		icon = "🎲",
		description = "Picks a random mode from the Modes tabs and asks before running it.",
		run = function()
			local pool = {}
			for _, def in ipairs(ALL_SCRIPTS) do
				if def.tab == "🔪 Modes" or def.tab == "💔 Modes 2" then
					table.insert(pool, def)
				end
			end
			local pick = pool[math.random(#pool)]
			showDialog({
				title = "🎲 " .. pick.name,
				body = T(pick.description or "") .. "\n\n" .. T("Run it?"),
				accent = THEME.orange,
				a = { "No", THEME.panelLight },
				b = { "Run!", THEME.orange, function()
					runScript(pick)
				end },
			})
		end,
	})
	addButton(homeTab, {
		name = "Say boo",
		icon = "👻",
		description = "Shows a spooky popup. A good first button to test.",
		run = function()
			notify("Boo! 👻")
		end,
	})

	addButton(homeTab, {
		name = "Run last script again",
		icon = "🔁",
		description = "Runs the last script you ran in this session again.",
		run = function()
			if hub.lastRun then
				runScript(hub.lastRun)
			else
				notify("Nothing run yet 👻", 2)
			end
		end,
	})

	addButton(homeTab, {
		name = "About V10",
		icon = "ℹ️",
		description = "Version info for the hub.",
		run = function()
			showDialog({
				title = "🎃 " .. HUB_TITLE,
				body = totalScripts .. " scripts  •  "
					.. (isMobile and T("Tap the 🎃 to show/hide, 🚨 = panic") or (T("Show/hide:") .. " " .. TOGGLE_KEY_TEXT .. "  •  " .. T("Panic:") .. " End"))
					.. "\n\n" .. T("Hub by Rip_Silence, GUI by WH1T3. Thanks for using the hub!"),
				accent = THEME.orange,
				a = { "Close", THEME.purple },
			})
		end,
	})
	addSection(homeTab, "🆕 NEW SCRIPTS")
	do
		local shownNew = 0
		for _, def in ipairs(ALL_SCRIPTS) do
			if NEW_SCRIPTS[def.name] and shownNew < 6 then
				shownNew += 1
				local copy = table.clone(def)
				copy.subtitle = T(def.tab) .. (def.subtitle and ("  •  " .. def.subtitle) or "")
				addButton(homeTab, copy)
			end
		end
		addLabel(homeTab, "Every new script has a 🆕 in front of its name.", 20, THEME.muted)
	end
	addSection(homeTab, "✨ SCRIPT OF THE DAY")
	do
		local day = tonumber(os.date("%j")) or 1
		local year = tonumber(os.date("%Y")) or 2026
		local pick = ALL_SCRIPTS[(day * 7 + year) % #ALL_SCRIPTS + 1]
		local copy = table.clone(pick)
		copy.subtitle = pick.tab .. (pick.subtitle and ("  •  " .. pick.subtitle) or "")
		addButton(homeTab, copy)
	end
	local allTimeLabel = addLabel(homeTab, TF("📈 All-time scripts run: %d", 0), 20, THEME.muted)
	local statsLabel = addLabel(homeTab, TF("⭐ Favorites: %d  •  ▶ This session: %d", 0, 0), 20, THEME.muted)
	refreshers["🏠 Home"] = function()
		local total = 0
		for _, n in pairs(saved.runs) do
			total += n
		end
		allTimeLabel.Text = TF("📈 All-time scripts run: %d", total)
		local favCount = 0
		for _ in pairs(saved.favorites) do
			favCount += 1
		end
		statsLabel.Text = TF("⭐ Favorites: %d  •  ▶ This session: %d", favCount, hub.sessionRuns or 0)
	end

	local StatsService = game:GetService("Stats")
	local sessionStart = os.clock()
	local frames, lastTime = 0, os.clock()
	track(RunService.RenderStepped:Connect(function()
		frames += 1
		local now = os.clock()
		if now - lastTime >= 1 then
			local okPing, ping = pcall(function()
				return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			local up = math.floor(now - sessionStart)
			fpsLabel.Text = string.format(
				"FPS: %d  •  Ping: %s  •  " .. T("Session") .. ": %02d:%02d",
				math.floor(frames / (now - lastTime) + 0.5),
				okPing and (math.floor(ping + 0.5) .. " ms") or "n/a",
				math.floor(up / 60), up % 60
			)
			frames, lastTime = 0, now
		end
	end))

	-- FAVORITES + RECENT (rebuilt every time you open the tab)
	refreshers["⭐ Favorites"] = function()
		clearPage(favTab)
		addSection(favTab, "⭐ FAVORITES")
		addButton(favTab, {
			name = "Copy my favorites list",
			icon = "📋",
			description = "Copies the names of all your favorite scripts so you can share them (needs setclipboard).",
			run = function()
				local names = {}
				for _, def in ipairs(ALL_SCRIPTS) do
					if saved.favorites[def.key] then
						table.insert(names, def.name)
					end
				end
				if #names == 0 then
					notify("Nothing to copy yet ⭐", 2)
					return
				end
				local text = table.concat(names, "\n")
				if setclipboard then
					setclipboard(text)
					notify("📋 Copied!", 2)
				else
					notify(text, 6)
				end
			end,
		})
		local count = 0
		for _, def in ipairs(ALL_SCRIPTS) do
			if saved.favorites[def.key] then
				count += 1
				addButton(favTab, def)
			end
		end
		if count == 0 then
			addLabel(favTab, "Nothing here yet. Tap the ⋮ on any script and choose ⭐ Favorite.", 36, THEME.muted)
		end
		addSection(favTab, "🔥 MOST USED")
		local ranked = {}
		for _, def in ipairs(ALL_SCRIPTS) do
			local n = saved.runs[def.key]
			if n and n > 0 then
				table.insert(ranked, { def = def, n = n })
			end
		end
		table.sort(ranked, function(a, b)
			return a.n > b.n
		end)
		if #ranked == 0 then
			addLabel(favTab, "Your top scripts show up here after you run a few.", 20, THEME.muted)
		end
		for i = 1, math.min(5, #ranked) do
			local copy = table.clone(ranked[i].def)
			copy.subtitle = TF("Ran %dx", ranked[i].n) .. (copy.subtitle and ("  •  " .. copy.subtitle) or "")
			addButton(favTab, copy)
		end
		addSection(favTab, "🕘 RECENTLY RUN")
		if #recent == 0 then
			addLabel(favTab, "Scripts you run show up here.", 20, THEME.muted)
		end
		for _, def in ipairs(recent) do
			addButton(favTab, def)
		end
	end

	-- SEARCH (all scripts at once)
	local globalBox = makeSearchBox(searchTab, TF("🔎 Search all %d scripts or creators...", totalScripts))
	local searchToken = 0
	local function runSearch()
		searchToken += 1
		local mine = searchToken
		task.wait(0.25) -- wait until you stop typing
		if mine ~= searchToken then
			return
		end
		clearPage(searchTab, globalBox)
		local q = globalBox.Text:lower()
		if #q < 2 then
			addLabel(searchTab, "Type at least 2 letters to search every tab at once.", 36, THEME.muted)
			return
		end
		local shown = 0
		for _, def in ipairs(ALL_SCRIPTS) do
			if (def.hay or def.name:lower()):find(q, 1, true) then
				shown += 1
				if shown > 40 then
					break
				end
				local copy = table.clone(def)
				copy.subtitle = T(def.tab) .. (def.subtitle and ("  •  " .. def.subtitle) or "")
				addButton(searchTab, copy)
			end
		end
		if shown == 0 then
			addLabel(searchTab, TF("Nothing found for \"%s\".", globalBox.Text), 24, THEME.muted)
		elseif shown > 40 then
			addLabel(searchTab, "Showing the first 40. Type more letters to narrow it down.", 36, THEME.muted)
		end
	end
	globalBox:GetPropertyChangedSignal("Text"):Connect(function()
		task.spawn(runSearch)
	end)
	task.spawn(runSearch)

	-- MUSIC
	addSection(musicTab, "NOW PLAYING")
	nowLabel = addLabel(musicTab, nowPlayingText(), 40)

	addSection(musicTab, "PLAY ANY AUDIO ID")
	local idRow = make("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		LayoutOrder = nextOrder(),
	}, musicTab)
	local idBox = make("TextBox", {
		Size = UDim2.new(1, -78, 1, 0),
		BackgroundColor3 = THEME.bg,
		PlaceholderText = T("🎵 Paste audio ID or link..."),
		PlaceholderColor3 = THEME.muted,
		Text = "",
		TextColor3 = THEME.text,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, idRow)
	corner(idBox, 8)
	stroke(idBox, THEME.purple, 1)
	make("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, idBox)
	local playIdBtn = make("TextButton", {
		Size = UDim2.fromOffset(70, 34),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		BackgroundColor3 = THEME.orange,
		Text = T("▶ Play"),
		TextColor3 = THEME.text,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
	}, idRow)
	corner(playIdBtn, 8)
	playIdBtn.MouseButton1Click:Connect(function()
		safeCall(playById, idBox.Text)
	end)
	idBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			safeCall(playById, idBox.Text)
		end
	end)

	local controls = make("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		LayoutOrder = nextOrder(),
	}, musicTab)
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, controls)
	local function controlButton(text, callback)
		local b = make("TextButton", {
			Size = UDim2.new(0.25, -5, 1, 0),
			BackgroundColor3 = THEME.panelLight,
			Text = T(text),
			TextColor3 = THEME.text,
			Font = Enum.Font.GothamBold,
			TextSize = 15,
			LayoutOrder = nextOrder(),
		}, controls)
		corner(b, 8)
		b.MouseButton1Click:Connect(function()
			safeCall(callback)
		end)
		return b
	end
	controlButton("⏮", function() stepTrack(-1) end)
	controlButton("⏯", function() setMusic(not musicOn) end)
	controlButton("⏭", function() stepTrack(1) end)
	controlButton("💾 Save", saveCurrentToPlaylist)

	addSection(musicTab, "SETTINGS")
	local _, setMusicSwitch = addToggle(musicTab, {
		name = "Background music",
		icon = "🎵",
		description = "Turns the music on or off. The 🎵 button in the title bar does the same thing.",
		default = false,
		onChange = function(on)
			setMusic(on)
		end,
	})
	musicToggleSet = setMusicSwitch
	addToggle(musicTab, {
		name = "Loop this song",
		icon = "🔁",
		description = "ON = the song repeats forever. OFF = it moves on to the next song in your playlist when it ends.",
		default = loopTrack,
		onChange = setLoop,
	})

	addToggle(musicTab, {
		name = "Shuffle",
		icon = "🔀",
		description = "ON = the next song is picked at random. Works with the ⏭ / ⏮ buttons and when a song ends (Loop OFF).",
		default = shuffleOn,
		onChange = function(on)
			shuffleOn = on
			saved.shuffle = on
			saveData()
		end,
	})
	addToggle(musicTab, {
		name = "Resume music on start",
		icon = "▶️",
		description = "ON = your last song starts playing when the hub opens. Turn OFF if you want silence at the start.",
		default = autoplayOn,
		onChange = function(on)
			autoplayOn = on
			saved.autoplay = on
			saveData()
		end,
	})
	addSlider(musicTab, {
		name = "Music volume",
		icon = "🔊",
		description = "How loud the music is (0 = silent, 100 = max).",
		min = 0,
		max = 100,
		default = musicVolume,
		onChange = function(v)
			musicVolume = v
			sound.Volume = v / 100
			saved.volume = v
			saveSoon()
		end,
	})
	addLabel(
		musicTab,
		"Where to get IDs: Creator Store > Audio, open a song and copy the number (or the whole link) from the page. Some audio is private and won't play. Tap 💾 Save to keep a song in 📻 Playlist.",
		84,
		THEME.muted
	)

	-- PLAYLIST (rebuilt when you open it or when songs change)
	local function buildPlaylistPage()
		clearPage(playlistTab)
		addSection(playlistTab, "📻 YOUR PLAYLIST")
		if #playlist == 0 then
			addLabel(playlistTab, "Empty. Play an ID in the 🎵 tab, then tap 💾 Save.", 36, THEME.muted)
		end
		for _, trackEntry in ipairs(playlist) do
			addButton(playlistTab, {
				name = trackName(trackEntry),
				icon = sameTrack(trackEntry, current) and "▶" or "🎵",
				subtitle = trackEntry.id and ("ID " .. tostring(trackEntry.id)) or (trackEntry.url and "Link" or "File"),
				description = "Tap the song to play it. Use Remove to delete it from your playlist.",
				kind = "Song",
				run = function()
					playTrack(trackEntry)
				end,
				getExtra = function()
					return { "🗑 Remove", THEME.danger, function()
						removeFromPlaylist(trackEntry)
						notify("Removed from playlist", 2)
					end }
				end,
			})
		end
	end
	refreshers["📻 Playlist"] = buildPlaylistPage
	table.insert(musicListeners, function()
		if playlistTab.Visible then
			buildPlaylistPage()
		end
	end)

	-- EFFECTS
	local batsOn = false
	local batToken = 0

	local function startBats()
		batToken += 1
		local token = batToken
		for _ = 1, 8 do
			task.spawn(function()
				local bat = make("TextLabel", {
					BackgroundTransparency = 1,
					Text = "🦇",
					TextSize = math.random(18, 30),
					Size = UDim2.fromOffset(40, 40),
					Position = UDim2.new(-0.2, 0, 0.5, 0),
				}, effectsLayer)
				task.wait(math.random() * 2)
				while batsOn and token == batToken and bat.Parent do
					local y = math.random() * 0.8 + 0.05
					local dur = math.random(40, 80) / 10
					bat.Position = UDim2.new(-0.1, 0, y, 0)
					tween(bat, dur, {
						Position = UDim2.new(1.1, 0, math.clamp(y + (math.random() - 0.5) * 0.3, 0, 0.95), 0),
					}, Enum.EasingStyle.Linear)
					task.wait(dur)
				end
				bat:Destroy()
			end)
		end
	end

	addSection(effectsTab, "SPOOKY STUFF")
	addToggle(effectsTab, {
		name = "Floating bats",
		icon = "🦇",
		description = "Little bats fly across your screen. Purely decoration.",
		default = false,
		onChange = function(on)
			batsOn = on
			if on then
				startBats()
			else
				batToken += 1
				effectsLayer:ClearAllChildren()
			end
		end,
	})
	addButton(effectsTab, {
		name = "Pumpkin rain",
		icon = "🎃",
		description = "Makes pumpkins fall from the top of the screen for a few seconds.",
		run = function()
			for _ = 1, 20 do
				task.spawn(function()
					task.wait(math.random() * 1.5)
					local x = math.random()
					local p = make("TextLabel", {
						BackgroundTransparency = 1,
						Text = "🎃",
						TextSize = math.random(22, 34),
						Size = UDim2.fromOffset(40, 40),
						Position = UDim2.new(x, 0, -0.1, 0),
					}, effectsLayer)
					local dur = math.random(20, 40) / 10
					tween(p, dur, {
						Position = UDim2.new(x, 0, 1.1, 0),
						Rotation = math.random(-180, 180),
					}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
					task.wait(dur)
					p:Destroy()
				end)
			end
		end,
	})

	-- TOOLS
	addSection(toolsTab, "SESSION")
	local VirtualUser = game:GetService("VirtualUser")
	local afkConn
	local function setAntiAfk(on)
		if afkConn then
			afkConn:Disconnect()
			afkConn = nil
		end
		if on then
			afkConn = track(player.Idled:Connect(function()
				pcall(function()
					VirtualUser:CaptureController()
					VirtualUser:ClickButton2(Vector2.new())
				end)
			end))
		end
	end
	setAntiAfk(saved.antiAfk ~= false)
	addToggle(toolsTab, {
		name = "Anti-AFK",
		icon = "💤",
		description = "Stops Roblox from kicking you for being idle (20 min). Great for long runs. Saved.",
		default = saved.antiAfk ~= false,
		onChange = function(on)
			saved.antiAfk = on
			saveData()
			setAntiAfk(on)
		end,
	})
	addButton(toolsTab, {
		name = "Panic (hide everything)",
		icon = "🚨",
		description = "Instantly hides the hub and the pumpkin and stops the music. Press it again, the End key, or tap the faint dot in the top-left corner to bring everything back.",
		run = panicToggle,
	})
	addButton(toolsTab, {
		name = "Rejoin server",
		icon = "🔄",
		description = "Teleports you back into this same game.",
		confirm = true,
		confirmText = "Rejoin this game? You'll leave the current server.",
		run = function()
			game:GetService("TeleportService"):Teleport(game.PlaceId, player)
		end,
	})
	addButton(toolsTab, {
		name = "Copy Place ID / Job ID",
		icon = "📋",
		description = "Copies the place id and this server's job id (needs setclipboard).",
		run = function()
			local text = "PlaceId: " .. game.PlaceId .. " | JobId: " .. game.JobId
			if setclipboard then
				setclipboard(text)
				notify("📋 Copied!", 2)
			else
				notify(text, 6)
			end
		end,
	})
	if setfpscap then
		addSlider(toolsTab, {
			name = "FPS cap",
			icon = "⚡",
			description = "Changes your max FPS (needs setfpscap).",
			min = 30,
			max = 240,
			default = 60,
			onChange = function(v)
				setfpscap(v)
			end,
		})
	end

	addSection(toolsTab, "VISUALS")
	do
	local Lighting = game:GetService("Lighting")
	local startCamera = workspace.CurrentCamera
	local startFov = startCamera and startCamera.FieldOfView or 70
	addSlider(toolsTab, {
		name = "Field of view",
		icon = "🔭",
		description = "Changes your camera field of view (the game may reset it). Use Reset FOV to go back.",
		min = 40,
		max = 120,
		default = math.floor(startFov + 0.5),
		onChange = function(v)
			local cam = workspace.CurrentCamera
			if cam then
				cam.FieldOfView = v
			end
		end,
	})
	addButton(toolsTab, {
		name = "Reset FOV",
		icon = "↩️",
		description = "Puts your camera field of view back to what it was when the hub started.",
		run = function()
			local cam = workspace.CurrentCamera
			if cam then
				cam.FieldOfView = startFov
			end
		end,
	})
	local boostRestore = nil
	addToggle(toolsTab, {
		name = "FPS boost",
		icon = "🚀",
		description = "Turns off shadows and lowers graphics quality for more FPS. Turn it OFF to restore your old settings.",
		default = false,
		onChange = function(on)
			if on then
				boostRestore = { shadows = Lighting.GlobalShadows }
				pcall(function()
					boostRestore.quality = settings().Rendering.QualityLevel
				end)
				Lighting.GlobalShadows = false
				pcall(function()
					settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
				end)
				notify("🚀 FPS boost ON", 2)
			elseif boostRestore then
				Lighting.GlobalShadows = boostRestore.shadows
				if boostRestore.quality then
					pcall(function()
						settings().Rendering.QualityLevel = boostRestore.quality
					end)
				end
				boostRestore = nil
				notify("FPS boost OFF", 2)
			end
		end,
	})
	end

	addSection(toolsTab, "EXECUTOR CHECK")
	local exName = "Unknown"
	pcall(function()
		if identifyexecutor then
			exName = tostring((identifyexecutor()))
		end
	end)
	local function has(fnName)
		local okH, v = pcall(function()
			return (getgenv and getgenv()[fnName]) or getfenv(0)[fnName]
		end)
		return okH and v ~= nil
	end
	local function mark(fnName)
		return (has(fnName) and "✅ " or "❌ ") .. fnName
	end
	addLabel(
		toolsTab,
		"Executor: " .. exName .. "\n"
			.. mark("loadstring") .. "   " .. mark("writefile") .. "   " .. mark("readfile") .. "\n"
			.. mark("setclipboard") .. "   " .. mark("setfpscap") .. "   " .. mark("getgenv") .. "\n"
			.. T("If a script button fails, check the ❌ above first."),
		84,
		THEME.muted
	)

	addSection(toolsTab, "DATA")
	addButton(toolsTab, {
		name = "Reset favorites & stats",
		icon = "🧹",
		description = "Clears your favorites and the Most used counters. Playlist and settings stay.",
		confirm = true,
		confirmText = "Clear all favorites and run counts?",
		run = function()
			saved.favorites = {}
			saved.runs = {}
			saveData()
			notify("🧹 Cleared", 2)
		end,
	})
	addButton(toolsTab, {
		name = "Copy debug info",
		icon = "🐞",
		description = "Copies your executor, language and hub version so you can paste it when reporting a bug (no personal info). Needs setclipboard.",
		run = function()
			local text = table.concat({
				"Hub: " .. HUB_TITLE,
				"Scripts: " .. totalScripts,
				"Executor: " .. exName,
				"Language: " .. tostring(langCode),
				"Mobile: " .. tostring(isMobile),
				"PlaceId: " .. game.PlaceId,
				"loadstring: " .. tostring(has("loadstring")),
				"writefile: " .. tostring(has("writefile")),
				"setclipboard: " .. tostring(has("setclipboard")),
			}, "\n")
			if setclipboard then
				setclipboard(text)
				notify("📋 Copied!", 2)
			else
				notify(text, 8)
			end
		end,
	})
	addButton(toolsTab, {
		name = "Reset EVERYTHING",
		icon = "💣",
		description = "Wipes ALL saved data: favorites, stats, playlist, notes and settings. Re-run the hub afterwards.",
		confirm = true,
		confirmText = "Wipe ALL saved data? This can't be undone.",
		run = function()
			for k in pairs(saved) do
				saved[k] = nil
			end
			saved.favorites, saved.playlist, saved.runs = {}, {}, {}
			saveData()
			notify("🧹 Everything reset. Re-run the hub.", 4)
		end,
	})

	-- SETTINGS
	addSection(settingsTab, "UI")
	addToggle(settingsTab, {
		name = "Notifications",
		icon = "🔔",
		description = "Turns the little popup messages in the corner on or off.",
		default = notificationsEnabled,
		onChange = function(on)
			notificationsEnabled = on
			saved.notifications = on
			saveData()
		end,
	})
	addToggle(settingsTab, {
		name = "Confirm before running",
		icon = "🛡️",
		description = "When ON, every script button asks 'Are you sure?' before it runs. Handy to avoid misclicks on a phone.",
		default = confirmScripts,
		onChange = function(on)
			confirmScripts = on
			saved.confirm = on
			saveData()
		end,
	})
	addToggle(settingsTab, {
		name = "Hide hub after running a script",
		icon = "🙈",
		description = "After you run a script the hub hides itself so you can see the game. Bring it back with the 🎃, your key or the quick bar.",
		default = saved.autoHide == true,
		onChange = function(on)
			saved.autoHide = on
			saveData()
		end,
	})
	addSlider(settingsTab, {
		name = "Window size %",
		icon = "📐",
		description = "Makes the whole hub bigger or smaller (up to 130% so it is easier to tap on phones).",
		min = 50,
		max = 130,
		default = 100,
		onChange = function(v)
			userScale = v / 100
			if isOpen then
				uiScale.Scale = targetScale()
			end
		end,
	})
	addSection(settingsTab, "CONTROLS (PC + MOBILE)")
	addToggle(settingsTab, {
		name = "Keybinds (PC)",
		icon = "⌨️",
		description = TF("Keyboard shortcuts: %s = show/hide, End = panic, Right Ctrl = run last script, Insert = music on/off. Turn OFF if you don't use a keyboard.", TOGGLE_KEY_TEXT),
		default = keybindsOn,
		onChange = function(on)
			keybindsOn = on
			saved.keybinds = on
			saveData()
		end,
	})
	addToggle(settingsTab, {
		name = "On-screen buttons (mobile)",
		icon = "📱",
		description = "Shows a small draggable bar with 🚨 panic, 🔁 run last script and 🎵 music, so phone and tablet players don't need the keybinds. ON by default on phones.",
		default = quickBarOn,
		onChange = function(on)
			quickBarOn = on
			saved.quickBar = on
			saveData()
			updateQuickBar()
		end,
	})
	addSection(settingsTab, "LOOK")
	local currentLangName = "English"
	for _, l in ipairs(LANGS) do
		if l.code == langCode then
			currentLangName = l.name
		end
	end
	addButton(settingsTab, {
		name = "Language",
		icon = "🌐",
		subtitle = currentLangName,
		description = "Changes the hub language: English, Español, Português, Français. It's saved and shows up the next time you run the hub.",
		run = function()
			local idx = 1
			for i, l in ipairs(LANGS) do
				if l.code == (saved.lang or langCode) then
					idx = i
				end
			end
			local nextLang = LANGS[idx % #LANGS + 1]
			saved.lang = nextLang.code
			saveData()
			notify(TL(nextLang.code, "🌐 %s selected. Re-run the hub to apply it.", nextLang.name), 5)
		end,
	})
	addButton(settingsTab, {
		name = "Accent color",
		icon = "🎨",
		description = "Cycles the hub colors: Pumpkin, Blood, Toxic, Ghost, Gold, Sakura, Void, Mint. It's saved and shows up the next time you run the hub.",
		run = function()
			accentIndex = accentIndex % #ACCENTS + 1
			saved.accent = ACCENTS[accentIndex].name
			saveData()
			notify(TF("🎨 %s selected. Re-run the hub to apply it.", saved.accent), 4)
		end,
	})
	addButton(settingsTab, {
		name = "Reset positions",
		icon = "🧭",
		description = "Puts the hub back in the middle of the screen and the pumpkin back on the left.",
		run = function()
			tween(window, 0.3, { Position = UDim2.fromScale(0.5, 0.5) })
			tween(pumpkin, 0.3, { Position = PUMPKIN_HOME })
		end,
	})
	addButton(settingsTab, {
		name = "Close UI",
		icon = "🚪",
		description = "Closes the hub completely (it asks you first).",
		run = askToClose,
	})

	-- CREDITS (people come from CREDITS at the top of the file)
	addSection(creditsTab, "THE TEAM")
	for _, person in ipairs(CREDITS) do
		person.kind = person.kind or "Credit"
		addButton(creditsTab, person)
	end
	addLabel(creditsTab, "Tap a name or its three dots to see more.", 36, THEME.muted)

	-- UPDATES (lines come from UPDATE_LOGS at the top of the file)
local V12_NEWS = {
	"🌈 Animated gradient border that spins around the window (+ Rainbow mode in Settings)",
	"✨ Shimmering title and floating sparkles in the background",
	"🔆 Glowing indicator on the active tab, tabs light up on hover",
	"🎬 Pages slide in smoothly when you switch tabs",
	"💧 Buttons glow, squish when pressed and show a ripple where you tap",
	"🔔 Better popups: accent bar + a timer bar that counts down",
	"👤 Profile card with your avatar at the bottom of the tab list",
	"🎚️ Gradient loading bar and nicer section titles",
	"⚙️ Settings: Rainbow border + Background sparkles switches",
}
local V11_NEWS = {
	"❄️ Screen effects: snowfall, falling leaves, rain, floating ghosts, rising embers",
	"⚡ Lightning flash button (flashing light, careful!)",
	"🩸 Blood moon screen tint (toggle)",
	"⏰ Reminder timer in Tools (1 to 60 minutes)",
	"🖥️ Server info button (players + server uptime)",
	"💾 Copy settings backup to your clipboard",
	"🔥 Daily streak on Home: open the hub every day to grow it",
	"🛑 Stop all effects button",
}
local V10_NEWS = {
	"🆕 NEW badges on new scripts + a New section on Home",
	"↕ Sort button in every tab: Default, A→Z, Z→A, Newest",
	"🔢 Script counts on every tab",
	"📝 Notes tab (saved automatically)",
	"🙈 Option to hide the hub after you run a script",
	"🔭 FOV slider + 🚀 FPS boost in Tools",
	"🐞 Copy debug info button for bug reports",
	"🔀 Shuffle + resume-on-start for the music player",
	"🎨 3 new accent colors: Sakura, Void, Mint",
	"💬 Friendlier error messages when a script fails",
	"📋 Copy your favorites list",
	"🧹 Reset everything button (Tools > Data)",
}
	addSection(updatesTab, "WHAT'S NEW IN V12")
	for _, line in ipairs(V12_NEWS) do
		addLabel(updatesTab, line, 36)
	end
	addSection(updatesTab, "WHAT'S NEW IN V11")
	for _, line in ipairs(V11_NEWS) do
		addLabel(updatesTab, line, 36)
	end
	addSection(updatesTab, "WHAT'S NEW IN V10")
	for _, line in ipairs(V10_NEWS) do
		addLabel(updatesTab, line, 36)
	end
	addSection(updatesTab, "EARLIER UPDATES")
	for _, line in ipairs({
		"🌐 Languages: English, Español, Português, Français",
		"📱 Mobile mode: draggable on-screen buttons that replace the keybinds",
		"⌨️ More keybinds (End, Right Ctrl, Insert) + toggles in Settings",
		"🔍 Window size now goes up to 130% for phones",
		"🚨 Panic button / End key hides everything instantly",
		"ℹ️ About V36 popup on Home",
		"🧹 Removed locked / deleted scripts for a cleaner list",
		"✨ Script of the day + 📈 all-time run counter on Home",
		"🚀 Scripts now load in the background, so the hub never freezes",
		"✅ Success / ⚠️ error popups for every script you run",
		"🔥 Most used scripts + 🔁 Run last script again",
		"🔎 Search by script name OR creator (try \"Guestly\")",
		"🧰 New Tools tab: Anti-AFK, rejoin, copy IDs, FPS cap",
		"🩺 Executor check: see which functions your executor supports",
		"📊 Live FPS, ping and session timer on Home",
		"🎨 5 accent colors in Settings",
		"🎵 Music player, 📻 playlist, ⭐ favorites and 🎲 random mode",
	}) do
		addLabel(updatesTab, line, 36)
	end
	addSection(updatesTab, "SCRIPT UPDATE LOG")
	for _, line in ipairs(UPDATE_LOGS) do
		addLabel(updatesTab, line, 36)
	end

	------------------------------------------------------------
	-- V11 BIG UPDATE
	-- Everything below plugs into helpers that already exist above:
	--   make(...)      builds a Roblox object        tween(...)  animates it
	--   addToggle / addButton / addSlider / addSection / addLabel  build menu rows
	--   notify(text, seconds)  shows a popup         track(conn)  auto-cleans connections
	-- New rows land at the BOTTOM of the tab you pass in (Effects, Tools, Home).
	------------------------------------------------------------

	-- A layer of our own. (The bats toggle clears effectsLayer, so we don't share it.)
	local fxLayer = make("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 1,
	}, gui)

	-- ONE function drives every falling/rising effect. Each effect is just a
	-- table of settings, so adding a new one later is only a few lines.
	-- "token" trick: stopping bumps the number, and every old loop notices
	-- its token is out of date and exits by itself.
	local particleTokens = {}
	local EFFECTS = {
		snow    = { name = "Snowfall",       icon = "❄️", emoji = "❄️", count = 18, size = {16, 26}, time = {40, 80}, fromY = -0.1, toY = 1.1,  drift = 0.10, spin = true },
		leaves  = { name = "Falling leaves", icon = "🍂", emoji = "🍂", count = 14, size = {20, 30}, time = {40, 70}, fromY = -0.1, toY = 1.1,  drift = 0.30, spin = true },
		rain    = { name = "Rain",           icon = "💧", emoji = "💧", count = 30, size = {14, 20}, time = {10, 20}, fromY = -0.1, toY = 1.1,  drift = 0.03, spin = false },
		ghosts  = { name = "Floating ghosts", icon = "👻", emoji = "👻", count = 6,  size = {26, 40}, time = {60, 100}, fromY = 1.1, toY = -0.1, drift = 0.20, spin = false },
		embers  = { name = "Rising embers",  icon = "✨", emoji = "✨", count = 16, size = {14, 24}, time = {40, 70}, fromY = 1.1,  toY = -0.1, drift = 0.15, spin = false },
	}

	local function stopEffect(kind)
		particleTokens[kind] = (particleTokens[kind] or 0) + 1
	end

	local function startEffect(kind)
		local def = EFFECTS[kind]
		stopEffect(kind) -- cancel any old copy first
		local token = particleTokens[kind]
		for _ = 1, def.count do
			task.spawn(function()
				local p = make("TextLabel", {
					BackgroundTransparency = 1,
					Text = def.emoji,
					TextSize = math.random(def.size[1], def.size[2]),
					Size = UDim2.fromOffset(40, 40),
					Position = UDim2.new(0, 0, def.fromY, 0),
				}, fxLayer)
				task.wait(math.random() * 3) -- so they don't all start together
				-- keep going while: still the newest token AND the hub still exists
				while particleTokens[kind] == token and p:IsDescendantOf(game) do
					local x = math.random()
					local dur = math.random(def.time[1], def.time[2]) / 10
					local endX = math.clamp(x + (math.random() - 0.5) * def.drift, 0, 1)
					p.Position = UDim2.new(x, 0, def.fromY, 0)
					tween(p, dur, {
						Position = UDim2.new(endX, 0, def.toY, 0),
						Rotation = def.spin and math.random(-180, 180) or 0,
					}, Enum.EasingStyle.Linear)
					task.wait(dur)
				end
				p:Destroy()
			end)
		end
	end

	addSection(effectsTab, "V11 WEATHER & ATMOSPHERE")
	local effectSwitches = {} -- so "Stop all" can flip the switches back off
	for _, kind in ipairs({ "snow", "leaves", "rain", "ghosts", "embers" }) do
		local def = EFFECTS[kind]
		local _, setSwitch = addToggle(effectsTab, {
			name = def.name,
			icon = def.icon,
			description = "Decoration only. Turn it off any time.",
			default = false,
			onChange = function(on)
				if on then
					startEffect(kind)
				else
					stopEffect(kind)
				end
			end,
		})
		effectSwitches[kind] = setSwitch
	end

	addButton(effectsTab, {
		name = "Stop all effects",
		icon = "🛑",
		description = "Turns off every V11 effect at once.",
		run = function()
			for kind, setSwitch in pairs(effectSwitches) do
				stopEffect(kind)
				setSwitch(false)
			end
		end,
	})

	-- Lightning: a white frame that appears, dims, flickers once, then fades.
	local lightningBusy = false
	addButton(effectsTab, {
		name = "Lightning flash",
		icon = "⚡",
		description = "A quick white flash across the screen. WARNING: flashing light, skip it if you're sensitive to that.",
		confirm = true,
		confirmText = "This flashes the screen. Continue?",
		run = function()
			if lightningBusy then
				return
			end
			lightningBusy = true
			local flash = make("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 0.35,
				ZIndex = 2,
			}, fxLayer)
			tween(flash, 0.12, { BackgroundTransparency = 0.9 })
			task.wait(0.15)
			flash.BackgroundTransparency = 0.5
			tween(flash, 0.7, { BackgroundTransparency = 1 })
			task.wait(0.75)
			flash:Destroy()
			lightningBusy = false
		end,
	})

	-- Blood moon: a ColorCorrectionEffect in Lighting (it only changes how YOUR screen looks).
	local Lighting = game:GetService("Lighting")
	local moonFx
	local function setBloodMoon(on)
		if moonFx then
			moonFx:Destroy()
			moonFx = nil
		end
		if on then
			moonFx = Instance.new("ColorCorrectionEffect")
			moonFx.Name = "HubBloodMoon"
			moonFx.TintColor = Color3.fromRGB(255, 170, 170)
			moonFx.Contrast = 0.1
			moonFx.Saturation = 0.1
			moonFx.Parent = Lighting
		end
	end
	gui.Destroying:Connect(function()
		setBloodMoon(false) -- clean up if the hub gets closed
	end)
	addToggle(effectsTab, {
		name = "Blood moon tint",
		icon = "🩸",
		description = "Gives your whole screen a spooky red tint. Turn it off to go back to normal.",
		default = false,
		onChange = setBloodMoon,
	})

	-- TOOLS: reminder timer, server info, settings backup
	addSection(toolsTab, "V11 EXTRAS")
	local reminderMinutes = 5
	addSlider(toolsTab, {
		name = "Reminder minutes",
		icon = "⏰",
		description = "Pick how many minutes, then press Start reminder.",
		min = 1,
		max = 60,
		default = 5,
		onChange = function(v)
			reminderMinutes = math.floor(v + 0.5)
		end,
	})
	addButton(toolsTab, {
		name = "Start reminder",
		icon = "⏱️",
		description = "Pops up a message when your time is up (handy so you don't lose track during long runs).",
		run = function()
			local mins = reminderMinutes
			notify("⏱️ Reminder set for " .. mins .. " min", 3)
			task.delay(mins * 60, function()
				notify("⏰ Your " .. mins .. " minute reminder is up!", 8)
			end)
		end,
	})
	addButton(toolsTab, {
		name = "Server info",
		icon = "🖥️",
		description = "Shows how many players are here and how long this server has been running.",
		run = function()
			local up = math.floor(workspace.DistributedGameTime)
			notify(
				string.format(
					"🖥️ Players: %d/%d  •  Uptime: %dh %02dm",
					#Players:GetPlayers(),
					Players.MaxPlayers,
					up // 3600,
					(up % 3600) // 60
				),
				6
			)
		end,
	})
	addButton(toolsTab, {
		name = "Copy settings backup",
		icon = "💾",
		description = "Copies all your saved hub data (favorites, settings, notes) as text. Needs setclipboard.",
		run = function()
			local okJ, text = pcall(function()
				return HttpService:JSONEncode(saved)
			end)
			if okJ and setclipboard then
				setclipboard(text)
				notify("💾 Backup copied!", 2)
			else
				notify("⚠️ Your executor can't copy to the clipboard", 4)
			end
		end,
	})

	-- HOME: daily streak. os.date("!%Y-%m-%d") = today's date (UTC) as text, e.g. "2026-10-13".
	-- If the last day you opened the hub was YESTERDAY the streak grows, otherwise it restarts at 1.
	do
		local today = os.date("!%Y-%m-%d")
		if saved.lastDay ~= today then
			local yesterday = os.date("!%Y-%m-%d", os.time() - 86400)
			if saved.lastDay == yesterday then
				saved.streak = (saved.streak or 0) + 1
			else
				saved.streak = 1
			end
			saved.bestStreak = math.max(saved.bestStreak or 0, saved.streak)
			saved.lastDay = today
			saveData()
		end
		addSection(homeTab, "🔥 DAILY STREAK")
		addLabel(
			homeTab,
			"🔥 " .. saved.streak .. " day streak  •  🏆 Best: " .. (saved.bestStreak or saved.streak),
			20,
			THEME.orange
		)
	end

	------------------------------------------------------------
	-- V12 NEON UI EXTRAS
	------------------------------------------------------------
	addSection(settingsTab, "V12 LOOK")
	addToggle(settingsTab, {
		name = "Rainbow border",
		icon = "🌈",
		description = "The window border cycles through every color instead of using your accent color. Saved.",
		default = saved.rainbow == true,
		onChange = function(on)
			saved.rainbow = on
			saveData()
			setRainbow(on)
		end,
	})
	addToggle(settingsTab, {
		name = "Background sparkles",
		icon = "✨",
		description = "Little glowing dots float up behind the window. Turn off if you want max performance. Saved.",
		default = saved.sparkles ~= false,
		onChange = function(on)
			saved.sparkles = on
			saveData()
			sparklesOn = on
		end,
	})

	-- Profile card: sits at the very bottom of the tab list (LayoutOrder 99999 = last)
	do
		local card = make("Frame", {
			Name = "ProfileCard",
			Size = UDim2.new(1, 0, 0, 46),
			BackgroundColor3 = THEME.bg,
			LayoutOrder = 99999,
		}, tabList)
		corner(card, 8)
		local cardStroke = stroke(card, THEME.purple, 1)
		pulse(cardStroke, "Color", THEME.orange, 2)
		local avatar = make("ImageLabel", {
			Size = UDim2.fromOffset(34, 34),
			Position = UDim2.fromOffset(6, 6),
			BackgroundColor3 = THEME.panelLight,
			Image = "",
		}, card)
		corner(avatar, 17)
		make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -46, 0, 20),
			Position = UDim2.fromOffset(44, 5),
			Text = player.DisplayName,
			TextColor3 = THEME.text,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, card)
		make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -46, 0, 16),
			Position = UDim2.fromOffset(44, 24),
			Text = "🔥 " .. tostring(saved.streak or 1) .. " day streak",
			TextColor3 = THEME.orange,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, card)
		-- avatar comes from Roblox's servers, so load it in the background and ignore failures
		task.spawn(function()
			pcall(function()
				local img = Players:GetUserThumbnailAsync(
					player.UserId,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size48x48
				)
				avatar.Image = img
			end)
		end)
	end

	------------------------------------------------------------
	-- ADD-ON API
	-- Other scripts can plug into the hub through getgenv().SilenceHub, e.g.
	--   local hub = getgenv().SilenceHub
	--   hub.addToggle(hub.settingsTab, { name = "My toggle", onChange = function(on) end })
	-- Add-ons register themselves in hub.addons[name] = { cleanup = function() end }
	-- so they get cleaned up when the hub closes.
	------------------------------------------------------------
	do
		local env = (getgenv and getgenv()) or _G
		local api = {
			version = "V12",
			gui = gui, window = window, tabList = tabList, settingsTab = settingsTab, THEME = THEME,
			make = make, tween = tween, pulse = pulse, corner = corner, stroke = stroke, notify = notify,
			addSection = addSection, addToggle = addToggle, addButton = addButton,
			startEffect = startEffect, stopEffect = stopEffect, EFFECTS = EFFECTS, fxLayer = fxLayer,
			borderGrad = borderGrad, titleGrad = titleGrad, accentSequence = accentSequence,
			isRainbow = function()
				return rainbowOn
			end,
			hooks = HubHooks,
			addons = {},
		}
		env.SilenceHub = api
		gui.Destroying:Connect(function()
			for _, addon in pairs(api.addons) do
				pcall(addon.cleanup)
			end
			if env.SilenceHub == api then
				env.SilenceHub = nil
			end
		end)
	end

	showPage("🏠 Home")

	------------------------------------------------------------
	-- LOADING SCREEN
	------------------------------------------------------------
	local loading = make("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = THEME.bg,
		ZIndex = 100,
	}, gui)
	make("UIGradient", {
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 120, 180)),
		Rotation = 90,
	}, loading) -- V12

	-- Fail-safe: if anything ever stalls, the loading screen removes itself
	task.delay(12, function()
		if loading and loading.Parent then
			loading:Destroy()
			pumpkin.Visible = true
			ready = true
			setOpen(true)
		end
	end)

	local emojis = { "🦇", "👻", "🎃", "💀", "🕷️" }
	local loadingActive = true
	for _ = 1, 14 do
		task.spawn(function()
			local e = make("TextLabel", {
				BackgroundTransparency = 1,
				Text = emojis[math.random(#emojis)],
				TextSize = math.random(20, 36),
				TextTransparency = 0.4,
				Size = UDim2.fromOffset(40, 40),
				Position = UDim2.new(0, 0, 1.2, 0),
			}, loading)
			task.wait(math.random() * 3)
			while loadingActive and e.Parent do
				local x = math.random()
				local dur = math.random(30, 60) / 10
				e.Position = UDim2.new(x, 0, 1.1, 0)
				tween(e, dur, { Position = UDim2.new(x, 0, -0.1, 0) }, Enum.EasingStyle.Linear)
				task.wait(dur)
			end
		end)
	end

	local loadTitle = make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 60),
		Position = UDim2.fromScale(0, 0.28),
		Text = "🎃 " .. HUB_TITLE:upper() .. " 🎃",
		TextColor3 = THEME.orange,
		Font = Enum.Font.GothamBlack,
		TextScaled = true,
	}, loading)
	make("UITextSizeConstraint", { MaxTextSize = 40 }, loadTitle)
	pulse(loadTitle, "TextColor3", THEME.purple, 0.9)

	local status = make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.fromScale(0, 0.44),
		Text = T("Summoning ghosts..."),
		TextColor3 = THEME.text,
		Font = Enum.Font.Gotham,
		TextSize = 18,
	}, loading)

	local barBack = make("Frame", {
		Size = UDim2.fromOffset(300, 10),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.57),
		BackgroundColor3 = THEME.panel,
	}, loading)
	corner(barBack, 5)

	local barFill = make("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
	}, barBack)
	corner(barFill, 5)
	make("UIGradient", { Color = ColorSequence.new(THEME.orange, THEME.purple) }, barFill) -- V12

	local percent = make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.fromScale(0, 0.61),
		Text = "0%",
		TextColor3 = THEME.orange,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
	}, loading)

	make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0, 0, 1, -40),
		Text = isMobile and T("Tip: tap the 🎃 to hide the hub") or TF("Tip: press %s or tap the 🎃 to hide the hub", TOGGLE_KEY_TEXT),
		TextColor3 = THEME.muted,
		Font = Enum.Font.Gotham,
		TextSize = 14,
	}, loading)

	local messages = {
		"Summoning ghosts...",
		"Carving pumpkins...",
		"Brewing potions...",
		"Waking the skeletons...",
		TF("Unlocking %d scripts...", totalScripts),
		"Almost ready...",
	}
	local steps = 40
	for i = 1, steps do
		local p = i / steps
		tween(barFill, 0.1, { Size = UDim2.fromScale(p, 1) }, Enum.EasingStyle.Linear)
		percent.Text = math.floor(p * 100) .. "%"
		status.Text = T(messages[math.min(#messages, math.ceil(p * #messages))])
		task.wait(0.09)
	end

	loadingActive = false
	fadeOut(loading, 0.5)
	task.wait(0.55)
	loading:Destroy()

	pumpkin.Visible = true
	ready = true
	setOpen(true)
	notify(TF("Welcome, %s! 🎃", player.DisplayName), 3)

	-- One-time "what's new" popup after updating
	if not saved.seenV12 then
		saved.seenV12 = true
		saveData()
		task.delay(1.2, function()
			local lines = {}
			for _, line in ipairs(V12_NEWS) do
				table.insert(lines, T(line))
			end
			showDialog({
				title = "🎃 What's new in V12",
				body = table.concat(lines, "\n"),
				accent = THEME.orange,
				a = { "Awesome!", THEME.purple },
			})
		end)
	end

	-- Background music (resumes your last song, if you played one before)
	if autoplayOn and current then
		task.spawn(setMusic, true)
	end

	-- Chat announcement
	if CHAT_ANNOUNCE then
		task.spawn(function()
			pcall(function()
				local channel = game:GetService("TextChatService").TextChannels:FindFirstChild("RBXGeneral")
				if not channel then
					return
				end
				for _, message in ipairs(CHAT_MESSAGES) do
					channel:DisplaySystemMessage(message)
					task.wait(1.5)
				end
			end)
		end)
	end

	-- Intro text over the Doors menu (skipped when MainUI doesn't exist)
	if SHOW_DOORS_INTRO then
		task.spawn(function()
			pcall(function()
				local mainUI = playerGui:FindFirstChild("MainUI")
				local mainFrame = mainUI and mainUI:FindFirstChild("MainFrame")
				local introText = mainFrame and mainFrame:FindFirstChild("IntroText")
				if not introText then
					return
				end
				local intro = introText:Clone()
				intro.Parent = mainUI
				intro.Name = "Hub Intro"
				intro.Visible = true
				intro.Text = DOORS_INTRO_TEXT
				intro.TextTransparency = 0

				local underline = intro:FindFirstChild("Underline")
				if underline then
					tween(underline, 3, { Size = UDim2.new(1.1, 0, 0.015, 6) }, Enum.EasingStyle.Linear)
					task.wait(7)
					tween(underline, 1.3, { Size = UDim2.new(0.95, 0, 0.015, 6) }, Enum.EasingStyle.Linear)
					tween(underline, 2, { ImageTransparency = 1 }, Enum.EasingStyle.Linear)
					tween(underline, 7, { Size = UDim2.new(0, 0, 0.015, 6) }, Enum.EasingStyle.Linear)
				end
				tween(intro, 2, { TextTransparency = 1 }, Enum.EasingStyle.Linear)
				task.wait(2.3)
				intro.Visible = false
				task.wait(4)
				intro:Destroy()
			end)
		end)
	end

	------------------------------------------------------------
	-- 💖 SECRET UNLOCK (key box -> loading screen -> secret tab)
	-- Runs in its own protected task: if it errors, the hub stays alive.
	-- Nothing here is ever written to the save file.
	------------------------------------------------------------
	task.spawn(function()
		local built, buildErr = pcall(function()
			if type(SECRET.url) ~= "string" or SECRET.url == "" then
				return
			end

			local PINK = Color3.fromRGB(255, 130, 190)
			local VIOLET = Color3.fromRGB(170, 90, 255)
			local unlocked, checking, attempts = false, false, 0

			-- ask the worker; true only when it answers exactly "valid"
			local function keyIsValid(key)
				local url = SECRET.url .. HttpService:UrlEncode(key)
				local body
				local okGet, res = pcall(function()
					return game:HttpGet(url)
				end)
				if okGet then
					body = res
				else
					local req = request or http_request
					if req then
						local okReq, r = pcall(function()
							return req({ Url = url, Method = "GET" })
						end)
						if okReq and r then
							body = r.Body
						end
					end
				end
				return type(body) == "string" and string.lower(body):match("^%s*valid%s*$") ~= nil
			end

			-- turns a number / rbxassetid / https link into something an ImageLabel can show
			local function resolveImage(src)
				if type(src) == "number" then
					return "rbxassetid://" .. src
				end
				if type(src) ~= "string" then
					return nil
				end
				if src:match("^rbxassetid://") or src:match("^rbxasset://") then
					return src
				end
				if src:match("^https?://") then
					local getAsset = getcustomasset or getsynasset
					if getAsset and writefile and isfile then
						local okImg, asset = pcall(function()
							local sum = 0
							for i = 1, #src do
								sum = (sum * 31 + src:byte(i)) % 1000000007
							end
							local path = "SilenceSecret_" .. sum .. ".png"
							if not isfile(path) then
								writefile(path, game:HttpGet(src))
							end
							return getAsset(path)
						end)
						if okImg then
							return asset
						end
					end
				end
				return nil
			end

			-- the loading screen (pictures cycle while the bar fills)
			local function playLoading()
				local scr = make("Frame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = Color3.fromRGB(34, 14, 48),
					ZIndex = 100,
				}, gui)
				make("UIGradient", {
					Color = ColorSequence.new(Color3.fromRGB(70, 24, 96), Color3.fromRGB(18, 8, 30)),
					Rotation = 90,
				}, scr)
				task.delay(25, function()
					if scr and scr.Parent then
						scr:Destroy()
					end
				end)

				local img = make("ImageLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(190, 190),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.3),
					ScaleType = Enum.ScaleType.Fit,
					ImageTransparency = 1,
				}, scr)
				corner(img, 18)

				local fallback = make("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(190, 190),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.3),
					Text = "💖",
					TextSize = 90,
					Visible = false,
				}, scr)

				make("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 40),
					Position = UDim2.fromScale(0, 0.5),
					Text = "💖 SECWET UNWOCKED 💖",
					TextColor3 = PINK,
					Font = Enum.Font.GothamBlack,
					TextSize = 26,
				}, scr)

				local status = make("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 26),
					Position = UDim2.fromScale(0, 0.575),
					Text = "Fetching pictuwes...",
					TextColor3 = THEME.text,
					Font = Enum.Font.Gotham,
					TextSize = 17,
				}, scr)

				local barBack = make("Frame", {
					Size = UDim2.fromOffset(300, 10),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.67),
					BackgroundColor3 = THEME.panel,
				}, scr)
				corner(barBack, 5)
				local barFill = make("Frame", {
					Size = UDim2.fromScale(0, 1),
					BackgroundColor3 = Color3.new(1, 1, 1),
				}, barBack)
				corner(barFill, 5)
				make("UIGradient", { Color = ColorSequence.new(PINK, VIOLET) }, barFill)

				local percent = make("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 24),
					Position = UDim2.fromScale(0, 0.7),
					Text = "0%",
					TextColor3 = PINK,
					Font = Enum.Font.GothamBold,
					TextSize = 16,
				}, scr)

				-- download / resolve the pictures first (this is the only part that can take a moment)
				local images = {}
				for _, src in ipairs(SECRET.images) do
					local ready2 = resolveImage(src)
					if ready2 then
						table.insert(images, ready2)
					end
				end
				if #images == 0 then
					fallback.Visible = true
					pulse(fallback, "TextSize", 110, 0.9)
				end

				local messages = { "Fwuffing da taiws...", "Stwaightening da bows...", "Adding extwa spawkwe...", "Awmost weady..." }
				local steps, shown = 40, 0
				for i = 1, steps do
					local p = i / steps
					tween(barFill, 0.1, { Size = UDim2.fromScale(p, 1) }, Enum.EasingStyle.Linear)
					percent.Text = math.floor(p * 100) .. "%"
					status.Text = messages[math.min(#messages, math.ceil(p * #messages))]
					if #images > 0 and (i - 1) % 10 == 0 then
						shown += 1
						img.Image = images[((shown - 1) % #images) + 1]
						img.ImageTransparency = 1
						tween(img, 0.4, { ImageTransparency = 0 })
					end
					task.wait(0.09)
				end

				fadeOut(scr, 0.5)
				tween(img, 0.5, { ImageTransparency = 1 })
				task.wait(0.55)
				scr:Destroy()
			end

			-- 🌸 FEMBOY MODE: recolors + uwu-ifies the WHOLE hub. Fully reversible, never saved.
			local femOn, femGen = false, 0
			local femState = {} -- [label] = { orig, last, conn }
			local femAdded, femFrom, femTo, femOld
			local FEM_COLORS = {
				Color3.fromRGB(28, 14, 38), -- bg
				Color3.fromRGB(44, 22, 58), -- panel
				Color3.fromRGB(68, 36, 88), -- panelLight
				Color3.fromRGB(255, 140, 200), -- orange -> pink
				Color3.fromRGB(130, 200, 255), -- purple -> baby blue
				Color3.fromRGB(255, 238, 248), -- text
				Color3.fromRGB(205, 160, 210), -- muted
			}
			local EMOJI_SWAP = { ["🎃"] = "🐾", ["👻"] = "🌸", ["🦇"] = "🦊", ["💀"] = "💖" }

			local function uwuify(text)
				if #text < 3 or text:find("<", 1, true) or text:find("http", 1, true) or text:find("rbxasset", 1, true) then
					return text
				end
				local out = text
				for from, to in pairs(EMOJI_SWAP) do
					out = out:gsub(from, to)
				end
				out = out:gsub("[rl]", "w"):gsub("[RL]", "W")
				out = out:gsub("n([aeiou])", "ny%1"):gsub("N([aeiou])", "Ny%1")
				out = out:gsub("ove", "uv")
				if #out >= 12 and #out % 4 == 0 and out:match("^%a") then
					out = out:sub(1, 1) .. "-" .. out
				end
				if #out >= 24 and out:match("[%.!]$") then
					local tails = { " uwu", " >w<", " :3" }
					out = out .. tails[#out % 3 + 1]
				end
				return out
			end

			local function femHook(lbl)
				if not (lbl:IsA("TextLabel") or lbl:IsA("TextButton")) or femState[lbl] then
					return
				end
				local st = { orig = lbl.Text }
				femState[lbl] = st
				local function restyle()
					local cur = lbl.Text
					if cur == st.last then
						return -- that was our own change
					end
					st.orig = cur
					local nt = uwuify(cur)
					st.last = nt
					if nt ~= cur then
						lbl.Text = nt
					end
				end
				st.conn = lbl:GetPropertyChangedSignal("Text"):Connect(restyle)
				lbl.Destroying:Connect(function()
					if st.conn then
						st.conn:Disconnect()
					end
					femState[lbl] = nil
				end)
				restyle()
			end

			local function sameC(a, b)
				return math.abs(a.R - b.R) + math.abs(a.G - b.G) + math.abs(a.B - b.B) < 0.004
			end
			local function mapC(c, from, to)
				for i = 1, #from do
					if sameC(c, from[i]) then
						return to[i]
					end
				end
				return c
			end
			local function fixColors(o, from, to)
				local function set(prop)
					local okGet, cur = pcall(function()
						return o[prop]
					end)
					if okGet and typeof(cur) == "Color3" then
						local n = mapC(cur, from, to)
						if n ~= cur then
							o[prop] = n
						end
					end
				end
				if o:IsA("GuiObject") then
					set("BackgroundColor3")
				end
				if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
					set("TextColor3")
				end
				if o:IsA("ImageLabel") or o:IsA("ImageButton") then
					set("ImageColor3")
				end
				if o:IsA("ScrollingFrame") then
					set("ScrollBarImageColor3")
				end
				if o:IsA("UIStroke") then
					set("Color")
				end
				if o:IsA("UIGradient") then
					local newKps, changed = {}, false
					for i, kp in ipairs(o.Color.Keypoints) do
						local nv = mapC(kp.Value, from, to)
						if nv ~= kp.Value then
							changed = true
						end
						newKps[i] = ColorSequenceKeypoint.new(kp.Time, nv)
					end
					if changed then
						o.Color = ColorSequence.new(newKps)
					end
				end
			end

			local function setFem(on)
				if on == femOn then
					return
				end
				femOn = on
				femGen += 1
				local gen = femGen
				if femAdded then
					femAdded:Disconnect()
					femAdded = nil
				end

				if on then
					femOld = { THEME.bg, THEME.panel, THEME.panelLight, THEME.orange, THEME.purple, THEME.text, THEME.muted }
					femFrom, femTo = femOld, FEM_COLORS
					THEME.bg, THEME.panel, THEME.panelLight = FEM_COLORS[1], FEM_COLORS[2], FEM_COLORS[3]
					THEME.orange, THEME.purple = FEM_COLORS[4], FEM_COLORS[5]
					THEME.text, THEME.muted = FEM_COLORS[6], FEM_COLORS[7]
					femAdded = gui.DescendantAdded:Connect(function(d)
						task.defer(function()
							if femOn then
								pcall(fixColors, d, femFrom, femTo)
								pcall(femHook, d)
							end
						end)
					end)
				else
					femFrom, femTo = FEM_COLORS, femOld
					if femOld then
						THEME.bg, THEME.panel, THEME.panelLight = femOld[1], femOld[2], femOld[3]
						THEME.orange, THEME.purple = femOld[4], femOld[5]
						THEME.text, THEME.muted = femOld[6], femOld[7]
					end
					-- put every original text back
					local old = femState
					femState = {}
					for lbl, st in pairs(old) do
						if st.conn then
							st.conn:Disconnect()
						end
						pcall(function()
							lbl.Text = st.orig
						end)
					end
				end

				local from, to = femFrom, femTo
				task.spawn(function()
					local n = 0
					for _, d in ipairs(gui:GetDescendants()) do
						if gen ~= femGen then
							return
						end
						pcall(fixColors, d, from, to)
						if on then
							pcall(femHook, d)
						end
						n += 1
						if n % 250 == 0 then
							task.wait()
						end
					end
				end)
			end

			-- builds the secret tab (only ever called after a valid key)
			local function addSecretRow(tab, def)
				local row = make("TextButton", {
					Size = UDim2.new(1, 0, 0, 36),
					BackgroundColor3 = THEME.bg,
					Text = "",
					LayoutOrder = nextOrder(),
				}, tab)
				corner(row, 8)
				stroke(row, THEME.orange, 1)
				make("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -24, 1, 0),
					Position = UDim2.fromOffset(12, 0),
					Text = (def.icon and (def.icon .. "  ") or "") .. tostring(def.name),
					TextColor3 = THEME.text,
					Font = Enum.Font.GothamMedium,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
				}, row)
				row.MouseEnter:Connect(function()
					tween(row, 0.12, { BackgroundColor3 = THEME.panelLight })
				end)
				row.MouseLeave:Connect(function()
					tween(row, 0.12, { BackgroundColor3 = THEME.bg })
				end)
				row.MouseButton1Click:Connect(function()
					local okRun, runErr = pcall(def.run or function() end)
					if not okRun then
						notify("⚠️ " .. tostring(runErr), 4)
					end
				end)
				return row
			end

			local function relock()
				setFem(false)
				local btn, pg = tabButtons[SECRET.tabName], pages[SECRET.tabName]
				showPage("🏠 Home")
				if btn then
					btn:Destroy()
				end
				if pg then
					pg:Destroy()
				end
				tabButtons[SECRET.tabName] = nil
				pages[SECRET.tabName] = nil
				tabInds[SECRET.tabName] = nil
				unlocked = false
			end

			local function buildSecretTab()
				local tab = createTab(SECRET.tabName)
				addSection(tab, "💖 Secwet Femboy GUI")
				addLabel(tab, "Hewwo cutie~ u found da secwet >w< Use da switch bewow to tuwn femboy mode on/off.", 40, PINK)
				addToggle(tab, {
					name = "Femboy mode",
					icon = "🐾",
					description = "Changes da WHOWE hub into uwu femboy-fuwwy mode (pink + bwue cowows, uwu wanguage). Tuwn it off to go back to nowmaw.",
					default = femOn,
					onChange = function(on)
						setFem(on)
					end,
				})
				for _, def in ipairs(SECRET.buttons) do
					addSecretRow(tab, def)
				end
				addSecretRow(tab, {
					name = "Wock da secwet 🔒",
					run = relock,
				})
				showPage(SECRET.tabName)
			end

			local function unlock()
				unlocked = true
				pcall(playLoading)
				setFem(true) -- unlocking turns femboy mode ON; flip the switch in the tab to turn it off
				buildSecretTab()
			end

			-- the key box
			local function askForKey()
				local overlay = make("TextButton", {
					Name = "SecretKeyBox",
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 0.45,
					Text = "",
					ZIndex = 90,
				}, gui)

				local card = make("Frame", {
					Size = UDim2.fromOffset(300, 176),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundColor3 = THEME.panel,
				}, overlay)
				corner(card, 12)
				stroke(card, PINK, 2)

				make("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 34),
					Position = UDim2.fromOffset(0, 8),
					Text = "💖 Entew youw key",
					TextColor3 = PINK,
					Font = Enum.Font.GothamBold,
					TextSize = 18,
				}, card)

				local box = make("TextBox", {
					Size = UDim2.new(1, -32, 0, 34),
					Position = UDim2.fromOffset(16, 48),
					BackgroundColor3 = THEME.bg,
					PlaceholderText = "uwu-xxxxxxxxxx",
					PlaceholderColor3 = THEME.muted,
					Text = "",
					TextColor3 = THEME.text,
					Font = Enum.Font.Gotham,
					TextSize = 15,
					ClearTextOnFocus = false,
				}, card)
				corner(box, 8)
				stroke(box, VIOLET, 1)

				local msg = make("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -32, 0, 20),
					Position = UDim2.fromOffset(16, 88),
					Text = "",
					TextColor3 = THEME.muted,
					Font = Enum.Font.Gotham,
					TextSize = 13,
				}, card)

				local function pill(text, x, w, color)
					local b = make("TextButton", {
						Size = UDim2.fromOffset(w, 32),
						Position = UDim2.fromOffset(x, 128),
						BackgroundColor3 = color,
						Text = text,
						TextColor3 = Color3.new(1, 1, 1),
						Font = Enum.Font.GothamBold,
						TextSize = 14,
					}, card)
					corner(b, 8)
					return b
				end
				local goBtn = pill("Unwock", 16, 170, PINK)
				local cancelBtn = pill("Cancew", 196, 88, THEME.panelLight)

				cancelBtn.MouseButton1Click:Connect(function()
					box.Text = ""
					overlay:Destroy()
				end)

				local function submit()
					if checking then
						return
					end
					local key = box.Text:gsub("^%s+", ""):gsub("%s+$", "")
					if key == "" then
						return
					end
					if attempts >= 5 then
						msg.Text = "Too many twies. Cwose and weopen da hub."
						msg.TextColor3 = THEME.danger
						return
					end
					attempts += 1
					checking = true
					msg.Text = "Checking~"
					msg.TextColor3 = THEME.muted
					task.spawn(function()
						local okCheck, good = pcall(keyIsValid, key)
						box.Text = "" -- never keep the key around
						checking = false
						if okCheck and good then
							overlay:Destroy()
							unlock()
						else
							msg.Text = okCheck and "Invawid key uwu" or "Couwdn't weach da key sewvew :("
							msg.TextColor3 = THEME.danger
						end
					end)
				end
				goBtn.MouseButton1Click:Connect(submit)
				box.FocusLost:Connect(function(enterPressed)
					if enterPressed then
						submit()
					end
				end)
			end

			-- the secret trigger: tap/click the hub title SECRET.taps times in a row
			local taps, lastTap = 0, 0
			track(titleLabel.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
					return
				end
				local now = os.clock()
				if now - lastTap > 1.2 then
					taps = 0
				end
				lastTap = now
				taps += 1
				if taps >= (SECRET.taps or 7) then
					taps = 0
					if checking then
						return
					end
					if unlocked then
						if pages[SECRET.tabName] then
							showPage(SECRET.tabName)
						end
					elseif not gui:FindFirstChild("SecretKeyBox") then
						askForKey()
					end
				end
			end))
		end)
		if not built then
			warn("[HubSecret] could not start:", buildErr)
		end
	end)
end)

if not ok then
	warn("[HalloweenHub] failed to start:", err)
	gui:Destroy()
end
