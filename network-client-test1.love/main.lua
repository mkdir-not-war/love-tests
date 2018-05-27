--[[
	https://love2d.org/wiki/Tutorial:Networking_with_UDP
]]--

local socket = require "socket"
local io = require "io"

-- server address and port
local port = 8888
local address = "localhost"

local entity
local updaterate = 0.1

local world = {}
local t

function love.load()
	udp = socket.udp()

	-- set non-blocking "connection"
	udp:settimeout(0)

	-- Because clients only talk to the single server, 
	-- they can set peer name.
	print("input IP address of server <xxx.xxx.xxx.xxx>:")
	local addr = io.read()
	if addr ~= nil then address = addr end
	udp:setpeername(address, port)

	math.randomseed(os.time())
	entity = tostring(math.random(99999))

	local dg = string.format("%s %s %d %d", entity, 'at', 320, 240)
	udp:send(dg)

	t = 0
end

function love.update(dt)
	t = t + dt

	if t > updaterate then
		local x, y = 0, 0
		if love.keyboard.isDown('w') then 	y=y-(20*t) end
		if love.keyboard.isDown('s') then 	y=y+(20*t) end
		if love.keyboard.isDown('a') then 	x=x-(20*t) end
		if love.keyboard.isDown('d') then 	x=x+(20*t) end
		if love.keyboard.isDown('escape') then love.event.quit() end
		local dg = string.format("%s %s %f %f", entity, 'move', x, y)
		udp:send(dg)

		local dg = string.format("%s %s $", entity, 'update')
		udp:send(dg)
 
		t=t-updaterate -- set t for the next round
	end

	repeat
		data, msg = udp:receive()
		if data then
			ent, cmd, parms = data:match("^(%S*) (%S*) (.*)")
			if cmd == 'at' then
				local x, y = parms:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
				assert(x and y) -- validation is better, but asserts will serve.
				x, y = tonumber(x), tonumber(y)
				world[ent] = {x=x, y=y}
			elseif cmd == 'disconnect' then
				-- delete from world
				table.remove(world, entity)
				print(entity, " removed")
			else
				print("unrecognised command:", cmd)
			end
 
		elseif msg ~= 'timeout' then 
			error("Network error: "..tostring(msg))
		end
	until not data
end

function love.draw()
	love.graphics.setColor(0.9, 0.63, 0.05)
	love.graphics.print('hello world', 10, 10)
	for k, v in pairs(world) do
		love.graphics.print(k, v.x, v.y)
	end
end

function love.quit()
	local dg = string.format("%s %s $", entity, 'disconnect')
	udp:send(dg)
end
