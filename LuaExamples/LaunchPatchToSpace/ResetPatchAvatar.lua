UnityEngine = require("UnityEngine")

-- Debug --

DEBUG_MODE = true

local function DebugPrint(message)
    if DEBUG_MODE then
        print(message)
    end
end

-- AvatarManager --

local AvatarManager = {
    targetAvatarID = "9dcdb9b2-b4ce-4f8d-bfa9-53c6a8feaf6b", -- patch dog
    newAvatarID = "32ceb35d-24fa-469f-8aa4-23851ac68f84" -- default alchemist
}

function AvatarManager:CheckAndSwitchAvatar()
    local player = PlayerAPI.LocalPlayer
    local currentAvatarID = player.Avatar.AvatarID

    if currentAvatarID == self.targetAvatarID then
        player:SwitchAvatar(self.newAvatarID)
        DebugPrint("Switched avatar to " .. self.newAvatarID)
    else
        DebugPrint("Current avatar ID (" .. currentAvatarID .. ") does not match target avatar ID (" .. self.targetAvatarID .. ")")
    end
end

-- Unity Events --

function Start()
    AvatarManager:CheckAndSwitchAvatar()
end