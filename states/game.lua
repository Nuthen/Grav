game = {}

function game:enter()
	love.graphics.setBackgroundColor(255, 255, 255) -- the white background makes all the other colors brighter due to alpha transparency

	self.help = true
	self.showCenter = true
	self.freeze = false
	self.hideObjects = false
	self.absorb = false
	self.lines = true
	self.grid = false
	self.traceWidth = 2
	self.axisWidth = 2
	self.spawnObjectName = 'ship'
	self.zoomMax = 3
	self.snap = 20
	self.gridLineWidth = 2
	
	self.gridColor = {100, 105, 104, 150}
	
	self.font = font[24]
	
	local maxTextureSize = love.graphics.getSystemLimit('texturesize')
	local canvasSize = maxTextureSize
	self.canvas = love.graphics.newCanvas(canvasSize, canvasSize)
	self.canvas:setFilter('linear', 'linear') -- line traces will look a little clearer when zoomed
	
	-- makes the entire canvas white, this is done so that line traces do not have a black outline
	self.canvas:renderTo(function()
		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle('fill', 0, 0, self.canvas:getWidth(), self.canvas:getHeight())
	end)
	
	-- origin
	self.startX = self.canvas:getWidth()/2 - love.graphics.getWidth()/2
	self.startY = self.canvas:getHeight()/2 - love.graphics.getHeight()/2
	
	-- camera is centered on the canvas
	self.camera = {x = self.startX, y = self.startY, zoom = 1, speed = 400, targetBool = false, target = 1}
	
	self.dotSystem = DotSystem:new()
	self.UI = UI:new()
	
	self.spawnClicked = false
	self.oldScreenWidth, self.oldScreenHeight = love.graphics.getWidth(), love.graphics.getHeight()
end

function game:update(dt)
	self.dotSystem:update(dt, self.freeze)
	
	if self.camera.targetBool then -- focused camera
		if self.dotSystem.dots[self.camera.target] then
			self.camera.x = self.dotSystem.dots[self.camera.target].x - love.graphics.getWidth()/2
			self.camera.y = self.dotSystem.dots[self.camera.target].y - love.graphics.getHeight()/2
		end
	end
	
	local cameraX = self.camera.x
	local cameraY = self.camera.y
	
	local speed = self.camera.speed*dt/self.camera.zoom
	if love.keyboard.isDown('lshift', 'rshift') then speed = speed * 2 end
	if love.keyboard.isDown('w', 'up') then self.camera.y = self.camera.y - speed end
	if love.keyboard.isDown('s', 'down') then self.camera.y = self.camera.y + speed end
	if love.keyboard.isDown('a', 'left') then self.camera.x = self.camera.x - speed end
	if love.keyboard.isDown('d', 'right') then self.camera.x = self.camera.x + speed end
	
	-- if camera is moved by the player, exit follow camera mode
	if self.camera.x ~= cameraX or self.camera.y ~= cameraY then
		if self.camera.targetBool then
			self.UI:updateButton('Follow')
		end
	end
	
	self.UI:update()
end

function game:keypressed(key, isrepeat)
    if console.keypressed(key) then
        return
    end
	
	if key == 'f1' then -- Toggle Trace
		self.UI:updateButton('Trace')
	end
	
	if key == 'f2' then -- Toggle Objects
		self.UI:updateButton('Objects')
	end
	
	-- bigger objects absorb smaller objects (Osmos)
	if key == 'f3' then -- Toggle Objects
		self.UI:updateButton('Absorb')
	end
	
	if key == 'f4' then -- Toggle Limit
		self.UI:updateButton('Directions')
	end
	
	if key == 'f5' then -- Toggle Follow
		self.UI:updateButton('Follow')
	end
	
	-- move the camera to the origin
	if key == 'f6' then
		--self:resetCamera()
		self.UI:updateButton('Origin')
	end
	
	-- reset everything
	if key == 'f7' then -- clear
		--self:clear()
		self.UI:updateButton('Clear')
	end
	
	-- toggle help text
	if key == 'f9' then
		if self.help then
			self.help = false
		else
			self.help = true
		end
	end
	
	-- toggle grid snapping
	if key == 'f10' then
		if self.grid then
			self.grid = false
		else
			self.grid = true
		end
	end
	
	-- toggle crosshair in the center
	if key == 'f11' then
		if self.showCenter then
			self.showCenter = false
		else
			self.showCenter = true
		end
	end
	
	-- toggle fullscreen
	if key == 'f12' then
		self:toggleFullscreen()
	end
	
	-- pause simulation, useful for setting up objects
	if key == ' ' then
		self.UI:updateButton('Pause')
	end
	
	-- activate and switch through entities to focus the camera on
	if #self.dotSystem.dots > 0 then
		if key == ',' then -- <
			if not self.camera.targetBool then
				self.UI:updateButton('Follow')
			elseif self.camera.target > 1 then
				self.camera.target = self.camera.target - 1
			else
				self.camera.target = #self.dotSystem.dots
			end
			
		elseif key == '.' then -- >
			if not self.camera.targetBool then
				self.UI:updateButton('Follow')
			elseif self.camera.target < #self.dotSystem.dots then
				self.camera.target = self.camera.target + 1
			else
				self.camera.target = 1
			end
		end
	end
	
	if key == '=' then -- +
		self:changeDirections(1)
	elseif key == '-' then
		self:changeDirections(-1)
	end
	
	if key == '1' then
		self.UI:updateButton('Ship')
	elseif key == '2' then
		self.UI:updateButton('Repel Ship')
	elseif key == '3' then
		self.UI:updateButton('Planet')
	elseif key == '4' then
		self.UI:updateButton('Repel Planet')
	end
	
	if key == 'delete' then
		if self.camera.targetBool and self.dotSystem.dots[self.camera.target] then
			self.dotSystem.dots[self.camera.target].destroy = true
		end
	end
end

function game:mousepressed(x, y, mbutton)
    if console.mousepressed(x, y, mbutton) then
        return
    end
	
	if mbutton == 'wu' and self.camera.zoom < self.zoomMax then
		self.camera.zoom = self.camera.zoom + .1
	elseif mbutton == 'wd' and self.camera.zoom >= .2 then
		self.camera.zoom = self.camera.zoom - .1
	end
	
	if mbutton == 'l' then
		local clicked = self.UI:mousepressed(x, y, mbutton)
		
		if not clicked then
			if love.keyboard.isDown('lalt', 'ralt') or self.grid then
				x, y = game:snapCoordinates(x, y)
			end
		
			local newX, newY = self:convertCoordinates(x, y)
			
			self.spawnClicked = true
			self.dotSystem:mousepressed(newX, newY, mbutton)
		end
	end
end

function game:mousereleased(x, y, button)
	if love.keyboard.isDown('lalt', 'ralt') or self.grid then
		x, y = game:snapCoordinates(x, y)
	end
	
	local newX, newY = self:convertCoordinates(x, y)
	
	if self.spawnClicked then
		self.spawnClicked = false
		self.dotSystem:mousereleased(newX, newY, button, self.spawnObjectName)
	end
end

function game:draw()
    love.graphics.setFont(self.font)
	love.graphics.setColor(255, 255, 255)
	
	love.graphics.push()
	
	-- translate to origin, scale, translate back
	love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	love.graphics.scale(self.camera.zoom)
	love.graphics.translate(-love.graphics.getWidth()/2, -love.graphics.getHeight()/2)
	
	
	-- translate to screen coordinates
	love.graphics.translate(-self.camera.x, -self.camera.y)
	
	if self.lines then -- draw line traces
		love.graphics.draw(self.canvas)
	end
	love.graphics.pop()
	
	if love.keyboard.isDown('lalt', 'ralt') or self.grid then
		love.graphics.setColor(self.gridColor)
		love.graphics.setLineWidth(self.gridLineWidth)
		
		local snap = self.snap
		local dx, dy = (-self.camera.x % snap) - snap, (-self.camera.y % snap) - snap
		for i = 1, math.floor(love.graphics.getWidth()/snap) + 1 do
			love.graphics.line(snap*i + dx, dy, snap*i + dx, love.graphics.getHeight() + dy + snap)
		end
		for i = 1, math.floor(love.graphics.getHeight()/snap) + 1 do
			love.graphics.line(dx, snap*i + dy, love.graphics.getWidth() + dx + snap, snap*i + dy)
		end
	end
	
	love.graphics.push()
	
	-- translate to origin, scale, translate back
	love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	love.graphics.scale(self.camera.zoom)
	love.graphics.translate(-love.graphics.getWidth()/2, -love.graphics.getHeight()/2)
	
	
	-- translate to screen coordinates
	love.graphics.translate(-self.camera.x, -self.camera.y)
	
	
	if not self.hideObjects then -- draw entities
		self.dotSystem:draw()
	end
	
	if self.showCenter then -- draw axis at the center
		love.graphics.setLineWidth(self.axisWidth/self.camera.zoom)
		love.graphics.setColor(0, 0, 0)
		local d = 50/self.camera.zoom
		love.graphics.line(self.canvas:getWidth()/2 - d, self.canvas:getHeight()/2, self.canvas:getWidth()/2 + d, self.canvas:getHeight()/2)
		love.graphics.line(self.canvas:getWidth()/2, self.canvas:getHeight()/2 - d, self.canvas:getWidth()/2, self.canvas:getHeight()/2 + d)
	end
	
	love.graphics.pop()
	
	love.graphics.setColor(13, 15, 122)
	
	love.graphics.print(love.timer.getFPS(), 5, 5)
	
	if self.help then
		local helpText = {}
		table.insert(helpText, 'Spawn Object (LMB [+ ctrl])')
		table.insert(helpText, 'Camera (WASD [+ Shift])')
		table.insert(helpText, 'Zoom (wheel): '..self.camera.zoom)
		table.insert(helpText, 'Click on objects to change mass')
		table.insert(helpText, 'Total Objects: '..#self.dotSystem.dots)
		table.insert(helpText, 'Delete Object (delete)')
		table.insert(helpText, 'Hide Help (F9)')
		table.insert(helpText, 'Show Grid (F10/alt)')
		table.insert(helpText, 'Hide Axis (F11)')
		table.insert(helpText, 'Fullscreen (F12)')
		
		for i = 1, #helpText do
			love.graphics.print(helpText[i], 5, 50+28*i)
		end
	end
	
	self.UI:draw()
end

function game:resize(w, h)
	-- origin
	self.startX = self.canvas:getWidth()/2 - love.graphics.getWidth()/2
	self.startY = self.canvas:getHeight()/2 - love.graphics.getHeight()/2

	self.UI:resize(w, h)
	
	self.UI:updateButton('Origin')
end

function game:mousemoved(x, y, dx, dy)
	self.UI:mousemoved(x, y, dx, dy)
end




-- Takes mouse coordinates, accounts for camera translation and zoom, returns game coordinates
function game:convertCoordinates(x, y)
	local zoom = self.camera.zoom

	-- change mouse coordinates to game coordinates
	x = x + self.camera.x
	y = y + self.camera.y
	
	-- translate to origin, scale, translate back
	x, y = x - self.camera.x - love.graphics.getWidth()/2, y - self.camera.y - love.graphics.getHeight()/2
	x, y = x / zoom, y / zoom
	x, y = x + self.camera.x + love.graphics.getWidth()/2, y + self.camera.y + love.graphics.getHeight()/2

	return x, y
end

function game:snapCoordinates(x, y)
	local snap = self.snap
	local dx, dy = (-self.camera.x % snap) - snap, (-self.camera.y % snap) - snap
	local newX, newY = math.floor(x/snap + .5) * snap + dx, math.floor(y/snap + .5) * snap + dy
	
	return newX, newY
end


function game:toggleFullscreen()
	if love.window.getFullscreen() then
		local width, height = self.oldScreenWidth, self.oldScreenHeight
		love.window.setMode(width, height, {fullscreen = false, fsaa = 4, resizable = true, centered = false})
		self:resize(width, height)
	else
		self.oldScreenWidth, self.oldScreenHeight = love.graphics.getWidth(), love.graphics.getHeight()
	
		local width, height = love.window.getDesktopDimensions()
		love.window.setMode(width, height, {fullscreen = true, fsaa = 4})
		
		self:resize(width, height)
	end
end

-- UI Button Functions

-- Hide trace lines
function game:toggleTrace()
	if self.lines then
		self.lines = false
		self.canvas:clear()
	else
		self.lines = true
	end
end

-- Hide objects
function game:toggleObjects()
	if self.hideObjects then
		self.hideObjects = false
	else
		self.hideObjects = true
	end
end

-- Toggle absorb mode
function game:toggleAbsorb()
	if self.absorb then
		self.absorb = false
	else
		self.absorb = true
	end
end

-- Toggle direction limit
function game:toggleLimit() -- toggle limit on entity direction
	if self.dotSystem.limit then
		self.dotSystem.limit = false
	else
		self.dotSystem.limit = true
	end
end

-- Change direction limit by -1 or 1
function game:changeDirections(b)
	if b > 0 or self.dotSystem.directions > 1 then
		self.dotSystem.directions = self.dotSystem.directions + b
	end
end

function game:getDirections()
	return self.dotSystem.directions
end

function game:toggleFollow(target)
	if self.camera.targetBool then
		if target then
			self.camera.target = target
			return false
		else
			self.camera.targetBool = false
			return true
		end
	elseif #self.dotSystem.dots > 0 then -- if at least 1 object exists to follow
		self.camera.targetBool = true
		self.camera.target = target or 1
		return true
	else
		return false
	end
end

function game:getCameraTarget()
	return self.camera.target
end

function game:changeCameraTarget(b, target)
	if target then
		if not self.camera.targetBool then
			self.camera.targetBool = true
			self.UI:updateButton('Follow')
		end
		
		self.camera.target = target
	elseif #self.dotSystem.dots > 0 then
		if b < 0 then
			if self.camera.target > 1 then -- assumes b is -1
				self.camera.target = self.camera.target + b
			else
				self.camera.target = #self.dotSystem.dots
			end
		else
			if self.camera.target < #self.dotSystem.dots then
				self.camera.target = self.camera.target + b
			else
				self.camera.target = 1
			end
		end
	end
end

-- move camera to origin
function game:resetCamera()
	if self.camera.targetBool then
		self.UI:updateButton('Follow')
	end
	
	self.camera.x = self.startX
	self.camera.y = self.startY
end

-- clear all objects
function game:clear()
	self.canvas:clear()
	self.dotSystem.dots = {}
	
	self.camera.target = 1
	
	self:resetCamera()
end

-- pause game
function game:toggleFreeze()
	if self.freeze then
		self.freeze = false
	else
		self.freeze = true
	end
end


-- Functions for UI mass pane
function game:showPane()
	if self.camera.targetBool and self.dotSystem.dots[self.camera.target] then
		return true
	else
		return false
	end
end

-- returns mass of the currently followed target
function game:getTargetMass()
	if self.camera.targetBool and self.dotSystem.dots[self.camera.target] then
		return self.dotSystem.dots[self.camera.target]:getMass()
	else
		return -1
	end
end

-- sets mass of the currently followed target
function game:setTargetMass(mass)
	if self.camera.targetBool and self.dotSystem.dots[self.camera.target] then
		self.dotSystem.dots[self.camera.target]:setMass(mass)
	end
end


-- UI Object Bar
-- sets object to spawn
function game:setSpawnObject(objectName)
	self.spawnObjectName = objectName
end