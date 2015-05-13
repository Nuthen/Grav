DotSystem = class('DotSystem')

function DotSystem:initialize()
	self.dots = {}
	
	self.maxG = .5
	
	self.lines = true
	self.limit = false
	self.directions = 8
end

function DotSystem:toggleLines()
	if self.lines then
		self.lines = false
		game.canvas:clear()
	else
		self.lines = true
	end
end

function DotSystem:toggleLimit()
	if self.limit then
		self.limit = false
	else
		self.limit = true
	end
end

function DotSystem:update(dt)
	for i, dot in ipairs(self.dots) do
		if not dot.super then
			local gx, gy = 0, 0
			for j, dot2 in ipairs(self.dots) do
				if i ~= j then
					local dist = math.dist(dot.x, dot.y, dot2.x, dot2.y)
					--if dist >= (dot.size + dot2.size) then
						local angle = math.angle(dot.x, dot.y, dot2.x, dot2.y)
						local g = dot2.mass/(dist^2)
						if g > self.maxG then g = self.maxG end
						gx = gx + math.cos(angle)*g
						gy = gy + math.sin(angle)*g
					--end
				end
			end
		
			dot.gx = gx
			dot.gy = gy
		end
	end
	
	for i, dot in ipairs(self.dots) do
		dot:update(dt)
	end
	
	if self.lines then
		game.canvas:renderTo(function()
			love.graphics.push()
			love.graphics.translate(game.camera.x, game.camera.y)
			
			for i, dot in ipairs(self.dots) do
				love.graphics.setColor(dot.color[1], dot.color[2], dot.color[3], 125)
				--love.graphics.circle('fill', dot.x - game.camera.x, dot.y - game.camera.y, dot.size/5)
				love.graphics.line(dot.lastX - game.camera.x, dot.lastY - game.camera.y, dot.x - game.camera.x, dot.y - game.camera.y)
			end
			
			love.graphics.pop()
		end)
	end
end

function DotSystem:keypressed(key, isrepeat)
	if key == 'f1' then
		self:toggleLines()
	end
	
	if key == 'f2' then
		self:toggleLimit()
	end
	
	if key == 'f5' then -- clear
		game.canvas:clear()
		self.dots = {}
	end
	
	if key == '=' then -- +
		self.directions = self.directions + 1
	elseif key == '-' and self.directions > 0 then
		self.directions = self.directions - 1
	end
end

function DotSystem:mousepressed(x, y, mbutton)
	local directions = self.directions
	if not self.limit then
		directions = 0
	end

	if mbutton == 'l' then
		table.insert(self.dots, Dot:new(x, y, directions))
	elseif mbutton == 'r' then
		table.insert(self.dots, Dot:new(x, y, directions, true))
	end
end

function DotSystem:draw()
	for i, dot in ipairs(self.dots) do
		dot:draw()
	end
end