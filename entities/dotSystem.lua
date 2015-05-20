DotSystem = class('DotSystem')

function DotSystem:initialize()
	self.dots = {}
	
	self.maxG = .5 -- prevents gravity from causing objects to go infinitely fast as they get infinitely close
	self.minG = -.5 -- most acceleration a repel object can have
	
	-- changable variables
	self.limit = false -- if angles of entities should be limited
	self.directions = 8 -- number of directions an object can move in if self.limit is true
	self.traceAlpha = 255
	self.traceBrightness = .4 -- percent
	self.arrowWidth = 4
	
	-- do not change
	self.spawning = false -- true while dragging a starting velocity to create an object
	self.spawnX = 0
	self.spawnY = 0
	self.special = false
end

function DotSystem:update(dt, freeze)
	if not freeze then
		for i, dot in ipairs(self.dots) do -- iterate through each object and add together total gravity based on every other object
			local gx, gy = 0, 0
			for j, dot2 in ipairs(self.dots) do
				if i ~= j then -- different objects
					local dist = math.dist(dot.x, dot.y, dot2.x, dot2.y)
					local angle = math.angle(dot.x, dot.y, dot2.x, dot2.y)
					
					local g = dot2.mass/(dist^2) -- gravity formula
					if dot2.repel then g = g * -1 end
					if g > self.maxG then g = self.maxG end
					if g < self.minG then g = self.minG end
					
					gx = gx + math.cos(angle)*g
					gy = gy + math.sin(angle)*g
					
					if game.absorb and dist < (dot.size + dot2.size) then -- objects overlap, one is absorbed
						if dot.mass > dot2.mass then -- reverse these two for fun
							self:absorbObject(dot, dot2, dist)
						elseif dot2.mass > dot.mass then
							self:absorbObject(dot2, dot, dist)
						end -- nothing happens if 2 objects are the same mass
					end
				end
			end
		
			dot.gx = gx
			dot.gy = gy
		end
	end
	
	-- delete dead objects
	for i = #self.dots, 1, -1 do
		local dot = self.dots[i]
		if dot.destroy then
			table.remove(self.dots, i)
			
			-- fix camera target
			if i == game.camera.target then
				if game.camera.targetBool then
					if #self.dots <= game.camera.target and game.camera.target > 1 then
						game.camera.target = game.camera.target - 1
					end
					
					if #self.dots == 0 then
						game.UI:updateButton('Follow')
					end
				end
			elseif i < game.camera.target then
				game.camera.target = game.camera.target - 1
			end
		end
	end
	
	if not freeze then
		for i, dot in ipairs(self.dots) do
			dot:update(dt)
		end
		
		if game.lines then -- draw line traces
			game.canvas:renderTo(function()
				love.graphics.push()
				love.graphics.translate(game.camera.x, game.camera.y)
				
				love.graphics.setLineWidth(game.traceWidth)
				
				for i, dot in ipairs(self.dots) do
					local brightness = self.traceBrightness
					local r = dot.color[1] + math.floor(brightness * (255-dot.color[1] ))
					local g = dot.color[2] + math.floor(brightness * (255-dot.color[2] ))
					local b = dot.color[3] + math.floor(brightness * (255-dot.color[3] ))
					love.graphics.setColor(r, g, b, self.traceAlpha)
					love.graphics.line(dot.lastX - game.camera.x, dot.lastY - game.camera.y, dot.x - game.camera.x, dot.y - game.camera.y) -- draws a line between each objects current and last point onto the canvas
				end
				
				love.graphics.pop()
			end)
		end
	end
	
	-- if ctrl is pressed, self.special is true
	if self.spawning and love.keyboard.isDown('lctrl', 'rctrl') then
		self.special = true
	else
		self.special = false
	end
end

function DotSystem:absorbObject(dot, dot2, dist) -- dot.mass always greater than dot2.mass
	local overlap = (dot.size+dot2.size)-dist -- distance shared between both objects
	
	if overlap > 0 and dot.size > 0 and dot2.size > 0 then
		local dot2Percent = overlap/dot2.size -- distance shared / total size
		local massLoss = dot2.mass * dot2Percent -- mass taken away is based on the percent of size taken away
		
		if overlap > dot2.size then overlap = dot2.size end
		if massLoss > dot2.mass then massLoss = dot2.mass end
		
		local dot2Initial = dot2.size
		local dot2Final = dot2.size - overlap
		
		-- Area1Final = Area1Initial + (Area2Initial - Area2Final)
		dot.size = math.sqrt(dot.size^2 + dot2Initial^2 - dot2Final^2) -- based on area
		dot2.size = dot2.size - overlap
		dot.mass = dot.mass + massLoss
		dot2.mass = dot2.mass - massLoss
		
		if dot2.mass <= 0 or dot2.size <= 0 then -- if nothing is left - destroy
			dot2.destroy = true
		end
		
		if dot.mass > dot.massMax then dot.massMax = dot.mass end
		if dot2.mass < dot2.massMin then dot2.massMin = dot2.mass end
	end
end

function DotSystem:mousepressed(x, y, mbutton) -- will always be a left click
	local clicked = false
	for i, object in ipairs(self.dots) do
		if math.dist(x, y, object.x, object.y) <= object.size then -- set it to follow
			clicked = true
			game.UI:updateButton('Follow', i)
			break
		end
	end
	
	if not clicked then
		self.spawning = true
		self.spawnX = x
		self.spawnY = y
	end
end

function DotSystem:mousereleased(x, y, mbutton, spawnObjectName)
	if self.spawning then
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
			if special then -- super
				table.insert(self.dots, Ship:new(self.spawnX, self.spawnY, angle, speed, directions, false, true))
			else
				table.insert(self.dots, Ship:new(self.spawnX, self.spawnY, angle, speed, directions, false))
			end
		elseif spawnObjectName == 'repel ship' then
			if special then -- super
				table.insert(self.dots, Ship:new(self.spawnX, self.spawnY, angle, speed, directions, true, true))
			else
				table.insert(self.dots, Ship:new(self.spawnX, self.spawnY, angle, speed, directions, true))
			end
		elseif spawnObjectName == 'planet' then
			if special then -- super
				table.insert(self.dots, Planet:new(self.spawnX, self.spawnY, angle, speed, directions, false, true))
			else
				table.insert(self.dots, Planet:new(self.spawnX, self.spawnY, angle, speed, directions, false))
			end
		elseif spawnObjectName == 'repel planet' then -- repel
			if special then -- super
				table.insert(self.dots, Planet:new(self.spawnX, self.spawnY, angle, speed, directions, true, true))
			else
				table.insert(self.dots, Planet:new(self.spawnX, self.spawnY, angle, speed, directions, true))
			end
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