UnityEngine = require("UnityEngine")

-- Debug --

DEBUG_MODE = true

local function DebugPrint(message)
    if DEBUG_MODE then
        print(message)
    end
end

-- PlayerManager --

local PlayerManager = {
    teleportDuration = 5, -- seconds
    teleportInterval = 0.5, -- interval between teleports
    elapsedTime = 0,
    nextTeleportTime = 0,
    isTeleporting = false,
    pathPoints = {},
    currentPathIndex = 1
}

function PlayerManager:StartTeleporting()
    self.elapsedTime = 0
    self.nextTeleportTime = 0
    self.currentPathIndex = 1
    self.isTeleporting = true
    self:GeneratePathPoints()
end

function PlayerManager:StopTeleporting()
    self.isTeleporting = false
    self:RespawnPlayer()
end

function PlayerManager:GeneratePathPoints()
    local player = PlayerAPI.LocalPlayer
    local startPosition = player.GetPosition()

    -- Generate path points
    for i = 1, math.floor(self.teleportDuration / self.teleportInterval) do
        local offset = UnityEngine.NewVector3(0, 1 * i, 0)
        local point = startPosition + offset
        table.insert(self.pathPoints, point)
    end
end

function PlayerManager:TeleportAlongPath()
    local player = PlayerAPI.LocalPlayer
    if player.Username == "Patchuuri" and self.currentPathIndex <= #self.pathPoints then
        local newPosition = self.pathPoints[self.currentPathIndex]
        local newRotation = UnityEngine.NewQuaternion(0, 1, 0, 0) * UnityEngine.NewQuaternion(0, 0, 1, 0) -- 180 degrees upside down rotation

        player.TeleportPlayerTo(newPosition, newRotation.eulerAngles, false, true, false)

        DebugPrint("Teleported player " .. player.Username .. " to " .. tostring(newPosition))
        self.currentPathIndex = self.currentPathIndex + 1
    end
end

function PlayerManager:RespawnPlayer()
    local player = PlayerAPI.LocalPlayer
    player.Respawn()
    DebugPrint("Player " .. player.Username .. " has been respawned")
end

-- Unity Events --

function Start()
    local player = PlayerAPI.LocalPlayer
    if player.Username == "Patchuuri" then
        PlayerManager:StartTeleporting()
    end
end

function Update()
    if PlayerManager.isTeleporting then
        PlayerManager.elapsedTime = PlayerManager.elapsedTime + UnityEngine.Time.deltaTime
        if PlayerManager.elapsedTime >= PlayerManager.teleportDuration then
            PlayerManager:StopTeleporting()
        elseif PlayerManager.elapsedTime >= PlayerManager.nextTeleportTime then
            PlayerManager:TeleportAlongPath()
            PlayerManager.nextTeleportTime = PlayerManager.nextTeleportTime + PlayerManager.teleportInterval
        end
    end
end
