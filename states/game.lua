game = {}

function game:enter()
    self.dots = {}
	
	self.camera = {x = 0, y = 0}
end

function game:update(dt)
	for i = 1, #self.dots do
		local dot1 = self.dots[i]
		local gx, gy = 0, 0
		for j = 1, #self.dots do
			local dot2 = self.dots[j]
			if i ~= j then
				local dist = math.dist(dot1.x, dot1.y, dot2.x, dot2.y)
				--if dist <= dot1.size + dot2.size then
				
					--if dot1.size > dot2.size then
					local angle = math.angle(dot1.x, dot1.y, dot2.x, dot2.y)
					local g = dot2.mass/(dist^2)
					--if g < .7 then
						gx = gx + math.cos(angle)*g
						gy = gy + math.sin(angle)*g
					--end
				--end
			end
		end
		
		dot1.gx = gx
		dot1.gy = gy
	end
	
	for i = 1, #self.dots do
		local dot = self.dots[i]
		dot.vx = dot.vx + dot.gx
		dot.vy = dot.vy + dot.gy
		
		dot.x = dot.x + dot.vx
		dot.y = dot.y + dot.vy
	end
	
	
	local change = 30*dt
	if love.keyboard.isDown('w') then self.camera.y = self.camera.y - change end
	if love.keyboard.isDown('s') then self.camera.y = self.camera.y + change end
	if love.keyboard.isDown('a') then self.camera.x = self.camera.x - change end
	if love.keyboard.isDown('d') then self.camera.x = self.camera.x + change end
end

function game:keypressed(key, isrepeat)
    if console.keypressed(key) then
        return
    end
end

function game:mousepressed(x, y, mbutton)
    if console.mousepressed(x, y, mbutton) then
        return
    end
	
	if mbutton == 'l' then
		table.insert(self.dots, {x = x, y = y, size = math.random(3, 10), mass = math.random(1, 1000), gx = 0, gy = 0, vx = 0, vy = 0})
	elseif mbutton == 'r' then
		table.insert(self.dots, {x = x, y = y, size = math.random(20, 40), mass = math.random(5000, 10000), gx = 0, gy = 0, vx = 0, vy = 0})
	end
end

function game:draw()
	--love.graphics.translate(self.camera.x, self.camera.y)

    local text = "This is the game"
    local x = love.window.getWidth()/2 - font[48]:getWidth(text)/2
    local y = love.window.getHeight()/2
    love.graphics.setFont(font[48])
    --love.graphics.print(text, x, y)
	
	for i = 1, #self.dots do
		local dot = self.dots[i]
		love.graphics.circle('fill', dot.x, dot.y, dot.size)
	end
end