_menuPool = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu("OVERLOAD", "~b~OVERLOAD MOD MENU")
_menuPool:Add(mainMenu)



-- DRIFT COUNTER
local isDrifting = false
local driftPoints = 0
local driftTimer = 0
local driftUIActive = false
local showDriftCounter = true
--ENDS

--LEADERBOARD
local driftLeaderboard = {}


-- Function to update drift scores
function updateDriftScore(playerId, playerName, score)
    if not driftLeaderboard[playerId] or score > driftLeaderboard[playerId].score then
        driftLeaderboard[playerId] = { name = playerName, score = score }
    end
end
--

-- Function to get the sorted leaderboard
function getSortedLeaderboard()
    local sortedLeaderboard = {}
    for playerId, data in pairs(driftLeaderboard) do
        table.insert(sortedLeaderboard, { name = data.name, score = data.score })
    end
    
    table.sort(sortedLeaderboard, function(a, b) return a.score > b.score end)
    return sortedLeaderboard
end

function ShowDriftLeaderboard(menu)
    local leaderboardButton = NativeUI.CreateItem("Drift Leaderboard", "View the top drift scores.")
    menu:AddItem(leaderboardButton)

    leaderboardButton.Activated = function(sender, item)
        mainMenu:Visible(false) -- Close main menu

        local leaderboardMenu = NativeUI.CreateMenu("Leaderboard", "Top Drift Scores")
        _menuPool:Add(leaderboardMenu)

        -- Prevent camera from spinning
        Citizen.CreateThread(function()
            SetCursorLocation(0.5, 0.5)
            while leaderboardMenu:Visible() do
                Citizen.Wait(0)
                DisableControlAction(0, 1, true)  -- Disable Look Left/Right
                DisableControlAction(0, 2, true)  -- Disable Look Up/Down
                DisableControlAction(0, 30, true) -- Disable Move Left/Right
                DisableControlAction(0, 31, true) -- Disable Move Forward/Backward
                DisableControlAction(0, 32, true) -- Disable Move Up
                DisableControlAction(0, 33, true) -- Disable Move Down
                DisableControlAction(0, 34, true) -- Disable Move Left
                DisableControlAction(0, 35, true) -- Disable Move Right
            end
        end)

        local sortedLeaderboard = getSortedLeaderboard()
        for _, entry in ipairs(sortedLeaderboard) do
            local scoreItem = NativeUI.CreateItem(entry.name .. " - " .. entry.score, "")
            leaderboardMenu:AddItem(scoreItem)
        end

        _menuPool:RefreshIndex()
        leaderboardMenu:Visible(true)

        -- Restore controls when leaderboard menu is closed
        Citizen.CreateThread(function()
            while leaderboardMenu:Visible() do Citizen.Wait(100) end
            Citizen.Wait(100)
            EnableAllControlActions(0)
        end)
    end
end


--END


function DriftModeButton(menu)
    local driftButton = NativeUI.CreateItem("Drift tune", "Install drift tune into this vehicle (cannot be reverted).")
    menu:AddItem(driftButton)

    driftButton.Activated = function(sender, item)
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

        if item == driftButton then
            if vehicle ~= 0 then
                -- Toggle Drift Mode (not in use atm)
                isDrifting = true

                -- Physical
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDragCoeff", 25)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "vecCentreOfMassOffset", 0, 0.065, 0)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "vecInertiaMultiplier", 1.1, 1.35, 1.72) 

                -- Engine
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveBiasFront", 0.175)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "nInitialDriveGears", 5)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", 1.5)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fClutchChangeRateScaleUpShift", 4.8)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fClutchChangeRateScaleDownShift", 4.7)
                SetVehicleEnginePowerMultiplier(vehicle, 1)

                -- Brakes
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeBiasFront", 0.32)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fHandBrakeForce", 0.9)

                -- Traction
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fSteeringLock", 77.0)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMax", 1.53)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMin", 1.525)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveLateral", 29.5)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", 0)

                -- Suspension
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fSuspensionForce", 2.2)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fSuspensionCompDamp", 1)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fSuspensionReboundDamp", 1.6)

                -- Body roll
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fAntiRollBarForce", 0.3)

                notify("🔥 Drift Mode ON 🏎️💨")
                
            else
                notify("🚗 You are not in a vehicle!")
            end
        end
    end
end

--Drift counter button
function ShowDriftCounterButton(menu)
    local driftCounterCheckbox = NativeUI.CreateCheckboxItem("Hide drift counter", false, "Enable/Disable the drift counter")
    menu:AddItem(driftCounterCheckbox)

    driftCounterCheckbox.CheckboxEvent = function(sender, checked_)
        if showDriftCounter then
            showDriftCounter = false;
            --Hide the counter
            SendNUIMessage({ action = "hide" })
            notify("❌ Drift counter disabled")
        else
            showDriftCounter = true;
            notify("Drift counter enabled")
        end
    end
end

-- "Seats menu"
--[[ 
seats = {-1,0,1,2}
function FourthItem(menu) 
   local submenu = _menuPool:AddSubMenu(menu, "~b~Seats menu") 
   local seat = NativeUI.CreateSliderItem("Change seat", seats, 1)
    submenu.OnSliderChange = function(sender, item, index)
        if item == seat then
            vehSeat = item:IndexToItem(index)
            local pedsCar = GetVehiclePedIsIn(GetPlayerPed(-1),false)
            SetPedIntoVehicle(PlayerPedId(), pedsCar, vehSeat)
        end
    end
   submenu:AddItem(seat)
end
--]]

DriftModeButton(mainMenu)

ShowDriftCounterButton(mainMenu)

ShowDriftLeaderboard(mainMenu)

_menuPool:RefreshIndex()


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()

        -- Check if U is being pressed
        if IsControlJustPressed(1, 303) then
            local isVisible = not mainMenu:Visible()
            mainMenu:Visible(isVisible)

            if isVisible then
                SetCursorLocation(0.5, 0.5)
                SetPedCanPlayGestureAnims(PlayerPedId(), false)
            else
                SetPedCanPlayGestureAnims(PlayerPedId(), true)
                Citizen.Wait(100)

                EnableControlAction(0, 1, true)
                EnableControlAction(0, 2, true)
                EnableControlAction(0, 30, true)
                EnableControlAction(0, 31, true)
                EnableControlAction(0, 32, true)
                EnableControlAction(0, 33, true)
            end
        end
    end
end)


--DRIFT COUNTER
function isVehicleDrifting(vehicle)
    local speed = GetEntitySpeed(vehicle) -- Get speed in m/s
    local velocity = GetEntityVelocity(vehicle)
    local forwardVector = GetEntityForwardVector(vehicle)
    
    -- Calculate lateral movement (sideways speed)
    local lateralSpeed = (velocity.x * forwardVector.y) - (velocity.y * forwardVector.x)

    -- Define drift threshold
    return math.abs(lateralSpeed) > 2.0 and speed > 5.0
end

function getDriftAngle(vehicle)
    local velocity = GetEntityVelocity(vehicle)
    local forwardVector = GetEntityForwardVector(vehicle)

    -- Normalize vectors
    local speed = math.sqrt(velocity.x^2 + velocity.y^2)
    if speed == 0 then return 0 end -- Avoid division by zero

    local dotProduct = (velocity.x * forwardVector.x + velocity.y * forwardVector.y) / speed
    local angle = math.deg(math.acos(dotProduct)) -- Convert to degrees

    return angle
end

Citizen.CreateThread(function()
    local driftMultiplier = 1
    local driftTime = 0
    local maxMultiplier = 32
    local increaseInterval = 500
    local lastVelocity = vector3(0.0, 0.0, 0.0)
    local cooldownTime = 3000
    local lastCrashTime = 0
    local isDrifting = false
    local driftPoints = 0
    local driftUIActive = false

    while true do
        Citizen.Wait(10)

        local player = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(player, false)

        local playerId = GetPlayerServerId(PlayerId())
        local playerName = GetPlayerName(PlayerId())

        if vehicle ~= 0 then
            local velocity = GetEntityVelocity(vehicle)
            local speed = #(velocity) -- Speed in m/s

            -- Crash detection
            local velocityChange = #(velocity - lastVelocity)
            lastVelocity = velocity

            if velocityChange > 2 then
                lastCrashTime = GetGameTimer()

                -- Save drift score before resetting
                if driftPoints > 0 then
                    notify("🔥Score: " .. math.floor(driftPoints))
                    updateDriftScore(playerId, playerName, math.floor(driftPoints))
                end

                isDrifting = false
                driftMultiplier = 1
                driftPoints = 0
                driftUIActive = false
                SendNUIMessage({ action = "hide" })
            end

            if GetGameTimer() - lastCrashTime >= cooldownTime then
                if isVehicleDrifting(vehicle) then
                    if not isDrifting then
                        isDrifting = true
                        driftUIActive = true
                        driftTimer = 0
                        driftTime = 0
                        driftMultiplier = 1
                    end

                    driftTime = driftTime + 1
                    local driftAngle = getDriftAngle(vehicle)

                    -- Increase multiplier every few seconds
                    if driftTime % increaseInterval == 0 and driftMultiplier < maxMultiplier then
                        driftMultiplier = driftMultiplier * 2
                    end

                    -- Scale points based on drift angle
                    local angleFactor = math.min(driftAngle / 90, 1.0) -- Scale between 0 and 1
                    local speedFactor = math.min(speed / 15, 1.0) -- Limit speed contribution (max at 15m/s)

                    driftPoints = driftPoints + (angleFactor * speedFactor * 10 * driftMultiplier)

                    -- Update UI
                    if showDriftCounter then
                        SendNUIMessage({
                            action = "show",
                            points = math.floor(driftPoints), -- Show whole number
                            multiplier = driftMultiplier
                        })
                    end


                else
                    if isDrifting then
                        driftTimer = driftTimer + 1
                    
                        if driftTimer >= 400 then
                            -- Save drift score before resetting
                            if driftPoints > 0 then
                                notify("🔥Score: " .. math.floor(driftPoints))
                                updateDriftScore(playerId, playerName, math.floor(driftPoints))
                            end
                    
                            -- Reset drift state
                            isDrifting = false
                            driftMultiplier = 1
                            driftPoints = 0
                            driftUIActive = false
                            SendNUIMessage({ action = "hide" })
                        end
                    end
                    
                end
            end
        else
            isDrifting = false
            driftMultiplier = 1
            driftPoints = 0
            driftUIActive = false
            SendNUIMessage({ action = "hide" })
        end
    end
end)
--ENDS

RegisterCommand("discord", function(source, args, rawCommand)
    local discordInvite = "https://discord.gg/gSvQH8xdh2"

    notify("Join our Discord server: " .. discordInvite)
end, false)



function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end