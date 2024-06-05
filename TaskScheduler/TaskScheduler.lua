local tasks = {}

function SimpleTimingLib_Schedule(time, func, ...)
    local task = {...}
    task.func = func
    task.time = GetTime() + time
    table.insert(tasks, task)
end

function SimpleTimingLib_Unschedule(func, ...)
    for i = #tasks, 1, -1 do
        local task = tasks[i]
        if task.func == func then
            local matches = true
            for i = 1, select("#", ...) do -- select("#", ...) returns number of arg store in the vararg
                if select(i, ...) ~= task[i] then
                    matches = false
                    break
                end
            end
            if matches then
                table.remove(tasks, i)
            end
        end
    end
end

local function onUpdate()
    for i = #tasks, 1, -1 do
        local task = tasks[i]
        if task and task.time <= GetTime() then
            table.remove(tasks, i)
            task.func(unpack(task))
        end
    end
end

local frame = CreateFrame("Frame")
frame:SetScript("OnUpdate", onUpdate)
-- SimpleTimingLib_Schedule(10, print, "Hello")