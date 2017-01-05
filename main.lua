
local gravgun = RegisterMod("GravityGun",1)
local grav_gun_item = Isaac.GetItemIdByName("Gravity Gun")

function gravgun:render()
  Isaac.RenderText("gravgun test", 100, 100, 255, 55, 55, 255)
    local player = Isaac.GetPlayer(0)

    --Isaac.DebugString(player.Position.X .. ", " .. player.Position.Y)
  local entities = Isaac.GetRoomEntities()
    if #entities > 0  then
      for i=1,#entities do
         -- Isaac.DebugString(entities[i].Position.X .. ", " .. entities[i].Position.Y)
    end
  end
end

function gravgun:charge()
  Isaac.DebugString("Item used")
    local player = Isaac.GetPlayer(0)
      local entities = Isaac.GetRoomEntities()
    for i=1,#entities do
    if (entities[i]:IsEnemy()) then
      entities[i]:Kill()
    end
  end
end

gravgun:AddCallback(ModCallbacks.MC_POST_RENDER, gravgun.render)
gravgun:AddCallback(ModCallbacks.MC_USE_ITEM, gravgun.charge, grav_gun_item)
Isaac.DebugString("Mod was successfully loaded")

