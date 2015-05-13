game = {}

function game:enter()
	self.dotSystem = DotSystem:new()
	
	self.camera = {x = -love.graphics.getWidth()/2, y = -love.graphics.getHeight()/2, speed = 200}
	
	self.canvas = love.graphics.newCanvas(love.graphics.getWidth()*2, love.graphics.getHeight()*2)
	
	love.graphics.setBackgroundColor(255, 255, 255)
	
	self.help = true
end

function game:update(dt)
	self.dotSystem:update(dt)
	
	local speed = self.camera.speed*dt
	if love.keyboard.isDown('w') then self.camera.y = self.camera.y + speed end
	if love.keyboard.isDown('s') then self.camera.y = self.camera.y - speed end
	if love.keyboard.isDown('a') then self.camera.x = self.camera.x + speed end
	if love.keyboard.isDown('d') then self.camera.x = self.camera.x - speed end
end

function game:keypressed(key, isrepeat)
    if console.keypressed(key) then
        return
    end
	
	if key == 'f3' then
		if self.help then
			self.help = false
		else
			self.help = true
		end
	end
	
	self.dotSystem:keypressed(key, isrepeat)
end

function game:mousepressed(x, y, mbutton)
    if console.mousepressed(x, y, mbutton) then
        return
    end
	
	x = x - self.camera.x
	y = y - self.camera.y
	self.dotSystem:mousepressed(x, y, mbutton)
end

function game:draw()
    love.graphics.setFont(font[32])
	love.graphics.setColor(255, 255, 255)
	
	love.graphics.push()
	
	love.graphics.translate(self.camera.x, self.camera.y)
	
	if self.dotSystem.lines then
		love.graphics.draw(self.canvas)
	end
	
	self.dotSystem:draw()
	
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
		love.graphics.print('Directions (+/-): '..self.dotSystem.directions, 40, 95)
		
		love.graphics.print('Clear (F5)', 5, 125)
		love.graphics.print('Small mass (LMB)', 5, 155)
		love.graphics.print('Large mass (RMB)', 5, 185)
		love.graphics.print('Camera (WASD)', 5, 215)
		
		love.graphics.print('Hide Help (F3)', 5, 285)
	end
end














