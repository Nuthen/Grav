Pane = class('Pane')

function Pane:initialize(x, y, width, height, display, var, setVar)
	self.x = x
	self.y = y
	
	-- functions
	self.display = display or function() end
	self.var = var or function() end
	self.setVar = setVar or function() end
	
	self.variable = 0
	
	self.width = width or 150
	self.height = height or 50
	
	self.slider = Slider:new(self.x, self.y+self.height/4, self.width*3/4)
	
	self.moving = false
	
	self.capHeight = 15
	self.tabHeight = 5
	
	self.color = {28, 28, 28}
	self.tabColor = {21, 166, 189}
	
	self.font = font[24]
end

function Pane:update()
	if self.display() then
		if love.mouse.isDown('l') then
			local x, y = self.x, self.y
			local w, h = self.width, self.height
			
			local clicked = false
				
			local mX, mY = love.mouse:getPosition()
			if y - h/2 <= mY and y + h/2 >= mY then
				if x - w/2 <= mX and x + w/2 >= mX then
					clicked = self.slider:update()
					self.setVar(self.slider.sliderPos)
				end
			end
			
			self.variable, self.slider.sliderPos = self.var()
			if clicked then
				self.moving = false
			end
		else
			self.slider.moving = false
			self.moving = false
		end
	end
end

function Pane:mousemoved(x, y, dx, dy)
	if self.display() and love.mouse.isDown('l') and self.moving then
		self.x, self.y = self.x+dx, self.y+dy
		self.slider.x, self.slider.y = self.slider.x+dx, self.slider.y+dy
	end
end

function Pane:mousepressed(mX, mY)
	if self.display() then
		local x, y = self.x, self.y
		local w, h = self.width, self.height
		
		local clicked = false
		
		if y - h/2 - self.capHeight <= mY and y + h/2 + self.capHeight >= mY then
			if x - w/2 <= mX and x + w/2 >= mX then
				clicked = self.slider:mousepressed(mX, mY)
				self.setVar(self.slider.sliderPos)
				
				if not clicked and not self.slider.moving then
					self.moving = true
				end
				return true
			end
		end
	end
end

function Pane:draw()
	if self.display() then
		love.graphics.setFont(self.font)
	
		local x, y = self.x, self.y
		local w, h = self.width, self.height
		local capH = self.capHeight
		local tabH = self.tabHeight

		for i = -1, 1, 2 do -- draws both the bottom and top tabs
			love.graphics.setColor(self.color)
			love.graphics.rectangle('fill', x-w/2, y-h/2, w, h)
			love.graphics.polygon('fill', x-w/2, y+i*h/2, 
												  x-w/2+capH, y+i*(h/2+capH), 
												  x+w/2-capH, y+i*(h/2+capH), 
												  x+w/2, y+i*h/2)
			
			love.graphics.setColor(self.tabColor)
			love.graphics.polygon('fill', x-w/2+capH-tabH, y+i*(h/2+capH-tabH), 
												  x-w/2+capH, y+i*(h/2+capH),
												  x+w/2-capH, y+i*(h/2+capH),
												  x+w/2-capH+tabH, y+i*(h/2+capH-tabH))
		end
		
		local text = self.variable
		--local text = self.slider.sliderPos
		local textWidth = self.font:getWidth(text)
		local textHeight = self.font:getHeight()
		
		love.graphics.print(text, x-textWidth/2, y-textHeight/2-h/4)
		self.slider:draw()
	end
end