UI = class('UI')

function UI:initialize()
	self.height = 50
	------------------- Option Bar -------------------
	self.bar = Bar:new(love.graphics.getWidth()/2, 0, self.height)
	
	table.insert(self.bar.objects, Button:new('Trace', '(F1)', 'img/traceIcon32.png', 50, self.height, function() game:toggleTrace() end, true, true))
	table.insert(self.bar.objects, Button:new('Objects', '(F2)', 'img/objectIcon32.png', 50, self.height, function() game:toggleObjects() end, true, true))
	table.insert(self.bar.objects, Button:new('Absorb', '(F3)', 'img/absorbIcon32alt.png', 50, self.height, function() game:toggleAbsorb() end, true, false))
	
	table.insert(self.bar.objects, Button:new('Directions', '(F4)', 'img/directionIcon32.png', 50, self.height, function() game:toggleLimit() end, true, false))
	table.insert(self.bar.objects, ChangeButton:new('+ / -', 100, self.height, function() return game:getDirections() end,
		function() game:changeDirections(1) end,
		function() game:changeDirections(-1) end))
		
	table.insert(self.bar.objects, Button:new('Follow', '(F5)', 'img/cameraIcon32.png', 50, self.height, function(var) return game:toggleFollow(var) end, true, false))
	table.insert(self.bar.objects, ChangeButton:new('< / >', 100, self.height, function() return game:getCameraTarget() end,
		function() game:changeCameraTarget(1) end,
		function() game:changeCameraTarget(-1) end))
	
	table.insert(self.bar.objects, Button:new('Pause', '(Space)', 'img/pause32.png', 50, self.height, function() game:toggleFreeze() end, true, false))
	table.insert(self.bar.objects, Button:new('Origin', '(F6)', 'img/origin32.png', 50, self.height, function() game:resetCamera() end, false))
	table.insert(self.bar.objects, Button:new('Clear', '(F7)', 'img/clearIcon32X.png', 50, self.height, function() game:clear() end, false))
	
	self.bar:set()
	
	
	------------------- Object Bar -------------------
	self.objectBar = Bar:new(love.graphics.getWidth()/2, love.graphics.getHeight()-self.height, self.height)
	self.objectBar.switch = true -- only 1 can be selected at a time
	self.objectBar.flip = true
	
	table.insert(self.objectBar.objects, Button:new('Ship', '(1)', 'img/shipIcon32.png', 50, self.height, function() game:setSpawnObject('ship') end, true, true))
	table.insert(self.objectBar.objects, Button:new('Repel Ship', '(2)', 'img/shipRepelIcon32.png', 50, self.height, function() game:setSpawnObject('repel ship') end, true, false))
	table.insert(self.objectBar.objects, Button:new('Planet', '(3)', 'img/planetIcon32.png', 50, self.height, function() game:setSpawnObject('planet') end, true, false))
	table.insert(self.objectBar.objects, Button:new('Repel Planet', '(4)', 'img/repelIcon32.png', 50, self.height, function() game:setSpawnObject('repel planet') end, true, false))
	
	self.objectBar:set()
	
	
	
	------------------- Mass UI-------------------
	self.pane = Pane:new(love.graphics.getWidth()*3/4,  love.graphics.getHeight()/4, 150, 50, function() return game:showPane() end,
		function() local mass, percent = game:getTargetMass() return math.floor(mass)..' kg', percent end,
		function(mass) game:setTargetMass(mass) end)
end

function UI:mousemoved(x, y, dx, dy)
	self.pane:mousemoved(x, y, dx, dy)
end

function UI:resize(w, h)
	self.bar.x = w/2
	self.bar:set()
	self.objectBar.x = w/2
	self.objectBar.y = h - self.height
	self.objectBar:set()
	self.pane:resize(w, h)
end

function UI:update()
	self.bar:update()
	self.objectBar:update()
	self.pane:update()
end

function UI:mousepressed(x, y, mbutton)
	if mbutton == 'l' then
		clicked1 = self.bar:mousepressed(x, y)
		clicked2 = self.objectBar:mousepressed(x, y)
		clicked3 = self.pane:mousepressed(x, y)
		
		if clicked1 or clicked2 or clicked3 then
			return true
		end
	end
end

function UI:draw()
	self.bar:draw()
	self.objectBar:draw()
	self.pane:draw()
end

function UI:updateButton(tag, var)
	self.bar:updateButton(tag, var)
	self.objectBar:updateButton(tag, var)
end