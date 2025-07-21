--!strict
-- Built-in Roblox Services
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Utility
local SafeFunctionCaller = require(ReplicatedStorage.Shared.Utility.SafeFunctionCaller)
local TypeCheck = require(ReplicatedStorage.Shared.Utility.TypeCheck)

-- DataStore
local DataStore = DataStoreService:GetDataStore("UserData_Development_12")

-- Essential DataStore related Modules
local PlayerInstances = require(script.PlayerInstances)

-- DataStoreService Module
local Module = {}

-- Functions
function Module.Get(Player: Player): boolean
	if not Player then
		return false
	end
	local Key = tostring(Player.UserId)
	if Key then
		local FunctionToCall = DataStore.GetAsync
		local _Status, UserData = SafeFunctionCaller(FunctionToCall, DataStore, Key)
		if TypeCheck.table(UserData) then
			PlayerInstances.SetData(Player, UserData)
		elseif _Status == true and UserData == nil then
			Player:AddTag("New")
		end
		return _Status
	end
	return false
end

function Module.Set(Player: Player)
	if not Player then
		return
	end
	local Key = tostring(Player.UserId)
	if Key then
		local FunctionToCall = DataStore.SetAsync
		local DataToSave = PlayerInstances.GetData(Player)
		if TypeCheck.table(DataToSave) then
			SafeFunctionCaller(FunctionToCall, DataStore, Key, DataToSave)
		end
	end
end

return Module
