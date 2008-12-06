
-- The Computer Language Benchmarks Game
-- http://shootout.alioth.debian.org/
-- contributed by Wim Couwenberg
--
-- requires LGMP "A GMP package for Lua 5.1"
--
-- This is still the step-by-step unbounded spigot algorithm but a number of
-- optimizations make it an interesting alternative implementation.  :-)
--
-- 21 September 2008

local gmp, aux = {}, {}
require "c-gmp" (gmp, aux)
local add, mul, divmod = gmp.mpz_add, gmp.mpz_mul_ui, gmp.mpz_fdiv_qr
local addmul, submul = gmp.mpz_addmul_ui, gmp.mpz_submul_ui
local init, get, set = gmp.mpz_init_set_d, gmp.mpz_get_d, gmp.mpz_set
local cmp, divx, gcd = gmp.mpz_cmp, gmp.mpz_divexact, gmp.mpz_gcd

-- used to store various intermediate results
local t1, t2

--
-- Production:
--
-- [m11 m12]     [m11 m12][k  4*k+2]
-- [ 0  m22] <-- [ 0  m22][0  2*k+1]
--
local function produce(m11, m12, m22, k)
  local p = 2*k + 1
  mul(m12, p, m12)
  addmul(m12, m11, 2*p)
  mul(m11, k, m11)
  mul(m22, p, m22)
end

--
-- Extraction:
--
-- [m11 m12]     [10 -10*d][m11 m12]
-- [ 0  m22] <-- [ 0   1  ][ 0  m22]
--
local function extract(m11, m12, m22, d)
  submul(m12, m22, d)
  mul(m11, 10, m11)
  mul(m12, 10, m12)
end

--
-- Test for a new digit.  Note that
--
-- [m11 m12][4]   [m11 m12][3]   [m11]
-- [ 0  m22][1] = [ 0  m22][1] + [ 0 ]
--
-- so we can extract an extra digit exactly if (3*m11 + m12)%m22 + m11 is
-- smaller than m22.  (Here % denotes the remainder.)  Then m11 is itself
-- necessarily smaller than m22.
--
local function digit(m11, m12, m22)
  if cmp(m11, m22) < 0 then
    set(t1, m12)
    addmul(t1, m11, 3)
    divmod(t1, m22, t1, t2)
    add(t2, m11, t2)
    if cmp(t2, m22) < 0 then return get(t1) end
  end
end

--
-- Divide out common factors in the matrix coefficients m11, m12, m22.
--
local function reduce(m11, m12, m22)
  gcd(m11, m12, t1)
  gcd(t1, m22, t1)
  divx(m11, t1, m11)
  divx(m12, t1, m12)
  divx(m22, t1, m22)
end

-- Generate successive digits of PI.
local function pidigits(N)
  local write = io.write
  local floor = math.floor
  local k = 1
  local m11, m12, m22 = init(1), init(0), init(1)
  t1, t2 = init(0), init(0)
  local i = 0
  local r = 256
  while i < N do
    local d = digit(m11, m12, m22)
    if d then
      write(d)
      extract(m11, m12, m22, d)
      i = i + 1
      if i == r then reduce(m11, m12, m22); r = floor(1.0625*r) end
      if i % 10 == 0 then write("\t:", i, "\n") end
    else
      produce(m11, m12, m22, k)
      k = k + 1
    end
  end
  if i % 10 ~= 0 then write(string.rep(" ", 10 - N % 10), "\t:", N, "\n") end
end

local N = tonumber(arg and arg[1]) or 27
pidigits(N)
