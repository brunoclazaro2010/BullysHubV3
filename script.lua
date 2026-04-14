if not game:IsLoaded() then game.Loaded:Wait() end
pcall(function() game:GetService("Players").RespawnTime = 0 end)
local privateBuild = false

local SharedState = {
    SelectedPetData = nil,
    AllAnimalsCache = nil,
    DisableStealSpeed = nil,
    ListNeedsRedraw = true,
    AdminButtonCache = {},
    StealSpeedToggleFunc = nil,
    _ssUpdateBtn = nil,
    AdminProxBtn = nil,
    BalloonedPlayers = {},
    MobileScaleObjects = {},
    RefreshMobileScale = nil,
}

do

    local Sync = require(game.ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Synchronizer"))
    local patched = 0

    for name, fn in pairs(Sync) do
        if typeof(fn) ~= "function" then continue end
        if isexecutorclosure(fn) then continue end

        local ok, ups = pcall(debug.getupvalues, fn)
        if not ok then continue end

        for idx, val in pairs(ups) do
            if typeof(val) == "function" and not isexecutorclosure(val) then
                local ok2, innerUps = pcall(debug.getupvalues, val)
                if ok2 then
                    local hasBoolean = false
                    for _, v in pairs(innerUps) do
                        if typeof(v) == "boolean" then
                            hasBoolean = true
                            break
                        end
                    end
                    if hasBoolean then
                        debug.setupvalue(fn, idx, newcclosure(function() end))
                        patched += 1
                    end
                end
            end
        end
    end
    print("bullys hub NAO E SOURCE DO LETHAL")
end

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService"),
    Workspace = game:GetService("Workspace"),
    Lighting = game:GetService("Lighting"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    GuiService = game:GetService("GuiService"),
    TeleportService = game:GetService("TeleportService"),
}
local Players = Services.Players
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local ReplicatedStorage = Services.ReplicatedStorage
local TweenService = Services.TweenService
local HttpService = Services.HttpService
local Workspace = Services.Workspace
local Lighting = Services.Lighting
local VirtualInputManager = Services.VirtualInputManager
local GuiService = Services.GuiService
local TeleportService = Services.TeleportService
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Decrypted
Decrypted = setmetatable({}, {
    __index = function(S, ez)
        local Netty = ReplicatedStorage.Packages.Net
        local prefix, path
        if     ez:sub(1,3) == "RE/" then prefix = "RE/";  path = ez:sub(4)
        elseif ez:sub(1,3) == "RF/" then prefix = "RF/";  path = ez:sub(4)
        else return nil end
        local Remote
        for i, v in Netty:GetChildren() do
            if v.Name == ez then
                Remote = Netty:GetChildren()[i + 1]
                break
            end
        end
        if Remote and not rawget(Decrypted, ez) then rawset(Decrypted, ez, Remote) end
        return rawget(Decrypted, ez)
    end
})
local Utility = {}
function Utility:LarpNet(F) return Decrypted[F] end
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
end

local IS_MOBILE = isMobile()


local FileName = "XisPublic_v1.json" 
local DefaultConfig = {
    Positions = {
        AdminPanel = {X = 0.1859375, Y = 0.5767123526556385}, 
        StealSpeed = {X = 0.02, Y = 0.18}, 
        Settings = {X = 0.834375, Y = 0.43590998043052839}, 
        InvisPanel = {X = 0.8578125, Y = 0.17260276361454258}, 
        AutoSteal = {X = 0.02, Y = 0.35}, 
        MobileControls = {X = 0.9, Y = 0.4},
        MobileBtn_TP = {X = 0.5, Y = 0.4},
        MobileBtn_CL = {X = 0.5, Y = 0.4},
        MobileBtn_SP = {X = 0.5, Y = 0.4},
        MobileBtn_IV = {X = 0.5, Y = 0.4},
        MobileBtn_UI = {X = 0.5, Y = 0.4},
        JobJoiner = {X = 0.5, Y = 0.85},
        AutoBuy   = {X = 0.01, Y = 0.35},
    }, 
    TpSettings = {
        Tool           = "Flying Carpet",
        Speed          = 2, 
        TpKey          = "T",
        CloneKey       = "V",
        TpOnLoad       = false,
        MinGenForTp    = "",
        CarpetSpeedKey = "Q",
        InfiniteJump   = false,
    },
    StealSpeed   = 20,
    ShowStealSpeedPanel = true,
    MenuKey      = "LeftControl",
    MobileGuiScale = 0.5,
    XrayEnabled  = true,
    AntiRagdoll  = 0,
    AntiRagdollV2 = false,
    PlayerESP    = true,
    FPSBoost     = true,
    TracerEnabled = true,
    BrainrotESP = true,
    LineToBase = false,
    StealNearest = false,
    StealHighest = true,
    StealPriority = false,
    DefaultToNearest = false,
    DefaultToHighest = false,
    DefaultToPriority = false,
    DefaultToDisable = false,
    UILocked     = false,
    HideAdminPanel = false,
    HideAutoSteal = false,
    CompactAutoSteal = false,
    AutoKickOnSteal = false,
    InstantSteal = false,
    InvisStealAngle = 233,
    SinkSliderValue = 5,
    AutoRecoverLagback = true,
    AutoInvisDuringSteal = false,
    InvisToggleKey = "I",
    ClickToAP = false,
    ClickToAPKeybind = "L",
    DisableClickToAPOnMoby = false,
    ProximityAP = false,
    ProximityAPKeybind = "P",
    ProximityRange = 15,
    StealSpeedKey = "C",
    ShowInvisPanel = true,
    ResetKey = "X",
    AutoResetOnBalloon = false,
    AntiBeeDisco = false,
    AutoDestroyTurrets = false,
    AutoTurretOnBrainrot = false,
    FOV = 70,
    SubspaceMineESP = false,
    AutoUnlockOnSteal = false,
    ShowUnlockButtonsHUD = false,
    AutoTPOnFailedSteal = false,
    AutoTPPriority = true,
    KickKey = "",
    CleanErrorGUIs = false,
    ClickToAPSingleCommand = false,
    RagdollSelfKey = "",
    DuelBaseESP = true,
    AlertsEnabled = true,
    AlertSoundID = "rbxassetid://6518811702",
    DisableProximitySpamOnMoby = false,
    DisableClickToAPOnKawaifu = false,
    DisableProximitySpamOnKawaifu = false,
    HideKawaifuFromPanel = false,
    AutoStealSpeed = false,
    ShowJobJoiner = true,
    JobJoinerKey = "J",
    CurrentTheme = "rosa",
    ShowMiniActions = true,
    AutoHideMiniUI = false,
    MiniUIPos = {X = 0.01, Y = 0.35},
    MiniUILocked = false,
    Blacklist = {},
    BlacklistESP = true,
    BlacklistMsg = "BLOCKED",
    AutoBuyEnabled = false,
    AutoBuyKey = "K",
    AutoBuyRange = 17,
    AutoBuyColor = {R=0, G=220, B=255},
    HideAutoBuyUI = false,
    HideStealSpeedUI = false,
    HideStatusHUD = false,
    HideInvisPanel = false,
    HidePlatformUI = false,
    PlatformOffset = 12.5,
}


local Config = DefaultConfig

if isfile and isfile(FileName) then
    pcall(function()
        local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(FileName)) end)
        if not ok then return end
        for k, v in pairs(DefaultConfig) do
            if decoded[k] == nil then decoded[k] = v end
        end
        if decoded.TpSettings then
            for k, v in pairs(DefaultConfig.TpSettings) do
                if decoded.TpSettings[k] == nil then decoded.TpSettings[k] = v end
            end
        end
        if decoded.Positions then
            for k, v in pairs(DefaultConfig.Positions) do
                if decoded.Positions[k] == nil then decoded.Positions[k] = v end
            end
        end
        if type(decoded.Blacklist) ~= "table" then decoded.Blacklist = {} end
        Config = decoded
    end)
end
Config.ProximityAP = false

-- Aplica tema imediatamente nos valores da tabela Theme
-- (antes das UIs serem construidas, para que ja usem as cores certas)
if Config.CurrentTheme and THEMES and THEMES[Config.CurrentTheme] then
    for k, v in pairs(THEMES[Config.CurrentTheme]) do Theme[k] = v end
end

local function SaveConfig()
    if writefile then
        pcall(function()
            local toSave = {}
            for k, v in pairs(Config) do toSave[k] = v end
            toSave.ProximityAP = false
            writefile(FileName, HttpService:JSONEncode(toSave))
        end)
    end
end

local function isMobyUser(player)
    if not player or not player.Character then return false end
    return player.Character:FindFirstChild("_moby_highlight") ~= nil
end

local HighlightName = "KaWaifu_NeonHighlight"
local function isKawaifuUser(player)
    if not player or not player.Character then return false end
    return player.Character:FindFirstChild(HighlightName) ~= nil
end

_G.InvisStealAngle = Config.InvisStealAngle
_G.SinkSliderValue = Config.SinkSliderValue
_G.AutoRecoverLagback = Config.AutoRecoverLagback
_G.AutoInvisDuringSteal = Config.AutoInvisDuringSteal
    _G.INVISIBLE_STEAL_KEY = Enum.KeyCode[Config.InvisToggleKey] or Enum.KeyCode.I
_G.invisibleStealEnabled = false
_G.RecoveryInProgress = false

local function getControls()
	local playerScripts = LocalPlayer:WaitForChild("PlayerScripts")
	local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
	return playerModule:GetControls()
end

local Controls = getControls()

local function kickPlayer()
    pcall(function()
        TeleportService:Teleport(1818, LocalPlayer)
    end)
    pcall(function()
        LocalPlayer:Kick("\BULLYS HUB - macaco prego <3")
    end)
end

local function walkForward(seconds)
    local char = LocalPlayer.Character
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local Controls = getControls()
    local lookVector = hrp.CFrame.LookVector
    Controls:Disable()
    local startTime = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if os.clock() - startTime >= seconds then
            conn:Disconnect()
            hum:Move(Vector3.zero, false)
            Controls:Enable()
            return
        end
        hum:Move(lookVector, false)
    end)
end


local function instantClone()
    if _G.isCloning then return end
    _G.isCloning = true

    local ok, err = pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not (char and hum) then error("No character") end

        local cloner =
            LocalPlayer.Backpack:FindFirstChild("Quantum Cloner")
            or char:FindFirstChild("Quantum Cloner")

        if not cloner then error("No Quantum Cloner") end

        pcall(function()
            hum:EquipTool(cloner)
        end)

        task.wait(0.05)

        cloner:Activate()
        task.wait(0.05)

        local cloneName = tostring(LocalPlayer.UserId) .. "_Clone"
        for _ = 1, 100 do
            if Workspace:FindFirstChild(cloneName) then break end
            task.wait(0.1)
        end

        if not Workspace:FindFirstChild(cloneName) then
            error("")
        end

        local toolsFrames = LocalPlayer.PlayerGui:FindFirstChild("ToolsFrames")
        local qcFrame = toolsFrames and toolsFrames:FindFirstChild("QuantumCloner")
        local tpButton = qcFrame and qcFrame:FindFirstChild("TeleportToClone")
        if not tpButton then error("Teleport button missing") end

        tpButton.Visible = true

        if firesignal then
            firesignal(tpButton.MouseButton1Up)
        else
            local vim = cloneref and cloneref(game:GetService("VirtualInputManager")) or VirtualInputManager
            local inset = (cloneref and cloneref(game:GetService("GuiService")) or GuiService):GetGuiInset()
            local pos = tpButton.AbsolutePosition + (tpButton.AbsoluteSize / 2) + inset

            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
            task.wait()
            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
        end
    end)

    _G.isCloning = false
end

local function triggerClosestUnlock(yLevel, maxY)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local playerY = yLevel or hrp.Position.Y
    local Y_THRESHOLD = 5

    local bestPromptSameLevel = nil
    local shortestDistSameLevel = math.huge

    local bestPromptFallback = nil
    local shortestDistFallback = math.huge
    
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return end

    for _, obj in ipairs(plots:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local part = obj.Parent
            if part and part:IsA("BasePart") then
                if maxY and part.Position.Y > maxY then
                else
                    local distance = (hrp.Position - part.Position).Magnitude
                    local yDifference = math.abs(playerY - part.Position.Y)

                    if distance < shortestDistFallback then
                        shortestDistFallback = distance
                        bestPromptFallback = obj
                    end

                    if yDifference <= Y_THRESHOLD then
                        if distance < shortestDistSameLevel then
                            shortestDistSameLevel = distance
                            bestPromptSameLevel = obj
                        end
                    end
                end
            end
        end
    end

    local targetPrompt = bestPromptSameLevel or bestPromptFallback

    if targetPrompt then
        if fireproximityprompt then
            fireproximityprompt(targetPrompt)
        else
            targetPrompt:InputBegan(Enum.UserInputType.MouseButton1)
            task.wait(0.05)
            targetPrompt:InputEnded(Enum.UserInputType.MouseButton1)
        end
    end
end

local Theme = {
    Background      = Color3.fromRGB(20, 15, 20),   -- fundo escuro com tom rosa
    Surface         = Color3.fromRGB(35, 25, 35),   -- caixas
    SurfaceHighlight= Color3.fromRGB(50, 35, 50),   -- highlight

    Accent1         = Color3.fromRGB(255, 120, 200), -- rosa claro
    Accent2         = Color3.fromRGB(255, 70, 170),  -- rosa principal

    TextPrimary     = Color3.fromRGB(255, 240, 250),
    TextSecondary   = Color3.fromRGB(200, 160, 190),

    Success         = Color3.fromRGB(255, 120, 200), -- botões ON
    Error           = Color3.fromRGB(255, 90, 140),  -- erro
}

-- ============================================================
-- SISTEMA DE TEMAS - sem `local` no top-level para nao exceder 200 locals
-- ============================================================
THEMES = {
    rosa = {
        Background       = Color3.fromRGB(20, 15, 20),
        Surface          = Color3.fromRGB(35, 25, 35),
        SurfaceHighlight = Color3.fromRGB(50, 35, 50),
        Accent1          = Color3.fromRGB(255, 120, 200),
        Accent2          = Color3.fromRGB(255, 70, 170),
        TextPrimary      = Color3.fromRGB(255, 240, 250),
        TextSecondary    = Color3.fromRGB(200, 160, 190),
        Success          = Color3.fromRGB(255, 120, 200),
        Error            = Color3.fromRGB(255, 90, 140),
        GlowColor1       = Color3.fromRGB(255, 120, 200),
        GlowColor2       = Color3.fromRGB(255, 70, 170),
    },
    ciano = {
        Background       = Color3.fromRGB(5, 18, 25),
        Surface          = Color3.fromRGB(10, 30, 40),
        SurfaceHighlight = Color3.fromRGB(15, 45, 58),
        Accent1          = Color3.fromRGB(0, 220, 255),
        Accent2          = Color3.fromRGB(0, 170, 230),
        TextPrimary      = Color3.fromRGB(220, 248, 255),
        TextSecondary    = Color3.fromRGB(140, 210, 230),
        Success          = Color3.fromRGB(0, 220, 255),
        Error            = Color3.fromRGB(255, 80, 120),
        GlowColor1       = Color3.fromRGB(0, 220, 255),
        GlowColor2       = Color3.fromRGB(0, 170, 230),
    },
    dourado = {
        Background       = Color3.fromRGB(15, 12, 5),
        Surface          = Color3.fromRGB(28, 22, 8),
        SurfaceHighlight = Color3.fromRGB(42, 33, 12),
        Accent1          = Color3.fromRGB(255, 215, 0),
        Accent2          = Color3.fromRGB(218, 165, 32),
        TextPrimary      = Color3.fromRGB(255, 245, 210),
        TextSecondary    = Color3.fromRGB(200, 170, 100),
        Success          = Color3.fromRGB(255, 215, 0),
        Error            = Color3.fromRGB(255, 90, 80),
        GlowColor1       = Color3.fromRGB(255, 215, 0),
        GlowColor2       = Color3.fromRGB(218, 165, 32),
    },
    prata = {
        Background       = Color3.fromRGB(12, 12, 18),
        Surface          = Color3.fromRGB(24, 24, 34),
        SurfaceHighlight = Color3.fromRGB(36, 36, 50),
        Accent1          = Color3.fromRGB(210, 215, 235),
        Accent2          = Color3.fromRGB(150, 155, 175),
        TextPrimary      = Color3.fromRGB(240, 240, 255),
        TextSecondary    = Color3.fromRGB(170, 170, 195),
        Success          = Color3.fromRGB(210, 215, 235),
        Error            = Color3.fromRGB(255, 90, 110),
        GlowColor1       = Color3.fromRGB(210, 215, 235),
        GlowColor2       = Color3.fromRGB(150, 155, 175),
    },
    preto = {
        Background       = Color3.fromRGB(4, 4, 6),
        Surface          = Color3.fromRGB(12, 12, 16),
        SurfaceHighlight = Color3.fromRGB(22, 22, 28),
        Accent1          = Color3.fromRGB(200, 200, 210),
        Accent2          = Color3.fromRGB(110, 110, 125),
        TextPrimary      = Color3.fromRGB(230, 230, 240),
        TextSecondary    = Color3.fromRGB(140, 140, 155),
        Success          = Color3.fromRGB(200, 200, 210),
        Error            = Color3.fromRGB(255, 70, 90),
        GlowColor1       = Color3.fromRGB(200, 200, 210),
        GlowColor2       = Color3.fromRGB(110, 110, 125),
    },
    roxo = {
        Background       = Color3.fromRGB(10, 5, 20),
        Surface          = Color3.fromRGB(22, 12, 40),
        SurfaceHighlight = Color3.fromRGB(35, 18, 60),
        Accent1          = Color3.fromRGB(180, 80, 255),
        Accent2          = Color3.fromRGB(130, 40, 210),
        TextPrimary      = Color3.fromRGB(240, 225, 255),
        TextSecondary    = Color3.fromRGB(170, 130, 210),
        Success          = Color3.fromRGB(180, 80, 255),
        Error            = Color3.fromRGB(255, 80, 120),
        GlowColor1       = Color3.fromRGB(180, 80, 255),
        GlowColor2       = Color3.fromRGB(130, 40, 210),
    },
    verde = {
        Background       = Color3.fromRGB(5, 15, 8),
        Surface          = Color3.fromRGB(10, 28, 14),
        SurfaceHighlight = Color3.fromRGB(15, 42, 20),
        Accent1          = Color3.fromRGB(0, 220, 80),
        Accent2          = Color3.fromRGB(0, 170, 60),
        TextPrimary      = Color3.fromRGB(220, 255, 230),
        TextSecondary    = Color3.fromRGB(130, 200, 150),
        Success          = Color3.fromRGB(0, 220, 80),
        Error            = Color3.fromRGB(255, 80, 80),
        GlowColor1       = Color3.fromRGB(0, 220, 80),
        GlowColor2       = Color3.fromRGB(0, 170, 60),
    },
    laranja = {
        Background       = Color3.fromRGB(15, 8, 3),
        Surface          = Color3.fromRGB(28, 15, 6),
        SurfaceHighlight = Color3.fromRGB(42, 22, 8),
        Accent1          = Color3.fromRGB(255, 140, 0),
        Accent2          = Color3.fromRGB(220, 100, 0),
        TextPrimary      = Color3.fromRGB(255, 240, 220),
        TextSecondary    = Color3.fromRGB(200, 155, 100),
        Success          = Color3.fromRGB(255, 140, 0),
        Error            = Color3.fromRGB(255, 60, 60),
        GlowColor1       = Color3.fromRGB(255, 140, 0),
        GlowColor2       = Color3.fromRGB(220, 100, 0),
    },
    vermelho = {
        Background       = Color3.fromRGB(18, 5, 5),
        Surface          = Color3.fromRGB(32, 10, 10),
        SurfaceHighlight = Color3.fromRGB(50, 16, 16),
        Accent1          = Color3.fromRGB(255, 50, 50),
        Accent2          = Color3.fromRGB(200, 20, 20),
        TextPrimary      = Color3.fromRGB(255, 230, 230),
        TextSecondary    = Color3.fromRGB(200, 140, 140),
        Success          = Color3.fromRGB(255, 50, 50),
        Error            = Color3.fromRGB(255, 80, 80),
        GlowColor1       = Color3.fromRGB(255, 50, 50),
        GlowColor2       = Color3.fromRGB(200, 20, 20),
    },
    cinza = {
        Background       = Color3.fromRGB(15, 15, 18),
        Surface          = Color3.fromRGB(28, 28, 32),
        SurfaceHighlight = Color3.fromRGB(42, 42, 48),
        Accent1          = Color3.fromRGB(160, 160, 180),
        Accent2          = Color3.fromRGB(120, 120, 140),
        TextPrimary      = Color3.fromRGB(230, 230, 235),
        TextSecondary    = Color3.fromRGB(160, 160, 170),
        Success          = Color3.fromRGB(160, 160, 180),
        Error            = Color3.fromRGB(255, 80, 80),
        GlowColor1       = Color3.fromRGB(160, 160, 180),
        GlowColor2       = Color3.fromRGB(120, 120, 140),
    },
}

-- Registros para update ao vivo de cores
_themeRegistry = {}
function TrackColor(element, colorType)
    if not _themeRegistry[colorType] then _themeRegistry[colorType] = {} end
    table.insert(_themeRegistry[colorType], element)
end


function applyTheme(themeName)
    local t = THEMES[themeName]
    if not t then return end

    -- Mapa: cor antiga -> cor nova (para todas as 3 transicoes possiveis)
    local colorMap = {}
    for k, oldColor in pairs(Theme) do
        if t[k] then
            colorMap[oldColor] = t[k]
        end
    end

    -- Atualiza tabela Theme in-place
    for k, v in pairs(t) do
        Theme[k] = v
    end
    Config.CurrentTheme = themeName
    SaveConfig()

    -- Percorre TODOS os descendentes de PlayerGui e substitui as cores
    local function matchColor(c1, c2)
        if not c1 or not c2 then return false end
        local dr = math.abs(c1.R - c2.R)
        local dg = math.abs(c1.G - c2.G)
        local db = math.abs(c1.B - c2.B)
        return (dr + dg + db) < 0.04
    end

    local function remapColor(c)
        if not c then return c end
        for oldC, newC in pairs(colorMap) do
            if matchColor(c, oldC) then return newC end
        end
        return c
    end

    local guiNames = {
        "AutoStealUI", "BullysAdminPanel", "SettingsUI", "StealSpeedUI",
        "BullysInvisPanel", "BullysStatusHUD", "BullysMobileControls", "BullysNotif",
        "BullysThemeUI", "PriorityListGUI", "BullysJobJoiner", "BullysPriorityAlert",
        "BullysSettings", "BullysPlatformUI"
    }

    for _, guiName in ipairs(guiNames) do
        local sg = PlayerGui:FindFirstChild(guiName)
        if sg then
            for _, obj in ipairs(sg:GetDescendants()) do
                pcall(function()
                    if obj:IsA("Frame") or obj:IsA("TextButton") or
                       obj:IsA("TextBox") or obj:IsA("ScrollingFrame") or
                       obj:IsA("ImageLabel") then
                        if obj.BackgroundTransparency < 1 then
                            obj.BackgroundColor3 = remapColor(obj.BackgroundColor3)
                        end
                    end
                    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                        obj.TextColor3 = remapColor(obj.TextColor3)
                    end
                    if obj:IsA("UIStroke") then
                        obj.Color = remapColor(obj.Color)
                    end
                    if obj:IsA("ScrollingFrame") then
                        obj.ScrollBarImageColor3 = remapColor(obj.ScrollBarImageColor3)
                    end
                    if obj:IsA("UIGradient") then
                        -- atualiza gradient de stroke/frame
                        local kps = obj.Color.Keypoints
                        local changed = false
                        local newKps = {}
                        for _, kp in ipairs(kps) do
                            local nc = remapColor(kp.Value)
                            if nc ~= kp.Value then changed = true end
                            table.insert(newKps, ColorSequenceKeypoint.new(kp.Time, nc))
                        end
                        if changed then
                            obj.Color = ColorSequence.new(newKps)
                        end
                    end
                    if obj:IsA("Beam") then
                        local kps = obj.Color.Keypoints
                        local newKps = {}
                        for _, kp in ipairs(kps) do
                            table.insert(newKps, ColorSequenceKeypoint.new(kp.Time, remapColor(kp.Value)))
                        end
                        obj.Color = ColorSequence.new(newKps)
                    end
                end)
            end
            -- Frame raiz
            pcall(function()
                local root = sg:FindFirstChildWhichIsA("Frame")
                if root and root.BackgroundTransparency < 1 then
                    root.BackgroundColor3 = remapColor(root.BackgroundColor3)
                end
            end)
        end
    end

    -- Reconstroi nova UI (sincrono, ja com novo tema aplicado)
    task.spawn(function()
        local savedTab  = (_G.BullysSettingsUI and _G.BullysSettingsUI.currentTab) or "act"
        local wasVis    = _G.BullysSettingsUI and _G.BullysSettingsUI.panel and _G.BullysSettingsUI.panel.Visible
        if buildBullysSettingsUI then
            buildBullysSettingsUI()
        end
        task.wait()
        if _G.BullysSettingsUI then
            if _G.BullysSettingsUI.switchTab then
                _G.BullysSettingsUI.switchTab(savedTab)
            end
            if wasVis and _G.BullysSettingsUI.panel then
                _G.BullysSettingsUI.panel.Visible = true
            end
        end
        -- Reconstroi HUD e Mini UI com novas cores
        if _G.rebuildStatusHUD then
            _G.rebuildStatusHUD()
        end
        -- Update auto buy ring color to match new theme
        if _G.updateAutoBuyRingColor then _G.updateAutoBuyRingColor() end
        if _G.rebuildAutoBuyCirclePresets then _G.rebuildAutoBuyCirclePresets() end
        if buildMiniActionsUI then
            local miniWasVis = _G.MiniActionsUI and _G.MiniActionsUI.panel and _G.MiniActionsUI.panel.Visible
            buildMiniActionsUI()
            task.wait()
            if miniWasVis and _G.MiniActionsUI and _G.MiniActionsUI.panel then
                _G.MiniActionsUI.panel.Visible = true
            end
        end

        -- Atualiza racetrack borders com nova cor
        local guisRT = {"AutoStealUI","BullysAdminPanel","SettingsUI","StealSpeedUI","BullysInvisPanel","BullysSettings","BullysStatusHUD","BullysAutoBuyUI"}
        for _, gn in ipairs(guisRT) do
            local sg = PlayerGui:FindFirstChild(gn)
            if sg then
                for _, obj in ipairs(sg:GetDescendants()) do
                    if obj.Name == "RacetrackBorder" and obj:IsA("UIStroke") then
                        local g2 = obj:FindFirstChildOfClass("UIGradient")
                        if g2 then
                            g2.Color = ColorSequence.new{
                                ColorSequenceKeypoint.new(0,   Theme.Background),
                                ColorSequenceKeypoint.new(0.3, Theme.Accent1),
                                ColorSequenceKeypoint.new(0.5, Theme.Accent2),
                                ColorSequenceKeypoint.new(0.7, Theme.Accent1),
                                ColorSequenceKeypoint.new(1,   Theme.Background),
                            }
                            obj.Color = Theme.Accent1
                        end
                    end
                end
            end
        end
    end)

    ShowNotification("TEMA", "Tema " .. themeName .. " aplicado!")
end

-- Helper: throttle de conexões para evitar limite de 200 upvalues/conexões
function createThrottledConnection(event, callback, throttleFrames)
    throttleFrames = throttleFrames or 3
    local frameCount = 0
    return event:Connect(function(...)
        frameCount = frameCount + 1
        if frameCount >= throttleFrames then
            frameCount = 0
            callback(...)
        end
    end)
end

-- ============================================================
-- RACETRACK BORDER ANIMATION (baseado no Goblin Hub v2)
-- Nao usa `local` no top-level para nao exceder 200 locals
-- ============================================================
function addRacetrackBorder(parentFrame, carColor, speed)
    if not parentFrame or not parentFrame:IsA("Frame") then return end
    carColor = carColor or Theme.Accent1
    speed    = speed or 2.5

    local stroke = Instance.new("UIStroke")
    stroke.Name = "RacetrackBorder"
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness  = 6
    stroke.Color      = carColor
    stroke.Transparency = 0.3
    stroke.Parent = parentFrame

    local grad = Instance.new("UIGradient")
    local bg = Theme.Background
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,   bg),
        ColorSequenceKeypoint.new(0.3, carColor),
        ColorSequenceKeypoint.new(0.5, Theme.Accent2),
        ColorSequenceKeypoint.new(0.7, carColor),
        ColorSequenceKeypoint.new(1,   bg),
    }
    grad.Rotation = 0
    grad.Parent   = stroke

    local startTime = tick()
    local lastUp    = 0
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not parentFrame.Parent then
            conn:Disconnect()
            return
        end
        local now = tick()
        if now - lastUp < 0.016 then return end
        lastUp = now

        local W = parentFrame.AbsoluteSize.X
        local H = parentFrame.AbsoluteSize.Y
        if W <= 0 or H <= 0 then return end

        local perim    = (W + H) * 2
        local elapsed  = (now - startTime) % speed
        local progress = elapsed / speed
        local dist     = (progress * perim) % perim
        local rot      = 0

        if dist < W then
            rot = (dist / W) * 90
        elseif dist < W + H then
            rot = 90 + ((dist - W) / H) * 90
        elseif dist < W * 2 + H then
            rot = 180 + ((dist - W - H) / W) * 90
        else
            rot = 270 + ((dist - W * 2 - H) / H) * 90
        end

        grad.Rotation = rot

        local wave = math.sin(progress * math.pi * 2)
        local intensity = (wave + 1) * 0.5
        stroke.Transparency = 0.05 + intensity * 0.4
        stroke.Thickness    = 6 + math.sin(now * 5) * 0.15
    end)

    return stroke
end

local PRIORITY_LIST = {
   "Strawberry Elephant",
   "Meowl",
   "Skibidi Toilet",
   "Headless Horseman",
   "Dragon Gingerini",
   "Dragon Cannelloni",
   "Ketupat Bros",
   "Hydra Dragon Cannelloni",
   "La Supreme Combinasion",
   "Love Love Bear",
   "Ginger Gerat",
   "Cerberus",
   "Capitano Moby",
   "La Casa Boo",
   "Burguro and Fryuro",
   "Spooky and Pumpky",
   "Cooki and Milki",
   "Rosey and Teddy",
   "Popcuru and Fizzuru",
   "Reinito Sleighito",
   "Fragrama and Chocrama",
   "Garama and Madundung",
   "Ketchuru and Musturu",
   "La Secret Combinasion",
   "Tralaledon",
   "Tictac Sahur",
   "Ketupat Kepat",
   "Tang Tang Keletang",
   "Orcaledon",
   "La Ginger Sekolah",
   "Los Spaghettis",
   "Lavadorito Spinito",
   "Swaggy Bros",
   "La Taco Combinasion",
   "Los Primos",
   "Chillin Chili",
   "Tuff Toucan",
   "W or L",
   "Chillin Chili",
   "Chipso and Queso"
}

local function findAdorneeGlobal(animalData)
    if not animalData then return nil end
    local plot = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(animalData.plot)
    if plot then
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if podiums then
            local podium = podiums:FindFirstChild(animalData.slot)
            if podium then
                local base = podium:FindFirstChild("Base")
                if base then
                    local spawn = base:FindFirstChild("Spawn")
                    if spawn then return spawn end
                    return base:FindFirstChildWhichIsA("BasePart") or base
                end
            end
        end
    end
    return nil
end

local function CreateGradient(parent)
    local g = Instance.new("UIGradient", parent)
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent2),
        ColorSequenceKeypoint.new(1, Theme.Accent2)
    }
    g.Rotation = 45
    return g
end

local function ApplyViewportUIScale(targetFrame, designWidth, designHeight, minScale, maxScale)
    if not targetFrame then return end
    if not IS_MOBILE then return end
    local existing = targetFrame:FindFirstChildOfClass("UIScale")
    if existing then existing:Destroy() end
    local sc = Instance.new("UIScale")
    sc.Parent = targetFrame
    SharedState.MobileScaleObjects[targetFrame] = sc
    if SharedState.RefreshMobileScale then
        SharedState.RefreshMobileScale()
    else
        sc.Scale = math.clamp(tonumber(Config.MobileGuiScale) or 0.5, 0, 1)
    end
end

SharedState.RefreshMobileScale = function()
    local s = math.clamp(tonumber(Config.MobileGuiScale) or 0.5, 0, 1)
    for frame, sc in pairs(SharedState.MobileScaleObjects) do
        if frame and frame.Parent and sc and sc.Parent == frame then
            sc.Scale = s
        else
            SharedState.MobileScaleObjects[frame] = nil
        end
    end
end

local function AddMobileMinimize(frame, labelText)
    if not IS_MOBILE then return end
    if not frame or not frame.Parent then return end
    local guiParent = frame.Parent
    local header = frame:FindFirstChildWhichIsA("Frame")
    if not header then return end

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
    minimizeBtn.Position = UDim2.new(1, -30, 0, 6)
    minimizeBtn.BackgroundColor3 = Theme.SurfaceHighlight
    minimizeBtn.Text = "-"
    minimizeBtn.Font = Enum.Font.GothamBlack
    minimizeBtn.TextSize = 18
    minimizeBtn.TextColor3 = Theme.TextPrimary
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = header
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

    local restoreBtn = Instance.new("TextButton")
    restoreBtn.Size = UDim2.new(0, 110, 0, 34)
    restoreBtn.Position = UDim2.new(0, 10, 1, -44)
    restoreBtn.BackgroundColor3 = Theme.SurfaceHighlight
    restoreBtn.Text = labelText or "OPEN"
    restoreBtn.Font = Enum.Font.GothamBold
    restoreBtn.TextSize = 12
    restoreBtn.TextColor3 = Theme.TextPrimary
    restoreBtn.Visible = false
    restoreBtn.AutoButtonColor = false
    restoreBtn.Parent = guiParent
    Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(0, 10)

    MakeDraggable(restoreBtn, restoreBtn)

    minimizeBtn.MouseButton1Click:Connect(function()
        frame.Visible = false
        restoreBtn.Visible = true
    end)

    restoreBtn.MouseButton1Click:Connect(function()
        frame.Visible = true
        restoreBtn.Visible = false
    end)
end

local function MakeDraggable(handle, target, saveKey)
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if Config.UILocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if saveKey then
                        local parentSize = target.Parent.AbsoluteSize
                        Config.Positions[saveKey] = {
                            X = target.AbsolutePosition.X / parentSize.X,
                            Y = target.AbsolutePosition.Y / parentSize.Y,
                        }
                        SaveConfig()
                    end
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function ShowNotification(title, text)
    local existing = PlayerGui:FindFirstChild("BullysNotif")
    if existing then existing:Destroy() end

    local sg = Instance.new("ScreenGui", PlayerGui)
    sg.Name = "BullysNotif"; sg.ResetOnSpawn = false

    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 290, 0, 54)
    f.Position = UDim2.new(0.5, -145, 0, 80)
    f.BackgroundColor3 = Color3.fromRGB(6, 6, 12)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 9)

    local stroke = Instance.new("UIStroke", f)
    stroke.Thickness = 1; stroke.Color = Theme.Accent2; stroke.Transparency = 1

    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(0, 3, 1, -12); bar.Position = UDim2.new(0, 5, 0, 6)
    bar.BackgroundColor3 = Theme.Accent1; bar.BorderSizePixel = 0
    bar.BackgroundTransparency = 1
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local t1 = Instance.new("TextLabel", f)
    t1.Size = UDim2.new(1, -22, 0, 18); t1.Position = UDim2.new(0, 16, 0, 7)
    t1.BackgroundTransparency = 1; t1.Text = title:upper()
    t1.Font = Enum.Font.GothamBlack; t1.TextSize = 11
    t1.TextColor3 = Theme.Accent1; t1.TextXAlignment = Enum.TextXAlignment.Left
    t1.TextTransparency = 1

    local t2 = Instance.new("TextLabel", f)
    t2.Size = UDim2.new(1, -22, 0, 15); t2.Position = UDim2.new(0, 16, 0, 27)
    t2.BackgroundTransparency = 1; t2.Text = text
    t2.Font = Enum.Font.GothamMedium; t2.TextSize = 10
    t2.TextColor3 = Theme.TextSecondary; t2.TextXAlignment = Enum.TextXAlignment.Left
    t2.TextTransparency = 1

    local fadeIn = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(f,      fadeIn, {BackgroundTransparency = 0.08}):Play()
    TweenService:Create(stroke, fadeIn, {Transparency = 0.3}):Play()
    TweenService:Create(bar,    fadeIn, {BackgroundTransparency = 0}):Play()
    TweenService:Create(t1,     fadeIn, {TextTransparency = 0}):Play()
    TweenService:Create(t2,     fadeIn, {TextTransparency = 0}):Play()

    task.delay(2, function()
        if not sg.Parent then return end
        local fadeOut = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(f,      fadeOut, {BackgroundTransparency = 1}):Play()
        TweenService:Create(stroke, fadeOut, {Transparency = 1}):Play()
        TweenService:Create(bar,    fadeOut, {BackgroundTransparency = 1}):Play()
        TweenService:Create(t1,     fadeOut, {TextTransparency = 1}):Play()
        local last = TweenService:Create(t2, fadeOut, {TextTransparency = 1})
        last:Play(); last.Completed:Wait()
        if sg.Parent then sg:Destroy() end
    end)
end

local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local function handleAnimator(animator)
    local model = animator:FindFirstAncestorOfClass("Model")
    if model and isPlayerCharacter(model) then return end
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:Stop(0) end
    animator.AnimationPlayed:Connect(function(track) track:Stop(0) end)
end

local function stripVisuals(obj)
    local model = obj:FindFirstAncestorOfClass("Model")
    local isPlayer = model and isPlayerCharacter(model)

    if obj:IsA("Animator") then handleAnimator(obj) end

    if obj:IsA("Accessory") or obj:IsA("Clothing") then
        if obj:FindFirstAncestorOfClass("Model") then
            obj:Destroy()
        end
    end

    if not isPlayer then
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or 
           obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or 
           obj:IsA("Highlight") then
            obj.Enabled = false
        end
        if obj:IsA("Explosion") then
            obj:Destroy()
        end
        if obj:IsA("MeshPart") then
            obj.TextureID = ""
        end
    end

    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.Plastic
        obj.Reflectance = 0
        obj.CastShadow = false
    end

    if obj:IsA("SurfaceAppearance") or obj:IsA("Texture") or obj:IsA("Decal") then
        obj:Destroy()
    end
end

local function setFPSBoost(enabled)
    Config.FPSBoost = enabled
    SaveConfig()
    
    if enabled then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 0
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or 
               v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") then
                v:Destroy()
            end
        end

        for _, obj in pairs(Workspace:GetDescendants()) do
            stripVisuals(obj)
        end

        Workspace.DescendantAdded:Connect(function(obj)
            if Config.FPSBoost then
                stripVisuals(obj)
            end
        end)
    end
end
if Config.FPSBoost then task.spawn(function() task.wait(1); setFPSBoost(true) end) end

local State = {
    ProximityAPActive = false,
    carpetSpeedEnabled = false,
    infiniteJumpEnabled = Config.TpSettings.InfiniteJump,
    xrayEnabled = false,
    antiRagdollMode = Config.AntiRagdoll or 0,
    floatActive = false,
    isTpMoving = false,
}
local Connections = {
    carpetSpeedConnection = nil,
    infiniteJumpConnection = nil,
    xrayDescConn = nil,
    antiRagdollConn = nil,
    antiRagdollV2Task = nil,
}
local UI = {
    carpetStatusLabel = nil,
    settingsGui = nil,
}
local carpetSpeedEnabled = State.carpetSpeedEnabled
local carpetSpeedConnection = Connections.carpetSpeedConnection
local _carpetStatusLabel = UI.carpetStatusLabel

local function setCarpetSpeed(enabled)
    State.carpetSpeedEnabled = enabled
    carpetSpeedEnabled = State.carpetSpeedEnabled
    if Connections.carpetSpeedConnection then Connections.carpetSpeedConnection:Disconnect(); Connections.carpetSpeedConnection = nil end
    carpetSpeedConnection = Connections.carpetSpeedConnection
    if not enabled then return end

    if SharedState.DisableStealSpeed then SharedState.DisableStealSpeed() end

    Connections.carpetSpeedConnection = RunService.Heartbeat:Connect(function()
    carpetSpeedConnection = Connections.carpetSpeedConnection
        local c = LocalPlayer.Character
        if not c then return end
        local hum = c:FindFirstChild("Humanoid")
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        local toolName = Config.TpSettings.Tool
        local hasTool = c:FindFirstChild(toolName)
        
        if not hasTool then
            local tb = LocalPlayer.Backpack:FindFirstChild(toolName)
            if tb then hum:EquipTool(tb) end
        end

        if hasTool then
            local md = hum.MoveDirection
            if md.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    md.X * 140, 
                    hrp.AssemblyLinearVelocity.Y, 
                    md.Z * 140
                )
            else
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end
    end)
end

local JumpData = {lastJumpTime = 0}
local infiniteJumpEnabled = State.infiniteJumpEnabled
local infiniteJumpConnection = Connections.infiniteJumpConnection

local function setInfiniteJump(enabled)
    State.infiniteJumpEnabled = enabled
    infiniteJumpEnabled = State.infiniteJumpEnabled
    Config.TpSettings.InfiniteJump = enabled
    SaveConfig()
    if Connections.infiniteJumpConnection then Connections.infiniteJumpConnection:Disconnect(); Connections.infiniteJumpConnection = nil end
    infiniteJumpConnection = Connections.infiniteJumpConnection
    if not enabled then return end

    Connections.infiniteJumpConnection = RunService.Heartbeat:Connect(function()
    infiniteJumpConnection = Connections.infiniteJumpConnection
        if not UserInputService:IsKeyDown(Enum.KeyCode.Space) then return end
        local now = tick()
        if now - JumpData.lastJumpTime < 0.1 then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        JumpData.lastJumpTime = now
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 55, hrp.AssemblyLinearVelocity.Z)
    end)
end
if infiniteJumpEnabled then setInfiniteJump(true) end

local XrayState = {
    originalTransparency = {},
    xrayEnabled = false,
}
local originalTransparency = XrayState.originalTransparency
local xrayEnabled = XrayState.xrayEnabled

local function isBaseWall(obj)
    if not obj:IsA("BasePart") then return false end
    local name = obj.Name:lower()
    local parentName = (obj.Parent and obj.Parent.Name:lower()) or ""
    return name:find("base") or parentName:find("base")
end

local function enableXray()
    XrayState.xrayEnabled = true
    xrayEnabled = XrayState.xrayEnabled
    do
        local descendants = Workspace:GetDescendants()
        for i = 1, #descendants do
            local obj = descendants[i]
            if obj:IsA("BasePart") and obj.Anchored and isBaseWall(obj) then
                XrayState.originalTransparency[obj] = obj.LocalTransparencyModifier
                originalTransparency[obj] = XrayState.originalTransparency[obj]
                obj.LocalTransparencyModifier = 0.85
            end
        end
    end
end

local xrayDescConn = Connections.xrayDescConn
local function disableXray()
    XrayState.xrayEnabled = false
    xrayEnabled = XrayState.xrayEnabled
    if Connections.xrayDescConn then Connections.xrayDescConn:Disconnect(); Connections.xrayDescConn = nil end
    xrayDescConn = Connections.xrayDescConn
    for part, val in pairs(XrayState.originalTransparency) do
        if part and part.Parent then part.LocalTransparencyModifier = val end
    end
    XrayState.originalTransparency = {}
    originalTransparency = XrayState.originalTransparency
end

if Config.XrayEnabled then
    enableXray()
    Connections.xrayDescConn = Workspace.DescendantAdded:Connect(function(obj)
        if XrayState.xrayEnabled and obj:IsA("BasePart") and obj.Anchored and isBaseWall(obj) then
            XrayState.originalTransparency[obj] = obj.LocalTransparencyModifier
            originalTransparency[obj] = XrayState.originalTransparency[obj]
            obj.LocalTransparencyModifier = 0.85
        end
    end)
    xrayDescConn = Connections.xrayDescConn
end

local antiRagdollMode = State.antiRagdollMode
local antiRagdollConn = Connections.antiRagdollConn

local function isRagdolled()
    local char = LocalPlayer.Character; if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    local state = hum:GetState()
    local ragStates = {
        [Enum.HumanoidStateType.Physics]     = true,
        [Enum.HumanoidStateType.Ragdoll]     = true,
        [Enum.HumanoidStateType.FallingDown] = true,
    }
    if ragStates[state] then return true end
    local endTime = LocalPlayer:GetAttribute("RagdollEndTime")
    if endTime and (endTime - Workspace:GetServerTimeNow()) > 0 then return true end
    return false
end

local function stopAntiRagdoll()
    if Connections.antiRagdollConn then Connections.antiRagdollConn:Disconnect(); Connections.antiRagdollConn ... (424 KB restante(s))
