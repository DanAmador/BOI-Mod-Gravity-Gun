
local gravgun = RegisterMod("GravityGun",1)
local grav_gun_item = Isaac.GetItemIdByName("Gravity Gun")

function gravgun:render()
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities()
  local debug_offset = 20
  local aimDirection = player.GetAimDirection(player)
  local angle = 180 + math.deg(math.atan((aimDirection.Y),(-aimDirection.X))) 
  Isaac.RenderText( "angle:" .. angle , 100, 10, 255,55,55,255 )
  Isaac.RenderText(player.Position.X .. ", " .. player.Position.Y, 10, debug_offset, 255, 55, 55, 255)
  -- for i=1,#entities do
  --if entities[i]:IsEnemy() and not entities[i]:IsBoss() and #entities > 0 then
  --Isaac.RenderText("Entity #".. i .." at: ".. entities[i].Position.X .. ", " .. entities[i].Position.Y .. " Distance:" .. gravgun:distance(player.Position, entities[i].Position), 10, (i * 10 )+debug_offset, 255,0,0,255)
  --end
  --end
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
    Isaac.DebugString("Polygon #" ..i.." .. x:" .. polygon[i].x .. " y:" .. polygon[i].y)
    if (polygon[i].y < point.Y and polygon[j].y >= point.Y or polygon[j].y < point.Y and polygon[i].y >= point.Y) then
      if (polygon[i].x + ( point.X - polygon[i].y ) / (polygon[j].y - polygon[i].x) * (polygon[j].x - polygon[i].x) < point.X) then
        oddNodes = not oddNodes;
      end
    end
    j = i;
  end
  Isaac.DebugString("Object is insidePolygon:" .. tostring(oddNodes))
  return oddNodes
end

function gravgun:asciiDebug(polygon)
  for i=1, #polygon do
    local screenVec = Isaac.WorldToScreenPosition(Vector(polygon[i].x, polygon[i].y)) 
    Isaac.DebugString("Polygon #" ..i.." .. x:" .. screenVec.X .. " y:" .. screenVec.Y)
    Isaac.RenderText("X",screenVec.X, screenVec.Y, 255,55,55,255)
  end
end
function createPolygon()
  local player = Isaac.GetPlayer(0)
  local aimVector = player.GetAimDirection(player)
  local angle = math.rad(180) + math.atan((-aimVector.Y),(-aimVector.X)) 
  local triangleOffset = math.rad(22.5)

  return {{x = player.Position.X, y = player.Position.Y}, -- Have reference to self (player) to form a triangle 
    gravgun:getTrianglePoints(player.Position.X, player.Position.Y, (angle + triangleOffset)),
    gravgun:getTrianglePoints(player.Position.X, player.Position.Y, (angle - triangleOffset))}
end

function gravgun:getTrianglePoints(X,Y,angle)
  -- Isaac.DebugString("Aim direction angle: " .. math.deg(angle))
  local radius = 300
  return {x = X + (radius * math.cos(angle)),
          y = Y + (radius * math.sin(angle))}

end

function gravgun:charge()
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities()
  for i=1,#entities do
    if entities[i]:IsEnemy() and not entities[i]:IsBoss() and #entities > 0 then
      local distance = gravgun:distance(player.Position, entities[i].Position)
      Isaac.DebugString("Distance from entity #" .. i .. " is " .. distance)
        Isaac.DebugString("Inside range")
        if gravgun:insidePolygon(entities[i].Position, createPolygon()) then
          Isaac.DebugString("Inside polygon")
          entities[i]:Kill()
        end
    end
  end
end

gravgun:AddCallback(ModCallbacks.MC_POST_RENDER, gravgun.render)
gravgun:AddCallback(ModCallbacks.MC_USE_ITEM, gravgun.charge, grav_gun_item)
Isaac.DebugString("Mod was successfully loaded")
