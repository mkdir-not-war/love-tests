platform = {}
player = {}
 
function love.load()
	platform.width = love.graphics.getWidth()
	platform.height = love.graphics.getHeight()
 
	platform.x = 0
	platform.y = platform.height / 2
 
	player.x = love.graphics.getWidth() / 2
	player.y = love.graphics.getHeight() / 2
 
	player.speed = 200
 
	player.img = love.graphics.newImage('supfool.png')

	player.width = 64
	player.height = 64
 
	player.ground = player.y
 
	player.y_velocity = 0
	player.x_velocity = 0
 
	player.jump_height = -800
	player.gravity = -1200
end

function love.keyreleased(key)
	if key == 'w' and player.y_velocity <= 0 then
		-- dampen the jump significantly
		player.y_velocity = player.y_velocity / 4
	elseif key == 'a' then
		if love.keyboard.isDown('d') then
			player.x_velocity = 1
		else
			player.x_velocity = 0
		end
	elseif key == 'd' then
		if love.keyboard.isDown('a') then
			player.x_velocity = -1
		else
			player.x_velocity = 0
		end
	end
end

function love.keypressed(key)
	if key == 'd' then
		if player.x < (love.graphics.getWidth() - player.width) then
			player.x_velocity = 1
		end
	elseif key == 'a' then
		if player.x > 0 then 
			player.x_velocity = -1
		end
	elseif key == 'w' then
		if player.y == player.ground then
			player.y_velocity = player.jump_height
		end
	elseif key == 'escape' then
		love.event.quit()
	end
end
 
function love.update(dt)
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
end
 
function love.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)
 
	love.graphics.draw(player.img, player.x, player.y, 0, 
		player.width/player.img:getWidth(), 
		player.height/player.img:getHeight(), 
		0, 32)
end