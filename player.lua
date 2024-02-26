
local update_script={}


update_script.timeline={}

update_script.update=function(rounded_time)
    local player=minetest.get_player_by_name("singleplayer")
    if player then
        update_script.timeline[rounded_time]={
            pos=player:get_pos(),
            yaw=player:get_look_horizontal(),
            animation=player:get_animation()
        }
    end
end

update_script.reverse=function()
    local player=minetest.get_connected_players()[1]
    local player_props=player:get_properties()
    local obj=minetest.add_entity(player:get_pos(),"tenent_timetravel:tenent_dummy")
    obj:set_properties(player_props)
    local entity=obj:get_luaentity()
    entity._timeline=update_script.timeline

    mint=10e10
    maxt=-10e10
    for t,_ in pairs(update_script.timeline) do
        if t>maxt then
            maxt=t
        end
        if t<mint then
            mint=t
        end
    end
    entity._min_time=mint
    entity._max_time=maxt


    update_script.timeline={}
end

return update_script