-- The Great Computer Language Shootout
-- http://shootout.alioth.debian.org/
-- contributed by Mike Pall

local n = tonumber(arg[1])
local function pr(fmt, x) io.write(string.format(fmt, x)) end

do
  local sum1, sum2, sum3, sum4, sum5, sum6, sum7 = 1, 0, 0, 0, 0, 0, 0
  local twothirds, sqrt, sin, cos = 2/3, math.sqrt, math.sin, math.cos
  for k=1,n do
    local k2, sk, ck = k*k, sin(k), cos(k)
    local k3 = k2*k
    sum1 = sum1 + twothirds^k
    sum2 = sum2 + 1/sqrt(k)
    sum3 = sum3 + 1/(k2+k)
    sum4 = sum4 + 1/(k3*sk*sk)
    sum5 = sum5 + 1/(k3*ck*ck)
    sum6 = sum6 + 1/k
    sum7 = sum7 + 1/k2
  end
  pr("%.9f\t(2/3)^k\n", sum1)
  pr("%.9f\tk^-0.5\n", sum2)
  pr("%.9f\t1/k(k+1)\n", sum3)
  pr("%.9f\tFlint Hills\n", sum4)
  pr("%.9f\tCookson Hills\n", sum5)
  pr("%.9f\tHarmonic\n", sum6)
  pr("%.9f\tRiemann Zeta\n", sum7)
end

do local sum = 0; for k=1,n-1,2 do sum = sum + 1/k end
for k=2,n,2 do sum = sum - 1/k end
pr("%.9f\tAlternating Harmonic\n", sum) end

do local sum = 0; for k=1,2*n-1,4 do sum = sum + 1/k end
for k=3,2*n,4 do sum = sum - 1/k end
pr("%.9f\tGregory\n", sum) end

