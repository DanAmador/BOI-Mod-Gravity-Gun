
local gravgun = RegisterMod("GravityGun",1)

function gravgun:render()
  Isaac.RenderText("gravgun test", 100, 100, 255, 55, 55, 255)
  local entities = Isaac.GetRoomEntities()
    if #entities > 0  then
      for i=1,#entities do
          Isaac.DebugString(entities[i].Position.X .. ", " .. entities[i].Position.Y)
    end
  end
end

function gravgun:charge()
  local player = Isaac.GetPlayer()
  local entities = Isaac.GetRoomEntities()
  for i=0,#entities do
    if (entities[i]:isEnemy()) then
      entities[i].kill()
    end
  end
end
gravgun:AddCallback(ModCallbacks.MC_POST_RENDER, gravgun.render)
gravgun:AddCallback(ModCallbacks.MC_USE_ITEM,gravgun.charge)
Isaac.DebugString("Mod was successfully loaded")

