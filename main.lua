local grav_gun_mod = RegisterMod("GravityGun",1)
local grav_gun_item = Isaac.GetItemIdByName("Gravity Gun")
local grav_gun_entity = Isaac.GetEntityTypeByName("Gravity Gun")

grav_gun = nil 
grabbed_flag = false

enemy_grabbed = nil
thrown_vector = nil
angle, counter = 0,0

function grav_gun_mod:render()
  local player = Isaac.GetPlayer(0)
  local aimDirection = player:GetAimDirection()
  local delta_move = 8
  local entities = Isaac.GetRoomEntities()
  angle = math.rad(180) + math.atan((-aimDirection.Y),(-aimDirection.X))


if player:HasCollectible(grav_gun_item) then
  local room = Game():GetRoom():GetDecorationSeed()
  if prevroom == nil then prevroom = room end
  if room ~= prevRoom then ResetGun() end
  if grav_gun == nil then grav_gun = Isaac.Spawn(grav_gun_entity,0,0,Vector(player.Position.X + (math.cos(angle) * 25), player.Position.Y + (math.sin(angle) * 25)- 10),Vector(0,0),nil) end
  prevRoom = room
  sprite = grav_gun:GetSprite()  
  grav_gun.Position = Vector(player.Position.X + (math.cos(angle) * 25),  player.Position.Y + (math.sin(angle) * 25) - 10);
  grav_gun.SpriteRotation = math.deg(angle)
  -- grav_gun.PositionOffset = Vector(25,-10)

  if enemy_grabbed ~= nil then
    if grabbed_flag then
   sprite:Play("grav_gun_charge", true)
    
    trianglePoints = grav_gun_mod:getTrianglePoints(player.Position.X, player.Position.Y, angle, 90)
    new_position_vector = trianglePoints
    enemy_grabbed.Position = new_position_vector
    else
      if counter <= delta_move then
        counter = counter + 1
        enemy_grabbed.Position =  lerp(enemy_grabbed.Position,thrown_vector,1/delta_move)

        for i = 1, #entities do
          if entities[i]:IsEnemy() and enemy_grabbed.Position:Distance(entities[i].Position) < 50 then
            entities[i]:TakeDamage(5 + (player.Damage  + player.ShotSpeed * 5)/5,0, EntityRef(enemy_grabbed), 10)
          end
        end
      else
        enemy_grabbed = nil
      end
    end
  
  end
  else
  sprite:Play("grav_gun_idle",true)
  end

  -- DEBUG SHIT
  local entities = Isaac.GetRoomEntities()
  local debug_offset = 20
  Isaac.RenderText( "angle:" .. angle , 100, 10, 255,55,55,255 )
  Isaac.RenderText(player.Position.X .. ", " .. player.Position.Y, 10, debug_offset, 255, 55, 55, 255)
  grav_gun_mod:asciiDebug(createPolygon())
end

function ResetGun()
  if grav_gun~=nil then
    grav_gun:Remove()
    grav_gun = nil
  end
end


function lerp(a,b,t)
  return a + (b -a) * t
end
function grav_gun_mod:insidePolygon(point, polygon)
  --Reference http://alienryderflex.com/polygon/ worked most of the time so I opted for the barycentric technique explained further in..
  --https://blogs.msdn.microsoft.com/rezanour/2011/08/07/barycentric-coordinates-and-point-in-triangle-tests/
  local u = polygon[2] - polygon[1]
  local v = polygon[3] - polygon[1]
  local w = point - polygon[1]

  local vCrossW = v:Cross(w)
  local vCrossU = v:Cross(u)

  if w:Dot(u) < 0  then
    return false
  end

  local uCrossW = u:Cross(w)
  local uCrossV = u:Cross(v)

  if(uCrossW * uCrossV < 0)then
    return false
  end

  local r = vCrossW / uCrossV
  local t = uCrossW / uCrossV

  return (r + t <= 1) and polygon[1]:Distance(point) <= 200
end

function grav_gun_mod:asciiDebug(polygon)
  for i=1, #polygon do
    local screenVec = Isaac.WorldToRenderPosition(polygon[i])
    Isaac.RenderText("X",screenVec.X, screenVec.Y, 255,55,55,255)
  end

  local entities = Isaac.GetRoomEntities()
  for i = 1, #entities do
    if entities[i]:IsEnemy() then
      local debugVec = Isaac.WorldToRenderPosition(entities[i].Position)
      Isaac.RenderText(tostring(grav_gun_mod:insidePolygon(entities[i].Position,createPolygon())), debugVec.X, debugVec.Y, 255,50,50,255)
    end
  end
end

function createPolygon()
  local player = Isaac.GetPlayer(0)
  local triangleOffset = math.rad(27.5)
  local radius = 250
  return {player.Position, -- Have reference to self (player) to form a triangle
          grav_gun_mod:getTrianglePoints(player.Position.X, player.Position.Y, (angle + triangleOffset), radius),
          grav_gun_mod:getTrianglePoints(player.Position.X, player.Position.Y, (angle - triangleOffset), radius)}
end

function grav_gun_mod:getTrianglePoints(X,Y,angle_with_offset, radius)
  return Vector( X + (radius * math.cos(angle_with_offset)), Y + (radius * math.sin(angle_with_offset)))
end

function grav_gun_mod:item_use()
  if grabbed_flag and enemy_grabbed ~= nil  then
    grav_gun_mod:shoot()
  else
    grav_gun_mod:charge()
  end
end

function grav_gun_mod:shoot()
  local player = Isaac.GetPlayer(0)
  local distance = 350
  counter = 0
  thrown_vector = Vector(enemy_grabbed.Position.X + math.cos(angle) * distance * player.ShotSpeed , enemy_grabbed.Position.Y + math.sin(angle) * distance * player.ShotSpeed)
  grabbed_flag = false
end


function grav_gun_mod:charge()
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities()
  local closest_enemy = nil
  local closest_distance = 200
  for i=1,#entities do
    if entities[i]:IsEnemy() and not entities[i]:IsBoss() and #entities > 0 then
      local distance = player.Position:Distance(entities[i].Position)
      if grav_gun_mod:insidePolygon(entities[i].Position, createPolygon()) then
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
    enemy_grabbed:AddSlowing(EntityRef(enemy_grabbed),10000, 9999, Color(10,10,10,10,10,10,10))
    enemy_grabbed:AddFreeze(EntityRef(enemy_grabbed),10000)
  end
end

grav_gun_mod:AddCallback(ModCallbacks.MC_POST_RENDER, grav_gun_mod.render)
grav_gun_mod:AddCallback(ModCallbacks.MC_USE_ITEM, grav_gun_mod.item_use, grav_gun_item)
Isaac.DebugString("Mod was successfully loaded")