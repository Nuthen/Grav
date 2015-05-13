Dot = class('Dot')

function Dot:initialize(x, y, angle, speed, directions, super)
	self.x = x
	self.y = y
	self.super = super or false
	self.directions = directions or 0
	
	self.lastX = x
	self.lastY = y
	
	if self.super then
		local sizeFactor = math.random(5000, 10000)
		self.size = math.floor(sizeFactor/100)+5
		self.mass = sizeFactor
	else
		local sizeFactor = math.random(1, 2000)
		self.size = math.floor(sizeFactor/100)+5
		self.mass = sizeFactor
	end
	
	self.gx = 0
	self.gy = 0
	self.vx = 0
	self.vy = 0
	
	if not super then
		self.angle = angle
		self.speed = speed/50
		
		self.vx = math.cos(self.angle)*self.speed
		self.vy = math.sin(self.angle)*self.speed
	end
	
	self.color = {math.random(255), math.random(255), math.random(255)}
	
	if self.super then
		self.color[4] = 150
	end
end

function Dot:update(dt)
	self.vx = self.vx + self.gx
	self.vy = self.vy + self.gy
	
	self.angle = math.angle(0, 0, self.vx, self.vy)
	self.speed = math.sqrt(self.vx^2 + self.vy^2)
	
	if self.directions > 0 then
		self.angle = math.floor((self.angle/math.rad(360/self.directions)) + .5)*math.rad(360/self.directions)
	end
	
	--self.x = self.x + self.vx*dt
	--self.y = self.y + self.vy*dt
	
	local lastX = self.x
	local lastY = self.y
	
	self.lastX = lastX
	self.lastY = lastY
	
	self.x = self.x + math.cos(self.angle)*self.speed
	self.y = self.y + math.sin(self.angle)*self.speed
end

function Dot:draw()
	love.graphics.setColor(self.color[1], self.color[2], self.color[3], 150)
	love.graphics.circle('fill', self.x, self.y, self.size)
	love.graphics.setColor(255, 0, 0)
	--love.graphics.line(self.x, self.y, self.x+self.vx, self.y+self.vy)
	
	if self.angle then
		love.graphics.line(self.x, self.y, self.x+math.cos(self.angle)*self.speed, self.y+math.sin(self.angle)*self.speed)
	end
end