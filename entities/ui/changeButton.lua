-- for changing a variable

ChangeButton = class('ChangeButton')

function ChangeButton:initialize(width, height, getVariable, buttonFunction1, buttonFunction2)
	--self.tag = tag
	--self.img = love.graphics.newImage(img)
	
	self.x = nil
	self.y = nil
	
	self.width = width
	self.height = height
	self.tabHeight = 5
	
	--self.toggle = toggle
	--self.on = default or false
	
	self.font = font[24]
	
	self.color = {28, 28, 28}
	self.tabColor = {21, 166, 189}
	self.defaultIconColor = {255, 255, 255}
	self.hoveredIconColor = {204, 144, 41}
	self.clickedIconColor = {15, 209, 154}
	
	self.currentIconColor = {r = self.defaultIconColor[1], g = self.defaultIconColor[2], b = self.defaultIconColor[3]}
	self.hovered = false
	self.clickLight = false
	self.action = action or function() end
	
	--self.tagWidth = self.font:getWidth(self.tag)
	--self.tagHeight = self.font:getHeight()
	
	local w = width
	local h = self.height
	
	self.getVariable = getVariable or function() return '' end
	
	self.buttons = {}
	table.insert(self.buttons, ModifierButton:new('+', w/4, h/2, 20, 20, buttonFunction1))
	table.insert(self.buttons, ModifierButton:new('-', -w/4, h/2, 20, 20, buttonFunction2))
end

function ChangeButton:update(x, y)
	for k, button in pairs(self.buttons) do
		button:update(x, y)
	end
end

function ChangeButton:mousepressed(x, y, i)
	if x > self.x - self.width/2 and x < self.x + self.width/2 then -- y check has already happened at a higher level
		for k, button in pairs(self.buttons) do
			button:mousepressed(x, y)
		end
		
		return true
	end
end

function ChangeButton:draw(mod)
    love.graphics.setFont(self.font)
	
	local x, y = self.x, self.y
	local w, h = self.width, self.height
	love.graphics.setColor(self.color)
	love.graphics.rectangle('fill', x - w/2, y, w, h)
	
	if mod == 1 then
		love.graphics.polygon('fill', x+w/2, y, x+w/2+h+self.tabHeight, y, x+w/2, y+h+self.tabHeight)
	elseif mod == -1 then
		love.graphics.polygon('fill', x-w/2, y, x-w/2-h-self.tabHeight, y, x-w/2, y+h+self.tabHeight)
	end
	
	love.graphics.setColor(self.tabColor)
	love.graphics.rectangle('fill', x - w/2, y + h, w, self.tabHeight)
	
	if mod == 1 then
		love.graphics.polygon('fill', x+w/2, y+h, x+w/2+self.tabHeight, y+h, x+w/2, y+h+self.tabHeight)
	elseif mod == -1 then
		love.graphics.polygon('fill', x-w/2, y+h, x-w/2-self.tabHeight, y+h, x-w/2, y+h+self.tabHeight)
	end
	
	love.graphics.setColor(self.defaultIconColor)
	if self.on then
		love.graphics.setColor(self.clickedIconColor)
	elseif self.hovered and not self.clickLight then
		love.graphics.setColor(self.hoveredIconColor)
	end
	
	
	local var = self.getVariable()
	local varWidth = self.font:getWidth(var)
	local varHeight = self.font:getHeight()
	local border = 4
	
	love.graphics.setColor(150, 150, 150, 125)
	love.graphics.rectangle('fill', x - varWidth/2 - border, y + h/2 - varHeight/2 + 4, varWidth + border*2, varHeight - 6)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(var, x - varWidth/2, y + h/2 - varHeight/2)
	
	
	for k, button in pairs(self.buttons) do
		button:draw()
	end
end

function ChangeButton:drawTag()

end




function ChangeButton:posSet() -- called when x and y is set
	for k, button in pairs(self.buttons) do
		button.x = self.x + button.dx
		button.y = self.y + button.dy
	end
end




ModifierButton = class('ModifierButton')

function ModifierButton:initialize(text, dx, dy, width, height, action)
	self.text = text
	
	self.dx = dx
	self.dy = dy
	
	self.x = nil
	self.y = nil
	
	self.width = width
	self.height = height
	
	self.font = font[24]
	
	self.textWidth = self.font:getWidth(self.text)
	self.textHeight = self.font:getHeight()
	
	self.color = {28, 28, 28}
	self.tabColor = {21, 166, 189}
	self.defaultIconColor = {255, 255, 255}
	self.hoveredIconColor = {204, 144, 41}
	self.clickedIconColor = {15, 209, 154}
	
	self.currentIconColor = {r = self.defaultIconColor[1], g = self.defaultIconColor[2], b = self.defaultIconColor[3]}
	self.hovered = false
	self.clickLight = false
	self.action = action or function() end
end

function ModifierButton:update(x, y)
	self.hovered = false
	
	local x, y = love.mouse.getPosition()
	if y >= self.y - self.height/2 and y <= self.y + self.height/2 then
		if x > self.x - self.width/2 and x < self.x + self.width/2 then
			self.hovered = true
		end
	end
end

function ModifierButton:mousepressed(x, y, i)
	if y >= self.y - self.height/2 and y <= self.y + self.height/2 then
		if x > self.x - self.width/2 and x < self.x + self.width/2 then
			self.action()
			
			
			--[[
			self.clickLight = true
			self.currentIconColor = {r = self.clickedIconColor[1], g = self.clickedIconColor[2], b = self.clickedIconColor[3]}
			tween.start(.5, game.UI.bar.objects[i].currentIconColor, {r = self.defaultIconColor[1], g = self.defaultIconColor[2], b = self.defaultIconColor[3]}, 'inOutQuad', function() 
					self.clickLight = false
					self.hovered = false
				end)
			]]
		end
	end
end

function ModifierButton:draw()
    love.graphics.setFont(self.font)
	
	local x, y = self.x, self.y
	local w, h = self.width, self.height
	
	love.graphics.setColor(self.currentIconColor.r, self.currentIconColor.g, self.currentIconColor.b)
	if self.on then
		love.graphics.setColor(self.clickedIconColor)
	elseif self.hovered and not self.clickLight then
		love.graphics.setColor(self.hoveredIconColor)
	end
	
	love.graphics.rectangle('fill', x - w/2, y - h/2, w, h)
	love.graphics.setColor(0, 0, 0)
	love.graphics.print(self.text, x - self.textWidth/2, y - self.textHeight/2 - 2)
end




