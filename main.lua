--
-- Created by IntelliJ IDEA.
-- User: nander
-- Date: 21-12-17
-- Time: 19:18
-- To change this template use File | Settings | File Templates.
--
function runner(lines, pointer)
    if pointer == 0 then
        pointer = 1
        while(string.find(lines[pointer], "#") ) do
            pointer = pointer + 1
        end
        while type(BASERHYTHM) ~= "number" do
            lines[pointer]:gsub("%d+", function(i) BASERHYTHM = tonumber(i) end)
            pointer = pointer + 1
        end
    end
    local myStr = {}
    while lines[pointer] do
        if string.find(lines[pointer], "#") then
            pointer = pointer + 1
        elseif string.find(lines[pointer], "{") then
            subset, pointer = runner(lines, pointer + 1)
            for k, v in ipairs(subset) do
                myStr[#myStr + 1] = v
            end
        elseif string.find(lines[pointer], "}") then
            local num = -1
            lines[pointer]:gsub("%d+", function(i) num = i end)
            local res = {}
            for i = 1, num do
                for k, v in ipairs(myStr) do
                    res[#res + 1] = v
                end
            end
            return res, pointer + 1
        else
            local nums = {}
            lines[pointer]:gsub("%d+", function(i) nums[#nums + 1] = i end)
            if #nums > 0 then
                if not nums[4] then
                    nums[4] = 1
                end
                for i = 1, nums[4] do
                    myStr[#myStr + 1] = nums
                end
            end
            pointer = pointer + 1
        end
    end
    return myStr, pointer
end

STATE = {}
love.load = function(arg)
    if arg[2] then
        filename = "files/" .. arg[2]
    else
        filename = "files/test.met"
    end
    low = love.audio.newSource("4c#.wav", "static")
    high = love.audio.newSource("4d.wav", "static")
    local l = {}
    for line in io.lines(filename) do
        l[#l + 1] = line
    end
    STATE.rhythm = runner(l, 0)
    STATE.cur = tonumber(arg[3]) or 1
    STATE.timeSince = 0
    STATE.count = 0
    print("loaded rhythm of length: " .. #STATE.rhythm .. ", starting at " .. STATE.cur)
end

love.update = function(dt)
    if not STATE.rhythm[STATE.cur] then return end
    if STATE.timeSince == 0 then
        high:clone( ):play()
        STATE.count = STATE.count + 1
        if not STATE.rhythm[STATE.cur] then return end
        print("HI", STATE.rhythm[STATE.cur][1], STATE.rhythm[STATE.cur][2], STATE.rhythm[STATE.cur][3])
    end
    STATE.timeSince = STATE.timeSince + dt
    local b = STATE.rhythm[STATE.cur]
    if not b then return end
    local t = b[1] / b[2] * 4 * 60 / b[3]
    if STATE.timeSince > t then
        STATE.timeSince = 0
        STATE.count = 0
        STATE.cur = STATE.cur + 1
    elseif STATE.count * 60 / 2 / b[3] < STATE.timeSince then
        low:clone( ):play()
        STATE.count = STATE.count + 1
        print("LOW")
    end
end

love.draw = function()
    local b = STATE.rhythm[STATE.cur]
    if not b then
        love.graphics.print("FINISHED",10,10)
        return
    end
    first = true
    for j = 0, 40 do
        local b = STATE.rhythm[STATE.cur + j]

        if b then
            love.graphics.print(b[1].."/"..b[2],10,32+48*j)

            for i = 0, b[1] - 1 do
                if first then
                    love.graphics.setColor(128, 128, 128)
                else
                    love.graphics.setColor(64, 64, 64)
                end

                love.graphics.rectangle("fill", 50 + BASERHYTHM/b[3]*256 / b[2] * i, 32+48*j, BASERHYTHM/b[3]*256 / b[2], 32)

                first = not first
            end
        end
        love.graphics.setColor(256, 256, 256)

    end
    local b = STATE.rhythm[STATE.cur]

    local d = math.max(b[2], 8)
    local i = math.floor(STATE.timeSince / (60 * 4 / (d * b[3])))

    love.graphics.rectangle("fill", 50 + BASERHYTHM/b[3]*256 / d * i, 32, BASERHYTHM/b[3]*256 / d, 32)
end