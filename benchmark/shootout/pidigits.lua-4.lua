
-- The Computer Language Benchmarks Game
-- http://shootout.alioth.debian.org/
-- Contributed by Wim Couwenberg


-- This is a pure lua implementation of the spigot algorithm for calculating
-- the digits of pi.  It combines the production step and the calculation of
-- the image of the interval [3, 4] into a single computation.  This is based
-- on the fact that for any integer n >= 1 the following equation between
-- matrix products holds:
--
--              [ n  4*n + 2][4  3]   [4  3][2*n - 1  n - 1]
--              [ 0  2*n + 1][1  1] = [1  1][   2     n + 2]
--
-- 1 September 2008


-- the requested number of digits
local N = tonumber(...)

-- Large numbers are expanded in base 2^exp.  Assumption: arithmetic in the Lua
-- interpreter is based on IEEE doubles and we don't need more than 4*N
-- productions to obtain the first N digits of pi.
local exp = 50 - math.ceil(math.log(N)/math.log(2))
local base = 2^exp

-- hardwiring the base in the large number computations (instead of using it as
-- an upvalue) saves quite some time!  Therefore the core algorithms are
-- compiled dynamically for the base that is computed above.  (Idea courtesy of
-- Mike Pall.)
local algo = [[
local function produce(n1, n2, d, n)
    local c1, c2, c3 = 0, 0, 0
    local f = 2*n + 1
    local m11, m12 = 2*n - 1, n - 1
    local      m22 =          n + 2
    for i = 1, #n1 do
        local n1i, n2i = n1[i], n2[i]
        local x = m11*n1i + 2*n2i + c1
        if x < base then
            n1[i], c1 = x, 0
        else
            c1 = x%base
            n1[i], c1 = c1, (x - c1)/base
        end
        x = m12*n1i + m22*n2i + c2
        if x < base then
            n2[i], c2 = x, 0
        else
            c2 = x%base
            n2[i], c2 = c2, (x - c2)/base
        end
        x = f*d[i] + c3
        if x < base then
            d[i], c3 = x, 0
        else
            c3 = x%base
            d[i], c3 = c3, (x - c3)/base
        end
    end
    if c1 ~= 0 or c3 ~= 0 then
        local nn1 = #n1 + 1
        n1[nn1], n2[nn1], d[nn1] = c1, c2, c3
    end
end

local function extract(n1, n2, d, n)
    local c1, c2 = 0, 0
    local f = -10*n
    for i = 1, #n1 do
        local fdi = f*d[i]
        local x = 10*n1[i] + fdi + c1
        if x < base and x >= 0 then
            n1[i], c1 = x, 0
        else
            c1 = x%base
            n1[i], c1 = c1, (x - c1)/base
        end
        x = 10*n2[i] + fdi + c2
        if x < base and x >= 0 then
            n2[i], c2 = x, 0
        else
            c2 = x%base
            n2[i], c2 = c2, (x - c2)/base
        end
    end
    if c1 ~= 0 then
        local nn = #n1 + 1
        n1[nn], n2[nn], d[nn] = c1, c2, 0
    end
end

return produce, extract
]]

local produce, extract = loadstring(string.gsub(algo, "base", tostring(base)))()

local function digit(n1, n2, d)
    local nn = #n1
    local dnn = d[nn]
    if dnn ~= 0 then
        local n1nn, n2nn = n1[nn], n2[nn]
        local r1, r2 = n1nn%dnn, n2nn%dnn
        local p1, p2 = (n1nn - r1)/dnn, (n2nn - r2)/dnn
        if p1 == p2 and p1 <= r1 and p2 <= r2 then return p1 end
    end
end

-- first approximants are 4/1 and 3/1
-- these are expressed in large numbers n1/d, n2/d
local n1 = {4}
local n2 = {3}
local d  = {1}

-- next production step index 
local n = 1

-- here goes...
local write = io.write
local digits = 0
while digits < N do
    local g = digit(n1, n2, d)
    if g then
        write(g)
        extract(n1, n2, d, g)
        digits = digits + 1
        if digits%10 == 0 then write("\t:", digits, "\n") end
    else
        produce(n1, n2, d, n)
        n = n + 1
    end
end

if N%10 ~= 0 then
    write(string.rep(" ", 10 - N%10), "\t:", N, "\n")
end
