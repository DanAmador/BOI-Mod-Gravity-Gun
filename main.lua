
local gravgun = RegisterMod("GravityGun",1)
local grav_gun_item = Isaac.GetItemIdByName("Gravity Gun")

function gravgun:render()
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities()
  local debug_offset = 20
  aimDirection = player.GetAimDirection(player)
  Isaac.RenderText("Aim Direction: " .. aimDirection.X .. ", " .. aimDirection.Y, 10, 10, 255,55,55,255 )
  Isaac.RenderText(player.Position.X .. ", " .. player.Position.Y, 10, debug_offset, 255, 55, 55, 255)
  for i=1,#entities do
    if entities[i]:IsEnemy() and not entities[i]:IsBoss() and #entities > 0 then
      Isaac.RenderText("Entity #".. i .." at: ".. entities[i].Position.X .. ", " .. entities[i].Position.Y .. " Distance:" .. gravgun:distance(player.Position, entities[i].Position), 10, (i * 10 )+debug_offset, 255,0,0,255)
    end
      end
end

function gravgun:distance(vector1, vector2)
  return math.sqrt((vector2.X - vector1.X)^2 + (vector2.Y - vector1.Y)^2)
end

function gravgun:charge()
  Isaac.DebugString("Item used")
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities()
  for i=1,#entities do
    if entities[i]:IsEnemy() and not entities[i]:IsBoss() and #entities > 0 then
      local distance = gravgun:distance(player.Position, entities[i].Position)
      Isaac.DebugString("Distance from entity #" .. i .. " is " .. distance)
      if distance < 200  then
        entities[i]:Kill()
      end
    end
  end
end

gravgun:AddCallback(ModCallbacks.MC_POST_RENDER, gravgun.render)
gravgun:AddCallback(ModCallbacks.MC_USE_ITEM, gravgun.charge, grav_gun_item)
Isaac.DebugString("Mod was successfully loaded")
