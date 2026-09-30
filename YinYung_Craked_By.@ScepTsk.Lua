--[[
    ═══════════════════════════════════════════════════════════════════════════
    Yin yang welcome 
    ═══════════════════════════════════════════════════════════════════════════
]]

print("\n" .. string.rep("=", 80))
print("Yin Yang V39")
print(string.rep("=", 80))

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalizationService = game:GetService("LocalizationService")

if not LocalPlayer then
    error("ERROR: No local player available")
    return
end

--// ═════════════════════════════════════════════════════════════════════════════
--// ANTI-DUMP / ANTI-EXTRACT PROTECTION
--// ═════════════════════════════════════════════════════════════════════════════
do
    local _destroyed = false

    local function _selfDestruct(reason)
        if _destroyed then return end
        _destroyed = true
        -- Limpiar toda UI existente de forma silenciosa
        pcall(function()
            local targets = {"SAEKeySystem", "YinYangUI", "YinYangMain"}
            for _, guiParent in ipairs({
                game:GetService("CoreGui"),
                LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui"),
            }) do
                if guiParent then
                    for _, name in ipairs(targets) do
                        local g = guiParent:FindFirstChild(name)
                        if g then g:Destroy() end
                    end
                    for _, child in ipairs(guiParent:GetChildren()) do
                        if child:IsA("ScreenGui") then
                            pcall(function() child:Destroy() end)
                        end
                    end
                end
            end
        end)
        pcall(function()
            if type(isfile) == "function" and type(delfile) == "function" then
                if isfile("SAE_EvadeBeta_Key.txt") then
                    delfile("SAE_EvadeBeta_Key.txt")
                end
            end
        end)
        error("__YY_PROTECTED__" .. (reason or ""), 0)
    end

    -- [1] DETECCIÓN DE debug API
    pcall(function()
        local _db = debug
        if type(_db) == "table" then
            local _dangerousFns = {
                "getinfo", "getupvalue", "setupvalue", "getlocal",
                "setlocal", "getmetatable", "setmetatable",
                "traceback", "sethook", "getfenv", "setfenv"
            }
            for _, fnName in ipairs(_dangerousFns) do
                local original = _db[fnName]
                if type(original) == "function" then
                    _db[fnName] = function(...)
                        local _isDangerousCall = (
                            fnName == "getinfo" or fnName == "getupvalue" or fnName == "setupvalue"
                            or fnName == "getmetatable" or fnName == "setmetatable"
                            or fnName == "getfenv" or fnName == "setfenv"
                            or fnName == "getlocal" or fnName == "setlocal"
                            or fnName == "sethook"
                        )
                        if _isDangerousCall then
                            _selfDestruct("debug_api_intercepted:" .. fnName)
                        end
                        return original(...)
                    end
                end
            end
        end
    end)

    -- [2] DETECCIÓN DE decompile()
    pcall(function()
        if type(decompile) == "function" then
            local _origDecompile = decompile
            getgenv().decompile = function(obj, ...)
                if obj and (obj:IsA("LocalScript") or obj:IsA("ModuleScript") or obj:IsA("Script")) then
                    _selfDestruct("decompile_attempt")
                end
                return _origDecompile(obj, ...)
            end
        end
    end)

    -- [3] DETECCIÓN DE getscriptbytecode / dumpstring / getscripthash
    pcall(function()
        local _dumpFunctions = {"getscriptbytecode", "dumpstring", "getscripthash"}
        local _genv = type(getgenv) == "function" and getgenv() or _G
        for _, fnName in ipairs(_dumpFunctions) do
            if type(_genv[fnName]) == "function" then
                local _orig = _genv[fnName]
                _genv[fnName] = function(...)
                    _selfDestruct("bytecode_dump_intercepted:" .. fnName)
                    return _orig(...)
                end
            end
        end
    end)

    -- [4] MONITOREO CONTINUO
    local _envSnapshot = {}
    pcall(function()
        if type(getgenv) == "function" then
            local _genv = getgenv()
            for k, _ in pairs(_genv) do
                _envSnapshot[k] = true
            end
        end
    end)

    -- [5] VERIFICACIÓN DE ENTORNO
    pcall(function()
        local _isStudio = RunService:IsStudio()
        if _isStudio then
            if not LocalPlayer then
                _selfDestruct("studio_no_player")
            end
        end
    end)

    -- [6] WATCHDOG
    task.spawn(function()
        local _checkInterval = 3
        while not _destroyed do
            task.wait(_checkInterval)
            if _destroyed then break end

            pcall(function()
                if type(decompile) == "function" then
                    local _src = tostring(decompile)
                    if _src:find("native") or _src:find("C function") then
                        _selfDestruct("decompile_restored_native")
                    end
                end
            end)

            pcall(function()
                if type(getgenv) == "function" then
                    local _genv = getgenv()
                    local _dumpSignals = {
                        "getscriptbytecode", "dumpstring", "getscripthash",
                        "readbytecode", "getfuncinfo", "getprotolist"
                    }
                    for _, fnName in ipairs(_dumpSignals) do
                        if type(_genv[fnName]) == "function" and not _envSnapshot[fnName] then
                            _selfDestruct("injected_dump_fn:" .. fnName)
                        end
                    end
                end
            end)
        end
    end)
end
--// ═════════════════════════════════════════════════════════════════════════════
--// END PROTECTION
--// ═════════════════════════════════════════════════════════════════════════════

print("\nSERVICES: Initialized successfully")

--// ═════════════════════════════════════════════════════════════════════════════
--// MAIN CONFIGURATION
--// ═════════════════════════════════════════════════════════════════════════════

local Config = {
    --// SPEED MULTIPLIER (WalkSpeed real, distinto de Teleport Walk)
    EnableSpeedMultiplier = false,
    SpeedMultiplierValue = 1,

    --// BASIC MOVEMENT
    TeleportMovementSpeed = 5,
    EnableTeleportWalk = false,
    JumpHeight = 50,
    EnableEnhancedJump = false,
    --// INFINITE SLIDE
    EnableInfiniteSlide = false,
    InfiniteSlideSpeed = 30,
    --// INFINITE SLIDE OLD
    EnableInfiniteSlideOld = false,
    InfiniteSlideSpeedOld = 30,
    AutoJump = false,
    AutoJumpSpeed = 1.5,
    AutoCrouch = false,
    AutoCrouchSpeed = 1.5,
    EnableJumpAcceleration = false,
    JumpAccelerationSpeed = 42,

    --// GRAVITY MODIFICATION
    EnableGravityMod = false,
    GravityScale = 0.5,

    --// FRONTAL JUMP
    EnableFrontalJump = false,

    --// RAMP MULTIPLIER
    EnableRampMultiplier = false,

    --// BACK JUMP
    EnableBackJump = false,
    BackJumpSpeed = 42,

    --// MAP FEATURES
    EnableFullBright = false,
    EnableAutoTicket = false,
    EnableVoidEscape = false,
    EnableAfkMap     = false,
    EnableGagMap     = false,
    EnableAntiAfk    = false,
    EnableWhistleESP = false,

    --// EXTRA
    EnableReviveAura = false,
    EnableAutoSave   = false,
    EnableEspDown    = false,
    EnableAutoCarry = false,
    CarryRange    = 30,
    CarryInterval = 0.2,
    EnableAutoForceSpawn = false,
    EnableAntiBot = false,
    AntiBotDistance = 10,
    AntiBotCooldown = 0.15,

    --// EMOTE SPEED
    EnableEmoteSpeed = false,
    EmoteSpeedMultiplier = 1.5,

    --// LAYER JUMPS
    EnableLayerJumps = false,
    LayerJumpsCount = 2,

    --// IMPULSE JUMP
    EnableImpulseJump = false,
    ImpulseJumpSpeed = 42,

    --// AUTO TRIMP
    EnableAutoTrimp = false,
    AutoTrimpMultiplier = 2.5,
    AutoTrimpFallSpeed = 0.5,
    EnableTrimpTeleport = false,

    --// FIGURE-8 LOOP
    EnableFigure8  = false,
    Figure8Speed   = 1.5,
    Figure8Radius  = 8,
    --// LISSAJOUS 3:2 LOOP
    EnableLissajous  = false,
    LissajousSpeed   = 1.5,
    LissajousRadius  = 8,
    --// HIPOTROCOIDE
    EnableSpiro      = false,
    SpiroSpeed       = 0.8,
    SpiroRadius      = 12,
    SpiroRatio       = 0.35,

    --// REMOVE WALLS
    EnableRemoveWalls = false,
}

--// Frontal Jump Variables
local camera = Workspace.CurrentCamera
getgenv().FrontalJumpSpeed = 42
getgenv().RampMultiplier = 1.55
getgenv().RampMultiplierValue = 1.55
local maxExtraSpeed = 80
local currentSpeed = getgenv().FrontalJumpSpeed
local airAccumulator = 0
local lastTick = tick()
local wasAir = false
local activeBV = nil
local lastJumpTime = tick()
local jumpInterval = 0.65
local autoJumpNextTime = 0
local autoCrouchNextTime = 0
local rampLocked = false

--// Back Jump Variables
getgenv().BackJumpSpeed = 42
getgenv().BackRampMultiplier = 0
local backCurrentSpeed = getgenv().BackJumpSpeed
local backAirAccumulator = 0
local backLastTick = tick()
local backWasAir = false
local backActiveBV = nil
local backLastJumpTime = tick()
local backJumpInterval = 0.65
local backRampLocked = false

--// RaycastParams cacheados
local _rpFrontal = RaycastParams.new()
_rpFrontal.FilterType = Enum.RaycastFilterType.Blacklist
local _rpBack = RaycastParams.new()
_rpBack.FilterType = Enum.RaycastFilterType.Blacklist
local _rpRamp = RaycastParams.new()
_rpRamp.FilterType = Enum.RaycastFilterType.Blacklist
local _rpSlide = RaycastParams.new()
_rpSlide.FilterType = Enum.RaycastFilterType.Blacklist
local _rpAntiBot = RaycastParams.new()
_rpAntiBot.FilterType = Enum.RaycastFilterType.Blacklist

--// FullBright Variables
local Lighting = game:GetService("Lighting")

local fullBrightState = {
    Enabled = false,
    Connection = nil,
    Original = nil,
}

local fullBrightHooks = {
    SaveSettings = nil,
}

function captureFullBrightState()
    if fullBrightState.Original then
        return
    end
    local ok, snapshot = pcall(function()
        return {
            Brightness = Lighting.Brightness,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            ColorShift_Bottom = Lighting.ColorShift_Bottom,
            ColorShift_Top = Lighting.ColorShift_Top,
            GlobalShadows = Lighting.GlobalShadows,
            ClockTime = Lighting.ClockTime,
            ExposureCompensation = Lighting.ExposureCompensation,
            FogColor = Lighting.FogColor,
            FogEnd = Lighting.FogEnd,
            FogStart = Lighting.FogStart,
            EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
            EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
        }
    end)
    if ok and snapshot then
        fullBrightState.Original = snapshot
    end
end

function disconnectFullBrightConnection()
    if fullBrightState.Connection then
        pcall(function()
            fullBrightState.Connection:Disconnect()
        end)
        fullBrightState.Connection = nil
    end
end

function restoreFullBrightState()
    local original = fullBrightState.Original
    if not original then return end
    pcall(function()
        Lighting.Brightness = original.Brightness
        Lighting.Ambient = original.Ambient
        Lighting.OutdoorAmbient = original.OutdoorAmbient
        Lighting.ColorShift_Bottom = original.ColorShift_Bottom
        Lighting.ColorShift_Top = original.ColorShift_Top
        Lighting.GlobalShadows = original.GlobalShadows
        Lighting.ClockTime = original.ClockTime
        Lighting.ExposureCompensation = original.ExposureCompensation
        Lighting.FogColor = original.FogColor
        Lighting.FogEnd = original.FogEnd
        Lighting.FogStart = original.FogStart
        Lighting.EnvironmentDiffuseScale = original.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale = original.EnvironmentSpecularScale
    end)
end

function applyFullBright()
    pcall(function()
        if Lighting.GlobalShadows ~= false then Lighting.GlobalShadows = false end
        if Lighting.Brightness ~= 1 then Lighting.Brightness = 1 end
        local white = Color3.new(1, 1, 1)
        if Lighting.Ambient ~= white then Lighting.Ambient = white end
        if Lighting.OutdoorAmbient ~= white then Lighting.OutdoorAmbient = white end
        if Lighting.ColorShift_Bottom ~= white then Lighting.ColorShift_Bottom = white end
        if Lighting.ColorShift_Top ~= white then Lighting.ColorShift_Top = white end
        if Lighting.ClockTime ~= 12 then Lighting.ClockTime = 12 end
        if Lighting.ExposureCompensation ~= 0 then Lighting.ExposureCompensation = 0 end
        if Lighting.FogColor ~= white then Lighting.FogColor = white end
        if Lighting.FogEnd ~= 1e10 then Lighting.FogEnd = 1e10 end
        if Lighting.FogStart ~= 0 then Lighting.FogStart = 0 end
        if Lighting.EnvironmentDiffuseScale ~= 1 then Lighting.EnvironmentDiffuseScale = 1 end
        if Lighting.EnvironmentSpecularScale ~= 1 then Lighting.EnvironmentSpecularScale = 1 end
    end)
end

function setFullBrightEnabled(state)
    local enabled = state and true or false
    fullBrightState.Enabled = enabled
    Config.EnableFullBright = enabled
    if enabled then
        captureFullBrightState()
        applyFullBright()
        if not fullBrightState.Connection then
            fullBrightState.Connection = RunService.Heartbeat:Connect(function()
                if not fullBrightState.Enabled then return end
                applyFullBright()
            end)
        end
    else
        disconnectFullBrightConnection()
        restoreFullBrightState()
    end
    if fullBrightHooks.SaveSettings then
        pcall(function()
            fullBrightHooks.SaveSettings()
        end)
    end
end

--// Variables to save options state
local savedOptions = {
    EnableTeleportWalk = false,
    EnableEnhancedJump = false,
    EnableGravityMod = false,
}

--// ═════════════════════════════════════════════════════════════════════════════
--// SETTINGS SAVE/LOAD SYSTEM
--// ═════════════════════════════════════════════════════════════════════════════

local HttpService = game:GetService("HttpService")
local SettingsFile = "EVADE_V52_Settings.json"

function SaveSettings()
    pcall(function()
        local data = {
            EnableTeleportWalk = Config.EnableTeleportWalk,
            TeleportMovementSpeed = Config.TeleportMovementSpeed,
            EnableEnhancedJump = Config.EnableEnhancedJump,
            JumpHeight = Config.JumpHeight,
            EnableInfiniteSlide = Config.EnableInfiniteSlide,
            InfiniteSlideSpeed = Config.InfiniteSlideSpeed,
            EnableInfiniteSlideOld = Config.EnableInfiniteSlideOld,
            InfiniteSlideSpeedOld = Config.InfiniteSlideSpeedOld,
            AutoJump = Config.AutoJump,
            AutoJumpSpeed = Config.AutoJumpSpeed,
            AutoCrouch = Config.AutoCrouch,
            AutoCrouchSpeed = Config.AutoCrouchSpeed,
            EnableJumpAcceleration = Config.EnableJumpAcceleration,
            JumpAccelerationSpeed = Config.JumpAccelerationSpeed,
            EnableGravityMod = Config.EnableGravityMod,
            GravityScale = Config.GravityScale,
            EnableFrontalJump = Config.EnableFrontalJump,
            FrontalJumpSpeed = getgenv().FrontalJumpSpeed,
            RampMultiplier = getgenv().RampMultiplier,
            EnableRampMultiplier = Config.EnableRampMultiplier,
            RampMultiplierValue = getgenv().RampMultiplierValue,
            EnableFullBright = Config.EnableFullBright,
            EnableAutoTicket = Config.EnableAutoTicket,
            EnableVoidEscape = Config.EnableVoidEscape,
            EnableAfkMap     = Config.EnableAfkMap,
            EnableGagMap     = Config.EnableGagMap,
            EnableAntiAfk    = Config.EnableAntiAfk,
            EnableWhistleESP = Config.EnableWhistleESP,
            EnableReviveAura = Config.EnableReviveAura,
            EnableAutoSave   = Config.EnableAutoSave,
            EnableEspDown    = Config.EnableEspDown,
            EnableAutoCarry = Config.EnableAutoCarry,
            CarryRange    = Config.CarryRange,
            CarryInterval = Config.CarryInterval,
            EnableAutoForceSpawn = Config.EnableAutoForceSpawn,
            EnableAntiBot = Config.EnableAntiBot,
            AntiBotDistance = Config.AntiBotDistance,
            AntiBotCooldown = Config.AntiBotCooldown,
            EnableAutoTrimp = Config.EnableAutoTrimp,
            AutoTrimpMultiplier = Config.AutoTrimpMultiplier,
            AutoTrimpFallSpeed = Config.AutoTrimpFallSpeed,
            EnableTrimpTeleport = Config.EnableTrimpTeleport,
            EnableSpeedMultiplier = Config.EnableSpeedMultiplier,
            SpeedMultiplierValue = Config.SpeedMultiplierValue,
            EnableEmoteSpeed = Config.EnableEmoteSpeed,
            EmoteSpeedMultiplier = Config.EmoteSpeedMultiplier,
            EnableLayerJumps = Config.EnableLayerJumps,
            LayerJumpsCount = Config.LayerJumpsCount,
            EnableImpulseJump = Config.EnableImpulseJump,
            ImpulseJumpSpeed = Config.ImpulseJumpSpeed,
            EnableBackJump = Config.EnableBackJump,
            BackJumpSpeed = getgenv().BackJumpSpeed,
            BackRampMultiplier = getgenv().BackRampMultiplier,
            EnableFigure8  = Config.EnableFigure8,
            Figure8Speed   = Config.Figure8Speed,
            Figure8Radius  = Config.Figure8Radius,
            EnableLissajous  = Config.EnableLissajous,
            LissajousSpeed   = Config.LissajousSpeed,
            LissajousRadius  = Config.LissajousRadius,
            EnableSpiro      = Config.EnableSpiro,
            SpiroSpeed       = Config.SpiroSpeed,
            SpiroRadius      = Config.SpiroRadius,
            SpiroRatio       = Config.SpiroRatio,
        }
        writefile(SettingsFile, HttpService:JSONEncode(data))
    end)
end

function LoadSettings()
    local ok, result = pcall(function()
        if isfile and isfile(SettingsFile) then
            local content = readfile(SettingsFile)
            if content and content ~= "" then
                return HttpService:JSONDecode(content)
            end
        end
        return nil
    end)

    if ok and result then
        if result.EnableTeleportWalk ~= nil then Config.EnableTeleportWalk = result.EnableTeleportWalk end
        if result.TeleportMovementSpeed ~= nil then Config.TeleportMovementSpeed = result.TeleportMovementSpeed end
        if result.EnableEnhancedJump ~= nil then Config.EnableEnhancedJump = result.EnableEnhancedJump end
        if result.JumpHeight ~= nil then Config.JumpHeight = result.JumpHeight end
        if result.EnableInfiniteSlide ~= nil then Config.EnableInfiniteSlide = result.EnableInfiniteSlide end
        if result.InfiniteSlideSpeed ~= nil then Config.InfiniteSlideSpeed = math.clamp(result.InfiniteSlideSpeed, 15, 150) end
        if result.EnableInfiniteSlideOld ~= nil then Config.EnableInfiniteSlideOld = result.EnableInfiniteSlideOld end
        if result.InfiniteSlideSpeedOld ~= nil then Config.InfiniteSlideSpeedOld = math.clamp(result.InfiniteSlideSpeedOld, 15, 150) end
        if result.AutoJump ~= nil then Config.AutoJump = result.AutoJump end
        if result.AutoJumpSpeed ~= nil then Config.AutoJumpSpeed = math.clamp(tonumber(result.AutoJumpSpeed) or 1.5, 0.5, 8) end
        if result.AutoCrouch ~= nil then Config.AutoCrouch = result.AutoCrouch end
        if result.AutoCrouchSpeed ~= nil then Config.AutoCrouchSpeed = math.clamp(tonumber(result.AutoCrouchSpeed) or 1.5, 0.5, 24) end
        if result.EnableJumpAcceleration ~= nil then Config.EnableJumpAcceleration = result.EnableJumpAcceleration end
        if result.JumpAccelerationSpeed ~= nil then Config.JumpAccelerationSpeed = math.clamp(tonumber(result.JumpAccelerationSpeed) or 42, 30, 110) end
        if result.EnableGravityMod ~= nil then Config.EnableGravityMod = result.EnableGravityMod end
        if result.GravityScale ~= nil then Config.GravityScale = result.GravityScale end
        if result.EnableFrontalJump ~= nil then Config.EnableFrontalJump = result.EnableFrontalJump end
        if result.FrontalJumpSpeed ~= nil then getgenv().FrontalJumpSpeed = result.FrontalJumpSpeed end
        if result.RampMultiplier ~= nil then getgenv().RampMultiplier = result.RampMultiplier end
        if result.EnableRampMultiplier ~= nil then Config.EnableRampMultiplier = result.EnableRampMultiplier end
        if result.RampMultiplierValue ~= nil then getgenv().RampMultiplierValue = result.RampMultiplierValue end
        if result.EnableFullBright ~= nil then Config.EnableFullBright = result.EnableFullBright end
        if result.EnableAutoTicket ~= nil then Config.EnableAutoTicket = result.EnableAutoTicket end
        if result.EnableVoidEscape ~= nil then Config.EnableVoidEscape = result.EnableVoidEscape end
        if result.EnableAfkMap     ~= nil then Config.EnableAfkMap     = result.EnableAfkMap     end
        if result.EnableGagMap     ~= nil then Config.EnableGagMap     = result.EnableGagMap     end
        if result.EnableAntiAfk    ~= nil then Config.EnableAntiAfk    = result.EnableAntiAfk    end
        if result.EnableWhistleESP ~= nil then Config.EnableWhistleESP = result.EnableWhistleESP end
        if result.EnableReviveAura ~= nil then Config.EnableReviveAura = result.EnableReviveAura end
        if result.EnableAutoSave   ~= nil then Config.EnableAutoSave   = result.EnableAutoSave   end
        if result.EnableEspDown    ~= nil then Config.EnableEspDown    = result.EnableEspDown    end
        if result.EnableAutoCarry ~= nil then Config.EnableAutoCarry = result.EnableAutoCarry end
        if result.CarryRange    ~= nil then Config.CarryRange    = result.CarryRange    end
        if result.CarryInterval ~= nil then Config.CarryInterval = result.CarryInterval end
        if result.EnableAutoForceSpawn ~= nil then Config.EnableAutoForceSpawn = result.EnableAutoForceSpawn end
        if result.EnableAntiBot ~= nil then Config.EnableAntiBot = result.EnableAntiBot end
        if result.AntiBotDistance ~= nil then Config.AntiBotDistance = result.AntiBotDistance end
        if result.AntiBotCooldown ~= nil then Config.AntiBotCooldown = result.AntiBotCooldown end
        if result.EnableAutoTrimp ~= nil then Config.EnableAutoTrimp = result.EnableAutoTrimp end
        if result.AutoTrimpMultiplier ~= nil then Config.AutoTrimpMultiplier = result.AutoTrimpMultiplier end
        if result.AutoTrimpFallSpeed ~= nil then Config.AutoTrimpFallSpeed = result.AutoTrimpFallSpeed end
        if result.EnableTrimpTeleport ~= nil then Config.EnableTrimpTeleport = result.EnableTrimpTeleport end
        if result.EnableSpeedMultiplier ~= nil then Config.EnableSpeedMultiplier = result.EnableSpeedMultiplier end
        if result.SpeedMultiplierValue ~= nil then Config.SpeedMultiplierValue = result.SpeedMultiplierValue end
        if result.EnableEmoteSpeed ~= nil then Config.EnableEmoteSpeed = result.EnableEmoteSpeed end
        if result.EmoteSpeedMultiplier ~= nil then Config.EmoteSpeedMultiplier = result.EmoteSpeedMultiplier end
        if result.EnableLayerJumps ~= nil then Config.EnableLayerJumps = result.EnableLayerJumps end
        if result.LayerJumpsCount ~= nil then Config.LayerJumpsCount = result.LayerJumpsCount end
        if result.EnableImpulseJump ~= nil then Config.EnableImpulseJump = result.EnableImpulseJump end
        if result.ImpulseJumpSpeed ~= nil then Config.ImpulseJumpSpeed = math.clamp(tonumber(result.ImpulseJumpSpeed) or 42, 10, 120) end
        if result.EnableBackJump ~= nil then Config.EnableBackJump = result.EnableBackJump end
        if result.BackJumpSpeed ~= nil then getgenv().BackJumpSpeed = result.BackJumpSpeed end
        if result.BackRampMultiplier ~= nil then getgenv().BackRampMultiplier = result.BackRampMultiplier end
        if result.EnableFigure8  ~= nil then Config.EnableFigure8  = result.EnableFigure8 end
        if result.Figure8Speed   ~= nil then Config.Figure8Speed   = math.clamp(tonumber(result.Figure8Speed)  or 1.5, 0.2, 3.0) end
        if result.Figure8Radius  ~= nil then Config.Figure8Radius  = math.clamp(tonumber(result.Figure8Radius) or 8,   3,   25)  end
        if result.EnableLissajous  ~= nil then Config.EnableLissajous  = result.EnableLissajous end
        if result.LissajousSpeed   ~= nil then Config.LissajousSpeed   = math.clamp(tonumber(result.LissajousSpeed)  or 1.5, 0.2, 3.0) end
        if result.LissajousRadius  ~= nil then Config.LissajousRadius  = math.clamp(tonumber(result.LissajousRadius) or 8,   3,   25)  end
        if result.EnableSpiro  ~= nil then Config.EnableSpiro  = result.EnableSpiro end
        if result.SpiroSpeed   ~= nil then Config.SpiroSpeed   = math.clamp(tonumber(result.SpiroSpeed)  or 0.8, 0.1, 2.0)  end
        if result.SpiroRadius  ~= nil then Config.SpiroRadius  = math.clamp(tonumber(result.SpiroRadius) or 12,  5,   30)   end
        if result.SpiroRatio   ~= nil then Config.SpiroRatio   = math.clamp(tonumber(result.SpiroRatio)  or 0.35, 0.1, 0.9) end
        print("SETTINGS: Previous configuration loaded successfully")
    else
        print("SETTINGS: No saved configuration found, using defaults")
    end
end

LoadSettings()

fullBrightHooks.SaveSettings = SaveSettings

currentSpeed = Config.EnableJumpAcceleration and Config.JumpAccelerationSpeed or getgenv().FrontalJumpSpeed
backCurrentSpeed = getgenv().BackJumpSpeed

print("CONFIGURATION: Initialized")

--// ═════════════════════════════════════════════════════════════════════════════
--// LOAD YIN YANG v33 FINAL
--// ═════════════════════════════════════════════════════════════════════════════

print("\nLoading Yin Yang v28 Final from GitHub...")

local LIBRARY_URL = "https://raw.githubusercontent.com/Yinyangzx/Yin/refs/heads/main/Zin%20(11).txt"
local LIBRARY_LOAD_ATTEMPTS = 3
local LIBRARY_LOAD_RETRY_WAIT = 1.5

local function notifyLoadStatus(text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Yin Yang",
            Text = text,
            Duration = duration or 6,
        })
    end)
end

local success = false
local lastLoadError = nil

for attempt = 1, LIBRARY_LOAD_ATTEMPTS do
    local ok, err = pcall(function()
        loadstring(game:HttpGet(LIBRARY_URL))()
    end)

    if ok and _G.YinYang then
        success = true
        break
    end

    lastLoadError = err
    warn(string.format("[Yin Yang] Intento %d/%d de carga fallido: %s", attempt, LIBRARY_LOAD_ATTEMPTS, tostring(err)))

    if attempt < LIBRARY_LOAD_ATTEMPTS then
        notifyLoadStatus("No se pudo cargar la interfaz, reintentando (" .. attempt .. "/" .. LIBRARY_LOAD_ATTEMPTS .. ")...", 4)
        task.wait(LIBRARY_LOAD_RETRY_WAIT)
    end
end

if not success then
    notifyLoadStatus("No se pudo cargar la interfaz tras " .. LIBRARY_LOAD_ATTEMPTS .. " intentos. Revisa tu conexión y volvé a ejecutar el script.", 10)
    error("ERROR: Failed to load Yin Yang v28 Final — " .. tostring(lastLoadError))
    return
end

print("LIBRARY: Yin Yang v28 Final loaded successfully")
task.wait(0.5)

print("SYSTEM: Initialization completed")

--// ═════════════════════════════════════════════════════════════════════════════
--// CREATE UI
--// ═════════════════════════════════════════════════════════════════════════════

print("\nCreating EVADE v5.2 Beta interface...")

function GetSavedTheme()
    local theme = "Dark"
    pcall(function()
        if isfile and isfile("Yin_Yang_Config.txt") then
            local content = readfile("Yin_Yang_Config.txt")
            if content and content ~= "" then
                local value = content:match("theme:([^|]+)")
                if value then
                    theme = value
                end
            end
        end
    end)
    return theme
end

local UI = _G.YinYang:CreateWindow("Yin Yang", GetSavedTheme())

--// ═════════════════════════════════════════════════════════════════════════════
--// INVERSE RAINBOW EFFECT FOR TITLE
--// ═════════════════════════════════════════════════════════════════════════════

function setupRainbowInversedTitle()
    local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    task.wait(0.8)

    if PlayerGui:FindFirstChild("Yin") then
        local ScreenGui = PlayerGui.Yin
        local TitleLabel = ScreenGui:FindFirstChild("TitleLabel")

        if TitleLabel then
            print("Creating inverse rainbow effect with two TextLabels...")

            local origText = TitleLabel.Text
            local origSize = TitleLabel.Size
            local origPos = TitleLabel.Position
            local origFont = TitleLabel.Font
            local origTextSize = TitleLabel.TextSize

            TitleLabel.TextTransparency = 1

            local EvadeLabel = Instance.new("TextLabel")
            EvadeLabel.Name = "EvadeLabel"
            EvadeLabel.Text = "EVADE"
            EvadeLabel.Font = origFont
            EvadeLabel.TextSize = origTextSize
            EvadeLabel.BackgroundTransparency = 1
            EvadeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            EvadeLabel.Size = UDim2.new(0.6, 0, 1, 0)
            EvadeLabel.Position = UDim2.new(0, 0, 0, 0)
            EvadeLabel.TextXAlignment = Enum.TextXAlignment.Left
            EvadeLabel.ZIndex = TitleLabel.ZIndex + 1
            EvadeLabel.Parent = TitleLabel.Parent

            local BetaLabel = Instance.new("TextLabel")
            BetaLabel.Name = "BetaLabel"
            BetaLabel.Text = "v5.2 Beta"
            BetaLabel.Font = origFont
            BetaLabel.TextSize = origTextSize
            BetaLabel.BackgroundTransparency = 1
            BetaLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
            BetaLabel.Size = UDim2.new(0.4, 0, 1, 0)
            BetaLabel.Position = UDim2.new(0.6, 0, 0, 0)
            BetaLabel.TextXAlignment = Enum.TextXAlignment.Left
            BetaLabel.ZIndex = TitleLabel.ZIndex + 1
            BetaLabel.Parent = TitleLabel.Parent

            print("✅ Labels created: EvadeLabel + BetaLabel")

            local cycleCount = 0
            local rainbowFrameCounter = 0
            local rainbow = RunService.RenderStepped:Connect(function()
                if not EvadeLabel or not EvadeLabel.Parent or not BetaLabel or not BetaLabel.Parent then
                    rainbow:Disconnect()
                    return
                end
                rainbowFrameCounter = rainbowFrameCounter + 1
                if rainbowFrameCounter % 3 ~= 0 then return end

                cycleCount = cycleCount + 1
                local progress = (cycleCount % 120) / 120

                if progress < 0.5 then
                    local t = progress * 2
                    local evadeBrightness = 1 - t
                    EvadeLabel.TextColor3 = Color3.fromRGB(
                        math.floor(255 * evadeBrightness),
                        math.floor(255 * evadeBrightness),
                        math.floor(255 * evadeBrightness)
                    )
                    local betaBrightness = t
                    BetaLabel.TextColor3 = Color3.fromRGB(
                        math.floor(255 * betaBrightness),
                        math.floor(255 * betaBrightness),
                        math.floor(255 * betaBrightness)
                    )
                else
                    local t = (progress - 0.5) * 2
                    local evadeBrightness = t
                    EvadeLabel.TextColor3 = Color3.fromRGB(
                        math.floor(255 * evadeBrightness),
                        math.floor(255 * evadeBrightness),
                        math.floor(255 * evadeBrightness)
                    )
                    local betaBrightness = 1 - t
                    BetaLabel.TextColor3 = Color3.fromRGB(
                        math.floor(255 * betaBrightness),
                        math.floor(255 * betaBrightness),
                        math.floor(255 * betaBrightness)
                    )
                end
            end)

            print("✅ Inverse rainbow effect activated")
        end
    end
end

task.delay(1, setupRainbowInversedTitle)

--// ═════════════════════════════════════════════════════════════════════════════
--// SCRIPT UI LANGUAGE
--// ═════════════════════════════════════════════════════════════════════════════
local ScriptLanguage = "en"
local ScriptTranslator = nil
local ScriptTranslationCache = {}

local function getScriptLanguage(localeId)
    local language = string.lower(tostring(localeId or "en")):match("^(%a+)") or "en"
    return language
end

local function scriptText(spanishText, englishText)
    spanishText = tostring(spanishText or "")
    englishText = tostring(englishText or spanishText)

    if ScriptLanguage == "es" then return spanishText end
    if ScriptLanguage == "en" then return englishText end

    local cacheKey = ScriptLanguage .. "\0" .. englishText
    if ScriptTranslationCache[cacheKey] ~= nil then
        return ScriptTranslationCache[cacheKey]
    end

    local translated = nil
    if ScriptTranslator then
        pcall(function()
            translated = ScriptTranslator:Translate(game, englishText)
        end)
    end

    if translated and translated ~= "" and translated ~= englishText then
        ScriptTranslationCache[cacheKey] = translated
        return translated
    end

    ScriptTranslationCache[cacheKey] = englishText
    return englishText
end

local function refreshScriptLanguage()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local screenGui = playerGui and playerGui:FindFirstChild("Yin")
    if not screenGui then return end

    for _, object in ipairs(screenGui:GetDescendants()) do
        if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
            local spanishText = object:GetAttribute("TextSpanish")
            local englishText = object:GetAttribute("TextEnglish")
            if spanishText ~= nil and englishText ~= nil then
                object.Text = scriptText(spanishText, englishText)
            end

            local placeholderSpanish = object:GetAttribute("PlaceholderSpanish")
            local placeholderEnglish = object:GetAttribute("PlaceholderEnglish")
            if placeholderSpanish ~= nil and placeholderEnglish ~= nil then
                object.PlaceholderText = scriptText(placeholderSpanish, placeholderEnglish)
            end
        end
    end
end

local function setScriptLanguageFromLocale(localeId)
    ScriptLanguage = getScriptLanguage(localeId)
    ScriptTranslationCache = {}
    refreshScriptLanguage()
end

pcall(function()
    local systemLocale = LocalizationService.SystemLocaleId
    if systemLocale and systemLocale ~= "" then
        setScriptLanguageFromLocale(systemLocale)
    end
end)

task.spawn(function()
    local ok, translator = pcall(function()
        return LocalizationService:GetTranslatorForPlayerAsync(LocalPlayer)
    end)

    if ok and translator then
        ScriptTranslator = translator
        local function updateScriptLanguage()
            setScriptLanguageFromLocale(translator.LocaleId)
        end
        updateScriptLanguage()
        pcall(function()
            translator:GetPropertyChangedSignal("LocaleId"):Connect(updateScriptLanguage)
        end)
    end
end)

--// CREATE TABS
--// ═════════════════════════════════════════════════════════════════════════════

local TabMove = UI:CreateTab("Move", "rbxassetid://127654592832194")
local TabMap = UI:CreateTab("Map", "rbxassetid://108047640113959")
local TabExtra = UI:CreateTab("Extra", "rbxassetid://87314564821705")
local TabEmote = UI:CreateTab("Emote", "rbxassetid://120302862220435")
local TabAvatar = UI:CreateTab("Avatar", "Avatar", "rbxassetid://97892611931074")

UI:CreateSpotifyTab()

print("TABS: Created (Move + Map + Extra + Avatar)")

--// ═════════════════════════════════════════════════════════════════════════════
--// TAB: AVATAR
--// ═════════════════════════════════════════════════════════════════════════════

do
function createAvatarStroke(parent, transparency)
    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(220, 220, 225)
    border.Thickness = 1
    border.Transparency = transparency or 0.38
    border.ZIndex = 12
    border.Parent = parent
    border:SetAttribute("ThemeRole", "Stroke")
    return border
end

local AvatarHeader = Instance.new("Frame")
AvatarHeader.Name = "AvatarHeader"
AvatarHeader.Size = UDim2.new(1, 0, 0, 58)
AvatarHeader.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
AvatarHeader.BorderSizePixel = 0
AvatarHeader.ZIndex = 10
AvatarHeader.Parent = TabAvatar.Page
AvatarHeader:SetAttribute("ThemeRole", "Secondary")
local AvatarHeaderCorner = Instance.new("UICorner")
AvatarHeaderCorner.CornerRadius = UDim.new(0, 10)
AvatarHeaderCorner.Parent = AvatarHeader
createAvatarStroke(AvatarHeader, 0.44)

local AvatarHeaderIconBox = Instance.new("Frame")
AvatarHeaderIconBox.Size = UDim2.fromOffset(40, 40)
AvatarHeaderIconBox.Position = UDim2.fromOffset(9, 9)
AvatarHeaderIconBox.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
AvatarHeaderIconBox.BorderSizePixel = 0
AvatarHeaderIconBox.ZIndex = 11
AvatarHeaderIconBox.Parent = AvatarHeader
local AvatarHeaderIconCorner = Instance.new("UICorner")
AvatarHeaderIconCorner.CornerRadius = UDim.new(0, 8)
AvatarHeaderIconCorner.Parent = AvatarHeaderIconBox
createAvatarStroke(AvatarHeaderIconBox, 0.2)

local AvatarHeaderIcon = Instance.new("ImageLabel")
AvatarHeaderIcon.Size = UDim2.fromOffset(26, 26)
AvatarHeaderIcon.Position = UDim2.fromOffset(7, 7)
AvatarHeaderIcon.BackgroundTransparency = 1
AvatarHeaderIcon.Image = "rbxassetid://125446874976286"
AvatarHeaderIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
AvatarHeaderIcon.ZIndex = 12
AvatarHeaderIcon.Parent = AvatarHeaderIconBox

local AvatarHeaderTitle = Instance.new("TextLabel")
AvatarHeaderTitle.Size = UDim2.new(1, -78, 0, 24)
AvatarHeaderTitle.Position = UDim2.fromOffset(61, 9)
AvatarHeaderTitle.BackgroundTransparency = 1
AvatarHeaderTitle.Text = scriptText("CAMBIO DE AVATAR", "AVATAR CHANGE")
AvatarHeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
AvatarHeaderTitle.TextSize = 16
AvatarHeaderTitle.Font = Enum.Font.GothamBlack
AvatarHeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
AvatarHeaderTitle.ZIndex = 11
AvatarHeaderTitle.Parent = AvatarHeader
AvatarHeaderTitle:SetAttribute("ThemeTextRole", "Text")
AvatarHeaderTitle:SetAttribute("TextSpanish", "CAMBIO DE AVATAR")
AvatarHeaderTitle:SetAttribute("TextEnglish", "AVATAR CHANGE")

local AvatarHeaderLine = Instance.new("Frame")
AvatarHeaderLine.Size = UDim2.new(1, -91, 0, 1)
AvatarHeaderLine.Position = UDim2.new(0, 61, 0, 41)
AvatarHeaderLine.BackgroundColor3 = Color3.fromRGB(205, 205, 210)
AvatarHeaderLine.BorderSizePixel = 0
AvatarHeaderLine.ZIndex = 11
AvatarHeaderLine.Parent = AvatarHeader
AvatarHeaderLine:SetAttribute("ThemeRole", "Stroke")

local AvatarHeaderSpark = Instance.new("TextLabel")
AvatarHeaderSpark.Size = UDim2.fromOffset(20, 20)
AvatarHeaderSpark.Position = UDim2.new(1, -28, 0, 31)
AvatarHeaderSpark.BackgroundTransparency = 1
AvatarHeaderSpark.Text = "✦"
AvatarHeaderSpark.TextColor3 = Color3.fromRGB(255, 255, 255)
AvatarHeaderSpark.TextSize = 17
AvatarHeaderSpark.Font = Enum.Font.GothamBold
AvatarHeaderSpark.ZIndex = 12
AvatarHeaderSpark.Parent = AvatarHeader
AvatarHeaderSpark:SetAttribute("ThemeTextRole", "Text")

local AvatarDescription = Instance.new("TextLabel")
AvatarDescription.Name = "AvatarDescription"
AvatarDescription.Size = UDim2.new(1, 0, 0, 34)
AvatarDescription.BackgroundTransparency = 1
AvatarDescription.Text = scriptText(
    "Escribe el nombre de un jugador para usar su avatar visual.",
    "Enter a player's username to use their visual avatar."
)
AvatarDescription.TextColor3 = Color3.fromRGB(225, 225, 230)
AvatarDescription.TextSize = 12
AvatarDescription.Font = Enum.Font.GothamBold
AvatarDescription.TextWrapped = true
AvatarDescription.TextXAlignment = Enum.TextXAlignment.Left
AvatarDescription.TextYAlignment = Enum.TextYAlignment.Center
AvatarDescription.ZIndex = 10
AvatarDescription.Parent = TabAvatar.Page
AvatarDescription:SetAttribute("ThemeTextRole", "Text")
AvatarDescription:SetAttribute("TextSpanish", "Escribe el nombre de un jugador para usar su avatar visual.")
AvatarDescription:SetAttribute("TextEnglish", "Enter a player's username to use their visual avatar.")

local AvatarInputHolder = Instance.new("Frame")
AvatarInputHolder.Name = "AvatarUsernameInputHolder"
AvatarInputHolder.Size = UDim2.new(1, 0, 0, 52)
AvatarInputHolder.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
AvatarInputHolder.BorderSizePixel = 0
AvatarInputHolder.ZIndex = 10
AvatarInputHolder.Parent = TabAvatar.Page
AvatarInputHolder:SetAttribute("ThemeRole", "Secondary")
local AvatarInputCorner = Instance.new("UICorner")
AvatarInputCorner.CornerRadius = UDim.new(0, 10)
AvatarInputCorner.Parent = AvatarInputHolder
createAvatarStroke(AvatarInputHolder, 0.2)

local AvatarInputIcon = Instance.new("ImageLabel")
AvatarInputIcon.Size = UDim2.fromOffset(24, 24)
AvatarInputIcon.Position = UDim2.fromOffset(15, 14)
AvatarInputIcon.BackgroundTransparency = 1
AvatarInputIcon.Image = "rbxassetid://125446874976286"
AvatarInputIcon.ImageColor3 = Color3.fromRGB(240, 240, 245)
AvatarInputIcon.ZIndex = 12
AvatarInputIcon.Parent = AvatarInputHolder

local AvatarUsernameInput = Instance.new("TextBox")
AvatarUsernameInput.Name = "AvatarUsernameInput"
AvatarUsernameInput.Size = UDim2.new(1, -67, 1, 0)
AvatarUsernameInput.Position = UDim2.fromOffset(52, 0)
AvatarUsernameInput.BackgroundTransparency = 1
AvatarUsernameInput.BorderSizePixel = 0
AvatarUsernameInput.ZIndex = 12
AvatarUsernameInput.ClearTextOnFocus = false
AvatarUsernameInput.PlaceholderText = scriptText("Nombre de usuario", "Username")
AvatarUsernameInput.PlaceholderColor3 = Color3.fromRGB(155, 155, 165)
AvatarUsernameInput.Text = ""
AvatarUsernameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
AvatarUsernameInput.TextSize = 15
AvatarUsernameInput.Font = Enum.Font.GothamBold
AvatarUsernameInput.TextXAlignment = Enum.TextXAlignment.Left
AvatarUsernameInput.Parent = AvatarInputHolder
AvatarUsernameInput:SetAttribute("ThemeTextRole", "Text")
AvatarUsernameInput:SetAttribute("PlaceholderSpanish", "Nombre de usuario")
AvatarUsernameInput:SetAttribute("PlaceholderEnglish", "Username")

local AvatarApplyHolder = Instance.new("Frame")
AvatarApplyHolder.Name = "AvatarApplyHolder"
AvatarApplyHolder.Size = UDim2.new(1, 0, 0, 48)
AvatarApplyHolder.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
AvatarApplyHolder.BorderSizePixel = 0
AvatarApplyHolder.ZIndex = 10
AvatarApplyHolder.Parent = TabAvatar.Page
AvatarApplyHolder:SetAttribute("ThemeRole", "Secondary")
local AvatarApplyCorner = Instance.new("UICorner")
AvatarApplyCorner.CornerRadius = UDim.new(0, 10)
AvatarApplyCorner.Parent = AvatarApplyHolder
createAvatarStroke(AvatarApplyHolder, 0.16)

local AvatarApplyButton = Instance.new("TextButton")
AvatarApplyButton.Name = "AvatarApplyButton"
AvatarApplyButton.Size = UDim2.new(1, 0, 1, 0)
AvatarApplyButton.BackgroundTransparency = 1
AvatarApplyButton.BorderSizePixel = 0
AvatarApplyButton.AutoButtonColor = false
AvatarApplyButton.Text = ""
AvatarApplyButton.ZIndex = 11
AvatarApplyButton.Parent = AvatarApplyHolder

local AvatarApplyLabel = Instance.new("TextLabel")
AvatarApplyLabel.Size = UDim2.new(1, -62, 1, 0)
AvatarApplyLabel.Position = UDim2.fromOffset(31, 0)
AvatarApplyLabel.BackgroundTransparency = 1
AvatarApplyLabel.Text = scriptText("APLICAR AVATAR", "APPLY AVATAR")
AvatarApplyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
AvatarApplyLabel.TextSize = 14
AvatarApplyLabel.Font = Enum.Font.GothamBlack
AvatarApplyLabel.TextXAlignment = Enum.TextXAlignment.Center
AvatarApplyLabel.ZIndex = 12
AvatarApplyLabel.Parent = AvatarApplyHolder
AvatarApplyLabel:SetAttribute("ThemeTextRole", "Text")
AvatarApplyLabel:SetAttribute("TextSpanish", "APLICAR AVATAR")
AvatarApplyLabel:SetAttribute("TextEnglish", "APPLY AVATAR")

local AvatarApplyArrow = Instance.new("TextLabel")
AvatarApplyArrow.Size = UDim2.fromOffset(28, 28)
AvatarApplyArrow.Position = UDim2.new(1, -42, 0.5, -14)
AvatarApplyArrow.BackgroundTransparency = 1
AvatarApplyArrow.Text = "›"
AvatarApplyArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
AvatarApplyArrow.TextSize = 31
AvatarApplyArrow.Font = Enum.Font.GothamBold
AvatarApplyArrow.ZIndex = 12
AvatarApplyArrow.Parent = AvatarApplyHolder
AvatarApplyArrow:SetAttribute("ThemeTextRole", "Text")

local AvatarStatusHolder = Instance.new("Frame")
AvatarStatusHolder.Name = "AvatarStatusHolder"
AvatarStatusHolder.Size = UDim2.new(1, 0, 0, 52)
AvatarStatusHolder.LayoutOrder = 10
AvatarStatusHolder.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
AvatarStatusHolder.BorderSizePixel = 0
AvatarStatusHolder.Visible = false
AvatarStatusHolder.ZIndex = 10
AvatarStatusHolder.Parent = TabAvatar.Page
AvatarStatusHolder:SetAttribute("ThemeRole", "Secondary")
local AvatarStatusCorner = Instance.new("UICorner")
AvatarStatusCorner.CornerRadius = UDim.new(0, 10)
AvatarStatusCorner.Parent = AvatarStatusHolder
createAvatarStroke(AvatarStatusHolder, 0.35)

local AvatarStatusIcon = Instance.new("ImageLabel")
AvatarStatusIcon.Size = UDim2.fromOffset(27, 27)
AvatarStatusIcon.Position = UDim2.fromOffset(14, 12)
AvatarStatusIcon.BackgroundTransparency = 1
AvatarStatusIcon.Image = "rbxassetid://88658875299906"
AvatarStatusIcon.ImageColor3 = Color3.fromRGB(145, 255, 180)
AvatarStatusIcon.ZIndex = 12
AvatarStatusIcon.Parent = AvatarStatusHolder

local AvatarStatus = Instance.new("TextLabel")
AvatarStatus.Name = "AvatarStatus"
AvatarStatus.Size = UDim2.new(1, -62, 1, -12)
AvatarStatus.Position = UDim2.fromOffset(50, 6)
AvatarStatus.BackgroundTransparency = 1
AvatarStatus.Text = ""
AvatarStatus.TextColor3 = Color3.fromRGB(180, 180, 190)
AvatarStatus.TextSize = 11
AvatarStatus.Font = Enum.Font.Gotham
AvatarStatus.ZIndex = 12
AvatarStatus.TextWrapped = true
AvatarStatus.TextXAlignment = Enum.TextXAlignment.Left
AvatarStatus.TextYAlignment = Enum.TextYAlignment.Center
AvatarStatus.Parent = AvatarStatusHolder
AvatarStatus:SetAttribute("TextSpanish", "")
AvatarStatus:SetAttribute("TextEnglish", "")

local avatarStatusSpanish, avatarStatusEnglish = "", ""
local avatarStatusColor = Color3.fromRGB(180, 180, 190)
function SetAvatarStatus(spanish, english, color)
    avatarStatusSpanish = spanish
    avatarStatusEnglish = english
    avatarStatusColor = color or Color3.fromRGB(180, 180, 190)
    AvatarStatusHolder.Visible = true
    AvatarStatus:SetAttribute("TextSpanish", spanish)
    AvatarStatus:SetAttribute("TextEnglish", english)
    AvatarStatus.Text = scriptText(spanish, english)
    AvatarStatus.TextColor3 = avatarStatusColor
    AvatarStatusIcon.ImageColor3 = avatarStatusColor
end

function GetAvatarVisualHumanoid()
    local rigsFolder = workspace:FindFirstChild("Rigs")
    local visualRig = rigsFolder and rigsFolder:FindFirstChild(Players.LocalPlayer.Name)
    local humanoid = visualRig and visualRig:FindFirstChildOfClass("Humanoid")
    return visualRig, humanoid
end

function ApplyAvatarByUsername()
    local username = tostring(AvatarUsernameInput.Text or ""):match("^%s*(.-)%s*$")
    if username == "" then
        SetAvatarStatus("Escribe un nombre de usuario.", "Enter a username.", Color3.fromRGB(255, 135, 135))
        return
    end

    local visualRig, visualHumanoid = GetAvatarVisualHumanoid()
    if not visualRig or not visualHumanoid then
        SetAvatarStatus("No se encontró el rig visual R6.", "The visual R6 rig was not found.", Color3.fromRGB(255, 135, 135))
        return
    end
    if visualHumanoid.RigType ~= Enum.HumanoidRigType.R6 then
        SetAvatarStatus("El rig visual no es R6.", "The visual rig is not R6.", Color3.fromRGB(255, 135, 135))
        return
    end

    SetAvatarStatus("Cargando avatar de " .. username .. "...", "Loading " .. username .. "'s avatar...", Color3.fromRGB(195, 215, 255))
    local okUser, userIdOrError = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    if not okUser then
        SetAvatarStatus("No se encontró ese usuario.", "That user was not found.", Color3.fromRGB(255, 135, 135))
        return
    end

    local okDescription, descriptionOrError = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userIdOrError)
    end)
    if not okDescription then
        SetAvatarStatus("No se pudo cargar el avatar.", "The avatar could not be loaded.", Color3.fromRGB(255, 135, 135))
        return
    end

    local okApply, applyError = pcall(function()
        visualHumanoid:ApplyDescriptionReset(descriptionOrError)
    end)
    if not okApply then
        SetAvatarStatus("No se pudo aplicar el avatar.", "The avatar could not be applied.", Color3.fromRGB(255, 135, 135))
        warn("[Avatar] ApplyDescriptionReset error:", applyError)
        return
    end

    SetAvatarStatus(
        "Avatar de " .. username .. " aplicado. Escribe otro nombre para cambiarlo.",
        username .. "'s avatar was applied. Enter another name to change it.",
        Color3.fromRGB(145, 255, 180)
    )
end

AvatarApplyButton.MouseButton1Click:Connect(ApplyAvatarByUsername)
AvatarUsernameInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        ApplyAvatarByUsername()
    end
end)

function RefreshAvatarThemeIcons()
    local textColor = AvatarHeaderTitle.TextColor3
    AvatarHeaderIcon.ImageColor3 = textColor
    AvatarInputIcon.ImageColor3 = textColor
end
RefreshAvatarThemeIcons()
AvatarHeaderTitle:GetPropertyChangedSignal("TextColor3"):Connect(RefreshAvatarThemeIcons)

--// CUSTOM BODY PART TOGGLES
TabAvatar:CreateDivider()
TabAvatar:CreateLabel("PARTES CORPORALES", "CUSTOM BODY PARTS", 12)

local CustomBodyPartState = {
    Saved = {},
    HeadlessFallback = {
        Active = false,
        HeadTransparency = nil,
        FaceTransparency = nil,
    },
}

local CustomBodyParts = {
    Korblox = {
        Spanish = "Pierna derecha Korblox",
        English = "Korblox Right Leg",
        Property = "RightLeg",
        AssetId = 139607718,
    },
    Headless = {
        Spanish = "Cabeza invisible Headless",
        English = "Headless Invisible Head",
        Property = "Head",
        AssetId = 15093053680,
    },
}

function SetHeadlessFallback(visualRig, enabled)
    local head = visualRig and visualRig:FindFirstChild("Head")
    if not head or not head:IsA("BasePart") then
        return false
    end

    local face = head:FindFirstChild("face")
    if enabled then
        if not CustomBodyPartState.HeadlessFallback.Active then
            CustomBodyPartState.HeadlessFallback.HeadTransparency = head.LocalTransparencyModifier
            CustomBodyPartState.HeadlessFallback.FaceTransparency = face and face:IsA("Decal") and face.Transparency or nil
        end
        head.LocalTransparencyModifier = 1
        if face and face:IsA("Decal") then
            face.Transparency = 1
        end
        CustomBodyPartState.HeadlessFallback.Active = true
    else
        head.LocalTransparencyModifier = CustomBodyPartState.HeadlessFallback.HeadTransparency or 0
        if face and face:IsA("Decal") and CustomBodyPartState.HeadlessFallback.FaceTransparency ~= nil then
            face.Transparency = CustomBodyPartState.HeadlessFallback.FaceTransparency
        end
        CustomBodyPartState.HeadlessFallback = {
            Active = false,
            HeadTransparency = nil,
            FaceTransparency = nil,
        }
    end
    return true
end

function ApplyCustomBodyPart(partInfo, enabled)
    local visualRig, visualHumanoid = GetAvatarVisualHumanoid()
    if not visualRig or not visualHumanoid then
        SetAvatarStatus("No se encontró el rig visual R6.", "The visual R6 rig was not found.", Color3.fromRGB(255, 135, 135))
        return false
    end
    if visualHumanoid.RigType ~= Enum.HumanoidRigType.R6 then
        SetAvatarStatus("Las piezas requieren un rig visual R6.", "Custom parts require the visual R6 rig.", Color3.fromRGB(255, 135, 135))
        return false
    end

    local okDescription, descriptionOrError = pcall(function()
        return visualHumanoid:GetAppliedDescription()
    end)
    if not okDescription or not descriptionOrError then
        SetAvatarStatus("No se pudo leer el avatar actual.", "The current avatar description could not be read.", Color3.fromRGB(255, 135, 135))
        warn("[Avatar] GetAppliedDescription error:", descriptionOrError)
        return false
    end

    if enabled then
        if CustomBodyPartState.Saved[partInfo.Property] == nil then
            CustomBodyPartState.Saved[partInfo.Property] = descriptionOrError[partInfo.Property]
        end
        descriptionOrError[partInfo.Property] = partInfo.AssetId
        SetAvatarStatus("Aplicando " .. partInfo.Spanish .. "...", "Applying " .. partInfo.English .. "...", Color3.fromRGB(195, 215, 255))
    else
        descriptionOrError[partInfo.Property] = CustomBodyPartState.Saved[partInfo.Property] or 0
        CustomBodyPartState.Saved[partInfo.Property] = nil
        if partInfo.Property == "Head" and CustomBodyPartState.HeadlessFallback.Active then
            SetHeadlessFallback(visualRig, false)
        end
    end

    local okApply, applyError = pcall(function()
        visualHumanoid:ApplyDescriptionReset(descriptionOrError)
    end)
    if not okApply then
        if enabled and partInfo.Property == "Head" and SetHeadlessFallback(visualRig, true) then
            SetAvatarStatus("Cabeza invisible aplicada localmente.", "Headless fallback applied locally.", Color3.fromRGB(145, 255, 180))
            warn("[Avatar] Headless Dynamic Head fallback used:", applyError)
            return true
        end
        SetAvatarStatus("No se pudo aplicar la pieza.", "The body part could not be applied.", Color3.fromRGB(255, 135, 135))
        warn("[Avatar] ApplyDescriptionReset error:", applyError)
        return false
    end

    SetAvatarStatus(
        enabled and "Pieza aplicada al rig visual." or "Pieza restaurada.",
        enabled and "Body part applied to the visual rig." or "Body part restored.",
        enabled and Color3.fromRGB(145, 255, 180) or Color3.fromRGB(180, 180, 190)
    )
    return true
end

local KorbloxRightLegToggle
local HeadlessHeadToggle

KorbloxRightLegToggle = TabAvatar:CreateToggle(
    CustomBodyParts.Korblox.Spanish,
    CustomBodyParts.Korblox.English,
    false,
    function(enabled)
        local ok = ApplyCustomBodyPart(CustomBodyParts.Korblox, enabled)
        if not ok and enabled then
            KorbloxRightLegToggle.SetValue(false)
        end
    end
)

HeadlessHeadToggle = TabAvatar:CreateToggle(
    CustomBodyParts.Headless.Spanish,
    CustomBodyParts.Headless.English,
    false,
    function(enabled)
        local ok = ApplyCustomBodyPart(CustomBodyParts.Headless, enabled)
        if not ok and enabled then
            HeadlessHeadToggle.SetValue(false)
        end
    end
)
end

--// ═════════════════════════════════════════════════════════════════════════════
--// TAB: MOVEMENT
--// ═════════════════════════════════════════════════════════════════════════════

print("\nConfiguring Move tab...")

local lastSpeedSelf, lastSpeedState, lastSpeedValue = nil, nil, nil
getgenv().YYSpeedRestoreRequested = false
getgenv().YYRestoreSpeedMultiplier = nil

TabMove:CreateCombinedToggle("Combinado (prueba)", "Combined (test)")
TabMove:CreateDivider()

TabMove:CreateLabel("MULTIPLICADOR DE VELOCIDAD (WalkSpeed)", "SPEED MULTIPLIER (WalkSpeed)", 14)
TabMove:CreateDivider()

TabMove:CreateFloatingToggle("Velocidad", "Speed", Config.EnableSpeedMultiplier, function(state)
    Config.EnableSpeedMultiplier = state
    print(state and "✓ Speed Multiplier ENABLED" or "X Speed Multiplier DISABLED")
    if state then
        getgenv().YYSpeedRestoreRequested = false
        getgenv().YYSpeedApplyRequested = true
        if getgenv().YYApplySpeedMultiplier then
            getgenv().YYApplySpeedMultiplier()
        end
    else
        getgenv().YYSpeedRestoreRequested = true
        if getgenv().YYRestoreSpeedMultiplier then
            getgenv().YYRestoreSpeedMultiplier()
        end
    end
    SaveSettings()
end)

TabMove:CreateSlider(
    "Speed Value",
    1, 5, Config.SpeedMultiplierValue,
    function(value)
        Config.SpeedMultiplierValue = value
        if Config.EnableSpeedMultiplier and getgenv().YYApplySpeedMultiplier then
            getgenv().YYSpeedApplyRequested = true
            getgenv().YYApplySpeedMultiplier()
        end
        print("✓ Speed Multiplier value: " .. value)
        SaveSettings()
    end,
    nil, 1.3
)

TabMove:CreateDivider()

TabMove:CreateLabel("MOVIMIENTO BÁSICO", "BASIC MOVEMENT", 14)
TabMove:CreateDivider()

TabMove:CreateFloatingToggle("Caminata", "Walk", Config.EnableTeleportWalk, function(state)
    Config.EnableTeleportWalk = state
    print(state and "✓ Teleport Walk ENABLED" or "X Teleport Walk DISABLED")
    SaveSettings()
end)

TabMove:CreateSlider(
    "Teleport Speed",
    1, 50, Config.TeleportMovementSpeed,
    function(value)
        Config.TeleportMovementSpeed = value
        print("✓ Teleport speed: " .. value)
        SaveSettings()
    end,
    nil, 3
)

TabMove:CreateDivider()

TabMove:CreateFloatingToggle("Altura de Salto", "Jump Height", Config.EnableEnhancedJump, function(state)
    Config.EnableEnhancedJump = state
    print(state and "✓ Enhanced Jump ENABLED" or "X Enhanced Jump DISABLED")
    SaveSettings()
end)

TabMove:CreateSlider(
    "Jump Height",
    20, 300, Config.JumpHeight,
    function(value)
        Config.JumpHeight = value
        print("✓ Jump height: " .. value)
        SaveSettings()
    end,
    nil, 30
)

TabMove:CreateDivider()
TabMove:CreateLabel("SLIDE INFINITO", "INFINITE SLIDE", 14)
TabMove:CreateDivider()

TabMove:CreateFloatingToggle("Slide Inf", "Inf Slide", Config.EnableInfiniteSlide, function(state)
    Config.EnableInfiniteSlide = state
    print(state and "✓ Infinite Slide ENABLED" or "X Infinite Slide DISABLED")
    SaveSettings()
end)

TabMove:CreateSlider(
    "Slide Speed",
    15, 150, Config.InfiniteSlideSpeed,
    function(value)
        Config.InfiniteSlideSpeed = math.clamp(math.floor(value), 15, 150)
        print("✓ Infinite Slide speed: " .. Config.InfiniteSlideSpeed)
        SaveSettings()
    end,
    nil, 30
)

TabMove:CreateLabel(
    "Mantiene el deslizamiento mientras mantienes la entrada de slide",
    "Maintains the slide while the slide input is held",
    11
)

TabMove:CreateLabel("SLIDE INF OLD", "SLIDE INF OLD", 14)
TabMove:CreateDivider()

TabMove:CreateFloatingToggle("Slide Inf Old", "Inf Slide Old", Config.EnableInfiniteSlideOld, function(state)
    Config.EnableInfiniteSlideOld = state
    print(state and "Slide Inf OLD ENABLED" or "Slide Inf OLD DISABLED")
    SaveSettings()
end)

TabMove:CreateSlider(
    "Slide Speed Old",
    15, 150, Config.InfiniteSlideSpeedOld,
    function(value)
        Config.InfiniteSlideSpeedOld = math.clamp(math.floor(value), 15, 150)
        print("Infinite Slide OLD speed: " .. Config.InfiniteSlideSpeedOld)
        SaveSettings()
    end,
    nil, 30
)

TabMove:CreateLabel(
    "Version anterior del slide: velocidad directa sin BodyVelocity ni proyeccion de superficie",
    "Previous slide version: direct velocity without BodyVelocity or surface projection",
    11
)

TabMove:CreateDivider()

TabMove:CreateFloatingToggle("Auto Salto", "Auto Jump", Config.AutoJump, function(state)
    Config.AutoJump = state
    if not state then
        autoJumpNextTime = 0
    end
    print(state and "✓ Auto Jump ENABLED" or "X Auto Jump DISABLED")
    SaveSettings()
end)

TabMove:CreateSlider(
    "Auto Jump Speed",
    0.5, 8, Config.AutoJumpSpeed,
    function(value)
        Config.AutoJumpSpeed = math.clamp(tonumber(value) or 1.5, 0.5, 8)
        print("✓ Auto Jump speed: " .. string.format("%.2f", Config.AutoJumpSpeed) .. " jumps/s")
        SaveSettings()
    end,
    nil, 0.5
)

TabMove:CreateLabel(
    "Saltos por segundo; un valor mayor hace que salte más rápido",
    "Jumps per second; a higher value makes it jump faster",
    11
)

TabMove:CreateFloatingToggle("Agachado", "Crouch", Config.AutoCrouch, function(state)
    Config.AutoCrouch = state
    if not state then
        autoCrouchNextTime = 0
    end
    print(state and "✓ Auto Crouch ENABLED" or "X Auto Crouch DISABLED")
    SaveSettings()
end)

TabMove:CreateSlider(
    "Crouch Speed",
    0.5, 24, Config.AutoCrouchSpeed,
    function(value)
        Config.AutoCrouchSpeed = math.clamp(tonumber(value) or 1.5, 0.5, 24)
        print("✓ Auto Crouch speed: " .. string.format("%.2f", Config.AutoCrouchSpeed) .. " toggles/s")
        SaveSettings()
    end,
    nil, 0.5
)

TabMove:CreateFloatingToggle("Jump Aceleración", "Jump Acceleration", Config.EnableJumpAcceleration, function(state)
    Config.EnableJumpAcceleration = state
    lastJumpTime = tick()
    currentSpeed = Config.JumpAccelerationSpeed
    print(state and "✓ Jump Acceleration ENABLED" or "X Jump Acceleration DISABLED")
    SaveSettings()
end)

local JumpAccelerationSpeedSlider = TabMove:CreateSlider(
    "Jump Aceleración",
    30, 110, Config.JumpAccelerationSpeed,
    function(value)
        Config.JumpAccelerationSpeed = math.clamp(tonumber(value) or 42, 30, 110)
        if Config.EnableJumpAcceleration then currentSpeed = Config.JumpAccelerationSpeed end
        print("✓ Jump Acceleration Speed: " .. Config.JumpAccelerationSpeed)
        SaveSettings()
    end,
    nil, 1
)

TabMove:CreateLabel("Sin rampas", "No ramps", 11)
TabMove:CreateDivider()

--// LAYER JUMPS
TabMove:CreateLabel("SALTOS EN CAPAS (Multi-Salto)", "LAYER JUMPS (Multi-Jump)", 14)
TabMove:CreateDivider()

TabMove:CreateFloatingToggle("Saltos en Capas", "Layer Jumps", Config.EnableLayerJumps, function(state)
    Config.EnableLayerJumps = state
    print(state and "✓ Layer Jumps ENABLED" or "X Layer Jumps DISABLED")
    SaveSettings()
end)

TabMove:CreateSlider(
    "Jump Count",
    2, 20, Config.LayerJumpsCount,
    function(value)
        Config.LayerJumpsCount = math.floor(value)
        print("✓ Layer Jumps count: " .. Config.LayerJumpsCount)
        SaveSettings()
    end,
    nil, 20
)

TabMove:CreateDivider()

--// IMPULSE JUMP
TabMove:CreateLabel("SALTO CON IMPULSO", "IMPULSE JUMP", 14)
TabMove:CreateDivider()

TabMove:CreateFloatingToggle("Salto con Impulso", "Impulse Jump", Config.EnableImpulseJump, function(state)
    Config.EnableImpulseJump = state
    print(state and "✓ Impulse Jump ENABLED" or "X Impulse Jump DISABLED")
    SaveSettings()
end)

TabMove:CreateSlider(
    "Impulse Speed",
    10, 120, Config.ImpulseJumpSpeed,
    function(value)
        Config.ImpulseJumpSpeed = value
        print("✓ Impulse Jump speed: " .. string.format("%.0f", value))
        SaveSettings()
    end,
    nil, 120
)

TabMove:CreateDivider()

--// FRONTAL JUMP
TabMove:CreateLabel("SALTO FRONTAL", "FRONTAL JUMP", 14)
TabMove:CreateDivider()

TabMove:CreateFloatingToggle("Salto Frontal", "Frontal Jump", Config.EnableFrontalJump, function(state)
    Config.EnableFrontalJump = state
    if state then
        savedOptions.EnableTeleportWalk = Config.EnableTeleportWalk
        savedOptions.EnableEnhancedJump = Config.EnableEnhancedJump
        savedOptions.EnableGravityMod = Config.EnableGravityMod

        Config.EnableTeleportWalk = false
        Config.EnableEnhancedJump = false
        Config.EnableGravityMod = false

        lastJumpTime = tick()
        currentSpeed = getgenv().FrontalJumpSpeed
        airAccumulator = 0

        print("✓ Frontal Jump ENABLED - Beta")
        print("   - Teleport Walk disabled")
        print("   - Enhanced Jump disabled")
        print("   - Gravity Mod disabled")
    else
        Config.EnableTeleportWalk = savedOptions.EnableTeleportWalk
        Config.EnableEnhancedJump = savedOptions.EnableEnhancedJump
        Config.EnableGravityMod = savedOptions.EnableGravityMod

        if activeBV then activeBV:Destroy() end
        activeBV = nil
        currentSpeed = getgenv().FrontalJumpSpeed

        print("X Frontal Jump DISABLED")
        print("   - Options restored")
    end
    SaveSettings()
end)

TabMove:CreateSlider(
    "Movement Speed",
    30, 110, getgenv().FrontalJumpSpeed,
    function(value)
        getgenv().FrontalJumpSpeed = value
        currentSpeed = value
        print("✓ Frontal Jump Speed: " .. value)
        SaveSettings()
    end,
    nil, 32
)

TabMove:CreateSlider(
    "Ramp Multiplier",
    0.10, 5.0, getgenv().RampMultiplier,
    function(value)
        getgenv().RampMultiplier = value
        print("✓ Ramp Multiplier: " .. value)
        SaveSettings()
    end,
    nil, 1.5
)

TabMove:CreateDivider()

--// RAMP MULTIPLIER (independiente)
TabMove:CreateLabel("MULTIPLICADOR DE RAMPA", "RAMP MULTIPLIER", 14)
TabMove:CreateDivider()

TabMove:CreateFloatingToggle("Impulso Rampa", "Ramp Boost", Config.EnableRampMultiplier, function(state)
    Config.EnableRampMultiplier = state
    print(state and "✓ Ramp Multiplier ENABLED (standalone)" or "X Ramp Multiplier DISABLED")
    SaveSettings()
end)

TabMove:CreateSlider(
    "Ramp Multiplier",
    0.10, 5.0, getgenv().RampMultiplierValue,
    function(value)
        getgenv().RampMultiplierValue = value
        print("✓ Ramp Multiplier (standalone): " .. value)
        SaveSettings()
    end,
    nil, 1.5
)

TabMove:CreateDivider()

--// BACK JUMP
TabMove:CreateLabel("SALTO HACIA ATRÁS", "BACK JUMP", 14)
TabMove:CreateDivider()

TabMove:CreateFloatingToggle("Salto Hacia Atrás", "Back Jump", Config.EnableBackJump, function(state)
    Config.EnableBackJump = state
    if state then
        backLastJumpTime = tick()
        backCurrentSpeed = getgenv().BackJumpSpeed
        backAirAccumulator = 0
        print("✓ Back Jump ENABLED")
    else
        if backActiveBV then backActiveBV:Destroy() end
        backActiveBV = nil
        backCurrentSpeed = getgenv().BackJumpSpeed
        print("X Back Jump DISABLED")
    end
    SaveSettings()
end)

TabMove:CreateSlider(
    "Back Speed",
    30, 110, getgenv().BackJumpSpeed,
    function(value)
        getgenv().BackJumpSpeed = value
        backCurrentSpeed = value
        print("✓ Back Jump Speed: " .. value)
        SaveSettings()
    end,
    nil, 32
)

TabMove:CreateSlider(
    "Back Ramp Multiplier",
    0, 5.0, getgenv().BackRampMultiplier,
    function(value)
        getgenv().BackRampMultiplier = value
        print("✓ Back Ramp Multiplier: " .. value)
        SaveSettings()
    end,
    nil, 0
)

TabMove:CreateDivider()
TabMove:CreateLabel("MODIFICACIÓN DE GRAVEDAD", "GRAVITY MODIFICATION", 14)
TabMove:CreateDivider()

TabMove:CreateFloatingToggle("Gravedad", "Gravity", Config.EnableGravityMod, function(state)
    Config.EnableGravityMod = state
    print(state and "✓ Gravity Mod ENABLED" or "X Gravity Mod DISABLED")
    SaveSettings()
end)

TabMove:CreateSlider(
    "Gravity Scale",
    0.1, 2, Config.GravityScale,
    function(value)
        Config.GravityScale = value
        print("✓ Gravity Scale: " .. value)
        SaveSettings()
    end,
    nil, 1
)

TabMove:CreateDivider()
TabMove:CreateLabel("AUTO TRIMP", 14)
TabMove:CreateDivider()

TabMove:CreateFloatingToggle("Auto Trimp", Config.EnableAutoTrimp, function(state)
    Config.EnableAutoTrimp = state
    print(state and "✓ Auto Trimp ENABLED" or "X Auto Trimp DISABLED")
    SaveSettings()
end)

TabMove:CreateSlider(
    "Trimp Multiplier",
    1.0, 10.0, Config.AutoTrimpMultiplier,
    function(value)
        Config.AutoTrimpMultiplier = value
        print("✓ Trimp Multiplier: " .. value)
        SaveSettings()
    end
)

TabMove:CreateSlider(
    "Fall Speed",
    0.1, 1.0, Config.AutoTrimpFallSpeed,
    function(value)
        Config.AutoTrimpFallSpeed = value
        print("✓ Trimp Fall Speed: " .. value)
        SaveSettings()
    end
)

TabMove:CreateLabel("Rebota en el suelo con velocidad acumulada", "Bounces off the ground with accumulated speed", 11)

TabMove:CreateDivider()
TabMove:CreateLabel("TRIMP + TELEPORT WALK", 14)
TabMove:CreateDivider()

TabMove:CreateFloatingToggle("Trimp + Walk", Config.EnableTrimpTeleport, function(state)
    Config.EnableTrimpTeleport = state
    print(state and "✓ Trimp + Teleport Walk ENABLED" or "X Trimp + Teleport Walk DISABLED")
    SaveSettings()
end)

TabMove:CreateSlider(
    "Trimp Multiplier",
    1.0, 10.0, Config.AutoTrimpMultiplier,
    function(value)
        Config.AutoTrimpMultiplier = value
        print("✓ Trimp Multiplier: " .. value)
        SaveSettings()
    end
)

TabMove:CreateSlider(
    "Fall Speed",
    0.1, 1.0, Config.AutoTrimpFallSpeed,
    function(value)
        Config.AutoTrimpFallSpeed = value
        print("✓ Trimp Fall Speed: " .. value)
        SaveSettings()
    end
)

TabMove:CreateSlider(
    "Teleport Speed",
    1, 50, Config.TeleportMovementSpeed,
    function(value)
        Config.TeleportMovementSpeed = value
        print("✓ Teleport speed: " .. value)
        SaveSettings()
    end,
    nil, 3
)

TabMove:CreateLabel("Combina rebote y caminata por teletransporte", "Combines trimp bounce and teleport walk", 11)

TabMove:CreateDivider()
TabMove:CreateLabel("MOVIMIENTO EN 8  ∞", "FIGURE-8 MOVEMENT  ∞", 14)
TabMove:CreateDivider()

TabMove:CreateFloatingToggle("Bucle en 8", "Figure-8 Loop", Config.EnableFigure8, function(state)
    Config.EnableFigure8 = state
    if state then
        StartFigure8Loop()
    else
        StopFigure8Loop()
    end
    print(state and "✓ Figure-8 Loop ENABLED" or "X Figure-8 Loop DISABLED")
    SaveSettings()
end)

TabMove:CreateSlider(
    "Velocidad / Speed",
    0.2, 3.0, Config.Figure8Speed,
    function(value)
        Config.Figure8Speed = value
        print("✓ Figure-8 Speed: " .. value)
        SaveSettings()
    end
)

TabMove:CreateSlider(
    "Radio / Radius (studs)",
    3, 25, Config.Figure8Radius,
    function(value)
        Config.Figure8Radius = value
        print("✓ Figure-8 Radius: " .. value)
        SaveSettings()
    end
)

TabMove:CreateLabel(
    "Traza un ∞ alrededor del punto de activación  •  Velocidad y radio ajustables en tiempo real",
    "Traces an ∞ around the activation point  •  Speed and radius adjustable in real-time",
    11
)

TabMove:CreateDivider()
TabMove:CreateLabel("CURVA DE LISSAJOUS 3:2  〰️", "LISSAJOUS 3:2 CURVE  〰️", 14)
TabMove:CreateDivider()

TabMove:CreateFloatingToggle("Lissajous 3:2", "Lissajous 3:2", Config.EnableLissajous, function(state)
    Config.EnableLissajous = state
    if state then
        StartLissajousLoop()
    else
        StopLissajousLoop()
    end
    print(state and "✓ Lissajous Loop ENABLED" or "X Lissajous Loop DISABLED")
    SaveSettings()
end)

TabMove:CreateSlider(
    "Velocidad / Speed",
    0.2, 3.0, Config.LissajousSpeed,
    function(value)
        Config.LissajousSpeed = value
        print("✓ Lissajous Speed: " .. value)
        SaveSettings()
    end
)

TabMove:CreateSlider(
    "Radio / Radius (studs)",
    3, 25, Config.LissajousRadius,
    function(value)
        Config.LissajousRadius = value
        print("✓ Lissajous Radius: " .. value)
        SaveSettings()
    end
)

TabMove:CreateLabel(
    "Figura de lazo con 6 cruzamientos  •  Patrón osciloscópico clásico",
    "6-crossing loop figure  •  Classic oscilloscope pattern",
    11
)

TabMove:CreateDivider()
TabMove:CreateLabel("HIPOTROCOIDE (Spirograph)  @", "HYPOTROCHOID (Spirograph)  @", 14)
TabMove:CreateDivider()

TabMove:CreateFloatingToggle("Spirograph", "Spirograph", Config.EnableSpiro, function(state)
    Config.EnableSpiro = state
    if state then
        StartSpiroLoop()
    else
        StopSpiroLoop()
    end
    print(state and "✓ Spirograph Loop ENABLED" or "X Spirograph Loop DISABLED")
    SaveSettings()
end)

TabMove:CreateSlider(
    "Velocidad / Speed",
    0.1, 2.0, Config.SpiroSpeed,
    function(value)
        Config.SpiroSpeed = value
        print("✓ Spiro Speed: " .. value)
        SaveSettings()
    end
)

TabMove:CreateSlider(
    "Radio Exterior / Outer Radius (studs)",
    5, 30, Config.SpiroRadius,
    function(value)
        Config.SpiroRadius = value
        print("✓ Spiro Radius: " .. value)
        SaveSettings()
    end
)

TabMove:CreateSlider(
    "Radio Interno / Inner Ratio (0.1 – 0.9)",
    0.1, 0.9, Config.SpiroRatio,
    function(value)
        Config.SpiroRatio = value
        print("✓ Spiro Ratio: " .. value)
        SaveSettings()
    end
)

TabMove:CreateLabel(
    "Figura tipo Spirograph  •  Cambia el ratio para estrellas, rosas y más formas",
    "Spirograph-style figure  •  Change ratio for stars, roses and more shapes",
    11
)

print("✓ MOVE: Tab completed")
