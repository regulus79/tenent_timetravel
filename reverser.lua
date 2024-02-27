
local update_script={}

update_script.timeline={}

local sign=function(x)
    if x>0 then
        return 1
    elseif x<0 then
        return -1
    else
        return 0
    end
end


minetest.register_node("tenent_timetravel:reverser",{
    description="Reverser",
    drawtype="mesh",
    mesh="reverser_middle.obj",
    tiles={"reverser_texture.png"},
    groups={cracky=1},
    paramtype2="4dir",
    after_place_node=function(pos,placer,itemstack)
        local place_dir_horizontal=minetest.fourdir_to_dir(minetest.get_node(pos).param2):cross(vector.new(0,1,0))
        --minetest.set_node(pos+place_dir_horizontal,{name="default:dirt"})
        --minetest.set_node(pos-place_dir_horizontal,{name="default:dirt"})
        minetest.add_entity(pos+place_dir_horizontal*2,"tenent_timetravel:reverser_rotater",minetest.serialize({
            _max_angle=math.pi/2,
            _starting_angle=math.atan2(place_dir_horizontal.z,place_dir_horizontal.x)+math.pi
        }))
        minetest.add_entity(pos-place_dir_horizontal*2,"tenent_timetravel:reverser_rotater",minetest.serialize({
            _max_angle=-math.pi/2,
            _starting_angle=math.atan2(place_dir_horizontal.z,place_dir_horizontal.x)+math.pi
        }))
    end
})

minetest.register_entity("tenent_timetravel:reverser_rotater",{
    initial_properties={
        visual="mesh",
        mesh="reverser_rotater.obj",
        textures={"reverser_texture.png"},
        visual_size=vector.new(10,10,10),
    },
    _timeline={},
    _just_finished=false,
    _starting_angle=0,
    _current_angle=0, -- Angle relative to the starting angle
    _max_angle=math.pi/2, -- Will be negative/positive depending on side
    _player_in_range=false,
    _other=nil,
    on_activate=function(self,staticdata,dtime)
        self._timeline={}
        local sd=minetest.deserialize(staticdata)
        if sd then
            self._max_angle=sd._max_angle
            self._starting_angle=sd._starting_angle
        end
        local offset_of_other=vector.new(0,0,1):rotate(vector.new(0,-self._max_angle+self._starting_angle,0))*4
        for _,obj in pairs(minetest.get_objects_inside_radius(self.object:get_pos()+offset_of_other,0.1)) do
            if obj:get_luaentity().name=="tenent_timetravel:reverser_rotater" then
                self._other=obj
                obj:get_luaentity()._other=self.object
                break
            end
        end
    end,
    on_step=function(self,dtime)
        local player=minetest.get_player_by_name("singleplayer")
        local player_was_in_range=self._player_in_range
        local player_in_range_of_other=false
        local turn_direction=0
        if player and player:get_pos():distance(self.object:get_pos())<2 or self._other and self._other:get_pos() and player:get_pos():distance(self._other:get_pos())<2 then
            self._player_in_range=true
        else
            self._player_in_range=false
        end
        if player and self._other and self._other:get_pos() and player:get_pos():distance(self._other:get_pos())<2 then
            player_in_range_of_other=true
        else
            player_in_range_of_other=false
        end

        if not player then
            minetest.chat_send_all("what? player is nil?")
        end

        local is_timeline_event_soon=false
        for i,time in pairs(self._timeline) do
            local time_until=(time-tenent_timetravel.current_time)*tenent_timetravel.time_rate
            if time_until>0 and time_until<math.pi/2 then
                is_timeline_event_soon=true
            end
        end

        if (self._player_in_range or player_in_range_of_other or is_timeline_event_soon) and not self._just_finished  then
            turn_direction=1
        else
            turn_direction=-1
        end
        if not (self._player_in_range or player_in_range_of_other) and self._just_finished then
            self._just_finished=false
        end

        if turn_direction>0 and self._current_angle/self._max_angle<1 or turn_direction<0 and self._current_angle/self._max_angle>0 then
            self._current_angle=self._current_angle+sign(self._max_angle)*dtime*turn_direction
            -- causes buggy mvoements
            --if player and player:get_pos():distance(self.object:get_pos())<2 then
                --player:set_look_horizontal(player:get_look_horizontal()+sign(self._max_angle)*dtime*turn_direction)
            --end
        end

        -- On finish turning
        if turn_direction>0 and self._current_angle/self._max_angle>1 then
            if player:get_pos():distance(self.object:get_pos())<2 and self._other and not self._other:get_luaentity()._just_finished then
                tenent_timetravel.reverse()
                player:set_pos(player:get_pos()-self.object:get_pos()+self._other:get_pos())
                self._just_finished=true
                self._other:get_luaentity()._just_finished=true
                table.insert(self._timeline,tenent_timetravel.current_time)
                table.insert(self._other:get_luaentity()._timeline,tenent_timetravel.current_time)
            end
        end
        self.object:set_rotation(vector.new(0,self._starting_angle+self._current_angle,0))
    end,
    get_staticdata=function(self)
        return minetest.serialize({
            _max_angle=self._max_angle,
            _starting_angle=self._starting_angle
        })
    end
})


update_script.update=function(rounded_time)
end

update_script.reverse=function()
end

return update_script