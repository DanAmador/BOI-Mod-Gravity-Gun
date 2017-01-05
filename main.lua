
local gravgun = RegisterMod("GravityGun",1)

function gravgun:render()

Isaac.RenderText("gravgun test", 100, 100, 255, 0, 0, 0)
end

gravgun:AddCallback(ModCallbacks.MC_POST_RENDER, gravgun.render)
Isaac.DebugString("Mod was successfully loaded")
