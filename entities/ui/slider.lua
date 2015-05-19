Slider = class('Slider')

function Slider:initialize(x, y, width)
	self.x = x
	self.y = y
	
	self.width = width
	
	self.selectorWidth = 5
	self.height = 20
	
	self.lineWidth = 2

	self.sliderPos = .5
	
	self.moving = false
end

function Slider:update()
	-- click check happens at a higher level
	local mX, mY = love.mouse:getPosition()

	local x, y = self.x, self.y
	local w, h = self.width, self.height
	
	if y - h/2 <= mY and y + h/2 >= mY or self.moving then
		if x - w/2 <= mX and x + w/2 >= mX or self.moving then
			local percent = (mX-x+w/2)/w
			if mX < x-w/2 then percent = 0 end
			if mX > x+w/2 then percent = 1 end
			
			self.sliderPos = percent
			return true
		end
	end
end

function Slider:mousepressed(mX, mY)
	local x, y = self.x, self.y
	local w, h = self.width, self.height
	
	if y - h/2 <= mY and y + h/2 >= mY then
		if x - w/2 <= mX and x + w/2 >= mX then
			local percent = (mX-x+w/2)/w
			
			self.sliderPos = percent
			self.moving = true
			return true
		end
	end
end

function Slider:draw()
	local x, y = self.x, self.y
	local w, h = self.width, self.height
		
	love.graphics.setLineWidth(self.lineWidth)
	love.graphics.line(x-w/2, y, x+w/2, y)
	
	local lineH = h/2
	love.graphics.line(x-w/2, y-lineH/2, x-w/2, y+lineH/2)
	love.graphics.line(x+w/2, y-lineH/2, x+w/2, y+lineH/2)
	love.graphics.line(x, y-lineH/2, x, y+lineH/2)
	
	love.graphics.rectangle('fill', x-w/2+w*self.sliderPos-self.selectorWidth/2, y-self.height/2, self.selectorWidth, self.height)
end