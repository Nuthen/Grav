Planet = class('Planet')

function Planet:initialize(x, y, angle, speed, directions, repel, super)
	self.x = x
	self.y = y
	
	self.super = super or false -- if true, has more mass
	self.directions = directions or 0 -- 0 means no restriction on angle of movement
	self.repel = repel or false
	
	self.lastX = x
	self.lastY = y
	
	local sizeFactor = math.random(5000, 10000)
	
	self.size = (math.floor(sizeFactor/100)+5) * 2
	self.mass = mass or sizeFactor
	if self.super then self.mass = self.mass*100 end
	
	self.gx = 0
	self.gy = 0
	self.vx = 0
	self.vy = 0
	
	local alpha = 150
	self.color = {math.random(255), math.random(255), math.random(255), alpha}
	
	self.destroy = false
end

function Planet:update(dt)
	self.vx = self.vx + self.gx
	self.vy = self.vy + self.gy
	
	self.angle = math.angle(0, 0, self.vx, self.vy)
	self.speed = math.sqrt(self.vx^2 + self.vy^2)
	
	if self.directions > 0 then -- calculate angle if limited
		self.angle = math.floor((self.angle/math.rad(360/self.directions)) + .5)*math.rad(360/self.directions)
	end
	
	-- used to disconnect the variables
	local lastX = self.x
	local lastY = self.y
	
	self.lastX = lastX
	self.lastY = lastY
	
	if not self.super then -- super objects will not move
		--self.x = self.x + math.cos(self.angle)*self.speed
		--self.y = self.y + math.sin(self.angle)*self.speed
	end
end

function Planet:draw()
	local alpha = 150
	love.graphics.setColor(self.color[1], self.color[2], self.color[3], alpha)
	
	love.graphics.circle('fill', self.x, self.y, self.size)
end