--[[

    This is abusing stuff using Unity Explorer to fix Static bindings for worlds.
    Will not exist for long. Overcomplicated this for nothing.

]]

UnityEngine = require("UnityEngine")

-- Debug --

DEBUG_MODE = false

local function DebugPrint(message)
    if DEBUG_MODE then
        print(message)
    end
end

-- PersistenceManager --

local PersistenceManager = {
    version = 3,
    registeredEntities = {},
    currentIndex = 1
}

function PersistenceManager:SetGlobalVector(name, vector)
    UnityEngine.Shader.SetGlobalVector("PS_" .. name, vector)
end

function PersistenceManager:GetGlobalVector(name)
    return UnityEngine.Shader.GetGlobalVector("PS_" .. name)
end

function PersistenceManager:SetGlobalInt(name, value)
    UnityEngine.Shader.SetGlobalInt("PS_" .. name, value)
end

function PersistenceManager:GetGlobalInt(name)
    return UnityEngine.Shader.GetGlobalInt("PS_" .. name)
end

function PersistenceManager:SaveEntityTransform(name, entity)
    local position = entity.transform.position
    local rotation = entity.transform.rotation
    local positionVector = UnityEngine.NewVector4(position.x, position.y, position.z, 0)
    local rotationVector = UnityEngine.NewVector4(rotation.x, rotation.y, rotation.z, rotation.w)
    self:SetGlobalVector(name .. "_Position", positionVector)
    self:SetGlobalVector(name .. "_Rotation", rotationVector)
    DebugPrint("Saved transform for " .. name)
end

function PersistenceManager:LoadEntityTransform(name, entity)
    local positionVector = self:GetGlobalVector(name .. "_Position")
    local rotationVector = self:GetGlobalVector(name .. "_Rotation")
    if positionVector and rotationVector then
        entity.transform.position = UnityEngine.NewVector3(positionVector.x, positionVector.y, positionVector.z)
        entity.transform.rotation = UnityEngine.NewQuaternion(rotationVector.x, rotationVector.y, rotationVector.z, rotationVector.w)
        DebugPrint("Loaded transform for " .. name)
        DebugPrint("Position: " .. tostring(positionVector))
    end
end

function PersistenceManager:SavePlayerPosition()
    local player = PlayerAPI.LocalPlayer

    local playerPos = player:GetPosition()
    local playerRot = player:GetRotation()

    local positionVector = UnityEngine.NewVector4(playerPos.x, playerPos.y, playerPos.z, 0)
    local rotationVector = UnityEngine.NewVector4(playerRot.x, playerRot.y, playerRot.z, playerRot.w)

    self:SetGlobalVector("PlayerPosition", positionVector)
    self:SetGlobalVector("PlayerRotation", rotationVector)
end

function PersistenceManager:LoadPlayerPosition()
    local player = PlayerAPI.LocalPlayer

    local posVector = self:GetGlobalVector("PlayerPosition")
    local rotVector = self:GetGlobalVector("PlayerRotation")

    if posVector and rotVector then
        local worldPos = UnityEngine.NewVector3(posVector.x, posVector.y, posVector.z)
        local worldRot = UnityEngine.NewQuaternion(rotVector.x, rotVector.y, rotVector.z, rotVector.w)
        player:TeleportPlayerTo(worldPos, worldRot.eulerAngles, false, true, false)
        player:TeleportPlayerTo(worldPos, worldRot.eulerAngles, false, true, false)
        player:TeleportPlayerTo(worldPos, worldRot.eulerAngles, false, true, false)
        player:TeleportPlayerTo(worldPos, worldRot.eulerAngles, false, true, false)
        DebugPrint("Loaded player position and rotation")
        DebugPrint("Position: " .. tostring(worldPos))
    end
end

function PersistenceManager:Initialize()
    self:SetGlobalInt("Version", self.version)
end

function PersistenceManager:CheckVersion()
    local globalVersion = self:GetGlobalInt("Version")
    if globalVersion and globalVersion ~= self.version then
        DebugPrint("Version mismatch. Ignoring persisted data.")
        return false
    end
    return true
end

function PersistenceManager:RegisterEntity(name, entity)
    self.registeredEntities[name] = entity
end

function PersistenceManager:LoadAllTransforms()
    for name, entity in pairs(self.registeredEntities) do
        self:LoadEntityTransform(name, entity)
    end
end

function PersistenceManager:SaveNextEntity()
    local entityNames = {}
    for name, _ in pairs(self.registeredEntities) do
        table.insert(entityNames, name)
    end
    
    if #entityNames == 0 then return end
    
    local name = entityNames[self.currentIndex]
    local entity = self.registeredEntities[name]
    
    if entity then
        self:SaveEntityTransform(name, entity)
    end
    
    self.currentIndex = self.currentIndex + 1
    if self.currentIndex > #entityNames then
        self.currentIndex = 1
    end
end

-- Unity Events --

local frameCount = 0
local initialized = false

function Start()
    -- Register all bound objects for persistence
    for name, entity in pairs(BoundObjects) do
        PersistenceManager:RegisterEntity(name, entity)
    end

    DebugPrint("Start function called")
    PersistenceManager:Initialize()
end

function FixedUpdate()
    frameCount = frameCount + 1

    -- 2 frame buffer because otherwise player position won't set properly
    if frameCount >= 2 and not initialized then
        if PersistenceManager:CheckVersion() then
            PersistenceManager:LoadAllTransforms()
            PersistenceManager:LoadPlayerPosition()
        end
        initialized = true
    end

    if initialized then
        PersistenceManager:SavePlayerPosition()
        PersistenceManager:SaveNextEntity()
    end
end