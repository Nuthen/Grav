Planet = class('Planet')

function Planet:initialize(x, y, angle, speed, directions, repel, super)
	self.x = x
	self.y = y
	
	self.super = super or false -- if true, has more mass
	self.directions = directions or 0 -- 0 means no restriction on angle of movement
	self.repel = repel or false
	
	self.lastX = x
	self.lastY = y
	
	self.massMin = 5000
	self.massMax = 10000
	
	self.sizeMin = 20
	self.sizeMax = 100
	
	self.alphaMin = 50
	self.alphaMax = 120
	
	if self.super then
		self.massMin = 50000
		self.massMax = 1000000
		
		self.sizeMin = 100
		self.sizeMax = 250
		
		self.alphaMin = 120
		self.alphaMax = 250
	end
	
	
	self.color = {math.random(255), math.random(255), math.random(255)}
	
	local massPercent = .25
	self:setMass(massPercent)
	
	self.gx = 0
	self.gy = 0
	self.vx = 0
	self.vy = 0
	
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
	love.graphics.setColor(self.color)
	
	love.graphics.circle('fill', self.x, self.y, self.size)
end


function Planet:getMass()
	local mass = self.mass
	local massPercent = (mass-self.massMin)/(self.massMax-self.massMin)
	return mass, massPercent
end

function Planet:setMass(massPercent)
	-- massPercent is 0-1
	self.mass = math.floor(massPercent*(self.massMax-self.massMin) + self.massMin)
	self.size = math.floor(massPercent*(self.sizeMax-self.sizeMin) + self.sizeMin)
	self.alpha = math.floor(massPercent*(self.alphaMax-self.alphaMin) + self.alphaMin)
	
	self.color[4] = self.alpha
end