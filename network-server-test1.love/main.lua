--[[
	https://love2d.org/wiki/Tutorial:Networking_with_UDP
]]--

local socket = require "socket"
local udp = socket.udp()

local world = {} -- the empty world-state
local connectedsockets = {}
local data, msg_or_ip, port_or_nil
local entity, cmd, parms

function love.load()
	udp:settimeout(0)
	udp:setsockname('*', 8888)
	print "Beginning server loop."
end

function removeentity(entity, msg_or_ip)
	for k in pairs(world[entity]) do
		world[entity][k] = nil
	end
	world[entity] = nil
	connectedsockets[msg_or_ip] = nil
end

function love.update()
	data, msg_or_ip, port_or_nil = udp:receivefrom()
	if not connectedsockets[msg_or_ip] then
		connectedsockets[msg_or_ip] = port_or_nil
	end

	if data then
		-- more of these funky match paterns!
		ent, cmd, parms = data:match("^(%S*) (%S*) (.*)")

		if cmd == 'move' then
			local x, y = parms:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
			assert(x and y) -- validation is better, but asserts will serve.
			-- don't forget, even if you matched a "number", the result is still a string!
			-- thankfully conversion is easy in lua.
			x, y = tonumber(x), tonumber(y)
			-- and finally we stash it away
			local entity = world[ent] or {x=0, y=0}
			world[ent] = {x=entity.x+x, y=entity.y+y}
		elseif cmd == 'at' then
			local x, y = parms:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
			assert(x and y) -- validation is better, but asserts will serve.
			x, y = tonumber(x), tonumber(y)
			world[ent] = {x=x, y=y}
		elseif cmd == 'update' then
			for k, v in pairs(world) do
				udp:sendto(string.format("%s %s %d %d", k, 'at', v.x, v.y), msg_or_ip,  port_or_nil)
			end
		elseif cmd == 'disconnect' then
			-- remove the entity from world
			removeentity(ent, msg_or_ip)
			for k, v in pairs(connectedsockets) do
				udp:sendto(string.format("%s %s $", ent, 'disconnect'), k,  v)	
			end
			--[[print(entity, " removed")
			for k, v in pairs(world) do
				print(k)
				for k2, v2 in pairs(v) do
					print(k2, v2)
				end
			end]]--
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