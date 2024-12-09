-- Copyright (c) 2024 RAMPAGE Interactive. All rights reserved.
-- Copyright (c) 2024 Metatable Games. All rights reserved.
-- Written by vq9o <business@vq9o.com>

local Class = {}
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")

export type void = nil
export type Callable = () -> void

function Class.new(ContentArray: { any }, Callback: Callable)
	local startTime = os.clock()
	local numAssets = #ContentArray
	local loadedAssets = 0
	local failCount = 0

	local GameGui = Players.LocalPlayer.PlayerGui.GameGui
	local ScenePreload = Players.LocalPlayer.PlayerGui.ScenePreload
	local GameGuiWasEnabled = GameGui.Enabled

	ScenePreload.Enabled = true
	GameGui.Enabled = false

	ScenePreload.AssetPreload.Container.AssetCount.Text = ("Loaded %s/%s asset(s)"):format(
		tostring(loadedAssets),
		tostring(numAssets)
	)
	ScenePreload.AssetPreload.Container.FailLabel.Text = ("%s asset(s) failed to load"):format(tostring(failCount))
	ScenePreload.AssetPreload.Container.FailLabel.TextColor3 = failCount > 0 and Color3.fromRGB(255, 0, 0)
		or Color3.fromRGB(255, 255, 255)

	for i, v in pairs(ContentArray) do
		ContentProvider:PreloadAsync({ v }, function(ContentID, Status)
			loadedAssets += 1

			if Status == Enum.AssetFetchStatus.Failure then
				failCount += 1
			end

			ScenePreload.AssetPreload.Container.AssetCount.Text = ("Loaded %s/%s asset(s)"):format(
				tostring(loadedAssets),
				tostring(numAssets)
			)
			ScenePreload.AssetPreload.Container.FailLabel.Text = ("%s asset(s) failed to load"):format(
				tostring(failCount)
			)
			ScenePreload.AssetPreload.Container.FailLabel.TextColor3 = failCount > 0 and Color3.fromRGB(255, 0, 0)
				or Color3.fromRGB(255, 255, 255)

			if loadedAssets == numAssets then
				warn(("Preloading complete, took %.2f seconds"):format(os.clock() - startTime))
				ScenePreload.Enabled = false
				GameGui.Enabled = GameGuiWasEnabled
				Callback()
			end
		end)
	end
end

return Class
