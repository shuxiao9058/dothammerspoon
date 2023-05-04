local M = {}

local mt = { __index = M }

local log = hs.logger.new('yabai')
log.setLogLevel('debug')

local json_encode = hs.json.encode
local json_decode = hs.json.decode

local yabaiPath = '/opt/local/bin/yabai'

function M:start()
    local task = self.deepest_task:start()
    self.task = task
    return self
end

function M:catch(argstr)
    local task = hs.task.new(yabaiPath, nil, hs.fnutils.split(argstr, '%s'))
    self.task:setCallback(function(exitCode, stdOut, stdErr) -- next task's callback
        -- self.result = {
        --     exitCode = exitCode,
        --     stdOut = stdOut,
        --     stdErr = stdErr
        -- }

        if exitCode ~= 0 then
            task:start() -- execute catch's task
        end
    end)

    self.task = task
    return self
end

function M:next(argstr)
    -- next task
    local task = hs.task.new(yabaiPath, nil, hs.fnutils.split(argstr, '%s'))
    self.task:setCallback(function(exitCode, stdOut, stdErr) -- default task's callback
        -- self.result = {
        --     exitCode = exitCode,
        --     stdOut = stdOut,
        --     stdErr = stdErr
        -- }

        if exitCode == 0 then -- execute next task
            task:start()
        end
    end)

    self.task = task
    return self
end

function M:call(argstr)
    local task = hs.task.new(yabaiPath, nil, hs.fnutils.split(argstr, '%s'))

    return setmetatable({
        deepest_task = task,
        task = task,
        result = nil, -- final result
    }, mt)
end

function M:waitUntilFinished()
    if not self.task then return end

    self.task:setCallback(function(exitCode, stdOut, stdErr) -- default task's callback
        local json
        if stdOut and stdOut ~= '' then
            json = json_decode(stdOut)
        end

        self.result = {
            exitCode = exitCode,
            stdOut = stdOut,
            stdErr = stdErr,
            json = json
        }
        -- log.df("exitCode = %d stdOut = %s, stdErr = %s", exitCode, stdOut, stdErr)
    end)

    self.task:waitUntilExit()
    return self
end

return M
