local ripple = {
	_VERSION = 'Ripple',
	_DESCRIPTION = 'Audio helpers for LÖVE.',
	_URL = 'https://github.com/tesselode/ripple',
	_LICENSE = [[
		MIT License

		Copyright (c) 2019 Andrew Minnich

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.
	]]
}

local unpack = unpack or table.unpack -- luacheck: ignore

--[[
	Represents an object that:
	- can have tags applied
	- has a volume
	- can have effects applied

	Tags, instances, and sounds are all taggable.

	Note that not all taggable objects have children - tags and sounds
	do, but instances do not.
]]
local Taggable = {}

--[[
	Gets the total volume of this object given its own volume
	and the volume of each of its tags.
]]
function Taggable:_getTotalVolume()
	local volume = self.volume
	for tag, _ in pairs(self._tags) do
		volume = volume * tag:_getTotalVolume()
	end
	return volume
end

--[[
	Gets all the effects that should be applied to this object given
	its own effects and the effects of each of its tags. The object's
	own effects will override tag effects.

	Note: currently, if multiple tags define settings for the same effect,
	the final result is undefined, as taggable objects use pairs to iterate
	through the tags, which iterates in an undefined order.
]]
function Taggable:_getAllEffects()
	local effects = {}
	for tag, _ in pairs(self._tags) do
		for name, filterSettings in pairs(tag:_getAllEffects()) do
			effects[name] = filterSettings
		end
	end
	for name, filterSettings in pairs(self._effects) do
		effects[name] = filterSettings
	end
	return effects
end

--[[
	A callback that is called when anything happens that could
	lead to a change in the object's total volume.
]]
function Taggable:_onChangeVolume() end

--[[
	A callback that is called when anything happens that could
	change which effects are applied to the object.
]]
function Taggable:_onChangeEffects() end

function Taggable:_setVolume(volume)
	self._volume = volume
	self:_onChangeVolume()
end

--[[
	_tag, _untag, and _setEffect are analogous to the
	similarly named public API functions (see below), but
	they don't call the _onChangeVolume and _onChangeEffects
	callbacks. This allows me to have finer control over when
	to call those callbacks, so I can set multiple tags and
	effects without needlessly calling the callbacks for each
	one.
]]

function Taggable:_tag(tag)
	self._tags[tag] = true
	tag._children[self] = true
end

function Taggable:_untag(tag)
	self._tags[tag] = nil
	tag._children[self] = nil
end

function Taggable:_setEffect(name, filterSettings)
	if filterSettings == nil then filterSettings = true end
	self._effects[name] = filterSettings
end

--[[
	Given an options table, initializes the object's volume,
	tags, and effects.
]]
function Taggable:_setOptions(options)
	self.volume = options and options.volume or 1
	-- reset tags
	for tag in pairs(self._tags) do
		self:_untag(tag)
	end
	-- apply new tags
	if options and options.tags then
		for _, tag in ipairs(options.tags) do
			self:_tag(tag)
		end
	end
	-- reset effects
	for name in pairs(self._effects) do
		self._effects[name] = nil
	end
	-- apply new effects
	if options and options.effects then
		for name, filterSettings in pairs(options.effects) do
			self:_setEffect(name, filterSettings)
		end
	end
	-- update final volume and effects
	self:_onChangeVolume()
	self:_onChangeEffects()
end

function Taggable:tag(...)
	for i = 1, select('#', ...) do
		local tag = select(i, ...)
		self:_tag(tag)
	end
	self:_onChangeVolume()
	self:_onChangeEffects()
end

function Taggable:untag(...)
	for i = 1, select('#', ...) do
		local tag = select(i, ...)
		self:_untag(tag)
	end
	self:_onChangeVolume()
	self:_onChangeEffects()
end

--[[
	Sets an effect for this object. filterSettings can be the following types:
	- table - the effect will be enabled with the filter settings given in the table
	- true/nil - the effect will be enabled with no filter
	- false - the effect will be explicitly disabled, overriding effect settings
	from a parent sound or tag
]]
function Taggable:setEffect(name, filterSettings)
	self:_setEffect(name, filterSettings)
	self:_onChangeEffects()
end

function Taggable:removeEffect(name)
	self._effects[name] = nil
	self:_onChangeEffects()
end

function Taggable:getEffect(name)
	return self._effects[name]
end

function Taggable:__index(key)
	if key == 'volume' then
		return self._volume
	end
	return Taggable[key]
end

function Taggable:__newindex(key, value)
	if key == 'volume' then
		self:_setVolume(value)
	else
		rawset(self, key, value)
	end
end

--[[
	Represents a tag that can be applied to sounds,
	instances of sounds, or other tags.
]]
local Tag = {__newindex = Taggable.__newindex}

function Tag:__index(key)
	if Tag[key] then return Tag[key] end
	return Taggable.__index(self, key)
end

function Tag:_onChangeVolume()
	-- tell objects using this tag about a potential
	-- volume change
	for child, _ in pairs(self._children) do
		child:_onChangeVolume()
	end
end

function Tag:_onChangeEffect()
	-- tell objects using this tag about a potential
	-- effect change
	for child, _ in pairs(self._children) do
		child:_onChangeEffect()
	end
end

-- Pauses all the sounds and instances tagged with this tag.
function Tag:pause(fadeDuration)
	for child, _ in pairs(self._children) do
		child:pause(fadeDuration)
	end
end

-- Resumes all the sounds and instances tagged with this tag.
function Tag:resume(fadeDuration)
	for child, _ in pairs(self._children) do
		child:resume(fadeDuration)
	end
end

-- Stops all the sounds and instances tagged with this tag.
function Tag:stop(fadeDuration)
	for child, _ in pairs(self._children) do
		child:stop(fadeDuration)
	end
end

function ripple.newTag(options)
	local tag = setmetatable({
		_effects = {},
		_tags = {},
		_children = {},
	}, Tag)
	tag:_setOptions(options)
	return tag
end

-- Represents a specific occurrence of a sound.
local Instance = {}

function Instance:__index(key)
	if key == 'pitch' then
		return self._source:getPitch()
	elseif key == 'loop' then
		return self._source:isLooping()
	elseif Instance[key] then
		return Instance[key]
	end
	return Taggable.__index(self, key)
end

function Instance:__newindex(key, value)
	if key == 'pitch' then
		self._source:setPitch(value)
	elseif key == 'loop' then
		self._source:setLooping(value)
	else
		Taggable.__newindex(self, key, value)
	end
end

function Instance:_getTotalVolume()
	local volume = Taggable._getTotalVolume(self)
	-- apply sound volume as well as tag/self volumes
	volume = volume * self._sound:_getTotalVolume()
	-- apply fade volume
	volume = volume * self._fadeVolume
	return volume
end

function Instance:_getAllEffects()
	local effects = {}
	for tag, _ in pairs(self._tags) do
		for name, filterSettings in pairs(tag:_getAllEffects()) do
			effects[name] = filterSettings
		end
	end
	-- apply sound effects as well as tag/self effects
	for name, filterSettings in pairs(self._sound:_getAllEffects()) do
		effects[name] = filterSettings
	end
	for name, filterSettings in pairs(self._effects) do
		effects[name] = filterSettings
	end
	return effects
end

function Instance:_onChangeVolume()
	-- update the source's volume
	self._source:setVolume(self:_getTotalVolume())
end

function Instance:_onChangeEffects()
	-- get the list of effects that should be applied
	local effects = self:_getAllEffects()
	for name, filterSettings in pairs(effects) do
		-- remember which effects are currently applied to the source
		if filterSettings == false then
			self._appliedEffects[name] = nil
		else
			self._appliedEffects[name] = true
		end
		if filterSettings == true then
			self._source:setEffect(name)
		else
			self._source:setEffect(name, filterSettings)
		end
	end
	-- remove effects that are currently applied but shouldn't be anymore
	for name in pairs(self._appliedEffects) do
		if not effects[name] then
			self._source:setEffect(name, false)
			self._appliedEffects[name] = nil
		end
	end
end

function Instance:_play(options)
	if options and options.fadeDuration then
		self._fadeVolume = 0
		self._fadeSpeed = 1 / options.fadeDuration
	else
		self._fadeVolume = 1
	end
	self._fadeDirection = 1
	self._afterFadingOut = false
	self._paused = false
	self:_setOptions(options)
	self.pitch = options and options.pitch or 1
	if options and options.loop ~= nil then
		self.loop = options.loop
	end
	if not web then self._source:seek(options and options.seek or 0) end
	self._source:play()
end

function Instance:_update(dt)
	-- fade in
	if self._fadeDirection == 1 and self._fadeVolume < 1 then
		self._fadeVolume = self._fadeVolume + self._fadeSpeed * dt
		if self._fadeVolume > 1 then self._fadeVolume = 1 end
		self:_onChangeVolume()
	-- fade out
	elseif self._fadeDirection == -1 and self._fadeVolume > 0 then
		self._fadeVolume = self._fadeVolume - self._fadeSpeed * dt
		if self._fadeVolume < 0 then
			self._fadeVolume = 0
			-- pause or stop after fading out
			if self._afterFadingOut == 'pause' then
				self:pause()
			elseif self._afterFadingOut == 'stop' then
				self:stop()
			end
		end
		self:_onChangeVolume()
	end
end

function Instance:isStopped()
	return (not self._source:isPlaying()) and (not self._paused)
end

function Instance:pause(fadeDuration)
	if fadeDuration and not self._paused then
		self._fadeDirection = -1
		self._fadeSpeed = 1 / fadeDuration
		self._afterFadingOut = 'pause'
	else
		self._source:pause()
		self._paused = true
	end
end

function Instance:resume(fadeDuration)
	if fadeDuration then
		if self._paused then
			self._fadeVolume = 0
			self:_onChangeVolume()
		end
		self._fadeDirection = 1
		self._fadeSpeed = 1 / fadeDuration
	end
	self._source:play()
	self._paused = false
end

function Instance:stop(fadeDuration)
	if fadeDuration and not self._paused then
		self._fadeDirection = -1
		self._fadeSpeed = 1 / fadeDuration
		self._afterFadingOut = 'stop'
	else
		self._source:stop()
		self._paused = false
	end
end

-- Represents a sound that can be played.
local Sound = {}

function Sound:__index(key)
	if key == 'loop' then
		return self._source:isLooping()
	elseif Sound[key] then
		return Sound[key]
	end
	return Taggable.__index(self, key)
end

function Sound:__newindex(key, value)
	if key == 'loop' then
		self._source:setLooping(value)
		for _, instance in ipairs(self._instances) do
			instance.loop = value
		end
	else
		Taggable.__newindex(self, key, value)
	end
end

function Sound:_onChangeVolume()
	-- tell instances about potential volume changes
	for _, instance in ipairs(self._instances) do
		instance:_onChangeVolume()
	end
end

function Sound:_onChangeEffects()
	-- tell instances about potential effect changes
	for _, instance in ipairs(self._instances) do
		instance:_onChangeEffects()
	end
end

function Sound:play(options)
	-- reuse a stopped instance if one is available
	for _, instance in ipairs(self._instances) do
		if instance:isStopped() then
			instance:_play(options)
			return instance
		end
	end
	-- otherwise, create a brand new one
	local instance = setmetatable({
		_sound = self,
		_source = self._source:clone(),
		_effects = {},
		_tags = {},
		_appliedEffects = {},
	}, Instance)
	table.insert(self._instances, instance)
	instance:_play(options)
	return instance
end

function Sound:pause(fadeDuration)
	for _, instance in ipairs(self._instances) do
		instance:pause(fadeDuration)
	end
end

function Sound:resume(fadeDuration)
	for _, instance in ipairs(self._instances) do
		instance:resume(fadeDuration)
	end
end

function Sound:stop(fadeDuration)
	for _, instance in ipairs(self._instances) do
		instance:stop(fadeDuration)
	end
end

function Sound:update(dt)
	for _, instance in ipairs(self._instances) do
		instance:_update(dt)
	end
end

function ripple.newSound(source, options)
	local sound = setmetatable({
		_source = source,
		_effects = {},
		_tags = {},
		_instances = {},
	}, Sound)
	sound:_setOptions(options)
	if options and options.loop then sound.loop = true end
	return sound
end

return ripple
