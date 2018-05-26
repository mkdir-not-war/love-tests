--[[
	https://love2d.org/wiki/Tutorial:Networking_with_UDP
]]--

local socket = require "socket"
local udp = socket.udp()



local world = {} -- the empty world-state
local data, msg_or_ip, port_or_nil
local entity, cmd, parms

function love.load()
	udp:settimeout(0)
	udp:setsockname('*', 8888)
	print "Beginning server loop."
end

function love.update()
	data, msg_or_ip, port_or_nil = udp:receivefrom()
	if data then
		-- more of these funky match paterns!
		entity, cmd, parms = data:match("^(%S*) (%S*) (.*)")

		if cmd == 'move' then
			local x, y = parms:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
			assert(x and y) -- validation is better, but asserts will serve.
			-- don't forget, even if you matched a "number", the result is still a string!
			-- thankfully conversion is easy in lua.
			x, y = tonumber(x), tonumber(y)
			-- and finally we stash it away
			local ent = world[entity] or {x=0, y=0}
			world[entity] = {x=ent.x+x, y=ent.y+y}
		elseif cmd == 'at' then
			local x, y = parms:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
			assert(x and y) -- validation is better, but asserts will serve.
			x, y = tonumber(x), tonumber(y)
			world[entity] = {x=x, y=y}
		elseif cmd == 'update' then
			for k, v in pairs(world) do
				udp:sendto(string.format("%s %s %d %d", k, 'at', v.x, v.y), msg_or_ip,  port_or_nil)
			end
		elseif cmd == 'quit' then
			love.event.quit()
		else
			print("unrecognised command:", cmd)
		end
	elseif msg_or_ip ~= 'timeout' then
		error("Unknown network error: "..tostring(msg))
	end
 
	socket.sleep(0.01)
end