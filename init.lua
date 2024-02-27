
tenent_timetravel={}

tenent_timetravel.update_interval=0.2

tenent_timetravel.current_time=0
tenent_timetravel.time_rate=1

local effects=dofile(minetest.get_modpath("tenent_timetravel").."/effects.lua")

tenent_timetravel.update_scripts={
    player=dofile(minetest.get_modpath("tenent_timetravel").."/player.lua"),
    nodes=dofile(minetest.get_modpath("tenent_timetravel").."/nodes.lua"),
    reverser=dofile(minetest.get_modpath("tenent_timetravel").."/reverser.lua"),
}


minetest.register_entity("tenent_timetravel:tenent_dummy",{
    initial_properties={
        _timeline={},
        _min_time=0,
        _max_time=0,
    },
    on_step=function(self,dtime)
        local update_interval=tenent_timetravel.update_interval
        local time=tenent_timetravel.current_time
        local rounded_time=update_interval*math.floor(time/update_interval+0.5)
        if not self._timeline then
            self.object:remove()
            return
        end
        local props=self.object:get_properties()
        if not self._timeline[rounded_time] then
            return
        end

        if time<self._min_time or time>self._max_time then
            if props.is_visible then
                props.is_visible=false
                self.object:set_properties(props)
                effects.light_ball_flash(self.object:get_pos(),0.25)
            end
            return
        elseif not props.is_visible then
            props.is_visible=true
            self.object:set_properties(props)
            effects.light_ball_flash(self.object:get_pos(),0.25)
        end

        local update=self._timeline[rounded_time]
        --[[
        prev_time=math.floor(time/10^6/update_interval)*10^6*update_interval
        next_time=math.ceil(time/10^6/update_interval)*10^6*update_interval
        if prev_time<self._start_time or prev_time>self._end_time then
            prev_time=rounded_time
        end
        if next_time<self._start_time or next_time>self._end_time then
            next_time=rounded_time
        end
        --print(prev_i,next_i)
        prev_pos=self._timeline[prev_time].pos
        next_pos=self._timeline[next_time].pos
        prev_yaw=self._timeline[prev_time].yaw
        next_yaw=self._timeline[next_time].yaw
        t=(time-prev_time)/(next_time-prev_time)]]

        --self.object:set_pos(prev_pos+(next_pos-prev_pos)*t)
        --self.object:set_yaw(prev_yaw+(next_yaw-prev_yaw)*t)


        self.object:move_to(update.pos)
        self.object:set_yaw(update.yaw or 0)
        self.object:set_animation(update.animation)
    end
})


tenent_timetravel.reverse=function()
    tenent_timetravel.time_rate=tenent_timetravel.time_rate*-1
    for _,update_script in pairs(tenent_timetravel.update_scripts) do
        update_script.reverse()
    end
end

minetest.register_chatcommand("reverse",{
    description="Reverse Time",
    func=function(name)
        tenent_timetravel.reverse()
    end
})

minetest.register_craftitem("tenent_timetravel:reverse",{
    description="Reverse Time",
    inventory_image="reverse_item.png",
    on_use=function(itemstack,user)
        tenent_timetravel.reverse()
    end
})

local time_since_update=0
minetest.register_globalstep(function(dtime)
    time_since_update=time_since_update+dtime

    tenent_timetravel.current_time=tenent_timetravel.current_time+dtime*tenent_timetravel.time_rate

    local update_interval=tenent_timetravel.update_interval
    if time_since_update>tenent_timetravel.update_interval then
        time_since_update=0
        rounded_time=update_interval*math.floor(tenent_timetravel.current_time/update_interval+0.5)
        for _,update_script in pairs(tenent_timetravel.update_scripts) do
            update_script.update(rounded_time)
        end
    end
end)