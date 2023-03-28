local gfx <const> = playdate.graphics
local geometry <const> = playdate.geometry
local X_OFFSET = 0
local Y_OFFSET = 50

local COLLISION_Y_OFFSET = 120

local function round(num)
	return num + 0.5 - (num + 0.5) % 1
end

local function clamp(val, min, max)
	return val < min and min or val > max and max or val
end

Fluid = {}
Fluid.__index = Fluid

class("Fluid").extends(gfx.sprite)

function Fluid:init(x, y, width, height, options)
	Fluid.super.init(self)
	self:setGroups(7)
	self:setCollidesWithGroups(1)
	self:setCenter(0, 0)
	
	options = options or {}
	
	-- setmetatable(fluid, Fluid)
	
	-- Set default options.
	self.tension = options.tension or 0.03 -- Wave stiffness.
	self.dampening = options.dampening or 0.0025 -- Wave oscillation.
	self.speed = options.speed or 0.06 -- Wave speed.
	self.vertex_count = options.vertices or 20
	print("OPTIONS", options.collisionResponseCb)

	self.collisionResponseCb = options.collisionResponseCb or function() end
	-- Allocate vertices.
	self.vertices = table.create(self.vertex_count, 0)
	
	-- Allocate polygon.
	self.polygon = geometry.polygon.new(self.vertex_count + 2)
	self.polygon:close()
	
	-- Set bounds.
	self:setBoundaries(X_OFFSET, Y_OFFSET, width, height)

	self:setCollideRect(x, y - COLLISION_Y_OFFSET, width, 1)
	self:setGroups(7)
    self:setCollidesWithGroups(1)
	
	-- Initialize.
	self:reset()
	self:add()
	self:moveTo(x, y) -- it is drawing offset from where the moveTo is but the actual physics coordinates of the polygon don't seem to be offset
end

function Fluid:setBoundaries(x, y, width, height)
	self.bounds = geometry.rect.new(x, y, width, height)
	
	-- Update fluid column width.
	self.column_width = width / (self.vertex_count - 1)
	
	-- Update height of vertices.
	for _, v in ipairs(self.vertices) do
		local height_delta <const> = v.height - v.natural_height
		v.natural_height = height
		v.height = height + height_delta
	end
	
	-- Set bottom right and left vertices.
	local fluid_bottom <const> = self.bounds.y + self.bounds.height
	self.polygon:setPointAt(self.vertex_count + 1, self.bounds.x + self.bounds.width, fluid_bottom)
	self.polygon:setPointAt(self.vertex_count + 2, self.bounds.x, fluid_bottom)
end

function Fluid:reset()
	-- Reset vertices to 0.
	for i = 1, self.vertex_count do
		self.vertices[i] = {
			height = self.bounds.height,
			natural_height = self.bounds.height,
			velocity = 0
		}
	end
end

function Fluid:getFluidX()
	return self.x + self.bounds.x
end

function Fluid:getFluidY()
	return self.y + self.bounds.y
end

function Fluid:getPointOnSurface(x)
	x = clamp(x - self:getFluidX(), 0, self.bounds.width)
	return self.polygon:pointOnPolygon(x)
end

function Fluid:touch(x, velocity)
	-- Don't allow touches outside the bounds of the water surface.
	if x < self:getFluidX() or x > self:getFluidX() + self.bounds.width then
		return
	end
	
	-- Apply velocity to vertex at touch point.
	local vertex_index <const> = clamp(round((((x - self:getFluidX()) / self.bounds.width) * (self.vertex_count - 1)) + 1), 1, self.vertex_count)
	self.vertices[vertex_index].velocity = -velocity
end

function Fluid:collisionResponse(other)
	if other:isa(Player) then
		return gfx.sprite.kCollisionTypeOverlap
	end
	return self.collisionResponseCb(self, other)
end

function Fluid:update()
	self:updatePolygon()
	self:fill()
	x, y, collisions = self:checkCollisions(self.x, self.y)
	self:checkCollisionsResponse(collisions)
end

function Fluid:checkCollisionsResponse(collisions)
	for i, collision in pairs(collisions) do
		if collision then
            local otherSprite = collision["other"]
			-- if otherSprite.dy > 0 then
			-- 	self:touch(otherSprite.x, 8)
			-- elseif otherSprite.dy < 0 then
			-- 	self:touch(otherSprite.x, -8)
			-- else
			self:touch(otherSprite.x, otherSprite.dy + 2)
				
			-- end
			if otherSprite:isa(Player) then
                otherSprite.dx = 0
                otherSprite.dy = 0
                otherSprite:startDeath()
            end
			return gfx.sprite.kCollisionTypeOverlap
        end
    end
end

function Fluid:updatePolygon()
	-- Simulate springs on each vertex.
	for _, v in ipairs(self.vertices) do
		v.velocity += self.tension * (v.natural_height - v.height) - v.velocity * self.dampening
		v.height += v.velocity
	end
	
	-- Propagate changes to the left and right to create a waves.

	-- Propagate to the left.
	for i = self.vertex_count, 1, -1 do
		local vertex <const> = self.vertices[i]
		if i > 1 then
			local left_vertex <const> = self.vertices[i - 1]
			local left_change <const> = self.speed * (vertex.height - left_vertex.height)
			left_vertex.velocity += left_change
			left_vertex.height += left_change
		end
	end
		
	-- Propagate to the right
	for i, vertex in ipairs(self.vertices) do
		if i < self.vertex_count then
			local right_vertex <const> = self.vertices[i + 1]
			local right_change <const> = self.speed * (vertex.height - right_vertex.height)
			right_vertex.velocity += right_change
			right_vertex.height += right_change
		end
		
		-- Update corresponding vertex on polygon.
		self.polygon:setPointAt(
			i, 
			self.bounds.x + ((i-1) * self.column_width), 
			(self.bounds.y + self.bounds.height) - vertex.height
		)
	end
end

function Fluid:fill()
	local image = gfx.image.new(X_OFFSET + self.bounds.width, Y_OFFSET + self.bounds.height)
	gfx.pushContext(image)
		gfx.setColor(gfx.kColorWhite)
		-- gfx.setDitherPattern(0.4)
		gfx.fillPolygon(self.polygon)
	gfx.popContext()
	self:setImage(image)
end