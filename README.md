Simple Tiled Implementation
==
---
Simple Tiled Implementation is a [**Tiled Map Editor**][Tiled] library designed for the *awesome* [**LÖVE**][LOVE] framework.

Quick Example
--
---
```lua
local sti = require "sti"
local myMap

function love.load()
    -- Load a map exported from Tiled as a lua file
    myMap = sti.new("assets/maps/map01.lua")
end

function love.update(dt)
	myMap:update(dt) -- this doesn't do anything (yet)!
end

function love.draw()
	myMap:draw()
end

```

License
--
---
This code is licensed under the [**MIT Open Source License**][MIT]. Check out the LICENSE file for more information.

[Tiled]: http://www.mapeditor.org/
[LOVE]: https://www.love2d.org/
[MIT]: http://www.opensource.org/licenses/mit-license.html