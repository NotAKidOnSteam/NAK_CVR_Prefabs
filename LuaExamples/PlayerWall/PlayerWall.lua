UnityEngine = require("UnityEngine")

-- Debug --

DEBUG_MODE = false

local function DebugPrint(message)
    if DEBUG_MODE then
        print(message)
    end
end

-- ObjectPool --

local ObjectPool = {
    pool = {},
    prefab = nil,
    parent = nil
}

function ObjectPool:Initialize(prefab, parent, initialSize)
    DebugPrint("Initializing ObjectPool")
    self.prefab = prefab
    self.parent = parent or nil
    for i = 1, initialSize do
        local obj = self:CreateNewObject()
        table.insert(self.pool, obj)
    end
    DebugPrint("ObjectPool initialized with " .. initialSize .. " objects")
end

function ObjectPool:CreateNewObject()
    DebugPrint("Creating new object")
    local obj = UnityEngine.GameObject.Instantiate(self.prefab, transform)
    obj:SetActive(false)
    return obj
end

function ObjectPool:GetTextMesh()
    if #self.pool > 0 then
        DebugPrint("Getting TextMesh from pool")
        return table.remove(self.pool)
    else
        DebugPrint("Pool is empty, creating new TextMesh")
        return self:CreateNewObject()
    end
end

function ObjectPool:ReturnTextMesh(obj)
    DebugPrint("Returning TextMesh to pool")
    obj:SetActive(false)
    table.insert(self.pool, obj)
end

-- PlayerManager --

local PlayerManager = {
    currentCount = 0,
    playerTextMeshes = {},
    playerEntries = {}
}

function PlayerManager:CheckForPlayerChanges()
    DebugPrint("Checking for player changes")
    local currentCount = PlayerAPI.PlayerCount

    -- check for player joins
    if currentCount > self.currentCount then
        local currentPlayers = PlayerAPI.AllPlayers
        for _, player in ipairs(currentPlayers) do
            if not self.playerTextMeshes[player.UserID] then
                DebugPrint("New player detected: " .. player.Username)
                self:HandlePlayerJoin(player)
                self:UpdatePlayerTextMeshes()
            end
        end
    -- check for player leaves
    elseif currentCount < self.currentCount then
        local currentPlayers = PlayerAPI.AllPlayers
        for userId, textMesh in pairs(self.playerTextMeshes) do
            local playerExists = false
            for _, player in ipairs(currentPlayers) do
                if player.UserID == userId then
                    playerExists = true
                    break
                end
            end
            if not playerExists then
                DebugPrint("Player left: " .. userId)
                self:HandlePlayerLeave(userId)
                self:UpdatePlayerTextMeshes()
            end
        end
    end

    self.currentCount = currentCount
end

function PlayerManager:HandlePlayerJoin(player)
    DebugPrint("Handling player join: " .. player.Username)
    local textMesh = ObjectPool:GetTextMesh()
    textMesh:SetActive(true)
    local textMeshComponent = textMesh:GetComponent("UnityEngine.TextMesh")
    textMeshComponent.text = player.Username

    -- why are the default colors not bound...
    -- if player.IsLocal then
    --     textMeshComponent.color = UnityEngine.NewColor(0, 1, 0, 1) -- green
    -- else
    --     textMeshComponent.color = UnityEngine.NewColor(0, 0, 1, 1) -- blue
    -- end

    textMesh.transform.localScale = UnityEngine.NewVector3(0.02, 0.02, 0.02)

    self.playerTextMeshes[player.UserID] = textMesh
    self.playerEntries[player.UserID] = player
    DebugPrint("TextMesh associated with player: " .. player.Username)
end

function PlayerManager:HandlePlayerLeave(userId)
    DebugPrint("Handling player leave: " .. userId)
    local textMesh = self.playerTextMeshes[userId]
    if textMesh then
        textMesh:SetActive(false)
        ObjectPool:ReturnTextMesh(textMesh)
        self.playerTextMeshes[userId] = nil
        self.playerEntries[userId] = nil
        DebugPrint("TextMesh returned to pool for player: " .. userId)
    end
end

function PlayerManager:UpdatePlayerTextMeshes()
    local index = 0
    local rowLength = 4
    local spacingY = 0.2
    local spacingX = 0.6

    local factoryPosition = BoundObjects.TextMeshFactory.transform.position
    local factoryRotation = BoundObjects.TextMeshFactory.transform.rotation

    for userId, textMesh in pairs(self.playerTextMeshes) do
        local row = math.floor(index / rowLength)
        local column = index % rowLength
        local position = factoryPosition + factoryRotation * UnityEngine.NewVector3(column * spacingX, -row * spacingY, 0)
        textMesh.transform:SetPositionAndRotation(position, factoryRotation)
        index = index + 1
    end
end

-- Unity Events --

function Start()
    local prefab = BoundObjects.TextMeshPrefab
    local factoryParent = BoundObjects.TextMeshFactory
    if not prefab or not factoryParent then
        print("Error! You have not bound TextPrefab and/or TextFactory.")
        return
    end

    DebugPrint("Start function called")
    ObjectPool:Initialize(prefab, factoryParent, 4) -- instantiate 4 text meshes by default
    PlayerManager:CheckForPlayerChanges() -- manually checking player count changes because exposed actions are problematic
end

function Update()
    PlayerManager:CheckForPlayerChanges()
end