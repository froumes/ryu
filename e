local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Function to check if we have a current job
local function hasNoCurrentJob()
    local phoneJob = LocalPlayer.PlayerGui.HUD.Main.Phone.Job.CurrentJob
    print("Checking current job: ", phoneJob and phoneJob.Text or "No job found")
    return phoneJob and phoneJob.Text == "None"
end

local function checkAndHandleATMInteraction()
    if hasEnoughCash() then
        print("=== Found ₩1,000,000 - Running ATM Interaction ===")
        wait (10)
        
        local function handleATMInteraction()
            local vim = game:GetService("VirtualInputManager")
            
            -- Press Backslash, S, S, and Enter in sequence
            vim:SendKeyEvent(true, Enum.KeyCode.BackSlash, false, game)  -- Press Backslash down
            wait(0.1)
            vim:SendKeyEvent(false, Enum.KeyCode.BackSlash, false, game)  -- Release Backslash
            wait(0.1)
            
            vim:SendKeyEvent(true, Enum.KeyCode.S, false, game)  -- Press S down
            wait(0.1)
            vim:SendKeyEvent(false, Enum.KeyCode.S, false, game)  -- Release S
            wait(0.1)
            
            vim:SendKeyEvent(true, Enum.KeyCode.S, false, game)  -- Press S down again
            wait(0.1)
            vim:SendKeyEvent(false, Enum.KeyCode.S, false, game)  -- Release S
            wait(0.1)

            vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)  -- Press Enter down
            wait(0.1)
            vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)  -- Release Enter
            wait(0.1)

            -- Press Backslash again
            vim:SendKeyEvent(true, Enum.KeyCode.BackSlash, false, game)  -- Press Backslash down
            wait(0.1)
            vim:SendKeyEvent(false, Enum.KeyCode.BackSlash, false, game)  -- Release Backslash
        end
        
        handleATMInteraction()
    end
end

-- Function to teleport to a position using BodyGyro
local function teleportTo(position, shouldBeGrounded)
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Create or get existing BodyGyro
    local bodyGyro = humanoidRootPart:FindFirstChild("BodyGyro") or Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 5000
    bodyGyro.Parent = humanoidRootPart
    
    -- If shouldBeGrounded, adjust Y position to be on the ground and 4 studs in front
    if shouldBeGrounded then
        -- Assuming posters face outward, move 4 studs away from the wall
        position = Vector3.new(position.X, position.Y - 0, position.Z + 4)
    end
    
    -- Teleport to position
    humanoidRootPart.CFrame = CFrame.new(position)
end

-- Main function to check borders and click delivery posters
local function checkDeliveryPosters()
    -- Only proceed if we don't have a current job
    while hasNoCurrentJob() do  -- Changed to while loop to keep trying while we have no job
        print("No current job - checking delivery posters...")
        -- Get the job borders folder
        local jobBorders = Workspace.Ignore.Interactables.JobsRelated["Job Borders"]
        
        -- Loop through each border
        for _, border in pairs(jobBorders:GetChildren()) do
            if not hasNoCurrentJob() then break end  -- Exit if we got a job
            
            if border.Name == "Border" then
                local postersFolder = border:FindFirstChild("Posters")
                if postersFolder then
                    -- Loop through temp parts in posters
                    for _, tempPart in pairs(postersFolder:GetChildren()) do
                        if not hasNoCurrentJob() then break end  -- Exit if we got a job
                        
                        if tempPart.Name:match("^temp%d+$") then
                            local surfaceGui = tempPart:FindFirstChild("SurfaceGui")
                            if surfaceGui then
                                local info = surfaceGui:FindFirstChild("Info")
                                if info and info:IsA("TextLabel") and string.match(info.Text, "^Deliver") then
                                    -- Spam teleport to the temp part for 1 second
                                    local startTime = tick()
                                    while tick() - startTime < 1 and hasNoCurrentJob() do
                                        teleportTo(tempPart.Position, true)
                                        
                                        -- Try to click the poster
                                        local clickDetector = tempPart:FindFirstChild("ClickDetector")
                                        if clickDetector then
                                            fireclickdetector(clickDetector)
                                        end
                                        
                                        wait()  -- Small wait to prevent crashes
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        wait()  -- Small wait before retrying if we still have no job
    end
end

-- Function to handle delivery locations
local function handleDeliveryLocation()
    if hasNoCurrentJob() then return end
    
    local deliveryAreas = Workspace.Ignore.Interactables.JobsRelated["Delivery Areas"]
    local foundLocations = {}
    
    -- First, find all active delivery locations
    for i = 1, 11 do
        local areaName = "a" .. i
        local area = deliveryAreas:FindFirstChild(areaName)
        
        if area and area:FindFirstChild("LocationBill") then
            print("Found delivery location:", areaName)
            table.insert(foundLocations, area)
        end
    end
    
    -- Now handle each location one at a time until the job is complete
    for _, area in ipairs(foundLocations) do
        local startTime = tick()
        -- Stay at location until either 3 seconds pass or we lose the job
        while tick() - startTime < 3 and not hasNoCurrentJob() do
            local targetPosition = area.Position - Vector3.new(0, 12, 0)
            teleportTo(targetPosition, true)
            wait() -- Small wait to prevent crashes
        end
        
        -- If we lost the job, we're done
        if hasNoCurrentJob() then
            print("Delivery completed at location")
            break
        end
    end
end

-- Function to check cash amount
local function hasEnoughCash()
    local cashLabel = LocalPlayer.PlayerGui.HUD.Bars.MainHUD.Cash
    return cashLabel and cashLabel.Text == "₩1,000,000"
end

-- Function to simulate key press and release
local function pressKey(keyCode)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    wait(0.05) -- Small delay between press and release
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    wait(0.05) -- Small delay between keys
end

-- Spawn ATM key press loop
task.spawn(function()
    while true do
        if hasEnoughCash() then
            -- Press Backslash
            wait (5)
            pressKey(Enum.KeyCode.BackSlash)
            
            -- Press S twice
            pressKey(Enum.KeyCode.S)
            pressKey(Enum.KeyCode.S)
            
            -- Press Enter
            pressKey(Enum.KeyCode.Return)
            
            -- Wait a bit before checking again
            wait(5)
        end
        wait(0.1) -- Check money every 0.1 seconds
    end
end)

-- Function to smoothly move to a position using BodyGyro
local function moveTowards(targetPosition, speed)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    -- Create or get existing BodyGyro
    local bodyGyro = humanoidRootPart:FindFirstChild("BodyGyro") or Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 5000
    bodyGyro.Parent = humanoidRootPart
    
    -- Calculate direction and distance
    local direction = (targetPosition - humanoidRootPart.Position).Unit
    local distance = (targetPosition - humanoidRootPart.Position).Magnitude
    
    -- Move towards target
    if distance > 0.5 then
        humanoidRootPart.CFrame = humanoidRootPart.CFrame + direction * speed
        return false
    end
    
    return true
end

-- Function to handle ATM interaction key presses

-- Function to interact with ATM
local function interactWithATM()
    local ATMs = workspace.Interactables.ATMs
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    -- Find closest empty ATM
    local closestATM = nil
    local closestDistance = math.huge
    
    for _, atm in pairs(ATMs:GetChildren()) do
        local screen = atm:FindFirstChild("Screen")
        if screen and #screen:GetChildren() == 0 then
            local screenGlass = atm:FindFirstChild("ScreenGlass")
            if screenGlass then
                local distance = (screenGlass.Position - humanoidRootPart.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestATM = atm
                end
            end
        end
    end
    
    -- Interact with closest ATM if found
    if closestATM then
        local screenGlass = closestATM:FindFirstChild("ScreenGlass")
        if screenGlass then
            -- Smoothly move to ATM
            local reached = false
            while not reached do
                reached = moveTowards(screenGlass.Position, 0.2)
                wait()
            end
            
            -- Click the screen glass once
            local clickDetector = screenGlass:FindFirstChild("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
                wait(0.5)  -- Wait for ATM UI to appear
                
                -- Set amount in ATM
                local amountBox = game:GetService("Players").LocalPlayer.PlayerGui.HUD.Tabs.ATM.AmountBox
                if amountBox then
                    amountBox.Text = "1000000"
                    wait(0.1)  -- Small wait after setting amount
                end
                
                return true
            end
        end
    end
    return false
end

-- Main loop spawning both check functions
while true do
    task.spawn(function()
        if hasEnoughCash() then
            print("=== Found ₩1,000,000 - Finding Empty ATM ===")
            interactWithATM()
            checkAndHandleATMInteraction()
        elseif hasNoCurrentJob() then 
            print("=== Starting Delivery Poster Check ===")
            checkDeliveryPosters()
            print("=== Finished Delivery Poster Check ===")
        else
            print("=== Handling Delivery Location ===")
            handleDeliveryLocation()
            print("=== Finished Handling Delivery ===")
        end
    end)
    
    wait(0.1)
end

-- Function to check if we have ₩1,000,000 and handle ATM interaction


-- Main loop spawning both check functions
task.spawn(function()
    while true do
        checkAndHandleATMInteraction()  -- Check for ATM interaction
        if hasNoCurrentJob() then 
            print("=== Starting Delivery Poster Check ===")
            checkDeliveryPosters()
            print("=== Finished Delivery Poster Check ===")
        else
            print("=== Handling Delivery Location ===")
            handleDeliveryLocation()
            print("=== Finished Handling Delivery ===")
        end
        wait(0.1)
    end
end)
