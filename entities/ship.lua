Ship = class('Ship')

function Ship:initialize(x, y, angle, speed, directions, repel, super)
	self.x = x
	self.y = y
	
	self.super = super or false -- if true, has more mass
	self.directions = directions or 0 -- 0 means no restriction on angle of movement
	self.repel = repel or false
	
	self.lastX = x
	self.lastY = y
	
	
	local sizeFactor = math.random(1, 2000)
	if self.super then sizeFactor = sizeFactor*2 end
	
	self.size = (math.floor(sizeFactor/150)+5) * 2
	self.mass = mass or sizeFactor
	
	self.gx = 0
	self.gy = 0
	
	self.angle = angle
	self.speed = speed/50

	local hBase = self.size+10*(1000-self.size)/2000
	self.hBase = hBase
	self.h = hBase
	
	self.vx = math.cos(self.angle)*self.speed
	self.vy = math.sin(self.angle)*self.speed
	
	self.color = {math.random(255), math.random(255), math.random(255)}
	
	self.destroy = false
end

function Ship:update(dt)
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
	
	self.x = self.x + math.cos(self.angle)*self.speed
	self.y = self.y + math.sin(self.angle)*self.speed
	
	
	-- change h based on speed
	self.h = self.hBase + self.speed
end

function Ship:draw()
	local alpha = 150
	
	love.graphics.setColor(self.color[1], self.color[2], self.color[3], alpha)
	
	if self.angle then -- draw a triangle
		local w = self.size
		local h = self.h -- the faster it is moving, the taller the object will be
		love.graphics.polygon('fill', self.x + math.cos(self.angle - math.rad(90))*w, self.y + math.sin(self.angle - math.rad(90))*w, 
											  self.x + math.cos(self.angle + math.rad(90))*w, self.y + math.sin(self.angle + math.rad(90))*w,
											  self.x + math.cos(self.angle)*h, self.y + math.sin(self.angle)*h)
	end
end