-- $Id: sieve.lua-2.lua,v 1.1 2004-11-10 06:48:59 bfulgham Exp $
-- http://www.bagley.org/~doug/shootout/
--
-- Roberto Ierusalimschy pointed out the for loop is much
-- faster for our purposes here than using a while loop.

function main(num)
    for num=num,1,-1 do
        local flags = {}
        count = 0
        for i=2,8192 do
            if not flags[i] then
                for k=i+i, 8192, i do
                    flags[k] = 1
                end
                count = count + 1
            end
        end
    end
end

NUM = tonumber((arg and arg[1])) or 1
count = 0
main(NUM)
io.write("Count: ", count, "\n")

