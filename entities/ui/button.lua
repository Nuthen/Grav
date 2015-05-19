Button = class('Button')

function Button:initialize(tag, key, img, width, height, action, toggle, default)
	self.tag = tag
	self.key = key
	self.img = love.graphics.newImage(img)
	
	self.x = nil
	self.y = nil
	
	self.width = width
	self.height = height
	self.tabHeight = 5
	
	self.toggle = toggle
	self.on = default or false
	
	self.font = font[32]
	
	self.color = {37, 51, 54}
	self.tabColor = {21, 166, 189}
	self.defaultIconColor = {255, 255, 255}
	self.hoveredIconColor = {181, 193, 230}
	self.clickedIconColor = {15, 209, 154}
	self.tagColor = {214, 235, 206}
	
	self.hovered = false
	self.clickLight = false
	self.action = action or function() end
	
	self.tagWidth = self.font:getWidth(self.tag..' '..self.key)
	self.tagHeight = self.font:getHeight()
end

function Button:update()
	self.hovered = false
	
	local x, y = love.mouse.getPosition()
	
	if y >= self.y and y <= self.y + self.height then -- height is uniform for all objects on the bar
		if x > self.x - self.width/2 and x < self.x + self.width/2 then
			self.hovered = true
		end
	end
end

function Button:mousepressed(x, y, i, override, var)
	if override or x > self.x - self.width/2 and x < self.x + self.width/2 then -- y check has already happened at a higher level
		clicked = self.action(var)
		
		if clicked or clicked == nil then
			if self.toggle then
				if self.on then
					self.on = false
				else
					self.on = true
				end
			end
		
			return true
		end
	end
end

function Button:draw(mod, flip)
    love.graphics.setFont(self.font)
	
	local x, y = self.x, self.y
	local w, h = self.width, self.height
	love.graphics.setColor(self.color)
	love.graphics.rectangle('fill', x - w/2, y, w, h)
	
	if mod ~= 0 then
		if flip then
			love.graphics.polygon('fill', x+mod*w/2, y+h, x+mod*(w/2+h+self.tabHeight), y+h, x+mod*w/2, y-self.tabHeight)
		else
			love.graphics.polygon('fill', x+mod*w/2, y, x+mod*(w/2+h+self.tabHeight), y, x+mod*w/2, y+h+self.tabHeight)
		end
	end
	
	love.graphics.setColor(self.tabColor)
	local dy = 0
	if flip then dy = -h-self.tabHeight end
	love.graphics.rectangle('fill', x - w/2, y + h + dy, w, self.tabHeight)
	
	if mod ~= 0 then
		if flip then
			love.graphics.polygon('fill', x+mod*w/2, y, x+mod*(w/2+self.tabHeight), y, x+mod*w/2, y-self.tabHeight)
		else
			love.graphics.polygon('fill', x+mod*w/2, y+h, x+mod*(w/2+self.tabHeight), y+h, x+mod*w/2, y+h+self.tabHeight)
		end
	end
	
	love.graphics.setColor(self.defaultIconColor)
	if self.on then
		love.graphics.setColor(self.clickedIconColor)
	elseif self.hovered and not self.clickLight then
		love.graphics.setColor(self.hoveredIconColor)
	end
	
	love.graphics.draw(self.img, x - self.img:getWidth()/2, y + h/2 - self.img:getHeight()/2)
end

function Button:drawTag()
	if self.hovered then
		local mX, mY = love.mouse:getPosition()
		local border = 4
		
		local dy = 0
		if mY + self.tagHeight + border*2 > love.graphics.getHeight() then
			dy = -self.tagHeight - border*2
		end
		
		love.graphics.setColor(self.tagColor)
		love.graphics.rectangle('fill', mX, mY + dy, self.tagWidth + border*2, self.tagHeight + border*2)
		
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(self.tag..' '..self.key, mX+border, mY+border + dy)
	end
end

function Button:posSet()

end