if _G.RainVisualLoaded then return end
_G.RainVisualLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local currentMode = "Rainbow"

Lighting.ClockTime = 0
Lighting.Brightness = 0.5
Lighting.Ambient = Color3.fromRGB(40, 40, 50)
Lighting.OutdoorAmbient = Color3.fromRGB(40, 40, 50)
Lighting.FogColor = Color3.fromRGB(10, 10, 20)
Lighting.FogStart = 50
Lighting.FogEnd = 500

local rainSound = Instance.new("Sound")
rainSound.Name = "RainSound"
rainSound.SoundId = "rbxassetid://1516791621"
rainSound.Volume = 1.5
rainSound.Looped = true
rainSound.Playing = true
rainSound.Parent = SoundService

local rainFolder = Instance.new("Folder")
rainFolder.Name = "RainEffect"
rainFolder.Parent = workspace.CurrentCamera

local tiltAngle = 25
local tiltRad = math.rad(tiltAngle)
local tiltTan = math.tan(tiltRad)

local function createLayer(count, size, speed, spread, height, useLight)
    local layer = {}
    for i = 1, count do
        local p = Instance.new("Part")
        p.Size = size
        p.Anchored = true
        p.CanCollide = false
        p.CanTouch = false
        p.CanQuery = false
        p.Massless = true
        p.Material = Enum.Material.Neon
        p.Color = Color3.fromHSV(math.random(), 1, 1)
        p.Transparency = 0.2
        p.Parent = rainFolder
        if useLight then
            local light = Instance.new("PointLight")
            light.Color = p.Color
            light.Range = 4
            light.Brightness = 1.5
            light.Parent = p
        end
        table.insert(layer, {
            part = p,
            hue = math.random(),
            offsetX = (math.random() - 0.5) * spread * 2,
            offsetZ = (math.random() - 0.5) * spread * 2,
            offsetY = math.random() * height,
            baseSpeed = speed,
            speed = speed + math.random(-30, 30),
            slantOffsetX = 0,
            spread = spread,
            maxHeight = height,
        })
    end
    return layer
end

local dropsFar = createLayer(100, Vector3.new(0.15, 1.5, 0.15), 260, 120, 150, false)
local dropsNear = createLayer(80, Vector3.new(0.4, 4, 0.4), 160, 60, 100, true)

local function updateLayer(layer, dt, center)
    for _, d in ipairs(layer) do
        d.offsetY = d.offsetY - d.speed * dt
        d.slantOffsetX = d.slantOffsetX + d.speed * dt * tiltTan
        if d.offsetY < -20 then
            d.offsetY = d.maxHeight
            d.slantOffsetX = 0
            d.offsetX = (math.random() - 0.5) * d.spread * 2
            d.offsetZ = (math.random() - 0.5) * d.spread * 2
            if currentMode == "Rainbow" then
                d.hue = math.random()
                d.part.Color = Color3.fromHSV(d.hue, 1, 1)
            end
            local light = d.part:FindFirstChildOfClass("PointLight")
            if light then light.Color = d.part.Color end
        end
        local pos = Vector3.new(center.X + d.offsetX + d.slantOffsetX, center.Y + d.offsetY, center.Z + d.offsetZ)
        d.part.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, tiltRad)
    end
end

RunService.RenderStepped:Connect(function(dt)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local center = hrp.Position
    updateLayer(dropsFar, dt, center)
    updateLayer(dropsNear, dt, center)
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if currentMode == "Rainbow" then
            for _, d in ipairs(dropsFar) do
                d.hue = (d.hue + 0.01) % 1
                d.part.Color = Color3.fromHSV(d.hue, 1, 1)
            end
            for _, d in ipairs(dropsNear) do
                d.hue = (d.hue + 0.01) % 1
                d.part.Color = Color3.fromHSV(d.hue, 1, 1)
                local light = d.part:FindFirstChildOfClass("PointLight")
                if light then light.Color = d.part.Color end
            end
        end
    end
end)

local skyFolder = Instance.new("Folder")
skyFolder.Name = "SkyDigits"
skyFolder.Parent = workspace

local skyDigits = {}

local function spawnSkyDigit()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local p = Instance.new("Part")
    p.Size = Vector3.new(0.1, 0.1, 0.1)
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Massless = true
    p.Transparency = 1
    p.Material = Enum.Material.SmoothPlastic
    p.Parent = skyFolder
    local angle = math.random() * math.pi * 2
    local distance = 15 + math.random() * 35
    local height = 15 + math.random() * 25
    local pos = hrp.Position + Vector3.new(math.cos(angle) * distance, height, math.sin(angle) * distance)
    p.CFrame = CFrame.new(pos)
    local sg = Instance.new("BillboardGui")
    sg.Size = UDim2.new(0, 60, 0, 60)
    sg.AlwaysOnTop = false
    sg.Adornee = p
    sg.Parent = p
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = tostring(math.random(1, 9))
    label.TextScaled = true
    label.Font = Enum.Font.Code
    label.TextColor3 = Color3.fromRGB(0, math.random(150, 255), 0)
    label.TextStrokeTransparency = 0.3
    label.TextStrokeColor3 = Color3.fromRGB(0, 50, 0)
    label.Parent = sg
    table.insert(skyDigits, {part = p, gui = sg, label = label})
    task.delay(0.2, function()
        if p and p.Parent then
            p:Destroy()
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(0.2)
        if currentMode == "Hacker" then
            for i = 1, 3 do
                spawnSkyDigit()
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        for i = #skyDigits, 1, -1 do
            local entry = skyDigits[i]
            if not entry.part or not entry.part.Parent then
                table.remove(skyDigits, i)
            end
        end
    end
end)

local auraFolder = Instance.new("Folder")
auraFolder.Name = "RainbowAura"
auraFolder.Parent = workspace.CurrentCamera

local auraCount = 40
local auraSize = 0.4
local auraRadius = 3.2

local function makeTrail(p, size)
    local a0 = Instance.new("Attachment")
    a0.Position = Vector3.new(0, size * 0.5, 0)
    a0.Parent = p
    local a1 = Instance.new("Attachment")
    a1.Position = Vector3.new(0, -size * 0.5, 0)
    a1.Parent = p
    local trail = Instance.new("Trail")
    trail.Attachment0 = a0
    trail.Attachment1 = a1
    trail.Lifetime = 0.5
    trail.MinLength = 0
    trail.WidthScale = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
    trail.Color = ColorSequence.new(p.Color)
    trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})
    trail.LightEmission = 1
    trail.LightInfluence = 0
    trail.FaceCamera = true
    trail.Parent = p
    return trail
end

local auraParts = {}

for i = 1, auraCount do
    local p = Instance.new("Part")
    p.Shape = Enum.PartType.Block
    p.Size = Vector3.new(auraSize, auraSize, auraSize)
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Massless = true
    p.Material = Enum.Material.Neon
    p.Color = Color3.fromHSV(i / auraCount, 1, 1)
    p.Transparency = 0.1
    p.Parent = auraFolder
    local light = Instance.new("PointLight")
    light.Color = p.Color
    light.Range = 4
    light.Brightness = 2
    light.Parent = p
    local trail = makeTrail(p, auraSize)
    local startTilt = math.random(-90, 90)
    local startHeight = (math.random() - 0.5) * 0.6
    local startSpeed = math.random(10, 50) / 10
    table.insert(auraParts, {
        part = p, light = light, trail = trail, hue = i / auraCount,
        angle = (i / auraCount) * math.pi * 2, radius = auraRadius,
        tilt = startTilt, height = startHeight, speed = startSpeed,
        spinSpeed = math.random(80, 200) / 100,
        startAngle = (i / auraCount) * math.pi * 2, startRadius = auraRadius,
        startTilt = startTilt, startHeight = startHeight, startSpeed = startSpeed,
        targetAngle = (i / auraCount) * math.pi * 2, targetRadius = auraRadius,
        targetTilt = startTilt, targetHeight = startHeight, targetSpeed = startSpeed,
        progress = 1, hackerPhase = math.random() * math.pi * 2,
        hackerSpawnTime = math.random() * 2, hackerState = "visible", hackerAlpha = 1,
        hackerRadius = auraRadius + (math.random() - 0.5) * 1.5,
        hackerJitter = math.random() * 0.3,
        hackerSpeed = math.random(0.8, 2.5),
    })
end

task.spawn(function()
    while true do
        task.wait(12)
        if currentMode == "Rainbow" then
            for _, a in ipairs(auraParts) do
                a.startAngle = a.angle
                a.startRadius = a.radius
                a.startTilt = a.tilt
                a.startHeight = a.height
                a.startSpeed = a.speed
                a.targetAngle = a.angle + math.random(-8, 8)
                a.targetRadius = auraRadius + (math.random() - 0.5) * 0.4
                a.targetTilt = math.random(-90, 90)
                a.targetHeight = (math.random() - 0.5) * 0.6
                a.targetSpeed = math.random(5, 40) / 10
                a.progress = 0
            end
        end
    end
end)

local auraT = 0
local hackerT = 0

local pulseState = nil

local function triggerAuraPulse()
    pulseState = {
        phase = "inhale",
        phaseTime = 0,
        startRadius = auraRadius,
        jitterTimer = 0,
    }
    for _, a in ipairs(auraParts) do
        a.baseRadius = a.radius
    end
end

local function updateAuraPulse(dt)
    if not pulseState then return end
    pulseState.phaseTime = pulseState.phaseTime + dt

    if pulseState.phase == "inhale" then
        local t = math.min(1, pulseState.phaseTime / 0.05)
        for _, a in ipairs(auraParts) do
            a.radius = pulseState.startRadius + (2.8 - pulseState.startRadius) * t
        end
        if pulseState.phaseTime >= 0.05 then
            pulseState.phase = "exhale"
            pulseState.phaseTime = 0
        end

    elseif pulseState.phase == "exhale" then
        local t = math.min(1, pulseState.phaseTime / 0.3)
        local e = 1 - (1 - t) * (1 - t)
        for _, a in ipairs(auraParts) do
            a.radius = 2.8 + (9 - 2.8) * e
        end
        if pulseState.phaseTime >= 0.3 then
            pulseState.phase = "jitter"
            pulseState.phaseTime = 0
            pulseState.jitterTimer = 0
        end

    elseif pulseState.phase == "jitter" then
        pulseState.jitterTimer = (pulseState.jitterTimer or 0) + dt
        if pulseState.jitterTimer >= 0.1 then
            pulseState.jitterTimer = 0
            for _, a in ipairs(auraParts) do
                a.radius = 2.5 + math.random() * 8
            end
        end
        if pulseState.phaseTime >= 0.7 then
            pulseState.phase = "return"
            pulseState.phaseTime = 0
        end

    elseif pulseState.phase == "return" then
        local t = math.min(1, pulseState.phaseTime / 0.3)
        local e = t * t
        for _, a in ipairs(auraParts) do
            local targetR = a.baseRadius or auraRadius
            a.radius = a.radius + (targetR - a.radius) * e
        end
        if pulseState.phaseTime >= 0.3 then
            for _, a in ipairs(auraParts) do
                a.radius = a.baseRadius or auraRadius
            end
            pulseState = nil
        end
    end
end

RunService.RenderStepped:Connect(function(dt)
    auraT = auraT + dt
    hackerT = hackerT + dt
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local center = hrp.Position
    updateAuraPulse(dt)
    if currentMode == "Rainbow" then
        for _, a in ipairs(auraParts) do
            if a.progress < 1 then
                a.progress = math.min(1, a.progress + dt / 12)
            end
            local e = 0.5 - 0.5 * math.cos(a.progress * math.pi)
            a.angle = a.startAngle + (a.targetAngle - a.startAngle) * e
            if not pulseState then
                a.radius = a.startRadius + (a.targetRadius - a.startRadius) * e
            end
            a.tilt = a.startTilt + (a.targetTilt - a.startTilt) * e
            a.height = a.startHeight + (a.targetHeight - a.startHeight) * e
            a.speed = a.startSpeed + (a.targetSpeed - a.startSpeed) * e
            local angle = a.angle + auraT * a.speed
            local tR = math.rad(a.tilt)
            local lX = math.cos(angle) * a.radius
            local lZ = math.sin(angle) * a.radius
            local tY = lZ * math.sin(tR)
            local tZ = lZ * math.cos(tR)
            a.part.CFrame = CFrame.new(center.X + lX, center.Y + tY + a.height, center.Z + tZ) * CFrame.Angles(auraT * a.spinSpeed, auraT * a.spinSpeed, 0)
            a.part.Transparency = 0.1
            a.part.Size = Vector3.new(auraSize, auraSize, auraSize)
            a.hue = (a.hue + dt * 0.3) % 1
            local color = Color3.fromHSV(a.hue, 1, 1)
            a.part.Color = color
            a.light.Color = color
            if a.trail then
                a.trail.Color = ColorSequence.new(color)
                a.trail.Enabled = true
            end
        end
    else
        for _, a in ipairs(auraParts) do
            a.hackerSpawnTime = a.hackerSpawnTime + dt
            local cycle = 0.5 + (a.hackerPhase % 0.7)
            if a.hackerSpawnTime >= cycle then
                a.hackerSpawnTime = 0
                a.hackerState = a.hackerState == "visible" and "hidden" or "visible"
                a.hackerRadius = auraRadius + (math.random() - 0.5) * 2
                a.angle = math.random() * math.pi * 2
                a.height = (math.random() - 0.5) * 1.5
            end
            if a.hackerState == "visible" then
                a.hackerAlpha = math.min(1, a.hackerAlpha + dt * 6)
            else
                a.hackerAlpha = math.max(0, a.hackerAlpha - dt * 8)
            end
            local jitter = math.sin(hackerT * 15 + a.hackerPhase) * a.hackerJitter
            local glitch = math.sin(hackerT * 30 + a.hackerPhase * 2)
            local moveAngle = a.angle + hackerT * a.hackerSpeed
            local tR = math.rad(a.tilt)
            local lX = math.cos(moveAngle) * (a.hackerRadius + jitter)
            local lZ = math.sin(moveAngle) * (a.hackerRadius + jitter)
            local tY = lZ * math.sin(tR)
            local tZ = lZ * math.cos(tR)
            local flash = 0.5 + 0.5 * math.sin(hackerT * 12 + a.hackerPhase)
            local flicker = math.random() > 0.85 and 0.2 or 1
            a.part.CFrame = CFrame.new(center.X + lX, center.Y + tY + a.height, center.Z + tZ) * CFrame.Angles(hackerT * 4 * a.spinSpeed, hackerT * 4 * a.spinSpeed, 0)
            a.part.Transparency = 1 - a.hackerAlpha * 0.95 * flicker
            a.part.Size = Vector3.new(
                auraSize * (0.7 + flash * 0.6 + glitch * 0.2),
                auraSize * (0.7 + flash * 0.6),
                auraSize * (0.7 + flash * 0.6 + glitch * 0.2)
            )
            local greenVal = 0.3 + flash * 0.7
            local color = Color3.fromRGB(
                math.floor(20 * flash),
                math.floor(255 * greenVal),
                math.floor(40 * flash)
            )
            a.part.Color = color
            a.light.Color = color
            a.light.Brightness = 3 * a.hackerAlpha * flicker
            if a.trail then
                a.trail.Color = ColorSequence.new(color)
                a.trail.Enabled = a.hackerAlpha > 0.1
                a.trail.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1 - a.hackerAlpha * 0.9),
                    NumberSequenceKeypoint.new(1, 1),
                })
            end
        end
    end
end)

local haloFolder = Instance.new("Folder")
haloFolder.Name = "RainbowHalo"
haloFolder.Parent = workspace.CurrentCamera

local haloCount = 24
local haloSize = 0.18
local haloRadius = 1.2
local haloHeight = 4.5

local haloParts = {}

for i = 1, haloCount do
    local p = Instance.new("Part")
    p.Shape = Enum.PartType.Block
    p.Size = Vector3.new(haloSize, haloSize, haloSize)
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Massless = true
    p.Material = Enum.Material.Neon
    p.Color = Color3.fromHSV(i / haloCount, 1, 1)
    p.Transparency = 0.1
    p.Parent = haloFolder
    local light = Instance.new("PointLight")
    light.Color = p.Color
    light.Range = 3
    light.Brightness = 2
    light.Parent = p
    local trail = makeTrail(p, haloSize)
    table.insert(haloParts, {
        part = p, light = light, trail = trail, hue = i / haloCount,
        baseAngle = (i / haloCount) * math.pi * 2,
        bobPhase = math.random() * math.pi * 2,
        spinSpeed = math.random(60, 150) / 100,
        hackerPhase = math.random() * math.pi * 2,
    })
end

local haloT = 0

RunService.RenderStepped:Connect(function(dt)
    haloT = haloT + dt
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local center = hrp.Position
    for _, h in ipairs(haloParts) do
        local angle = h.baseAngle + haloT * 1.5
        local yBob = math.sin(haloT * 2 + h.bobPhase) * 0.15
        local lX = math.cos(angle) * haloRadius
        local lZ = math.sin(angle) * haloRadius
        h.part.CFrame = CFrame.new(center.X + lX, center.Y + haloHeight + yBob, center.Z + lZ) * CFrame.Angles(haloT * h.spinSpeed, haloT * h.spinSpeed, 0)
        local color
        if currentMode == "Rainbow" then
            h.hue = (h.hue + dt * 0.3) % 1
            color = Color3.fromHSV(h.hue, 1, 1)
            h.part.Transparency = 0.1
            h.part.Size = Vector3.new(haloSize, haloSize, haloSize)
        else
            local flash = 0.5 + 0.5 * math.sin(haloT * 8 + h.hackerPhase)
            local greenVal = 0.3 + flash * 0.7
            color = Color3.fromRGB(10, math.floor(255 * greenVal), 20)
            h.part.Transparency = 0.05 + (1 - flash) * 0.35
            local s = haloSize * (0.8 + flash * 0.5)
            h.part.Size = Vector3.new(s, s, s)
        end
        h.part.Color = color
        h.light.Color = color
        if h.trail then h.trail.Color = ColorSequence.new(color) end
    end
end)

local portalFolder = Instance.new("Folder")
portalFolder.Name = "Portals"
portalFolder.Parent = workspace

local portals = {}
local portalEnabled = false
local placingMode = false
local lastPlaceTime = 0

local PORTAL_COLOR_A = Color3.fromRGB(140, 50, 255)
local PORTAL_COLOR_B = Color3.fromRGB(50, 5, 120)
local PORTAL_COLOR_CORE = Color3.fromRGB(20, 0, 40)
local PORTAL_RADIUS = 3.5

local function createPortal(position)
    local portal = {
        position = position,
        t = 0,
        particles = {},
        openProgress = 0,
        spawnTime = tick(),
    }
    local group = Instance.new("Folder")
    group.Name = "Portal"
    group.Parent = portalFolder
    portal.group = group

    local outerRing = Instance.new("Part")
    outerRing.Shape = Enum.PartType.Cylinder
    outerRing.Size = Vector3.new(0.4, PORTAL_RADIUS * 2.2, PORTAL_RADIUS * 2.2)
    outerRing.Anchored = true
    outerRing.CanCollide = false
    outerRing.CanTouch = false
    outerRing.CanQuery = false
    outerRing.Massless = true
    outerRing.Material = Enum.Material.Neon
    outerRing.Color = PORTAL_COLOR_A
    outerRing.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
    outerRing.Parent = group
    portal.outerRing = outerRing

    local outerLight = Instance.new("PointLight")
    outerLight.Color = PORTAL_COLOR_A
    outerLight.Range = 18
    outerLight.Brightness = 4
    outerLight.Parent = outerRing
    portal.outerLight = outerLight

    local ring1 = Instance.new("Part")
    ring1.Shape = Enum.PartType.Cylinder
    ring1.Size = Vector3.new(0.35, PORTAL_RADIUS * 2, PORTAL_RADIUS * 2)
    ring1.Anchored = true
    ring1.CanCollide = false
    ring1.CanTouch = false
    ring1.CanQuery = false
    ring1.Massless = true
    ring1.Material = Enum.Material.Neon
    ring1.Color = PORTAL_COLOR_A
    ring1.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
    ring1.Parent = group
    portal.ring1 = ring1

    local ring2 = Instance.new("Part")
    ring2.Shape = Enum.PartType.Cylinder
    ring2.Size = Vector3.new(0.25, PORTAL_RADIUS * 1.75, PORTAL_RADIUS * 1.75)
    ring2.Anchored = true
    ring2.CanCollide = false
    ring2.CanTouch = false
    ring2.CanQuery = false
    ring2.Massless = true
    ring2.Material = Enum.Material.Neon
    ring2.Color = PORTAL_COLOR_B
    ring2.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
    ring2.Parent = group
    portal.ring2 = ring2

    local ring3 = Instance.new("Part")
    ring3.Shape = Enum.PartType.Cylinder
    ring3.Size = Vector3.new(0.18, PORTAL_RADIUS * 1.4, PORTAL_RADIUS * 1.4)
    ring3.Anchored = true
    ring3.CanCollide = false
    ring3.CanTouch = false
    ring3.CanQuery = false
    ring3.Massless = true
    ring3.Material = Enum.Material.Neon
    ring3.Color = Color3.fromRGB(180, 100, 255)
    ring3.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
    ring3.Parent = group
    portal.ring3 = ring3

    local coreSphere = Instance.new("Part")
    coreSphere.Shape = Enum.PartType.Ball
    coreSphere.Size = Vector3.new(PORTAL_RADIUS * 1.9, PORTAL_RADIUS * 1.9, PORTAL_RADIUS * 1.9)
    coreSphere.Anchored = true
    coreSphere.CanCollide = false
    coreSphere.CanTouch = false
    coreSphere.CanQuery = false
    coreSphere.Massless = true
    coreSphere.Material = Enum.Material.Neon
    coreSphere.Color = PORTAL_COLOR_B
    coreSphere.Transparency = 0.4
    coreSphere.CFrame = CFrame.new(position)
    coreSphere.Parent = group
    portal.coreSphere = coreSphere

    local coreLight = Instance.new("PointLight")
    coreLight.Color = Color3.fromRGB(180, 100, 255)
    coreLight.Range = 14
    coreLight.Brightness = 5
    coreLight.Parent = coreSphere
    portal.coreLight = coreLight

    local darkCore = Instance.new("Part")
    darkCore.Shape = Enum.PartType.Ball
    darkCore.Size = Vector3.new(PORTAL_RADIUS * 1.3, PORTAL_RADIUS * 1.3, PORTAL_RADIUS * 1.3)
    darkCore.Anchored = true
    darkCore.CanCollide = false
    darkCore.CanTouch = false
    darkCore.CanQuery = false
    darkCore.Massless = true
    darkCore.Material = Enum.Material.Neon
    darkCore.Color = PORTAL_COLOR_CORE
    darkCore.Transparency = 0.15
    darkCore.CFrame = CFrame.new(position)
    darkCore.Parent = group
    portal.darkCore = darkCore

    local innerCore = Instance.new("Part")
    innerCore.Shape = Enum.PartType.Ball
    innerCore.Size = Vector3.new(PORTAL_RADIUS * 0.7, PORTAL_RADIUS * 0.7, PORTAL_RADIUS * 0.7)
    innerCore.Anchored = true
    innerCore.CanCollide = false
    innerCore.CanTouch = false
    innerCore.CanQuery = false
    innerCore.Massless = true
    innerCore.Material = Enum.Material.Neon
    innerCore.Color = Color3.fromRGB(220, 180, 255)
    innerCore.Transparency = 0.2
    innerCore.CFrame = CFrame.new(position)
    innerCore.Parent = group
    portal.innerCore = innerCore

    local sparkFolder = Instance.new("Folder")
    sparkFolder.Name = "Sparks"
    sparkFolder.Parent = group
    portal.sparkFolder = sparkFolder

    for i = 1, 24 do
        local spark = Instance.new("Part")
        spark.Shape = Enum.PartType.Ball
        spark.Size = Vector3.new(0.25, 0.25, 0.25)
        spark.Anchored = true
        spark.CanCollide = false
        spark.CanTouch = false
        spark.CanQuery = false
        spark.Massless = true
        spark.Material = Enum.Material.Neon
        spark.Color = Color3.fromHSV(math.random() * 0.15 + 0.75, 1, 1)
        spark.Transparency = 0.1
        spark.Parent = sparkFolder
        local sparkLight = Instance.new("PointLight")
        sparkLight.Color = spark.Color
        sparkLight.Range = 5
        sparkLight.Brightness = 2
        sparkLight.Parent = spark
        table.insert(portal.particles, {
            part = spark,
            angle = math.random() * math.pi * 2,
            height = (math.random() - 0.5) * PORTAL_RADIUS * 1.5,
            radius = PORTAL_RADIUS * (1.3 + math.random() * 0.4),
            speed = 0.5 + math.random() * 1.5,
            basePhase = math.random() * math.pi * 2,
            pullPhase = math.random() * math.pi * 2,
        })
    end

    local beamAttachment0 = Instance.new("Attachment")
    beamAttachment0.Position = Vector3.new(0, PORTAL_RADIUS * 0.9, 0)
    beamAttachment0.Parent = outerRing
    local beamAttachment1 = Instance.new("Attachment")
    beamAttachment1.Position = Vector3.new(0, -PORTAL_RADIUS * 0.9, 0)
    beamAttachment1.Parent = outerRing

    local beam = Instance.new("Beam")
    beam.Attachment0 = beamAttachment0
    beam.Attachment1 = beamAttachment1
    beam.Width0 = 0.3
    beam.Width1 = 0.3
    beam.Color = ColorSequence.new(PORTAL_COLOR_A)
    beam.Transparency = NumberSequence.new(0.3)
    beam.LightEmission = 1
    beam.LightInfluence = 0
    beam.FaceCamera = true
    beam.Parent = outerRing
    portal.beam = beam

    local ambientSound = Instance.new("Sound")
    ambientSound.SoundId = "rbxassetid://5657539493"
    ambientSound.Volume = 1.5
    ambientSound.Looped = true
    ambientSound.Playing = true
    ambientSound.Parent = group
    portal.ambientSound = ambientSound

    return portal
end

local function destroyPortal(portal)
    if portal and portal.group then
        portal.group:Destroy()
    end
end

local function clearPortals()
    for _, p in pairs(portals) do
        destroyPortal(p)
    end
    portals = {}
end

local teleportSound = Instance.new("Sound")
teleportSound.SoundId = "rbxassetid://5233733863"
teleportSound.Volume = 3
teleportSound.Parent = SoundService

local function playTeleportSound()
    local s = teleportSound:Clone()
    s.Parent = SoundService
    s:Play()
    game:GetService("Debris"):AddItem(s, 3)
end

local charVelocityThreshold = 15
local cameraRotationThreshold = 0.5
local lastCameraCF = camera.CFrame

local function isPlayerMoving()
    local char = player.Character
    if not char then return true end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return true end
    return hrp.AssemblyLinearVelocity.Magnitude > charVelocityThreshold
end

local function isCameraRotating()
    local diff = (camera.CFrame.LookVector - lastCameraCF.LookVector).Magnitude
    lastCameraCF = camera.CFrame
    return diff > cameraRotationThreshold
end

local function tryPlacePortal(input)
    if not portalEnabled or not placingMode then return end
    if tick() - lastPlaceTime < 0.3 then return end
    if isPlayerMoving() then return end
    if isCameraRotating() then return end

    local inputPos
    if input then
        inputPos = input.Position
    else
        inputPos = UserInputService:GetMouseLocation()
    end

    local inset = GuiService:GetGuiInset()
    local screenPos = Vector2.new(inputPos.X, inputPos.Y - inset.Y)
    local unitRay = camera:ViewportPointToRay(screenPos.X, screenPos.Y)
    local char = player.Character

    local filterList = {portalFolder, camera}
    if char then
        table.insert(filterList, char)
        for _, child in ipairs(char:GetChildren()) do
            table.insert(filterList, child)
        end
    end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = filterList

    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 2000, rayParams)
    if not result or not result.Instance or not result.Instance:IsA("BasePart") then return end
    local pos = result.Position + result.Normal * 0.5

    if #portals >= 2 then
        destroyPortal(portals[1])
        table.remove(portals, 1)
    end

    local newPortal = createPortal(pos)
    table.insert(portals, newPortal)
    lastPlaceTime = tick()
    playTeleportSound()
end

local function createTeleportEffect(position)
    local effectFolder = Instance.new("Folder")
    effectFolder.Parent = workspace
    effectFolder.Name = "TeleportEffect"
    for i = 1, 20 do
        local p = Instance.new("Part")
        p.Shape = Enum.PartType.Ball
        p.Size = Vector3.new(0.4, 0.4, 0.4)
        p.Anchored = true
        p.CanCollide = false
        p.CanTouch = false
        p.CanQuery = false
        p.Massless = true
        p.Material = Enum.Material.Neon
        p.Color = Color3.fromHSV(math.random() * 0.2 + 0.72, 1, 1)
        p.Transparency = 0.2
        p.Position = position
        p.Parent = effectFolder
        local light = Instance.new("PointLight")
        light.Color = p.Color
        light.Range = 6
        light.Brightness = 3
        light.Parent = p
        local dir = Vector3.new(
            (math.random() - 0.5) * 2,
            math.random() * 1.5,
            (math.random() - 0.5) * 2
        ).Unit
        local targetPos = position + dir * (5 + math.random() * 5)
        TweenService:Create(p, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = targetPos,
            Transparency = 1,
            Size = Vector3.new(0.05, 0.05, 0.05),
        }):Play()
        task.delay(0.9, function()
            if p and p.Parent then
                p:Destroy()
            end
        end)
    end
    task.delay(1.2, function()
        if effectFolder and effectFolder.Parent then
            effectFolder:Destroy()
        end
    end)
end

local lastTeleport = 0

RunService.RenderStepped:Connect(function(dt)
    if #portals == 0 then return end
    for _, portal in pairs(portals) do
        portal.t = portal.t + dt
        portal.openProgress = math.min(1, (tick() - portal.spawnTime) / 1.2)
        local openScale = portal.openProgress
        local pulse = 0.5 + 0.5 * math.sin(portal.t * 3)
        local rot = portal.t * 2
        local fastRot = portal.t * 4
        local slowRot = -portal.t * 1.3
        local pulseScale = 1 + pulse * 0.12
        local finalScale = openScale * pulseScale
        portal.outerRing.CFrame = CFrame.new(portal.position) * CFrame.Angles(0, 0, math.rad(90)) * CFrame.Angles(slowRot, 0, 0)
        portal.outerRing.Size = Vector3.new(0.4, PORTAL_RADIUS * 2.2 * finalScale, PORTAL_RADIUS * 2.2 * finalScale)
        portal.ring1.CFrame = CFrame.new(portal.position) * CFrame.Angles(0, 0, math.rad(90)) * CFrame.Angles(rot, 0, 0)
        portal.ring1.Size = Vector3.new(0.35, PORTAL_RADIUS * 2 * finalScale, PORTAL_RADIUS * 2 * finalScale)
        portal.ring2.CFrame = CFrame.new(portal.position) * CFrame.Angles(0, 0, math.rad(90)) * CFrame.Angles(-fastRot, 0, 0)
        portal.ring2.Size = Vector3.new(0.25, PORTAL_RADIUS * 1.75 * finalScale, PORTAL_RADIUS * 1.75 * finalScale)
        portal.ring3.CFrame = CFrame.new(portal.position) * CFrame.Angles(0, 0, math.rad(90)) * CFrame.Angles(fastRot * 1.8, 0, 0)
        portal.ring3.Size = Vector3.new(0.18, PORTAL_RADIUS * 1.4 * finalScale, PORTAL_RADIUS * 1.4 * finalScale)
        local spherePulse = 1 + math.sin(portal.t * 5) * 0.08
        portal.coreSphere.Size = Vector3.new(
            PORTAL_RADIUS * 1.9 * finalScale * spherePulse,
            PORTAL_RADIUS * 1.9 * finalScale * spherePulse,
            PORTAL_RADIUS * 1.9 * finalScale * spherePulse
        )
        portal.darkCore.Size = Vector3.new(
            PORTAL_RADIUS * 1.3 * finalScale,
            PORTAL_RADIUS * 1.3 * finalScale,
            PORTAL_RADIUS * 1.3 * finalScale
        )
        portal.innerCore.Size = Vector3.new(
            PORTAL_RADIUS * 0.7 * finalScale * (1 + math.sin(portal.t * 8) * 0.15),
            PORTAL_RADIUS * 0.7 * finalScale * (1 + math.sin(portal.t * 8) * 0.15),
            PORTAL_RADIUS * 0.7 * finalScale * (1 + math.sin(portal.t * 8) * 0.15)
        )
        local hueShift = (portal.t * 0.15) % 1
        local colorMain = Color3.fromHSV(0.75 + hueShift * 0.1, 1, 1)
        local colorSecondary = Color3.fromHSV(0.72 + hueShift * 0.1, 0.9, 0.7)
        portal.outerRing.Color = colorMain
        portal.outerLight.Color = colorMain
        portal.outerLight.Brightness = (4 + pulse * 4) * openScale
        portal.ring1.Color = colorMain
        portal.ring2.Color = colorSecondary
        portal.ring3.Color = Color3.fromRGB(200, 130, 255)
        portal.coreLight.Color = colorMain
        portal.coreLight.Brightness = (5 + pulse * 5) * openScale
        portal.beam.Color = ColorSequence.new(colorMain)
        portal.beam.Width0 = 0.3 * openScale
        portal.beam.Width1 = 0.3 * openScale
        portal.beam.Transparency = NumberSequence.new(0.3 + (1 - openScale) * 0.7)
        for _, spark in ipairs(portal.particles) do
            local pullPhase = (portal.t * spark.speed + spark.pullPhase) % 1
            local pullRadius = spark.radius * (1 - pullPhase * 0.9)
            local sparkAngle = spark.angle + portal.t * 2
            local x = math.cos(sparkAngle) * pullRadius * openScale
            local z = math.sin(sparkAngle) * pullRadius * openScale
            local y = spark.height + math.sin(portal.t * 3 + spark.basePhase) * 0.5
            spark.part.CFrame = CFrame.new(portal.position + Vector3.new(x, y, z))
            spark.part.Transparency = 0.1 + pullPhase * 0.7
            local sparkScale = (1 - pullPhase * 0.7) * openScale
            spark.part.Size = Vector3.new(0.25 * sparkScale, 0.25 * sparkScale, 0.25 * sparkScale)
        end
    end
    if #portals < 2 then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local now = tick()
    if now - lastTeleport < 0.8 then return end
    for i, portal in pairs(portals) do
        if portal.openProgress < 0.6 then continue end
        local dist = (hrp.Position - portal.position).Magnitude
        if dist < PORTAL_RADIUS + 0.5 then
            local otherIndex = (i == 1) and 2 or 1
            local other = portals[otherIndex]
            if other and other.openProgress > 0.5 then
                local teleportPos = other.position + Vector3.new(0, PORTAL_RADIUS + 1, 0)
                hrp.CFrame = CFrame.new(teleportPos)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                lastTeleport = now
                playTeleportSound()
                createTeleportEffect(other.position)
                createTeleportEffect(portal.position)
                break
            end
        end
    end
end)

local meteorEnabled = false
local meteorBtn = nil
local meteorRunning = false

local METEOR_COOLDOWN = 25
local lastMeteorUse = -999

local buffEnabled = false
local buffBtn = nil
local buffRunning = false
local buffActive = false
local buffLockedUntil = 0

local BUFF_COOLDOWN = 35
local BUFF_DURATION = 15
local BUFF_SPEED = 25
local BUFF_DEFAULT_SPEED = 16
local BUFF_HEALTH_COST = 30
local BUFF_LOCK_AFTER = 3
local meteorLockedUntil = 0

local function createCrater(pos)
    local craterFolder = Instance.new("Folder")
    craterFolder.Name = "MeteorCrater"
    craterFolder.Parent = workspace
    for i = 1, 16 do
        local angle = (i / 16) * math.pi * 2
        local length = 3 + math.random() * 6
        local crack = Instance.new("Part")
        crack.Size = Vector3.new(length, 0.15, 0.4)
        crack.Anchored = true
        crack.CanCollide = false
        crack.CanTouch = false
        crack.CanQuery = false
        crack.Massless = true
        crack.Material = Enum.Material.Neon
        crack.Color = Color3.fromRGB(60, 10, 5)
        crack.Transparency = 0.2
        crack.Parent = craterFolder
        crack.CFrame = CFrame.new(pos + Vector3.new(math.cos(angle) * length / 2, 0.1, math.sin(angle) * length / 2)) * CFrame.Angles(0, -angle, 0)
    end
    for i = 1, 30 do
        local angle = math.random() * math.pi * 2
        local distance = 2 + math.random() * 12
        local shard = Instance.new("Part")
        shard.Shape = Enum.PartType.Block
        shard.Size = Vector3.new(math.random() * 6 + 2, math.random() * 6 + 2, math.random() * 6 + 2)
        shard.Anchored = true
        shard.CanCollide = false
        shard.CanTouch = false
        shard.CanQuery = false
        shard.Massless = true
        shard.Material = Enum.Material.Neon
        shard.Color = Color3.fromRGB(math.random(80, 200), math.random(20, 70), math.random(5, 30))
        shard.Transparency = 0.15
        shard.Parent = craterFolder
        shard.CFrame = CFrame.new(pos + Vector3.new(math.cos(angle) * distance, 0.5, math.sin(angle) * distance)) * CFrame.Angles(math.random() * 3, math.random() * 3, math.random() * 3)
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255, 80, 20)
        light.Range = 6
        light.Brightness = 2
        light.Parent = shard
    end
    local lightPart = Instance.new("Part")
    lightPart.Size = Vector3.new(0.1, 0.1, 0.1)
    lightPart.Anchored = true
    lightPart.CanCollide = false
    lightPart.CanTouch = false
    lightPart.CanQuery = false
    lightPart.Transparency = 1
    lightPart.Parent = craterFolder
    lightPart.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
    local craterLight = Instance.new("PointLight")
    craterLight.Color = Color3.fromRGB(255, 100, 30)
    craterLight.Range = 30
    craterLight.Brightness = 5
    craterLight.Parent = lightPart
    return craterFolder
end

local function runMeteor()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local lockedPos = hrp.Position
    local randomAngle = math.random() * math.pi * 2
    local targetPos = lockedPos + Vector3.new(
        math.cos(randomAngle) * 25,
        0,
        math.sin(randomAngle) * 25
    )
    local startPos = targetPos + Vector3.new(
        (math.random() - 0.5) * 300,
        300,
        (math.random() - 0.5) * 300
    )
    local meteorFolder = Instance.new("Folder")
    meteorFolder.Name = "Meteor"
    meteorFolder.Parent = workspace
    local meteorCenter = Instance.new("Part")
    meteorCenter.Size = Vector3.new(1, 1, 1)
    meteorCenter.Anchored = true
    meteorCenter.CanCollide = false
    meteorCenter.CanTouch = false
    meteorCenter.CanQuery = false
    meteorCenter.Massless = true
    meteorCenter.Transparency = 1
    meteorCenter.Parent = meteorFolder
    meteorCenter.CFrame = CFrame.new(startPos)
    local cubeCount = 600
    local cubes = {}
    for i = 1, cubeCount do
        local isMagma = i > cubeCount * 0.65
        local cube = Instance.new("Part")
        cube.Shape = Enum.PartType.Block
        cube.Anchored = true
        cube.CanCollide = false
        cube.CanTouch = false
        cube.CanQuery = false
        cube.Massless = true
        local size
        local offset
        local distFromCenter
        if isMagma then
            size = math.random() * 1.8 + 0.6
            local angle = math.random() * math.pi * 2
            local phi = math.random() * math.pi
            distFromCenter = 9 + math.random() * 4
            offset = Vector3.new(
                math.sin(phi) * math.cos(angle) * distFromCenter,
                math.sin(phi) * math.sin(angle) * distFromCenter,
                math.cos(phi) * distFromCenter
            )
        else
            size = math.random() * 5 + 1.5
            local angle = math.random() * math.pi * 2
            local phi = math.random() * math.pi
            distFromCenter = math.random() * 8
            offset = Vector3.new(
                math.sin(phi) * math.cos(angle) * distFromCenter,
                math.sin(phi) * math.sin(angle) * distFromCenter,
                math.cos(phi) * distFromCenter
            )
        end
        cube.Size = Vector3.new(size, size, size)
        if isMagma then
            cube.Material = Enum.Material.Neon
            local heat = math.random()
            cube.Color = Color3.fromRGB(
                255,
                math.floor(70 + heat * 130),
                math.floor(5 + heat * 50)
            )
            cube.Transparency = 0.02 + math.random() * 0.08
            local magmaLight = Instance.new("PointLight")
            magmaLight.Color = Color3.fromRGB(255, 120, 30)
            magmaLight.Range = 8
            magmaLight.Brightness = 2.5
            magmaLight.Parent = cube
        else
            cube.Material = Enum.Material.Slate
            local rock = math.random()
            if rock > 0.66 then
                cube.Color = Color3.fromRGB(35, 25, 20)
            elseif rock > 0.33 then
                cube.Color = Color3.fromRGB(55, 40, 30)
            else
                cube.Color = Color3.fromRGB(75, 55, 40)
            end
            cube.Transparency = 0.05 + math.random() * 0.15
            if math.random() > 0.8 then
                local emberLight = Instance.new("PointLight")
                emberLight.Color = Color3.fromRGB(255, 70, 15)
                emberLight.Range = 5
                emberLight.Brightness = 1.5
                emberLight.Parent = cube
            end
        end
        cube.Parent = meteorFolder
        table.insert(cubes, {
            part = cube,
            offset = offset,
            isMagma = isMagma,
            baseSize = size,
            spin = Vector3.new(
                math.random() * 2 - 1,
                math.random() * 2 - 1,
                math.random() * 2 - 1
            ) * 2,
        })
    end
    local corePart = Instance.new("Part")
    corePart.Shape = Enum.PartType.Ball
    corePart.Size = Vector3.new(12, 12, 12)
    corePart.Anchored = true
    corePart.CanCollide = false
    corePart.CanTouch = false
    corePart.CanQuery = false
    corePart.Massless = true
    corePart.Material = Enum.Material.Neon
    corePart.Color = Color3.fromRGB(255, 140, 40)
    corePart.Transparency = 0.25
    corePart.Parent = meteorFolder
    local coreLight = Instance.new("PointLight")
    coreLight.Color = Color3.fromRGB(255, 100, 30)
    coreLight.Range = 40
    coreLight.Brightness = 8
    coreLight.Parent = corePart
    local smokeParticles = {}
    for i = 1, 50 do
        local smoke = Instance.new("Part")
        smoke.Shape = Enum.PartType.Ball
        smoke.Size = Vector3.new(math.random() * 3 + 1, math.random() * 3 + 1, math.random() * 3 + 1)
        smoke.Anchored = true
        smoke.CanCollide = false
        smoke.CanTouch = false
        smoke.CanQuery = false
        smoke.Massless = true
        smoke.Material = Enum.Material.SmoothPlastic
        smoke.Color = Color3.fromRGB(math.random(30, 60), math.random(25, 50), math.random(20, 45))
        smoke.Transparency = 0.5
        smoke.Parent = meteorFolder
        table.insert(smokeParticles, {
            part = smoke,
            offset = Vector3.new(
                (math.random() - 0.5) * 35,
                (math.random() - 0.5) * 35,
                (math.random() - 0.5) * 35
            ),
            drift = Vector3.new(
                (math.random() - 0.5) * 6,
                math.random() * 4 + 2,
                (math.random() - 0.5) * 6
            ),
            life = 0,
            maxLife = 1 + math.random(),
        })
    end
    local trailAttach0 = Instance.new("Attachment")
    trailAttach0.Position = Vector3.new(0, 10, 0)
    trailAttach0.Parent = meteorCenter
    local trailAttach1 = Instance.new("Attachment")
    trailAttach1.Position = Vector3.new(0, -10, 0)
    trailAttach1.Parent = meteorCenter
    local meteorTrail = Instance.new("Trail")
    meteorTrail.Attachment0 = trailAttach0
    meteorTrail.Attachment1 = trailAttach1
    meteorTrail.Lifetime = 1.8
    meteorTrail.MinLength = 0
    meteorTrail.WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 2.5),
        NumberSequenceKeypoint.new(0.4, 1.5),
        NumberSequenceKeypoint.new(1, 0),
    })
    meteorTrail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 250, 180)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 150, 40)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(220, 60, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 10, 5)),
    })
    meteorTrail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 1),
    })
    meteorTrail.LightEmission = 1
    meteorTrail.LightInfluence = 0
    meteorTrail.FaceCamera = true
    meteorTrail.Parent = meteorCenter
    local oldCameraType = camera.CameraType
    local oldCameraSubject = camera.CameraSubject
    camera.CameraType = Enum.CameraType.Scriptable
    local flightTime = 2.5
    local elapsed = 0
    local shakeTime = 0
    while elapsed < flightTime do
        local dt = RunService.RenderStepped:Wait()
        elapsed = elapsed + dt
        local t = elapsed / flightTime
        local easeT = t * t
        local currentPos = startPos:Lerp(targetPos, easeT)
        local dir = (targetPos - currentPos)
        if dir.Magnitude > 0.1 then
            meteorCenter.CFrame = CFrame.lookAt(currentPos, currentPos + dir.Unit)
        else
            meteorCenter.CFrame = CFrame.new(currentPos)
        end
        corePart.CFrame = CFrame.new(currentPos)
        local corePulse = 12 + math.sin(elapsed * 10) * 1.5
        corePart.Size = Vector3.new(corePulse, corePulse, corePulse)
        for _, c in ipairs(cubes) do
            local rotatedOffset = meteorCenter.CFrame:VectorToWorldSpace(c.offset)
            if c.isMagma then
                local wobble = 1 + math.sin(elapsed * 8 + c.offset.X) * 0.2
                local s = c.baseSize * wobble
                c.part.Size = Vector3.new(s, s, s)
            end
            c.part.CFrame = CFrame.new(currentPos + rotatedOffset) * CFrame.Angles(
                elapsed * c.spin.X,
                elapsed * c.spin.Y,
                elapsed * c.spin.Z
            )
        end
        for _, s in ipairs(smokeParticles) do
            s.life = s.life + dt
            if s.life >= s.maxLife then
                s.life = 0
                s.maxLife = 0.5 + math.random()
                s.offset = Vector3.new(
                    (math.random() - 0.5) * 35,
                    (math.random() - 0.5) * 35,
                    (math.random() - 0.5) * 35
                )
            end
            local progress = s.life / s.maxLife
            local smokePos = currentPos + s.offset + s.drift * s.life
            local scaledSize = 4 - progress * 3
            s.part.Size = Vector3.new(scaledSize, scaledSize, scaledSize)
            s.part.Transparency = 0.4 + progress * 0.6
            s.part.CFrame = CFrame.new(smokePos)
        end
        local camPos = currentPos + Vector3.new(40, 25, 40)
        camera.CFrame = CFrame.lookAt(camPos, currentPos)
        if elapsed > flightTime - 1 then
            shakeTime = shakeTime + dt
            local shakeAmount = (shakeTime / 1) * 0.9
            camera.CFrame = camera.CFrame * CFrame.Angles(
                (math.random() - 0.5) * shakeAmount,
                (math.random() - 0.5) * shakeAmount,
                (math.random() - 0.5) * shakeAmount
            )
        end
    end
    for _, c in ipairs(cubes) do
        if c.part then
            c.part.CFrame = CFrame.new(targetPos + c.offset * 0.7) * CFrame.Angles(
                math.random() * 6,
                math.random() * 6,
                math.random() * 6
            )
        end
    end
    corePart.CFrame = CFrame.new(targetPos + Vector3.new(0, -4, 0))
    corePart.Size = Vector3.new(10, 10, 10)
    camera.CFrame = camera.CFrame * CFrame.Angles(
        (math.random() - 0.5) * 1.8,
        (math.random() - 0.5) * 1.8,
        (math.random() - 0.5) * 1.8
    )
    createCrater(targetPos)
    local blackGui = Instance.new("ScreenGui")
    blackGui.Name = "MeteorBlack"
    blackGui.ResetOnSpawn = false
    blackGui.IgnoreGuiInset = true
    blackGui.DisplayOrder = 99999
    blackGui.Parent = player:WaitForChild("PlayerGui")
    local blackFrame = Instance.new("Frame")
    blackFrame.Size = UDim2.fromScale(1, 1)
    blackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blackFrame.BackgroundTransparency = 0
    blackFrame.BorderSizePixel = 0
    blackFrame.Parent = blackGui
    task.wait(2)
    TweenService:Create(blackFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1,
    }):Play()
    task.wait(0.9)
    blackGui:Destroy()
    camera.CameraType = oldCameraType
    camera.CameraSubject = oldCameraSubject
    task.wait(0.3)
    meteorFolder:Destroy()
end

local function runBuffCamera(duration, onFinish)
    local char = player.Character
    if not char then
        if onFinish then onFinish() end
        return
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        if onFinish then onFinish() end
        return
    end

    local oldType = camera.CameraType
    local oldSubject = camera.CameraSubject
    local torsoPos = hrp.Position + Vector3.new(0, 1.5, 0)

    camera.CameraType = Enum.CameraType.Scriptable

    task.spawn(function()
        local elapsed = 0
        local ok, err = pcall(function()
            while elapsed < duration do
                local dt = RunService.RenderStepped:Wait()
                elapsed = elapsed + dt
                local t = math.min(1, elapsed / duration)

                local startAngle = math.rad(45)
                local endAngle = math.rad(-45)
                local angle = startAngle + (endAngle - startAngle) * t
                local radius = 5 + t * 5

                local offset = Vector3.new(
                    math.cos(angle) * radius,
                    2,
                    math.sin(angle) * radius
                )
                local camPos = torsoPos + offset

                camera.CFrame = CFrame.lookAt(camPos, torsoPos)
            end
        end)

        camera.CameraType = oldType
        camera.CameraSubject = oldSubject

        if not ok then
            warn("Buff camera error:", err)
        end

        if onFinish then onFinish() end
    end)
end

local function triggerBuff()
    if buffRunning then return end
    if not buffEnabled then return end
    if tick() < buffLockedUntil then return end
    if tick() < meteorLockedUntil then return end
    if meteorRunning then return end

    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    buffRunning = true
    buffActive = true
    hum.WalkSpeed = 0

    triggerAuraPulse()

    local totalDuration = 0.05 + 0.3 + 0.7 + 0.3

    runBuffCamera(totalDuration, function()
        local c = player.Character
        if c then
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then
                h.Health = h.Health - BUFF_HEALTH_COST
                h.WalkSpeed = BUFF_SPEED
            end
        end

        buffLockedUntil = tick() + BUFF_COOLDOWN
        meteorLockedUntil = tick() + BUFF_LOCK_AFTER

        task.delay(BUFF_DURATION, function()
            local c2 = player.Character
            if c2 then
                local h2 = c2:FindFirstChildOfClass("Humanoid")
                if h2 then
                    h2.WalkSpeed = BUFF_DEFAULT_SPEED
                end
            end
            buffActive = false
        end)

        buffRunning = false
    end)
end

local settings = { Rain = true, Aura = true, Halo = true, Trails = true, Portal = false, Meteor = false, Buff = false }

local pg = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RainSettingsGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 100
screenGui.Parent = pg

local BTN_HEIGHT = 52
local PADDING = 10
local HEADER_HEIGHT = 56
local NUM_BUTTONS = 8
local FRAME_WIDTH = 320

local contentHeight = 4 + 12 + NUM_BUTTONS * BTN_HEIGHT + (NUM_BUTTONS - 1) * PADDING
local MAX_SCREEN_HEIGHT_RATIO = 0.75
local screenHeight = camera.ViewportSize.Y
local maxFrameHeight = math.floor(screenHeight * MAX_SCREEN_HEIGHT_RATIO)
local desiredFrameHeight = HEADER_HEIGHT + contentHeight + 24
local finalFrameHeight = math.min(desiredFrameHeight, maxFrameHeight)
local finalListHeight = finalFrameHeight - HEADER_HEIGHT - 24

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Position = UDim2.new(0, 100, 0, 120)
toggleBtn.Size = UDim2.new(0, 52, 0, 52)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "⚙"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 24
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.AutoButtonColor = false
toggleBtn.Active = true
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 14)
toggleCorner.Parent = toggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Thickness = 2
toggleStroke.Color = Color3.fromRGB(255, 255, 255)
toggleStroke.Transparency = 0.2
toggleStroke.Parent = toggleBtn

local toggleGrad = Instance.new("UIGradient")
toggleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 200, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 80, 255)),
})
toggleGrad.Rotation = 45
toggleGrad.Parent = toggleStroke

local portalBtn = Instance.new("TextButton")
portalBtn.Name = "PortalBtn"
portalBtn.AnchorPoint = Vector2.new(1, 0.5)
portalBtn.Position = UDim2.new(1, -20, 0.5, 0)
portalBtn.Size = UDim2.new(0, 70, 0, 70)
portalBtn.BackgroundColor3 = Color3.fromRGB(70, 20, 130)
portalBtn.BackgroundTransparency = 0.1
portalBtn.BorderSizePixel = 0
portalBtn.Text = "🌀"
portalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
portalBtn.TextSize = 34
portalBtn.Font = Enum.Font.GothamBold
portalBtn.AutoButtonColor = false
portalBtn.Visible = false
portalBtn.Parent = screenGui

local portalBtnCorner = Instance.new("UICorner")
portalBtnCorner.CornerRadius = UDim.new(0, 20)
portalBtnCorner.Parent = portalBtn

local portalBtnStroke = Instance.new("UIStroke")
portalBtnStroke.Thickness = 2.5
portalBtnStroke.Color = PORTAL_COLOR_A
portalBtnStroke.Transparency = 0.2
portalBtnStroke.Parent = portalBtn

local portalBtnGrad = Instance.new("UIGradient")
portalBtnGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, PORTAL_COLOR_A),
    ColorSequenceKeypoint.new(1, PORTAL_COLOR_B),
})
portalBtnGrad.Rotation = 45
portalBtnGrad.Parent = portalBtnStroke

local portalBtnLabel = Instance.new("TextLabel")
portalBtnLabel.AnchorPoint = Vector2.new(0.5, 1)
portalBtnLabel.Position = UDim2.new(0.5, 0, 1, -4)
portalBtnLabel.Size = UDim2.new(1, 0, 0, 14)
portalBtnLabel.BackgroundTransparency = 1
portalBtnLabel.Text = "STANDBY"
portalBtnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
portalBtnLabel.TextScaled = true
portalBtnLabel.Font = Enum.Font.GothamBold
portalBtnLabel.Parent = portalBtn

local meteorBtnUi = Instance.new("TextButton")
meteorBtnUi.Name = "MeteorBtn"
meteorBtnUi.AnchorPoint = Vector2.new(1, 0.5)
meteorBtnUi.Position = UDim2.new(1, -20, 0.5, -90)
meteorBtnUi.Size = UDim2.new(0, 70, 0, 70)
meteorBtnUi.BackgroundColor3 = Color3.fromRGB(90, 30, 10)
meteorBtnUi.BackgroundTransparency = 0.1
meteorBtnUi.BorderSizePixel = 0
meteorBtnUi.Text = "🪨"
meteorBtnUi.TextColor3 = Color3.fromRGB(255, 255, 255)
meteorBtnUi.TextSize = 34
meteorBtnUi.Font = Enum.Font.GothamBold
meteorBtnUi.AutoButtonColor = false
meteorBtnUi.Visible = false
meteorBtnUi.Parent = screenGui

local meteorBtnUiCorner = Instance.new("UICorner")
meteorBtnUiCorner.CornerRadius = UDim.new(0, 20)
meteorBtnUiCorner.Parent = meteorBtnUi

local meteorBtnUiStroke = Instance.new("UIStroke")
meteorBtnUiStroke.Thickness = 2.5
meteorBtnUiStroke.Color = Color3.fromRGB(255, 120, 40)
meteorBtnUiStroke.Transparency = 0.2
meteorBtnUiStroke.Parent = meteorBtnUi

local meteorBtnUiGrad = Instance.new("UIGradient")
meteorBtnUiGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 50, 20)),
})
meteorBtnUiGrad.Rotation = 45
meteorBtnUiGrad.Parent = meteorBtnUiStroke

local meteorBtnUiLabel = Instance.new("TextLabel")
meteorBtnUiLabel.AnchorPoint = Vector2.new(0.5, 1)
meteorBtnUiLabel.Position = UDim2.new(0.5, 0, 1, -4)
meteorBtnUiLabel.Size = UDim2.new(1, 0, 0, 14)
meteorBtnUiLabel.BackgroundTransparency = 1
meteorBtnUiLabel.Text = "METEOR"
meteorBtnUiLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
meteorBtnUiLabel.TextScaled = true
meteorBtnUiLabel.Font = Enum.Font.GothamBold
meteorBtnUiLabel.Parent = meteorBtnUi

local meteorCooldownLabel = Instance.new("TextLabel")
meteorCooldownLabel.AnchorPoint = Vector2.new(0.5, 0.5)
meteorCooldownLabel.Position = UDim2.fromScale(0.5, 0.45)
meteorCooldownLabel.Size = UDim2.fromScale(0.8, 0.6)
meteorCooldownLabel.BackgroundTransparency = 1
meteorCooldownLabel.Text = ""
meteorCooldownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
meteorCooldownLabel.TextScaled = true
meteorCooldownLabel.Font = Enum.Font.GothamBold
meteorCooldownLabel.ZIndex = 10
meteorCooldownLabel.Visible = false
meteorCooldownLabel.Parent = meteorBtnUi

local meteorCooldownStroke = Instance.new("UIStroke")
meteorCooldownStroke.Thickness = 2
meteorCooldownStroke.Color = Color3.fromRGB(0, 0, 0)
meteorCooldownStroke.Transparency = 0.3
meteorCooldownStroke.Parent = meteorCooldownLabel

meteorBtn = meteorBtnUi

local buffBtnUi = Instance.new("TextButton")
buffBtnUi.Name = "BuffBtn"
buffBtnUi.AnchorPoint = Vector2.new(1, 0.5)
buffBtnUi.Position = UDim2.new(1, -20, 0.5, -180)
buffBtnUi.Size = UDim2.new(0, 70, 0, 70)
buffBtnUi.BackgroundColor3 = Color3.fromRGB(120, 100, 20)
buffBtnUi.BackgroundTransparency = 0.1
buffBtnUi.BorderSizePixel = 0
buffBtnUi.Text = "⚡"
buffBtnUi.TextColor3 = Color3.fromRGB(255, 255, 255)
buffBtnUi.TextSize = 34
buffBtnUi.Font = Enum.Font.GothamBold
buffBtnUi.AutoButtonColor = false
buffBtnUi.Visible = false
buffBtnUi.Parent = screenGui

local buffBtnUiCorner = Instance.new("UICorner")
buffBtnUiCorner.CornerRadius = UDim.new(0, 20)
buffBtnUiCorner.Parent = buffBtnUi

local buffBtnUiStroke = Instance.new("UIStroke")
buffBtnUiStroke.Thickness = 2.5
buffBtnUiStroke.Color = Color3.fromRGB(255, 230, 80)
buffBtnUiStroke.Transparency = 0.2
buffBtnUiStroke.Parent = buffBtnUi

local buffBtnUiGrad = Instance.new("UIGradient")
buffBtnUiGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 120, 20)),
})
buffBtnUiGrad.Rotation = 45
buffBtnUiGrad.Parent = buffBtnUiStroke

local buffBtnUiLabel = Instance.new("TextLabel")
buffBtnUiLabel.AnchorPoint = Vector2.new(0.5, 1)
buffBtnUiLabel.Position = UDim2.new(0.5, 0, 1, -4)
buffBtnUiLabel.Size = UDim2.new(1, 0, 0, 14)
buffBtnUiLabel.BackgroundTransparency = 1
buffBtnUiLabel.Text = "УСИЛЕНИЕ"
buffBtnUiLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
buffBtnUiLabel.TextScaled = true
buffBtnUiLabel.Font = Enum.Font.GothamBold
buffBtnUiLabel.Parent = buffBtnUi

local buffCooldownLabel = Instance.new("TextLabel")
buffCooldownLabel.AnchorPoint = Vector2.new(0.5, 0.5)
buffCooldownLabel.Position = UDim2.fromScale(0.5, 0.45)
buffCooldownLabel.Size = UDim2.fromScale(0.8, 0.6)
buffCooldownLabel.BackgroundTransparency = 1
buffCooldownLabel.Text = ""
buffCooldownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
buffCooldownLabel.TextScaled = true
buffCooldownLabel.Font = Enum.Font.GothamBold
buffCooldownLabel.ZIndex = 10
buffCooldownLabel.Visible = false
buffCooldownLabel.Parent = buffBtnUi

local buffCooldownStroke = Instance.new("UIStroke")
buffCooldownStroke.Thickness = 2
buffCooldownStroke.Color = Color3.fromRGB(0, 0, 0)
buffCooldownStroke.Transparency = 0.3
buffCooldownStroke.Parent = buffCooldownLabel

buffBtn = buffBtnUi

meteorBtnUi.MouseEnter:Connect(function()
    TweenService:Create(meteorBtnUi, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
end)
meteorBtnUi.MouseLeave:Connect(function()
    if not meteorCooldownLabel.Visible then
        TweenService:Create(meteorBtnUi, TweenInfo.new(0.15), {BackgroundTransparency = 0.1}):Play()
    end
end)

meteorBtnUi.MouseButton1Click:Connect(function()
    if not meteorEnabled or meteorRunning then return end
    if tick() < buffLockedUntil then return end
    local now = tick()
    if now - lastMeteorUse < METEOR_COOLDOWN then return end
    lastMeteorUse = now
    meteorRunning = true
    pcall(function()
        runMeteor()
    end)
    meteorRunning = false
    buffLockedUntil = tick() + BUFF_LOCK_AFTER
end)

task.spawn(function()
    while meteorBtnUi.Parent do
        task.wait(0.05)
        local remaining = METEOR_COOLDOWN - (tick() - lastMeteorUse)
        if remaining > 0 and remaining <= METEOR_COOLDOWN then
            meteorBtnUi.Text = ""
            meteorCooldownLabel.Visible = true
            meteorCooldownLabel.Text = tostring(math.ceil(remaining))
            meteorBtnUi.BackgroundColor3 = Color3.fromRGB(50, 20, 10)
            meteorBtnUi.BackgroundTransparency = 0.35
        else
            if meteorCooldownLabel.Visible then
                meteorCooldownLabel.Visible = false
                meteorBtnUi.Text = "🪨"
                meteorBtnUi.BackgroundColor3 = Color3.fromRGB(90, 30, 10)
                meteorBtnUi.BackgroundTransparency = 0.1
            end
        end
    end
end)

buffBtnUi.MouseEnter:Connect(function()
    TweenService:Create(buffBtnUi, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
end)
buffBtnUi.MouseLeave:Connect(function()
    if not buffCooldownLabel.Visible then
        TweenService:Create(buffBtnUi, TweenInfo.new(0.15), {BackgroundTransparency = 0.1}):Play()
    end
end)

buffBtnUi.MouseButton1Click:Connect(function()
    triggerBuff()
end)

task.spawn(function()
    while buffBtnUi.Parent do
        task.wait(0.05)
        local remaining = buffLockedUntil - tick()
        if remaining > 0 then
            buffBtnUi.Text = ""
            buffCooldownLabel.Visible = true
            buffCooldownLabel.Text = tostring(math.ceil(remaining))
            buffBtnUi.BackgroundColor3 = Color3.fromRGB(60, 50, 10)
            buffBtnUi.BackgroundTransparency = 0.35
        else
            if buffCooldownLabel.Visible then
                buffCooldownLabel.Visible = false
                buffBtnUi.Text = "⚡"
                buffBtnUi.BackgroundColor3 = Color3.fromRGB(120, 100, 20)
                buffBtnUi.BackgroundTransparency = 0.1
            end
        end
    end
end)

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.Size = UDim2.new(0, FRAME_WIDTH, 0, finalFrameHeight)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 18)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2
mainStroke.Color = Color3.fromRGB(255, 255, 255)
mainStroke.Transparency = 0.3
mainStroke.Parent = mainFrame

local mainGrad = Instance.new("UIGradient")
mainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 180)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(100, 200, 255)),
    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(180, 80, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 255, 200)),
})
mainGrad.Rotation = 45
mainGrad.Parent = mainStroke

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
header.BackgroundTransparency = 0.4
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 18)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 20)
headerFix.Position = UDim2.new(0, 0, 1, -20)
headerFix.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
headerFix.BackgroundTransparency = 0.4
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local iconBox = Instance.new("Frame")
iconBox.AnchorPoint = Vector2.new(0, 0.5)
iconBox.Position = UDim2.new(0, 16, 0.5, 0)
iconBox.Size = UDim2.new(0, 32, 0, 32)
iconBox.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
iconBox.BackgroundTransparency = 0.2
iconBox.BorderSizePixel = 0
iconBox.Parent = header

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 10)
iconCorner.Parent = iconBox

local iconLbl = Instance.new("TextLabel")
iconLbl.Size = UDim2.new(1, 0, 1, 0)
iconLbl.BackgroundTransparency = 1
iconLbl.Text = "🌧"
iconLbl.TextScaled = true
iconLbl.Font = Enum.Font.GothamBold
iconLbl.Parent = iconBox

local title = Instance.new("TextLabel")
title.AnchorPoint = Vector2.new(0, 0.5)
title.Position = UDim2.new(0, 60, 0.5, -4)
title.Size = UDim2.new(1, -120, 0, 22)
title.BackgroundTransparency = 1
title.Text = "Rain Visual"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.AnchorPoint = Vector2.new(0, 0.5)
subtitle.Position = UDim2.new(0, 60, 0.5, 14)
subtitle.Size = UDim2.new(1, -120, 0, 14)
subtitle.BackgroundTransparency = 1
subtitle.Text = "settings"
subtitle.TextColor3 = Color3.fromRGB(140, 140, 180)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextSize = 11
subtitle.Font = Enum.Font.Gotham
subtitle.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.AnchorPoint = Vector2.new(1, 0.5)
closeBtn.Position = UDim2.new(1, -16, 0.5, 0)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 70)
closeBtn.BackgroundTransparency = 0.1
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 15
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeBtn

local listFrame = Instance.new("ScrollingFrame")
listFrame.Name = "ListFrame"
listFrame.Position = UDim2.new(0, 14, 0, HEADER_HEIGHT + 12)
listFrame.Size = UDim2.new(1, -28, 0, finalListHeight)
listFrame.BackgroundTransparency = 1
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 5
listFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 180, 255)
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
listFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, PADDING)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = listFrame

local listPad = Instance.new("UIPadding")
listPad.PaddingTop = UDim.new(0, 4)
listPad.PaddingBottom = UDim.new(0, 12)
listPad.Parent = listFrame

local function makeToggle(name, icon, key, initial, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, BTN_HEIGHT)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    btn.BackgroundTransparency = 0.1
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = listFrame
    local bC = Instance.new("UICorner")
    bC.CornerRadius = UDim.new(0, 12)
    bC.Parent = btn
    local bS = Instance.new("UIStroke")
    bS.Thickness = 1.5
    bS.Color = Color3.fromRGB(150, 180, 255)
    bS.Transparency = 0.6
    bS.Parent = btn
    local iB = Instance.new("Frame")
    iB.AnchorPoint = Vector2.new(0, 0.5)
    iB.Position = UDim2.new(0, 12, 0.5, 0)
    iB.Size = UDim2.new(0, 34, 0, 34)
    iB.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    iB.BackgroundTransparency = 0.2
    iB.BorderSizePixel = 0
    iB.Parent = btn
    local iC = Instance.new("UICorner")
    iC.CornerRadius = UDim.new(0, 10)
    iC.Parent = iB
    local iL = Instance.new("TextLabel")
    iL.Size = UDim2.new(1, 0, 1, 0)
    iL.BackgroundTransparency = 1
    iL.Text = icon
    iL.TextScaled = true
    iL.Font = Enum.Font.GothamBold
    iL.Parent = iB
    local lbl = Instance.new("TextLabel")
    lbl.AnchorPoint = Vector2.new(0, 0.5)
    lbl.Position = UDim2.new(0, 58, 0.5, 0)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(235, 235, 245)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextSize = 15
    lbl.Font = Enum.Font.GothamMedium
    lbl.Parent = btn
    local sF = Instance.new("Frame")
    sF.AnchorPoint = Vector2.new(1, 0.5)
    sF.Position = UDim2.new(1, -12, 0.5, 0)
    sF.Size = UDim2.new(0, 66, 0, 32)
    sF.BackgroundColor3 = initial and Color3.fromRGB(60, 180, 100) or Color3.fromRGB(180, 60, 80)
    sF.BorderSizePixel = 0
    sF.Parent = btn
    local sC = Instance.new("UICorner")
    sC.CornerRadius = UDim.new(0, 10)
    sC.Parent = sF
    local sS = Instance.new("UIStroke")
    sS.Thickness = 1.5
    sS.Color = initial and Color3.fromRGB(120, 255, 160) or Color3.fromRGB(255, 130, 150)
    sS.Transparency = 0.4
    sS.Parent = sF
    local sL = Instance.new("TextLabel")
    sL.Size = UDim2.new(1, 0, 1, 0)
    sL.BackgroundTransparency = 1
    sL.Text = initial and "ON" or "OFF"
    sL.TextColor3 = Color3.fromRGB(255, 255, 255)
    sL.TextSize = 14
    sL.Font = Enum.Font.GothamBold
    sL.Parent = sF
    local state = initial
    local function setState(newState)
        state = newState
        settings[key] = state
        local info = TweenInfo.new(0.25)
        TweenService:Create(sF, info, {BackgroundColor3 = state and Color3.fromRGB(60, 180, 100) or Color3.fromRGB(180, 60, 80)}):Play()
        TweenService:Create(sS, info, {Color = state and Color3.fromRGB(120, 255, 160) or Color3.fromRGB(255, 130, 150)}):Play()
        sL.Text = state and "ON" or "OFF"
        if callback then callback(state) end
    end
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(30, 30, 45)}):Play()
        TweenService:Create(bS, TweenInfo.new(0.15), {Transparency = 0.2}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.1, BackgroundColor3 = Color3.fromRGB(22, 22, 32)}):Play()
        TweenService:Create(bS, TweenInfo.new(0.15), {Transparency = 0.6}):Play()
    end)
    btn.MouseButton1Click:Connect(function() setState(not state) end)
end

local function makeModeToggle(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, BTN_HEIGHT)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    btn.BackgroundTransparency = 0.1
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = listFrame
    local bC = Instance.new("UICorner")
    bC.CornerRadius = UDim.new(0, 12)
    bC.Parent = btn
    local bS = Instance.new("UIStroke")
    bS.Thickness = 1.5
    bS.Color = Color3.fromRGB(100, 200, 255)
    bS.Transparency = 0.5
    bS.Parent = btn
    local iB = Instance.new("Frame")
    iB.AnchorPoint = Vector2.new(0, 0.5)
    iB.Position = UDim2.new(0, 12, 0.5, 0)
    iB.Size = UDim2.new(0, 34, 0, 34)
    iB.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    iB.BackgroundTransparency = 0.2
    iB.BorderSizePixel = 0
    iB.Parent = btn
    local iC = Instance.new("UICorner")
    iC.CornerRadius = UDim.new(0, 10)
    iC.Parent = iB
    local iL = Instance.new("TextLabel")
    iL.Size = UDim2.new(1, 0, 1, 0)
    iL.BackgroundTransparency = 1
    iL.Text = icon
    iL.TextScaled = true
    iL.Font = Enum.Font.GothamBold
    iL.Parent = iB
    local lbl = Instance.new("TextLabel")
    lbl.AnchorPoint = Vector2.new(0, 0.5)
    lbl.Position = UDim2.new(0, 58, 0.5, 0)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(235, 235, 245)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextSize = 15
    lbl.Font = Enum.Font.GothamMedium
    lbl.Parent = btn
    local sF = Instance.new("Frame")
    sF.AnchorPoint = Vector2.new(1, 0.5)
    sF.Position = UDim2.new(1, -12, 0.5, 0)
    sF.Size = UDim2.new(0, 82, 0, 32)
    sF.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    sF.BorderSizePixel = 0
    sF.Parent = btn
    local sC = Instance.new("UICorner")
    sC.CornerRadius = UDim.new(0, 10)
    sC.Parent = sF
    local sS = Instance.new("UIStroke")
    sS.Thickness = 1.5
    sS.Color = Color3.fromRGB(180, 230, 255)
    sS.Transparency = 0.4
    sS.Parent = sF
    local sL = Instance.new("TextLabel")
    sL.Size = UDim2.new(1, 0, 1, 0)
    sL.BackgroundTransparency = 1
    sL.Text = "Rainbow"
    sL.TextColor3 = Color3.fromRGB(255, 255, 255)
    sL.TextSize = 13
    sL.Font = Enum.Font.GothamBold
    sL.Parent = sF
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(30, 30, 45)}):Play()
        TweenService:Create(bS, TweenInfo.new(0.15), {Transparency = 0.2}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.1, BackgroundColor3 = Color3.fromRGB(22, 22, 32)}):Play()
        TweenService:Create(bS, TweenInfo.new(0.15), {Transparency = 0.5}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        local newMode = currentMode == "Rainbow" and "Hacker" or "Rainbow"
        currentMode = newMode
        local info = TweenInfo.new(0.3)
        if newMode == "Rainbow" then
            TweenService:Create(sF, info, {BackgroundColor3 = Color3.fromRGB(100, 200, 255)}):Play()
            TweenService:Create(sS, info, {Color = Color3.fromRGB(180, 230, 255)}):Play()
        else
            TweenService:Create(sF, info, {BackgroundColor3 = Color3.fromRGB(30, 180, 60)}):Play()
            TweenService:Create(sS, info, {Color = Color3.fromRGB(100, 255, 130)}):Play()
        end
        sL.Text = newMode
    end)
end

makeToggle("Дождь + Звук", "🌧", "Rain", true)
makeModeToggle("Система", "💻")
makeToggle("Аура", "✨", "Aura", true)
makeToggle("Нимб", "👑", "Halo", true)
makeToggle("Трейлы", "💫", "Trails", true)
makeToggle("Портал", "🌀", "Portal", false, function(state)
    portalEnabled = state
    portalBtn.Visible = state
    if not state then
        placingMode = false
        portalBtnLabel.Text = "STANDBY"
        portalBtn.BackgroundColor3 = Color3.fromRGB(70, 20, 130)
        clearPortals()
    end
end)
makeToggle("Метеорит", "🪨", "Meteor", false, function(state)
    meteorEnabled = state
    if meteorBtn then
        meteorBtn.Visible = state
    end
end)
makeToggle("Усиление", "⚡", "Buff", false, function(state)
    buffEnabled = state
    if buffBtn then
        buffBtn.Visible = state
    end
end)

portalBtn.MouseButton1Click:Connect(function()
    if not portalEnabled then return end
    placingMode = not placingMode
    if placingMode then
        portalBtnLabel.Text = "PLACING"
        portalBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 240)
    else
        portalBtnLabel.Text = "STANDBY"
        portalBtn.BackgroundColor3 = Color3.fromRGB(70, 20, 130)
    end
end)

portalBtn.MouseEnter:Connect(function()
    TweenService:Create(portalBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
end)

portalBtn.MouseLeave:Connect(function()
    TweenService:Create(portalBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.1}):Play()
end)

task.spawn(function()
    while screenGui.Parent do
        task.wait(0.2)
        rainFolder.Parent = settings.Rain and workspace.CurrentCamera or nil
        rainSound.Playing = settings.Rain
        auraFolder.Parent = settings.Aura and workspace.CurrentCamera or nil
        haloFolder.Parent = settings.Halo and workspace.CurrentCamera or nil
        if currentMode == "Hacker" then
            for _, d in ipairs(dropsFar) do
                local g = math.random(80, 255)
                d.part.Color = Color3.fromRGB(0, g, 0)
                d.speed = d.baseSpeed * 1.5
            end
            for _, d in ipairs(dropsNear) do
                local g = math.random(80, 255)
                d.part.Color = Color3.fromRGB(0, g, 0)
                d.speed = d.baseSpeed * 1.5
            end
        else
            for _, d in ipairs(dropsFar) do
                d.speed = d.baseSpeed
            end
            for _, d in ipairs(dropsNear) do
                d.speed = d.baseSpeed
            end
        end
        for _, a in ipairs(auraParts) do
            if a.trail then a.trail.Enabled = settings.Trails and (currentMode == "Rainbow" or a.hackerAlpha > 0.1) end
        end
        for _, h in ipairs(haloParts) do
            if h.trail then h.trail.Enabled = settings.Trails end
        end
    end
end)

local openState = false
local targetFrameHeight = finalFrameHeight

toggleBtn.MouseButton1Click:Connect(function()
    openState = not openState
    if openState then
        mainFrame.Position = UDim2.fromScale(0.5, 0.5)
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, FRAME_WIDTH, 0, 0)
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, FRAME_WIDTH, 0, targetFrameHeight),
        }):Play()
    else
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, FRAME_WIDTH, 0, 0),
        })
        tween:Play()
        tween.Completed:Connect(function() mainFrame.Visible = false end)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    openState = false
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, FRAME_WIDTH, 0, 0),
    })
    tween:Play()
    tween.Completed:Connect(function() mainFrame.Visible = false end)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not portalEnabled or not placingMode then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        tryPlacePortal(input)
    end
end)

local toggleDrag = false
local toggleDragStart
local toggleStartPos

toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleDrag = true
        toggleDragStart = input.Position
        toggleStartPos = toggleBtn.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if toggleDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - toggleDragStart
        toggleBtn.Position = UDim2.new(toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X, toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleDrag = false
    end
end)

print("Rain Visual + Meteor + Buff loaded")
