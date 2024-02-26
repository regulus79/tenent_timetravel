
local effects={}

minetest.register_entity("tenent_timetravel:light_ball_flash",{
    initial_properties={
        visual="mesh",
        mesh="regulus_light_ball.obj",
        textures={"regulus_light_ball.png"},
        use_texture_alpha=true,
        backface_culling=false,
        automatic_rotate=1,
        visual_size=vector.new(10,30,10),
        pointable=false,
        shaded=false,
        static_save=false,
    }
})


effects.light_ball_flash=function(pos,duration)
    local obj=minetest.add_entity(pos,"tenent_timetravel:light_ball_flash")
    minetest.after(duration,function()
        obj:remove()
    end)
end

return effects