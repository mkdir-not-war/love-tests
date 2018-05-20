Fireball = {}
platform = {}
player = {}

function love.load()
	platform = {width = love.graphics.getWidth(),
				height = love.graphics.getHeight(),
				x = 0,
				y = love.graphics.getHeight() / 2}
	player = {x = love.graphics.getWidth() / 2,
				y = love.graphics.getHeight() / 2,
				speed = 200,
				img = love.graphics.newImage('supfool.png'),
				width = 64,
				height = 64,
				direction = 1,
				canFireMagic = true,
				magicMaxTimer = 0.2,
				magicTimer = 0.2,
				ground = love.graphics.getHeight() / 2,
				y_velocity = 0,
				x_velocity = 0,
				jump_height = -800,
				gravity = -1600}

	fireball = {input = 'space',
				img = love.graphics.newImage('fireball.png'),
				width = 24,
				height = 24,
				x = -1,
				y = -1,
				speed = 400,
				x_velocity = 0,
				y_velocity = 0,
				dist_travelled = 0,
				max_dist = 300}

	goomba = {img = love.graphics.newImage('Goomba.png'),
			x = -1,
			y = -1}

	magiconscreen = {}
	enemiesonscreen = {}

end

function love.keyreleased(key)
	if key == 'w' and player.y_velocity <= 0 then
		-- dampen the jump significantly
		player.y_velocity = player.y_velocity / 4
	elseif key == 'a' then
		if love.keyboard.isDown('d') then
			player.x_velocity = 1
			player.direction = 1
		else
			player.x_velocity = 0
		end
	elseif key == 'd' then
		if love.keyboard.isDown('a') then
			player.x_velocity = -1
			player.direction = -1
		else
			player.x_velocity = 0
		end
	end
end

function love.keypressed(key)
	if key == 'd' then
		if player.x < (love.graphics.getWidth() - player.width) then
			player.x_velocity = 1
			player.direction = 1
		end
	elseif key == 'a' then
		if player.x > 0 then 
			player.x_velocity = -1
			player.direction = -1
		end
	elseif key == 'w' then
		if player.y == player.ground then
			player.y_velocity = player.jump_height
		end
	elseif key == fireball.input then
		if player.canFireMagic then
			player.canFireMagic = false
			spawnFireball(player.x + player.direction * 10,
						player.y - player.height/2,
						player.direction)
		end
	elseif key == 'escape' then
		love.event.quit()
	end
end

function Fireball:new(obj)
	o = copy(obj) or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function copy(f)
	local meta = getmetatable(f)
	local target = {}
	for k, v in pairs(f) do target[k] = v end
	setmetatable(target, meta)
	return target
end

function spawnFireball(x, y, vel)
	local newfireball = Fireball:new(fireball)

	newfireball.x = x
	newfireball.y = y
	newfireball.x_velocity = vel

	table.insert(magiconscreen, newfireball)
end

function updatePlayer(dt)
	-- apply y forces
	player.y = player.y + player.y_velocity * dt
	player.y_velocity = player.y_velocity - player.gravity * dt

	-- apply x forces
	player.x = player.x + player.x_velocity * (player.speed * dt)
 
 	-- collide with ground
	if player.y > player.ground then
		player.y_velocity = 0
    	player.y = player.ground
	end

	-- update magic timer
	if player.magicTimer > 0 then
		player.magicTimer = player.magicTimer - dt
	else
		player.canFireMagic = true
	end
end

function collideRect(a, b)
	return (a.x + a.width > b.x and 
			a.x < b.x + b.width and 
			a.y < b.y + b.height and
			a.y + a.height > b.y)
end

function updateMagics(dt)
	local i=1
	while i<=#magiconscreen do
		magic = magiconscreen[i]
		magic.x = magic.x + magic.x_velocity * (magic.speed * dt)
		magic.dist_travelled = (
			magic.dist_travelled + magic.x_velocity * (
				magic.speed * dt))
		if magic.dist_travelled > magic.max_dist then
			table.remove(magiconscreen, i)
		else
			i = i + 1
		end
	end
end
 
function love.update(dt)
	updatePlayer(dt)
	updateMagics(dt)
end
 
function love.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', 
		platform.x, platform.y, platform.width, platform.height)
 
	love.graphics.draw(player.img, 
		player.x - player.width/2 * -player.direction, 
		player.y - player.height/2, 
		0, 
		player.width/player.img:getWidth() * -player.direction, 
		player.height/player.img:getHeight(), 
		0, 32)

	for i, magic in ipairs(magiconscreen) do
		love.graphics.draw(magic.img, magic.x, magic.y, 0, 
			magic.width/magic.img:getWidth(),
			magic.height/magic.img:getHeight())
	end
end