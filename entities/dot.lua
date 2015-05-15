Dot = class('Dot')

function Dot:initialize(x, y, angle, speed, mass, directions, super, gigantic, repel)
	self.x = x
	self.y = y
	self.super = super or false -- if true, a large, immobile object
	self.gigantic = gigantic or false -- if true for a super object, then it is even larger
	self.directions = directions or 0 -- 0 means no restriction on angle of movement
	self.repel = repel or false
	
	self.lastX = x
	self.lastY = y
	
	if mass == 0 then
		local sizeFactor = math.random(1, 500)
		self.size = math.floor(sizeFactor/50)+5 * 2
		self.mass = mass or sizeFactor
	elseif self.super then
		if gigantic then
			local sizeFactor = math.random(20000, 1000000)
			self.size = math.sqrt(math.floor(sizeFactor/100)) * 2
			self.mass = mass or sizeFactor
		else
			local sizeFactor = math.random(5000, 10000)
			self.size = (math.floor(sizeFactor/100)+5) * 2
			self.mass = mass or sizeFactor
		end
	else
		local sizeFactor = math.random(1, 2000)
		self.size = math.floor(sizeFactor/50)+5 * 2
		self.mass = mass or sizeFactor
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
	
	if self.super then -- a super object has translucency
		self.color[4] = 150
	end
	
	self.destroy = false
end

function Dot:update(dt)
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
		self.x = self.x + math.cos(self.angle)*self.speed
		self.y = self.y + math.sin(self.angle)*self.speed
	end
end

function Dot:draw()
	local alpha = 150
	if self.mass == 0 or self.gigantic then alpha = 255 end
	love.graphics.setColor(self.color[1], self.color[2], self.color[3], alpha)
	
	if self.super then
		love.graphics.circle('fill', self.x, self.y, self.size, 50)
	end
	
	if self.angle then
		if not self.super then
			local w = self.size
			local h = self.speed * 2 *2 -- the faster it is moving, the taller the object will be
			love.graphics.polygon('fill', self.x + math.cos(self.angle - math.rad(90))*w, self.y + math.sin(self.angle - math.rad(90))*w, 
												  self.x + math.cos(self.angle + math.rad(90))*w, self.y + math.sin(self.angle + math.rad(90))*w,
												  self.x + math.cos(self.angle)*h, self.y + math.sin(self.angle)*h)
		end
	end
end