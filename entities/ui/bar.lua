Bar = class('Bar')

function Bar:initialize(x, y, height)
	self.x = x
	self.y = y

	self.objects = {}
	
	self.height = height or 50
	self.width = 0
	
	self.switch = false
	self.flip = false
end

function Bar:set() -- used once objects are set
	local width = 0
	for i, object in ipairs(self.objects) do
		width = width + object.width
	end
	
	self.width = width
	
	local leftX = self.x - width/2
	for i, object in ipairs(self.objects) do
		object.x = leftX + object.width/2
		object.y = self.y
		
		object:posSet()
		
		leftX = leftX + object.width
	end
end

function Bar:update()
	for i, object in ipairs(self.objects) do
		object:update()
	end
end

function Bar:mousepressed(x, y)
	local clicked = false
	local index = nil
	
	if y >= self.y and y <= self.y + self.height then -- height is uniform for all objects on the bar
		if x >= self.x - self.width/2 and x <= self.x + self.width/2 then
			for i, object in ipairs(self.objects) do
				if not self.switch or not object.on then -- if switch is on, then an object set to on already cannot be switched
					clicked = object:mousepressed(x, y, i)
					
					if clicked then
						index = i
						break
					end
				end
			end
			
			if self.switch and clicked then
				for i, object in ipairs(self.objects) do
					if i ~= index then
						object.on = false
					end
				end
			end
			
			return true
		end
	end
end

function Bar:draw()
	for i, object in ipairs(self.objects) do
		local mod = 0
		if i == 1 then mod = -1 end
		if i == #self.objects then mod = 1 end
		object:draw(mod, self.flip)
	end
	
	for i, object in ipairs(self.objects) do
		object:drawTag()
	end
end

function Bar:updateButton(tag)
	local index = nil
	
	for i, button in ipairs(self.objects) do
		if button.tag == tag then
			if not self.switch or not button.on then
				button:mousepressed(nil, nil, nil, true)
				
				index = i
				break
			end
		end
	end
	
	if self.switch then
		if index then
			for i, button in ipairs(self.objects) do
				if i ~= index then
					button.on = false
				end
			end
		end
	end
end