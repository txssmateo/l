-- Nina Blind WalkSpeed Test
-- Seven anonymous on-screen options.
-- Internal order (do not show tester):
-- OPTION 1 = 16 upright / 6 crawl
-- OPTION 2 = 16 upright / 6 crawl
-- OPTION 3 = 16.5 upright / 6 crawl
-- OPTION 4 = 16 upright / 6 crawl
-- OPTION 5 = 17 upright / 6 crawl + visual walk/run cadence targeted at 16
-- OPTION 6 = 16 upright / 6 crawl
-- OPTION 7 = 16.5 upright / 6 crawl + visual walk/run cadence targeted at 16

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

if _G.SaintsBlindSpeedTestCleanup then
    pcall(_G.SaintsBlindSpeedTestCleanup)
end

local connections = {}
local humanoid
local shiftHeld = false
local selected = nil

local function add(c)
    table.insert(connections, c)
    return c
end

local function isCrawling(h)
    return h and h.Health > 0 and shiftHeld and h.HipHeight < 0
end

local gui = Instance.new("ScreenGui")
gui.Name = "SaintsBlindWalkSpeedTest"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Choices"
frame.AnchorPoint = Vector2.new(0.5, 1)
frame.Position = UDim2.new(0.5, 0, 1, -55)
frame.Size = UDim2.fromOffset(780, 64)
frame.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
frame.BackgroundTransparency = 0.08
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(75, 75, 82)
stroke.Transparency = 0.25
stroke.Thickness = 1
stroke.Parent = frame

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.Parent = frame

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, 8)
layout.Parent = frame

local buttons = {}

local function makeButton(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(101, 48)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    b.BorderSizePixel = 0
    b.AutoButtonColor = true
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.TextColor3 = Color3.fromRGB(235, 235, 238)
    b.TextSize = 15
    b.Parent = frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 9)
    c.Parent = b

    buttons[#buttons + 1] = b
    return b
end

-- Neutral labels reveal nothing about speed.
local option1 = makeButton("OPTION 1")
local option2 = makeButton("OPTION 2")
local option3 = makeButton("OPTION 3")
local option4 = makeButton("OPTION 4")
local option5 = makeButton("OPTION 5")
local option6 = makeButton("OPTION 6")
local option7 = makeButton("OPTION 7")

local function refreshButtons()
    for i, b in ipairs(buttons) do
        if selected == i then
            b.BackgroundColor3 = Color3.fromRGB(72, 72, 80)
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            b.TextColor3 = Color3.fromRGB(235, 235, 238)
        end
    end
end

local function restoreVisualPace(h)
    -- When leaving Option 3, return active walk/run tracks to normal playback
    -- so its animation correction does not leak into Options 1 or 2.
    local animator = h and h:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            local n = string.lower(track.Name or "")
            if n:find("walk") or n:find("run") then
                pcall(function()
                    track:AdjustSpeed(1)
                end)
            end
        end
    end
end

local apply

local function selectOption(n)
    if (selected == 5 or selected == 7) and n ~= 5 and n ~= 7 and humanoid then
        restoreVisualPace(humanoid)
    end
    selected = n
    refreshButtons()
    if apply then
        apply()
    end
end

option1.MouseButton1Click:Connect(function() selectOption(1) end)
option2.MouseButton1Click:Connect(function() selectOption(2) end)
option3.MouseButton1Click:Connect(function() selectOption(3) end)
option4.MouseButton1Click:Connect(function() selectOption(4) end)
option5.MouseButton1Click:Connect(function() selectOption(5) end)
option6.MouseButton1Click:Connect(function() selectOption(6) end)
option7.MouseButton1Click:Connect(function() selectOption(7) end)

apply = function()
    local h = humanoid
    if not h or not h.Parent or h.Health <= 0 or not selected then return end

    local crawling = isCrawling(h)
    local targetSpeed

    if crawling then
        targetSpeed = 6
    elseif selected == 3 then
        targetSpeed = 16.5
    elseif selected == 5 then
        targetSpeed = 17
    elseif selected == 7 then
        targetSpeed = 16.5
    else
        targetSpeed = 16
    end

    if math.abs(h.WalkSpeed - targetSpeed) > 0.001 then
        h.WalkSpeed = targetSpeed
    end

    -- Options 5 and 7 keep the visible walk/run cadence near the game's normal 16.
    if (selected == 5 or selected == 7) and not crawling and h.MoveDirection.Magnitude > 0.05 then
        local animator = h:FindFirstChildOfClass("Animator")
        if animator then
            local scale = selected == 5 and (16 / 17) or (16 / 16.5)
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local n = string.lower(track.Name or "")
                if n:find("walk") or n:find("run") then
                    pcall(function()
                        track:AdjustSpeed(scale)
                    end)
                end
            end
        end
    end
end

local function bindCharacter(character)
    humanoid = character:WaitForChild("Humanoid")
    task.wait(0.15)
    apply()
end

add(UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        shiftHeld = true
        if apply then apply() end
    end
end))

add(UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        shiftHeld = false
        if apply then apply() end
    end
end))

local accumulator = 0
add(RunService.Heartbeat:Connect(function(dt)
    accumulator += dt
    if accumulator >= 0.05 then
        accumulator = 0
        apply()
    end
end))

if player.Character then
    task.spawn(bindCharacter, player.Character)
end

add(player.CharacterAdded:Connect(bindCharacter))

_G.SaintsBlindSpeedTestCleanup = function()
    if humanoid and humanoid.Parent then
        restoreVisualPace(humanoid)
        humanoid.WalkSpeed = 16
    end

    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(connections)

    if gui then
        gui:Destroy()
    end
end

refreshButtons()
print("Blind WalkSpeed test loaded. Select Option 1 through 7.")
