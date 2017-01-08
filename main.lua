
local gravgun = RegisterMod("GravityGun",1)
local grav_gun_item = Isaac.GetItemIdByName("Gravity Gun")
player = Isaac.GetPlayer(0)
grabbed_flag = false
enemy_grabbed = nil
angle = 0
function gravgun:render()
     local aimDirection = player.GetAimDirection(player)

     angle = math.rad(180) + math.atan((-aimDirection.Y),(-aimDirection.X))

     if grabbed_flag and enemy_grabbed ~= nil then
    trianglePoints = gravgun:getTrianglePoints(player.Position.X, player.Position.Y, angle, 100)
    new_position_vector = trianglePoints
    enemy_grabbed.Position = new_position_vector
  end
  -- DEBUG SHIT
  local entities = Isaac.GetRoomEntities()
  local debug_offset = 20
  Isaac.RenderText( "angle:" .. angle , 100, 10, 255,55,55,255 )
  Isaac.RenderText(player.Position.X .. ", " .. player.Position.Y, 10, debug_offset, 255, 55, 55, 255)
  gravgun:asciiDebug(createPolygon())
end

function gravgun:distance(vector1, vector2)
  return math.sqrt((vector2.X - vector1.X)^2 + (vector2.Y - vector1.Y)^2)
end

function gravgun:insidePolygon(point, polygon)
  --Reference http://alienryderflex.com/polygon/
  local oddNodes = false
  local j = #polygon
  for i = 1, #polygon do
    --Isaac.DebugString("Polygon #" ..i.." .. x:" .. polygon[i].x .. " y:" .. polygon[i].y)
    if (polygon[i].Y < point.Y and polygon[j].Y >= point.Y or polygon[j].Y < point.Y and polygon[i].Y >= point.Y) then
      if (polygon[i].X + ( point.X - polygon[i].Y ) / (polygon[j].Y - polygon[i].X) * (polygon[j].X - polygon[i].X) < point.X) then
        oddNodes = not oddNodes;
      end
    end
    j = i;
  end
  Isaac.DebugString("Object is insidePolygon: " .. tostring(oddNodes))
  return oddNodes
end

function gravgun:asciiDebug(polygon)
  for i=1, #polygon do
    local screenVec = Isaac.WorldToRenderPosition(polygon[i])
    --Isaac.DebugString("Polygon #" ..i.." .. x:" .. screenVec.X .. " y:" .. screenVec.Y)
    Isaac.RenderText("X",screenVec.X, screenVec.Y, 255,55,55,255)
  end

  local entities = Isaac.GetRoomEntities()
  for i = 1, #entities do
    if entities[i]:IsEnemy() then
      local debugVec = Isaac.WorldToRenderPosition(entities[i].Position)
      Isaac.RenderText(tostring(gravgun:insidePolygon(entities[i].Position,createPolygon())), debugVec.X, debugVec.Y, 255,50,50,255)      
    end
  end
end

function createPolygon()
  local triangleOffset = math.rad(27.5)
  local radius = 200
  return {player.Position, -- Have reference to self (player) to form a triangle
          gravgun:getTrianglePoints(player.Position.X, player.Position.Y, (angle + triangleOffset), radius),
          gravgun:getTrianglePoints(player.Position.X, player.Position.Y, (angle - triangleOffset), radius)}
end

function gravgun:getTrianglePoints(X,Y,angle_with_offset, radius)
  -- Isaac.DebugString("Aim direction angle: " .. math.deg(angle))
  return Vector( X + (radius * math.cos(angle_with_offset)), Y + (radius * math.sin(angle_with_offset)))

end

function gravgun:item_use()
  if grabbed_flag and enemy_grabbed ~= nil  then
    gravgun:shoot()
  else
    gravgun:charge()
  end
end

function gravgun:shoot()
  grabbed_flag = false
  enemy_grabbed = nil
end

function gravgun:charge()
  local entities = Isaac.GetRoomEntities()
  local closest_enemy = nil
  local closest_distance = 400
  for i=1,#entities do
    if entities[i]:IsEnemy() and not entities[i]:IsBoss() and #entities > 0 then
      local distance = gravgun:distance(player.Position, entities[i].Position)

      Isaac.DebugString("Distance from entity #" .. i .. " is " .. distance)
      if gravgun:insidePolygon(entities[i].Position, createPolygon()) then
        if distance < closest_distance then
          closest_enemy = entities[i]
          closest_distance = distance
        end
      end
    end
  end
  if closest_enemy ~= nil  then
    enemy_grabbed = closest_enemy
    grabbed_flag = true
    gravgun:addEffects()
  end
end

function gravgun:addEffects()
  enemy_grabbed:AddSlowing(enemy_grabbed, 10, 9999, Color(10,10,10,10,10,10))
  enemy_grabbed:AddFear(enemy_grabbed, 10)
  enemy_grabbed:AddConfusion(enemy_grabbed, 10)
  enemy_grabbed:AddFreeze(enemy_grabbed,10)
  enemy_grabbed.AddBurn(enemy_grabbed, 10,10)
end
gravgun:AddCallback(ModCallbacks.MC_POST_RENDER, gravgun.render)
gravgun:AddCallback(ModCallbacks.MC_USE_ITEM, gravgun.item_use, grav_gun_item)
Isaac.DebugString("Mod was successfully loaded")
