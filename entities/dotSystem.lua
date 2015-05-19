DotSystem = class('DotSystem')

function DotSystem:initialize()
	self.dots = {}
	
	self.maxG = .5 -- prevents gravity from causing objects to go infinitely fast as they get infinitely close
	
	self.limit = false -- if angles of entities should be limited
	self.directions = 8 -- number of directions an object can move in if self.limit is true
	
	self.spawning = false -- true while dragging a starting velocity to create an object
	self.spawnX = 0
	self.spawnY = 0
	
	self.special = false
	
	self.traceAlpha = 255
	
	self.arrowWidth = 4
end

function DotSystem:update(dt)
	for i, dot in ipairs(self.dots) do -- iterate through each object and add together total gravity based on every other object
		local gx, gy = 0, 0
		for j, dot2 in ipairs(self.dots) do
			if i ~= j then -- different objects
				local dist = math.dist(dot.x, dot.y, dot2.x, dot2.y)
				local angle = math.angle(dot.x, dot.y, dot2.x, dot2.y)
				
				local g = dot2.mass/(dist^2) -- gravity formula
				if dot2.repel then
					g = g * -1
				end
				
				if g > self.maxG then g = self.maxG end
				gx = gx + math.cos(angle)*g
				gy = gy + math.sin(angle)*g
				
				if game.absorb and dist < (dot.size + dot2.size) then -- objects overlap, one is absorbed
					self:absorbObject(dot, dot2, dist)
				end
			end
		end
	
		dot.gx = gx
		dot.gy = gy
	end
	
	-- delete dead objects
	for i = #self.dots, 1, -1 do
		local dot = self.dots[i]
		if dot.destroy then
			table.remove(self.dots, i)
			
			if i == game.camera.target then
				if game.camera.targetBool then
					game.UI:updateButton('Follow')
				end
			end
		end
	end
	
	for i, dot in ipairs(self.dots) do
		dot:update(dt)
	end
	
	if game.lines then -- draw line traces
		game.canvas:renderTo(function()
			love.graphics.push()
			love.graphics.translate(game.camera.x, game.camera.y)
			
			love.graphics.setLineWidth(game.traceWidth)
			
			for i, dot in ipairs(self.dots) do
				love.graphics.setColor(dot.color[1], dot.color[2], dot.color[3], self.traceAlpha)
				love.graphics.line(dot.lastX - game.camera.x, dot.lastY - game.camera.y, dot.x - game.camera.x, dot.y - game.camera.y) -- draws a line between each objects current and last point on the canvas
			end
			
			love.graphics.pop()
		end)
	end
	
	-- if ctrl is pressed, self.special is true
	if self.spawning and love.keyboard.isDown('lctrl', 'rctrl') then
		self.special = true
	else
		self.special = false
	end
end

function DotSystem:absorbObject(dot, dot2, dist)
	local overlap = (dot.size+dot2.size)-dist -- distance shared between both objects
	if dot.mass > dot2.mass then
		local dot2Percent = overlap/dot2.size -- distance shared / total size
		local massLoss = dot2.mass * dot2Percent -- mass taken away is based on the percent of size taken away
		
		dot.size = dot.size + overlap / 100 -- increase size less drastically
		dot2.size = dot2.size - overlap
		dot.mass = dot.mass + massLoss
		dot2.mass = dot2.mass - massLoss
		
		if dot2.mass <= 0 or dot2.size <= 0 then -- if nothing is left - destroy
			dot2.destroy = true
		end
	elseif dot2.mass > dot.mass then
		local dotPercent = overlap/dot.size
		local massLoss = dot.mass * dotPercent
		
		dot2.size = dot2.size + overlap / 100
		dot.size = dot.size - overlap
		dot2.mass = dot2.mass + massLoss
		dot.mass = dot.mass - massLoss
		
		if dot.mass <= 0 or dot.size <= 0 then
			dot.destroy = true
		end
	end
end

function DotSystem:keypressed(key, isrepeat)
	
end

function DotSystem:mousepressed(x, y, mbutton)
	if mbutton == 'l' or mbutton == 'r' or mbutton == 'm' then
		self.spawning = true
		self.spawnX = x
		self.spawnY = y
	end
end

function DotSystem:mousereleased(x, y, mbutton, spawnObjectName)
	self.spawning = false
	
	local directions = self.directions
	if not self.limit then
		directions = 0
	end
	
	local vx = x - self.spawnX
	local vy = y - self.spawnY
	
	local angle = math.angle(0, 0, vx, vy)
	local speed = math.sqrt(vx^2 + vy^2)
	
	local special = false
	if love.keyboard.isDown('lctrl', 'rctrl') then
		special = true
	end
	
	if spawnObjectName == 'ship' then
		if special then -- massless
			table.insert(self.dots, Dot:new(self.spawnX, self.spawnY, angle, speed, 0, directions))
		else
			table.insert(self.dots, Dot:new(self.spawnX, self.spawnY, angle, speed, nil, directions))
		end
	elseif mbutton == 'r' or spawnObjectName == 'planet' then
		if special then -- gigantic
			table.insert(self.dots, Dot:new(self.spawnX, self.spawnY, angle, speed, nil, directions, true, true))
		else
			table.insert(self.dots, Dot:new(self.spawnX, self.spawnY, angle, speed, nil, directions, true))
		end
	elseif mbutton == 'm' or spawnObjectName == 'repel' then -- repel
		if special then -- gigantic
			table.insert(self.dots, Dot:new(self.spawnX, self.spawnY, angle, speed, nil, directions, true, true, true))
		else
			table.insert(self.dots, Dot:new(self.spawnX, self.spawnY, angle, speed, nil, directions, true, false, true))
		end
	end
end

function DotSystem:draw()
	for i, dot in ipairs(self.dots) do
		dot:draw()
	end
	
	if self.spawning then
		love.graphics.setColor(255, 0, 0)
		
		if self.special then -- blue line when creating special entities
			love.graphics.setColor(0, 0, 255)
		end
		
		-- spawn arrow
		love.graphics.setLineWidth(self.arrowWidth/game.camera.zoom)
		local newX, newY = game:convertCoordinates(love.mouse.getX(), love.mouse.getY())
		love.graphics.line(self.spawnX, self.spawnY, newX, newY) -- initial vector indicator when dragging
		local angle = math.angle(self.spawnX, self.spawnY, newX, newY)
		local turn = 30 -- degrees
		local length = 30/game.camera.zoom
		-- arrow head
		love.graphics.line(newX + math.cos(angle + math.rad(180-turn)) * length, newY + math.sin(angle + math.rad(180-turn)) * length, newX, newY, newX + math.cos(angle - math.rad(180-turn)) * length, newY + math.sin(angle - math.rad(180-turn)) * length)
	end
end