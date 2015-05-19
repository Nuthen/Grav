Ship = class('Ship')

function Ship:initialize(x, y, angle, speed, directions, repel, super)
	self.x = x
	self.y = y
	
	self.super = super or false -- if true, has more mass
	self.directions = directions or 0 -- 0 means no restriction on angle of movement
	self.repel = repel or false
	
	self.lastX = x
	self.lastY = y
	
	--[[
	local sizeFactor = math.random(1, 2000)
	if self.super then sizeFactor = sizeFactor*2 end
	
	self.size = (math.floor(sizeFactor/150)+5) * 2
	self.mass = mass or sizeFactor
	]]
	
	self.massMin = 0
	self.massMax = 2000
	
	self.sizeMin = 10
	self.sizeMax = 25
	
	self.alphaMin = 75
	self.alphaMax = 150
	
	if self.super then
		self.massMin = 4000
		self.massMax = 10000
		
		self.sizeMin = 25
		self.sizeMax = 50
		
		self.alphaMin = 150
		self.alphaMax = 250
	end
	
	self.color = {math.random(255), math.random(255), math.random(255)}
	
	local massPercent = .25
	self:setMass(massPercent)
	
	self.gx = 0
	self.gy = 0
	
	self.angle = angle
	self.speed = speed/50
	
	self.vx = math.cos(self.angle)*self.speed
	self.vy = math.sin(self.angle)*self.speed
	
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
	love.graphics.setColor(self.color)
	
	if self.angle then -- draw a triangle
		local w = self.size
		local h = self.h -- the faster it is moving, the taller the object will be
		love.graphics.polygon('fill', self.x + math.cos(self.angle - math.rad(90))*w, self.y + math.sin(self.angle - math.rad(90))*w, 
											  self.x + math.cos(self.angle + math.rad(90))*w, self.y + math.sin(self.angle + math.rad(90))*w,
											  self.x + math.cos(self.angle)*h, self.y + math.sin(self.angle)*h)
	end
end


function Ship:getMass()
	local mass = self.mass
	local massPercent = (mass-self.massMin)/(self.massMax-self.massMin)
	return mass, massPercent
end

function Ship:setMass(massPercent)
	-- massPercent is 0-1
	self.mass = math.floor(massPercent*(self.massMax-self.massMin) + self.massMin)
	self.size = math.floor(massPercent*(self.sizeMax-self.sizeMin) + self.sizeMin)
	self.alpha = math.floor(massPercent*(self.alphaMax-self.alphaMin) + self.alphaMin)
	
	self.color[4] = self.alpha
	
	local hBase = self.size+10*(1000-self.size)/2000
	self.hBase = hBase
	self.h = hBase
end