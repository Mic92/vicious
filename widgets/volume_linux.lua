---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { match = string.match }
local helpers = require("vicious.helpers")
-- }}}


-- Volume: provides volume levels and state of requested ALSA mixers
-- vicious.widgets.volume
local volume_linux = {}


-- {{{ Volume widget type
local function worker(warg)
    if not warg then return end

    local mixer_state = {
        ["on"]  = "♫", -- "",
        ["off"] = "♩"  -- "M"
    }

    if type(warg) ~= "table" then
      warg = { warg }
    end

    local cmd = "amixer -M get "
    for _, arg in ipairs(warg) do
      cmd = cmd .. " " .. helpers.shellquote(arg)
    end

    -- Get mixer control contents
    local f = io.popen(cmd)
    local mixer = f:read("*all")
    f:close()

    -- Capture mixer control state:          [5%] ... ... [on]
    local volu, mute = string.match(mixer, "([%d]+)%%.*%[([%l]*)")
    -- Handle mixers without data
    if volu == nil then
       return {0, mixer_state["off"]}
    end

    -- Handle mixers without mute
    if mute == "" and volu == "0"
    -- Handle mixers that are muted
    or mute == "off" then
       mute = mixer_state["off"]
    else
       mute = mixer_state["on"]
    end

    return {tonumber(volu), mute}
end
-- }}}

return setmetatable(volume_linux, { __call = function(_, ...) return worker(...) end })
