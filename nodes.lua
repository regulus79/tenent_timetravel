
local update_script={}


update_script.timeline={}

minetest.register_on_dignode(function(pos,oldnode,digger)
    if oldnode.name=="tenent_timetravel:reverser" then
        return
    end
    local update_interval=tenent_timetravel.update_interval
    rounded_time=update_interval*math.floor(tenent_timetravel.current_time/update_interval+0.5)
    minetest.after(tenent_timetravel.update_interval, function()
        if tenent_timetravel.time_rate>0 then
            if not update_script.timeline[rounded_time] then
                update_script.timeline[rounded_time]={{pos=pos,oldnode=oldnode,newnode="air"}}
            else
                table.insert(update_script.timeline[rounded_time],{pos=pos,oldnode=oldnode,newnode="air"})
            end
        else
            if not update_script.timeline[rounded_time] then
                update_script.timeline[rounded_time]={{pos=pos,oldnode="air",newnode=oldnode}}
            else
                table.insert(update_script.timeline[rounded_time],{pos=pos,oldnode="air",newnode=oldnode})
            end
        end
    end)
end)

minetest.register_on_placenode(function(pos,newnode,placer,oldnode)
    if newnode.name=="tenent_timetravel:reverser" then
        return
    end
    local update_interval=tenent_timetravel.update_interval
    rounded_time=update_interval*math.floor(tenent_timetravel.current_time/update_interval+0.5)
    minetest.after(tenent_timetravel.update_interval, function()
        if tenent_timetravel.time_rate>0 then
            if not update_script.timeline[rounded_time] then
                update_script.timeline[rounded_time]={{pos=pos,oldnode=oldnode,newnode=newnode}}
            else
                table.insert(update_script.timeline[rounded_time],{pos=pos,oldnode=oldnode,newnode=newnode})
            end
        else
            if not update_script.timeline[rounded_time] then
                update_script.timeline[rounded_time]={{pos=pos,oldnode=newnode,newnode=oldnode}}
            else
                table.insert(update_script.timeline[rounded_time],{pos=pos,oldnode=newnode,newnode=oldnode})
            end
        end
    end)
end)


update_script.update=function(rounded_time)
    local nodechanges=update_script.timeline[rounded_time]
    if nodechanges then
        if tenent_timetravel.time_rate>0 then
            for _,nodechange in pairs(nodechanges) do
                if nodechange.pos and nodechange.newnode and nodechange.newnode.name then
                    minetest.set_node(nodechange.pos,nodechange.newnode)
                end
            end
        else
            for _,nodechange in pairs(nodechanges) do
                if nodechange.pos and nodechange.oldnode and nodechange.oldnode.name then
                    minetest.set_node(nodechange.pos,nodechange.oldnode)
                end
            end
        end
    end
end

update_script.reverse=function()
end

return update_script