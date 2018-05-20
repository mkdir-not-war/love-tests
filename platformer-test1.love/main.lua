function love.load()
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 9.81*64, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	objects = {}
	ballgrounded = false

	-- ground
	objects.ground = {}
	objects.ground.body = love.physics.newBody(
		world, 
		650/2, 650-50/2)
	objects.ground.shape = love.physics.newRectangleShape(
		650, 50)
	objects.ground.fixture = love.physics.newFixture(
		objects.ground.body,
		objects.ground.shape)
	objects.ground.fixture:setUserData("ground")

	-- ball
	objects.ball = {}
	objects.ball.body = love.physics.newBody(
		world, 
		650/2, 650/2, 
		"dynamic")
	objects.ball.shape = love.physics.newCircleShape(
		20)
	objects.ball.fixture = love.physics.newFixture(
		objects.ball.body,
		objects.ball.shape,
		1) -- density = 1
	--objects.ball.fixture:setRestitution(0.9)
	objects.ball.fixture:setUserData("ball")

	-- blocks

	-- initial graphics setup
	love.graphics.setBackgroundColor(0.41, 0.53, 0.97)
	love.window.setMode(650, 650) -- no fullscreen, vsync on, no AA
end

function beginContact(a, b, coll)
	-- a is the fixture object
	-- b is the second fixture object
	-- coll is the contact object that was created
	if a:getUserData() == "ball" and b:getUserData() == "ground" then
		ballgrounded = true
	end
end

function endContact(a, b, coll)
	if a:getUserData() == "ball" and b:getUserData() == "ground" then
		ballgrounded = false
	end
end

function preSolve(a, b, coll)

end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
	-- normalimpulse is impulse applied along the normal
	-- tangentimpulse is impulse applied along the tangent
end

function love.keypressed(key)
	if key == "right" then
		objects.ball.body:setLinearVelocity(50, 0)
	elseif key == "left" then
		objects.ball.body:setLinearVelocity(-50, 0)
	elseif key == "escape" then
		love.event.quit()
	elseif key == "up" and ballgrounded then
		objects.ball.body:setLinearVelocity(50, 0)
	end
end

function love.keyreleased(key)
	if key == "right" then
		objects.ball.body:setLinearVelocity(0, 0)
	elseif key == "left" then
		objects.ball.body:setLinearVelocity(0, 0)
	elseif key == "up" then
		objects.ball.body:setLinearVelocity(0, 0)
	end
end

function love.update(dt)
	world:update(dt) -- "this puts the world into motion"

	--[[
	-- input handling
	if love.keyboard.isDown("right") then
		objects.ball.body:applyForce(400, 0)
	elseif love.keyboard.isDown("left") then
		objects.ball.body:applyForce(-400, 0)
	elseif love.keyboard.isDown("up") then
		objects.ball.body:setPosition(650/2, 650/2)
		objects.ball.body:setLinearVelocity(0, 0)
	end
	]]--
end

function love.draw()
  love.graphics.setColor(0.28, 0.63, 0.05) 
  love.graphics.polygon(
  "fill", 
  objects.ground.body:getWorldPoints(
  objects.ground.shape:getPoints())) 
 
  love.graphics.setColor(0.76, 0.18, 0.05) 

  love.graphics.circle(
  	"fill", 
  	objects.ball.body:getX(), 
  	objects.ball.body:getY(), 
  	objects.ball.shape:getRadius())
 
 --[[
  love.graphics.setColor(0.20, 0.20, 0.20) 
  love.graphics.polygon(
  	"fill", 
  	objects.block1.body:getWorldPoints(
  		objects.block1.shape:getPoints()))
  love.graphics.polygon(
  	"fill", 
  	objects.block2.body:getWorldPoints(
  		objects.block2.shape:getPoints()))
  ]]--
end