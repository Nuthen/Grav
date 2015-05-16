game = {}

function game:enter()
	love.graphics.setBackgroundColor(255, 255, 255) -- the white background makes all the other colors brighter due to alpha transparency

	
	self.help = true
	self.showCenter = true
	self.freeze = false
	self.hideObjects = false
	self.absorb = false
	self.traceWidth = 2
	local canvasScale = 16 -- scale factor of canvas relative to screen size
	
	
	self.canvas = love.graphics.newCanvas(love.graphics.getWidth()*canvasScale, love.graphics.getHeight()*canvasScale)
	
	self.startX = self.canvas:getWidth()/2 - love.graphics.getWidth()/2
	self.startY = self.canvas:getHeight()/2 - love.graphics.getHeight()/2
	
	self.canvas:setFilter('linear', 'linear') -- line traces will look a little clearer when zoomed
	
	-- camera is centered on the canvas
	self.camera = {x = self.startX, y = self.startY, zoom = 1, speed = 400, targetBool = false, target = 1} -- centers the camera at the center of the canvas
	
	self.dotSystem = DotSystem:new()
	
	--self.shader = love.graphics.newShader('shaders/sharpen.glsl')
	--self.shader:send('stepSize', {1/love.graphics:getWidth(), 1/love.graphics:getHeight()})
end

function game:update(dt)
	if not self.freeze then
		self.dotSystem:update(dt)
	end
	
	if self.camera.targetBool then -- focused camera
		if self.dotSystem.dots[self.camera.target] then
			self.camera.x = self.dotSystem.dots[self.camera.target].x - love.graphics.getWidth()/2
			self.camera.y = self.dotSystem.dots[self.camera.target].y - love.graphics.getHeight()/2
		end
	end
	
	local cameraX = self.camera.x
	local cameraY = self.camera.y
	
	local speed = self.camera.speed*dt
	if love.keyboard.isDown('lshift', 'rshift') then speed = speed * 2 end
	if love.keyboard.isDown('w', 'up') then self.camera.y = self.camera.y - speed end
	if love.keyboard.isDown('s', 'down') then self.camera.y = self.camera.y + speed end
	if love.keyboard.isDown('a', 'left') then self.camera.x = self.camera.x - speed end
	if love.keyboard.isDown('d', 'right') then self.camera.x = self.camera.x + speed end
	
	-- if camera is moved by the player, exit focused camera mode
	if self.camera.x ~= cameraX or self.camera.y ~= cameraY then
		self.camera.targetBool = false
	end
end

function game:keypressed(key, isrepeat)
    if console.keypressed(key) then
        return
    end
	
	-- toggle help text
	if key == 'f3' then
		if self.help then
			self.help = false
		else
			self.help = true
		end
	end
	
	-- toggle crosshair in the center
	if key == 'f4' then
		if self.showCenter then
			self.showCenter = false
		else
			self.showCenter = true
		end
	end
	
	-- reset everything
	if key == 'f5' then -- clear
		self.canvas:clear()
		self.dotSystem.dots = {}
		
		self:resetCamera()
	end
	
	-- move the camera to the origin
	if key == 'f9' then
		self:resetCamera()
	end
	
	-- show only line traces
	if key == 'f10' then
		if self.hideObjects then
			self.hideObjects = false
		else
			self.hideObjects = true
		end
	end
	
	-- bigger objects absorb smaller objects (Osmos)
	if key == 'f11' then
		if self.absorb then
			self.absorb = false
		else
			self.absorb = true
		end
	end
	
	-- pause simulation, useful for setting up objects
	if key == ' ' then
		if self.freeze then
			self.freeze = false
		else
			self.freeze = true
		end
	end
	
	-- activate and switch through entities to focus the camera on
	if #self.dotSystem.dots > 0 then
		if key == ',' then -- <
			if not self.camera.targetBool then
				self.camera.targetBool = true
				self.camera.target = 1
			elseif self.camera.target > 1 then
				self.camera.target = self.camera.target - 1
			else
				self.camera.target = #self.dotSystem.dots
			end
			
		elseif key == '.' then -- >
			if not self.camera.targetBool then
				self.camera.targetBool = true
				self.camera.target = 1
			elseif self.camera.target < #self.dotSystem.dots then
				self.camera.target = self.camera.target + 1
			else
				self.camera.target = 1
			end
		end
	end
	
	
	self.dotSystem:keypressed(key, isrepeat)
end

function game:resetCamera()
	self.camera.targetBool = false
	self.camera.target = 1
	self.camera.x = self.startX
	self.camera.y = self.startY
end

function game:mousepressed(x, y, mbutton)
    if console.mousepressed(x, y, mbutton) then
        return
    end
	
	if mbutton == 'wu' then
		self.camera.zoom = self.camera.zoom + .1
	elseif mbutton == 'wd' and self.camera.zoom > .2 then
		self.camera.zoom = self.camera.zoom - .1
	end
	
	local newX, newY = self:convertCoordinates(x, y)
	
	self.dotSystem:mousepressed(newX, newY, mbutton)
end

function game:mousereleased(x, y, button)
	local newX, newY = self:convertCoordinates(x, y)
	
	self.dotSystem:mousereleased(newX, newY, button)
end

function game:convertCoordinates(x, y)
	local zoom = self.camera.zoom

	-- change mouse coordinates to game coordinates
	x = x + self.camera.x
	y = y + self.camera.y
	
	-- translate to origin, scale, translate back
	x, y = x - self.camera.x - love.graphics.getWidth()/2, y - self.camera.y - love.graphics.getHeight()/2
	--error(x..' '..y)
	self.pressX = x
	self.pressY = y
	x, y = x / zoom, y / zoom
	self.releaseX = x
	self.releaseY = y
	x, y = x + self.camera.x + love.graphics.getWidth()/2, y + self.camera.y + love.graphics.getHeight()/2

	return x, y
end

function game:draw()
    love.graphics.setFont(font[32])
	love.graphics.setColor(255, 255, 255)
	love.graphics.setLineWidth(self.traceWidth)
	
	love.graphics.push()
	--love.graphics.setShader(self.shader)
	
	-- translate to origin, scale, translate back
	love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	love.graphics.scale(self.camera.zoom)
	love.graphics.translate(-love.graphics.getWidth()/2, -love.graphics.getHeight()/2)
	
	love.graphics.translate(-self.camera.x, -self.camera.y)
	
	if self.dotSystem.lines then -- draw line traces
		love.graphics.draw(self.canvas)
	end
	
	if not self.hideObjects then -- draw entities
		self.dotSystem:draw()
	end
	
	if self.showCenter then -- draw axis at the center
		love.graphics.setColor(0, 0, 0)
		local d = 50
		love.graphics.line(self.canvas:getWidth()/2 - d, self.canvas:getHeight()/2, self.canvas:getWidth()/2 + d, self.canvas:getHeight()/2)
		love.graphics.line(self.canvas:getWidth()/2, self.canvas:getHeight()/2 - d, self.canvas:getWidth()/2, self.canvas:getHeight()/2 + d)
	end
	
	--love.graphics.setShader()
	love.graphics.pop()
	
	love.graphics.setColor(13, 15, 122)
	love.graphics.print(love.timer.getFPS(), 5, 5)
	
	if self.help then
		local lineStr = 'off'
		if self.dotSystem.lines then lineStr = 'on' end
		love.graphics.print('Trace Lines (F1): '..lineStr, 5, 35)
		
		local lineStr = 'off'
		if self.dotSystem.limit then lineStr = 'on' end
		love.graphics.print('Limit Movement (F2): '..lineStr, 5, 65)
		
		love.graphics.print('Directions (+ / -): '..self.dotSystem.directions, 40, 95) -- indented
		
		
		love.graphics.print('Hide Help (F3)', 5, 125)
		
		local lineStr = 'off'
		if self.showCenter then lineStr = 'on' end
		love.graphics.print('Show Axis (F4): '..lineStr, 5, 155)
		
		love.graphics.print('Clear (F5)', 5, 185)
		
		love.graphics.print('Small mass (LMB [+ ctrl])', 5, 215)
		love.graphics.print('Large mass (RMB [+ ctrl])', 5, 245)
		love.graphics.print('Camera (WASD/Shift)', 5, 275)
		
		local lineStr = 'off'
		if self.freeze then lineStr = 'on' end
		love.graphics.print('Freeze (space): '..lineStr, 5, 305)
		
		love.graphics.print('Origin (F9)', 5, 335)
		love.graphics.print('Hide Objects (F10)', 5, 365)
		love.graphics.print('Zoom (wheel): '..self.camera.zoom, 5, 395)
		
		love.graphics.print('Entities: '..#self.dotSystem.dots, 5, 425)
		love.graphics.print('Entity Focus (< / >): '..tostring(self.camera.target), 5, 455)
		
		local lineStr = 'off'
		if self.absorb then lineStr = 'on' end
		love.graphics.print('Absorb (F11): '..lineStr, 5, 485)
		
		if self.camera.targetBool and self.dotSystem.dots[self.camera.target] then
			love.graphics.print('Entity mass: '..self.dotSystem.dots[self.camera.target].mass, 5, 515)
		end
	end
end














