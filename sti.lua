--[[
------------------------------------------------------------------------------
Simple Tiled Implementation is licensed under the MIT Open Source License.
(http://www.opensource.org/licenses/mit-license.html)
------------------------------------------------------------------------------

Copyright (c) 2014 Landon Manning - LManning17@gmail.com - LandonManning.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local sti = {}
local Map = {}

function sti.new(map)
	local ret = setmetatable({}, {__index = Map})

	-- Load the map
	local firstSlash = map:reverse():find("[/\\]")
	local pathBase = ""

	if firstSlash ~= nil then
		pathBase = map:sub(1, 1 + (#map - firstSlash))
	end

	local mapFunc = assert(love.filesystem.load(map), "No map file named '" .. map .. "'")
	setfenv(mapFunc, {})
	ret.map = mapFunc()

	-- Create array of tile data
	ret.tiles = {}
	local gid = 1

	for i, tileset in ipairs(ret.map.tilesets) do
		local iw = tileset.imagewidth
		local ih = tileset.imageheight
		local tw = tileset.tilewidth
		local th = tileset.tileheight
		local s  = tileset.spacing
		local m  = tileset.margin
		local w  = math.floor((iw - m - s) / (tw + s))
		local h  = math.floor((ih - m - s) / (th + s))

		for y = 1, h do
			for x = 1, w do
				local qx = x * tw + m - tw
				local qy = y * th + m - th

				-- Spacing does not affect the first row/col
				if x > 1 then qx = qx + s end
				if y > 1 then qy = qy + s end

				ret.tiles[gid] = {
					gid = gid,
					tileset = tileset,
					quad = love.graphics.newQuad(qx, qy, tw, th, iw, ih),
					offset = {
						x = tileset.tileoffset.x - ret.map.tilewidth,
						y = tileset.tileoffset.y - tileset.tileheight
					}
				}

				gid = gid + 1
			end
		end
	end

	-- Add images
	for i, tileset in ipairs(ret.map.tilesets) do
		tileset.image = love.graphics.newImage(pathBase .. tileset.image)
	end

	-- Add tile structure, images
	for i, layer in ipairs(ret.map.layers) do
		if layer.type == "tilelayer" then
			layer.data = ret:createTileLayerData(layer)
		end

		if layer.type == "imagelayer" then
			layer.image = love.graphics.newImage(pathBase .. layer.image)
		end
	end

	ret.spriteBatches = {}
	for i, tileset in ipairs(ret.map.tilesets) do
		local image = ret.map.tilesets[i].image
		local w = tileset.imagewidth / tileset.tilewidth
		local h = tileset.imageheight / tileset.tileheight
		local size = w * h

		ret.spriteBatches[i] = love.graphics.newSpriteBatch(image, size)
	end

	return ret
end

function Map:update(dt)

end

function Map:draw()
	for i, layer in ipairs(self.map.layers) do
		if layer.type == "tilelayer" then
			self:drawTileLayer(i, layer)
		elseif layer.type == "objectgroup" then
			self:drawObjectLayer(i, layer)
		elseif layer.type == "imagelayer" then
			self:drawImageLayer(i, layer)
		else
			-- Invalid layer!
		end
	end
end

function Map:drawTileLayer(index, layer)
	if layer.visible then
		love.graphics.setColor(255, 255, 255, 255 * layer.opacity)

		local tw = self.map.tilewidth
		local th = self.map.tileheight

		for y,v in pairs(layer.data) do
			for x,tile in pairs(v) do
				if tile.gid ~= 0 then
					local tx = x * tw + tile.offset.x
					local ty = y * th + tile.offset.y

					love.graphics.draw(tile.tileset.image, tile.quad, tx, ty)
				end
			end
		end

		love.graphics.setColor(255, 255, 255, 255)
	end
end

function Map:drawObjectLayer(index, layer)
	if layer.visible then
		love.graphics.setColor(255, 255, 255, 255 * layer.opacity)

		love.graphics.setColor(255, 255, 255, 255)
	end
end

function Map:drawImageLayer(index, layer)
	if layer.visible then
		love.graphics.setColor(255, 255, 255, 255 * layer.opacity)
		love.graphics.draw(layer.image, 0, 0)
		love.graphics.setColor(255, 255, 255, 255)
	end
end

function Map:createTileLayerData(layer)
	local i = 1
	local map = {}

	for y = 1, layer.height do
		map[y] = {}
		for x = 1, layer.width do
			map[y][x] = self.tiles[layer.data[i]]
			i = i + 1
		end
	end

	return map
end

return sti
