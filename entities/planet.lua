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
	self.bandColor = {math.random(255), math.random(255), math.random(255)}
	
	self.bandWidth = 6
	
	local massPercent = .25
	self:setMass(massPercent)
	
	self.gx = 0
	self.gy = 0
	
	self.angle = angle
	self.speed = speed/50 -- initial speed is far too fast when set
	
	self.vx = math.cos(self.angle)*self.speed
	self.vy = math.sin(self.angle)*self.speed
	
	self.destroy = false
end

function Planet:update(dt)
	-- enable to make planets move
	--[[
	if not self.super then
		self.vx = self.vx + self.gx
		self.vy = self.vy + self.gy
		
		local angle = math.angle(0, 0, self.vx, self.vy)
		local speed = math.sqrt(self.vx^2 + self.vy^2)
		local directions = self.directions
		
		if directions > 0 then -- calculate angle if limited
			angle = math.floor((angle/math.rad(360/directions)) + .5)*math.rad(360/directions)
		end
		
		self.lastX = self.x
		self.lastY = self.y
		
		self.x = self.x + math.cos(angle)*speed
		self.y = self.y + math.sin(angle)*speed
		
		-- change h based on speed
		self.h = self.hBase + speed
		
		self.angle = angle
		self.speed = speed
	end
	]]
end

function Planet:draw()
	love.graphics.setColor(self.color)
	
	love.graphics.circle('fill', self.x, self.y, self.size)
	
	if self.repel then
		love.graphics.setLineWidth(self.bandWidth)
		love.graphics.setColor(self.bandColor)
		love.graphics.circle('line', self.x, self.y, self.size)
	end
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
	self.bandWidth = math.ceil(math.sqrt(self.size))
	
	self.color[4] = self.alpha
end