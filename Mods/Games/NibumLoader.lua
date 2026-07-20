local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local VALID_KEYS = {"ilyguys"}
local DISCORD_LINK = "https://discord.gg/DHeCNzTypH"
local KEY_FILE = "IBdihPHub_SavedKey.txt"

local SCRIPTS = {
    { Name = "+1 Wood per Click", Icon = "🪵", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/ggs/refs/heads/main/games/1wood-per-click.lua", GameId = 112231208081788 },
    { Name = "1 Keyboard = 1$/s", Icon = "⌨️", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/ggs/refs/heads/main/games/1keyboard%3D1%24s.lua", GameId = 121003786627094 },
    { Name = "Anime Astral Simulator", Icon = "🔥", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/anime-astral-simulator.lua", GameId = 102072869879193 },
    { Name = "Anime Battles", Icon = "🤺", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/anime-battles.lua", GameId = 126229277218112 },
    { Name = "Anime Card Farm", Icon = "🃏", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/anime-card-farm.lua", GameId = 125039473548047 },
    { Name = "Anime Duelists", Icon = "⚔️", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/anime-duelists.lua", GameId = 135858844777165 },
    { Name = "Anime Powerscaling Card Collection", Icon = "🌟", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/anime-powerscaling-card-collection.lua", GameId = 85580552562948 },
    { Name = "Anime RNG Defense", Icon = "🏰", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/anime-rng-defense.lua", GameId = 104693964860826 },
    { Name = "Anime Stars Card Collection", Icon = "🌸", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/anime-stars-card-collection.lua", GameId = 109715918987082 },
    { Name = "Anime Universe", Icon = "🌌", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/anime-universe.lua", GameId = 95992966043247 },
    { Name = "Become an Anime Billionaire", Icon = "💸", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/become-an-anime-billionaire.lua", GameId = 96891089305948 },
    { Name = "Bomb Fishing", Icon = "🎣", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/bomb-fishing.lua", GameId = 118677256126351 },
    { Name = "Build a Base and Steal", Icon = "🏯", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/build-a-base-and-steal.lua", GameId = 132016691802922 },
    { Name = "Build a Keyboard", Icon = "⌨️", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/build-a-keyboard.lua", GameId = 91679585668032 },
    { Name = "Catch and Tame", Icon = "🐒", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/catch-and-tame.lua", GameId = 96645548064314 },
    { Name = "Chicken Farm", Icon = "🐓", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/chicken-farm.lua", GameId = 137233438285284 },
    { Name = "Clean the Squishies", Icon = "😻", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/clean-the-squishies.lua", GameId = 84016394196827 },
    { Name = "Crab Tycoon", Icon = "🦀", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/crab-tycoon.lua", GameId = 92605157087535 },
    { Name = "Digimon Era", Icon = "🦖", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/digimon-era.lua", GameId = 77192431769439 },
    { Name = "Egg Case Farm", Icon = "🥚", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/egg-case-farm.lua", GameId = 74144293690546 },
    { Name = "Grow it RNG", Icon = "🪴", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/grow-it-rng.lua", GameId = 78292727217500 },
    { Name = "Grow Your Land", Icon = "🧑‍🌾", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/grow-your-land.lua", GameId = 78769336859161 },
    { Name = "Loot RNG", Icon = "🗡️", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/loot-rng.lua", GameId = 118575129990331 },
    { Name = "Make a Drill Farm", Icon = "⛏️", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/make-a-drill-farm.lua", GameId = 79315121100812 },
    { Name = "Make Hotsauce", Icon = "🌶️", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/make-hotsauce.lua", GameId = 122391683154858 },
    { Name = "Merge a Blackhole", Icon = "🪐", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/merge-a-blackhole.lua", GameId = 118605709428489 },
    { Name = "Mine a Mountain", Icon = "🏔️", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/mine-a-mountain.lua", GameId = 125927821145949 },
    { Name = "Mine a Planet", Icon = "🌎", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/mine-a-planet.lua", GameId = 121125129560252 },
    { Name = "Missiles vs Cities", Icon = "🚀", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/missiles-vs-cities.lua", GameId = 112641748896693 },
    { Name = "My Fishing Anime", Icon = "🪝", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/my-fishing-anime.lua", GameId = 112244246405144 },
    { Name = "My Giant Sandwich", Icon = "🥪", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/my-giant-sandwich.lua", GameId = 139546619723000 },
    { Name = "My Wood Farm", Icon = "🪵", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/my-wood-farm.lua", GameId = 79267089300389 },
    { Name = "Place the Keycaps", Icon = "⌨️", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/place-the-keycaps.lua", GameId = 103984418130080 },
    { Name = "RNG Heroes", Icon = "🦸", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/rng-heroes.lua", GameId = 108307565942574 },
    { Name = "Roll Anime", Icon = "🎲", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/roll-anime.lua", GameId = 134898243790699 },
    { Name = "Roll to Defend", Icon = "🛡️", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/roll-to-defend.lua", GameId = 129559579789369 },
    { Name = "Scratchy Loot", Icon = "🎰", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/scratchy-loot.lua", GameId = 78105732598311 },
    { Name = "Snowcone Stand", Icon = "❄️", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/snowcone-stand.lua", GameId = 76113971506717 },
    { Name = "Soccer Manager", Icon = "🏟️", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/soccer-manager.lua", GameId = 83988958116126 },
    { Name = "Spin a Car", Icon = "🏎️", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/spin-a-car.lua", GameId = 136758055891411 },
    { Name = "Tap Incremental", Icon = "👆", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/tap-incremental.lua", GameId = 82103875404639 },
    { Name = "Throw a Coin", Icon = "🪙", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/throw-a-coin.lua", GameId = 115681808123944 },
    { Name = "Throw a Coin - World 2", Icon = "🪙", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/throw-a-coin-world-2.lua", GameId = 72042130041700 },
    { Name = "World Cup Album", Icon = "🏆", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/world-cup-album.lua", GameId = 71724366181884 },
    { Name = "Youtuber Card Collection", Icon = "💻", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/youtuber-card-collection.lua", GameId = 81440501385895 },
    { Name = "Zombie Turret Farm", Icon = "🧟‍♂️", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/zombie-turret-farm.lua", GameId = 70790155462881 },
    { Name = "temp", Icon = "💻", URL = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/awcc/refs/heads/main/games/temp.lua", GameId = 14728552283 },
}

-- ═══ HELPERS ═══
local function trim(s) return s:gsub("^%s+", ""):gsub("%s+$", "") end

local function isKeyValid(key)
    if not key or key == "" then return false end
    key = trim(key)
    for _, k in ipairs(VALID_KEYS) do
        if key == k then return true end
    end
    return false
end

local function saveKey(key) pcall(function() if writefile then writefile(KEY_FILE, key) end end) end

local function loadKey()
    local ok, res = pcall(function()
        return (isfile and readfile and isfile(KEY_FILE)) and readfile(KEY_FILE) or nil
    end)
    return ok and res or nil
end

local function getGameScript()
    for _, s in ipairs(SCRIPTS) do
        if s.GameId == game.PlaceId then return s end
    end
end

local function launch(scriptData)
    pcall(function() loadstring(game:HttpGet(scriptData.URL))() end)
end

-- ═══ AUTO-LAUNCH IF KEY SAVED ═══
local savedKey = loadKey()
local gameScript = getGameScript()

if isKeyValid(savedKey) and gameScript then
    launch(gameScript)
    return
end

-- ═══ COLORS ═══
local C = {
    bg          = Color3.fromRGB(20, 20, 30),
    card        = Color3.fromRGB(32, 32, 48),
    surface     = Color3.fromRGB(36, 36, 52),
    surfaceL    = Color3.fromRGB(44, 44, 62),
    accent      = Color3.fromRGB(140, 120, 255),
    accentH     = Color3.fromRGB(160, 142, 255),
    accentP     = Color3.fromRGB(120, 100, 230),
    accentGhost = Color3.fromRGB(50, 42, 85),
    accentSoft  = Color3.fromRGB(65, 55, 110),
    discord     = Color3.fromRGB(88, 101, 242),
    discordH    = Color3.fromRGB(110, 122, 255),
    discordP    = Color3.fromRGB(72, 84, 220),
    success     = Color3.fromRGB(70, 220, 130),
    error       = Color3.fromRGB(255, 90, 90),
    errorBg     = Color3.fromRGB(60, 25, 25),
    warning     = Color3.fromRGB(255, 200, 60),
    text        = Color3.fromRGB(250, 250, 255),
    textB       = Color3.fromRGB(255, 255, 255),
    textS       = Color3.fromRGB(185, 185, 210),
    textM       = Color3.fromRGB(120, 120, 150),
    border      = Color3.fromRGB(55, 55, 78),
    borderF     = Color3.fromRGB(140, 120, 255),
    inputBg     = Color3.fromRGB(24, 24, 38),
    inputBgF    = Color3.fromRGB(30, 28, 48),
    black       = Color3.fromRGB(0, 0, 0),
    white       = Color3.fromRGB(255, 255, 255),
}

-- ═══ UI FACTORY ═══
local function new(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then pcall(function() inst[k] = v end) end
    end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end

local function corner(p, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = p }) end
local function stroke(p, col, thick) return new("UIStroke", { Color = col or C.border, Thickness = thick or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p }) end
local function tween(obj, props, dur, style, dir)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj, TweenInfo.new(dur or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props):Play()
end

local function label(props)
    props.BackgroundTransparency = 1
    props.Font = props.Font or Enum.Font.GothamMedium
    return new("TextLabel", props)
end

local function setupHover(btn, n, h, p)
    btn.MouseEnter:Connect(function() tween(btn, { BackgroundColor3 = h }, 0.15) end)
    btn.MouseLeave:Connect(function() tween(btn, { BackgroundColor3 = n }, 0.2) end)
    btn.MouseButton1Down:Connect(function() tween(btn, { BackgroundColor3 = p or h }, 0.05) end)
    btn.MouseButton1Up:Connect(function() tween(btn, { BackgroundColor3 = h }, 0.1) end)
end

local function makeBtn(props, parent)
    local btn = new("TextButton", {
        Size = props.size, Position = props.pos,
        BackgroundColor3 = props.col, Text = "",
        AutoButtonColor = false, ZIndex = props.z or 7,
        ClipsDescendants = true, Parent = parent,
    })
    corner(btn, 10)
    label({ Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = props.text,
        TextColor3 = C.textB, TextSize = props.ts or 12, Font = Enum.Font.GothamBold, ZIndex = (props.z or 7)+1, Parent = btn })
    setupHover(btn, props.col, props.hov, props.press)
    return btn
end

-- ═══ BUILD GUI ═══
if CoreGui:FindFirstChild("IBdihPLoader") then CoreGui.IBdihPLoader:Destroy() end

local Gui = new("ScreenGui", { Name = "IBdihPLoader", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = CoreGui })
local Backdrop = new("Frame", { Size = UDim2.new(1,0,1,0), BackgroundColor3 = C.black, BackgroundTransparency = 1, ZIndex = 1, Parent = Gui })

local CW, CH = 520, 330
local Card = new("Frame", {
    Name = "Card", Size = UDim2.new(0,CW,0,0),
    Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5),
    BackgroundColor3 = C.bg, BackgroundTransparency = 1,
    ClipsDescendants = true, ZIndex = 2, Parent = Gui,
})
corner(Card, 16)
local cardStroke = stroke(Card, C.border, 1)
cardStroke.Transparency = 1

-- Accent bar
local AccentBar = new("Frame", { Size = UDim2.new(1,0,0,3), BackgroundColor3 = C.accent, BorderSizePixel = 0, ZIndex = 15, Parent = Card })
local accentGrad = new("UIGradient", {
    Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(140,120,255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200,140,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100,180,255)) }),
    Parent = AccentBar,
})
task.spawn(function()
    local t = 0
    while AccentBar and AccentBar.Parent do
        t += 0.02
        accentGrad.Offset = Vector2.new(math.sin(t) * 0.4, 0)
        accentGrad.Rotation = math.sin(t * 0.5) * 25
        RunService.RenderStepped:Wait()
    end
end)

-- Intro animation
task.wait(0.15)
tween(Backdrop, { BackgroundTransparency = 0.5 }, 0.5)
task.wait(0.05)
tween(Card, { Size = UDim2.new(0,CW,0,CH), BackgroundTransparency = 0 }, 0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
tween(cardStroke, { Transparency = 0 }, 0.4)
task.wait(0.55)

-- Close button
local CloseBtn = new("TextButton", { Size = UDim2.new(0,30,0,30), Position = UDim2.new(1,-40,0,10), BackgroundColor3 = C.surface, BackgroundTransparency = 0.4, Text = "✕", TextColor3 = C.textM, TextSize = 15, Font = Enum.Font.GothamBold, AutoButtonColor = false, ZIndex = 20, Parent = Card })
corner(CloseBtn, 8)
CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, { BackgroundTransparency = 0, BackgroundColor3 = C.errorBg, TextColor3 = C.error }, 0.15) end)
CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, { BackgroundTransparency = 0.4, BackgroundColor3 = C.surface, TextColor3 = C.textM }, 0.2) end)
CloseBtn.MouseButton1Click:Connect(function()
    tween(Card, { Size = UDim2.new(0,CW,0,0), BackgroundTransparency = 1 }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    tween(Backdrop, { BackgroundTransparency = 1 }, 0.35)
    task.wait(0.4); Gui:Destroy()
end)

-- Content area
local Content = new("Frame", { Size = UDim2.new(1,-68,1,-56), Position = UDim2.new(0,34,0,28), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 4, Parent = Card })

local function closeThenLaunch(scriptData)
    tween(Card, { Size = UDim2.new(0,CW,0,0), BackgroundTransparency = 1 }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    tween(Backdrop, { BackgroundTransparency = 1 }, 0.4)
    task.wait(0.5); Gui:Destroy(); launch(scriptData)
end

-- ══════════════════════════════════════════
--   KEY PAGE
-- ══════════════════════════════════════════
local KeyPage = new("Frame", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = not isKeyValid(savedKey), ZIndex = 5, Parent = Content })

-- Header
local LogoMark = new("Frame", { Size = UDim2.new(0,40,0,40), Position = UDim2.new(0,0,0,2), BackgroundColor3 = C.accentGhost, ZIndex = 6, Parent = KeyPage })
corner(LogoMark, 12); stroke(LogoMark, C.accent, 1)
label({ Size = UDim2.new(1,0,1,0), Text = "✦", TextColor3 = C.accent, TextSize = 20, Font = Enum.Font.GothamBold, ZIndex = 7, Parent = LogoMark })
label({ Size = UDim2.new(0,200,0,20), Position = UDim2.new(0,52,0,3), Text = "IBdihP Hub", TextColor3 = C.textB, TextSize = 18, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = KeyPage })
label({ Size = UDim2.new(0,200,0,14), Position = UDim2.new(0,52,0,25), Text = "script loader  v3.0", TextColor3 = C.textS, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = KeyPage })

new("Frame", { Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,0,54), BackgroundColor3 = C.border, BorderSizePixel = 0, ZIndex = 5, Parent = KeyPage })

label({ Size = UDim2.new(1,0,0,16), Position = UDim2.new(0,0,0,68), Text = "Welcome, " .. LocalPlayer.Name .. " 👋", TextColor3 = C.text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = KeyPage })
label({ Size = UDim2.new(1,0,0,14), Position = UDim2.new(0,0,0,87), Text = gameScript and ("✓  " .. gameScript.Name) or "⚠  This game is not supported", TextColor3 = gameScript and C.success or C.warning, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = KeyPage })

-- Input
label({ Size = UDim2.new(1,0,0,12), Position = UDim2.new(0,0,0,114), Text = "ENTER KEY", TextColor3 = C.textM, TextSize = 9, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = KeyPage })

local InputWrap = new("Frame", { Size = UDim2.new(1,0,0,44), Position = UDim2.new(0,0,0,132), BackgroundColor3 = C.inputBg, ZIndex = 6, Parent = KeyPage })
corner(InputWrap, 10)
local inputStroke = stroke(InputWrap, C.border, 1.5)
label({ Size = UDim2.new(0,34,1,0), Position = UDim2.new(0,4,0,0), Text = "🔑", TextSize = 14, ZIndex = 7, Parent = InputWrap })
local KeyInput = new("TextBox", { Size = UDim2.new(1,-48,1,0), Position = UDim2.new(0,38,0,0), BackgroundTransparency = 1, Text = "", PlaceholderText = "enter your key here...", PlaceholderColor3 = C.textM, TextColor3 = C.textB, TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 7, Parent = InputWrap })

KeyInput.Focused:Connect(function() tween(inputStroke, { Color = C.borderF }, 0.2); tween(InputWrap, { BackgroundColor3 = C.inputBgF }, 0.2) end)
KeyInput.FocusLost:Connect(function() tween(inputStroke, { Color = C.border }, 0.25); tween(InputWrap, { BackgroundColor3 = C.inputBg }, 0.25) end)

local StatusMsg = label({ Size = UDim2.new(1,0,0,16), Position = UDim2.new(0,0,0,184), Text = "", TextColor3 = C.error, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = KeyPage })
label({ Size = UDim2.new(1,0,0,14), Position = UDim2.new(0,0,0,204), Text = "free permanent key in our discord — saves automatically ♡", TextColor3 = C.textM, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 5, Parent = KeyPage })

-- Buttons
local BtnRow = new("Frame", { Size = UDim2.new(1,0,0,44), 
