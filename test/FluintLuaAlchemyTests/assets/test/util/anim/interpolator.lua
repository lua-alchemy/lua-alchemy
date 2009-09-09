-- interpolator.lua -- tests for animation interpolators
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

-- TODO: Test times_and_values_looped, nearest_left_interpolator.

dofile('lua-nucleo/strict.lua')
dofile('lua-nucleo/import.lua') -- Import module should be loaded manually

local make_suite = select(1, ...)
assert(type(make_suite) == "function")

local times_and_values_looped,
      looped_linear_interpolator,
      nearest_left_interpolator,
      interpolator_imports
      = import 'lua-nucleo/util/anim/interpolator.lua'
      {
        'times_and_values_looped',
        'looped_linear_interpolator',
        'nearest_left_interpolator'
      }

--------------------------------------------------------------------------------

local test = make_suite("interpolator_tests", interpolator_imports)

test:UNTESTED "times_and_values_looped"
test:UNTESTED "nearest_left_interpolator"

--------------------------------------------------------------------------------

test:test_for "looped_linear_interpolator" (function()
  local check = function(
      keyframes,
      time,
      interval_hint,
      expected_value,
      expected_next_pos
    )
    keyframes = times_and_values_looped(00.0, 1.0)(keyframes)
    local actual_value, actual_next_pos = looped_linear_interpolator(
        keyframes, time, interval_hint
      )

    local err_str = ''

    if math.abs(actual_value - expected_value) > 1e-6 then
    --if actual_value ~= expected_value then
      err_str = err_str .. ("bad actual value %f, expected %f\n"):format(actual_value, expected_value)
    end

    if actual_next_pos ~= expected_next_pos then
      err_str = err_str .. ("bad next position %f, expected %f\n"):format(actual_next_pos, expected_next_pos)
    end

    if err_str ~= '' then
      error(
          ("looped linear interpolator check (time %f interval_hint %s, data %s) failed:\n%s"):format(
              time, tostring(interval_hint), tstr(keyframes),
              err_str
            )
        )
    end
  end

  local simple_data = { [0.0] = 1.0; [1.0] = 4.0; }

  local hints = { nil, 1, 2 }
  for i = 1, 3 do
    local hint = hints[i]
    check(
        simple_data,
        0.0, hint,
        1.0 + 0.0 * 3.0, 1
      )

    check(
        simple_data,
        0.25, hint,
        1.0 + 0.25 * 3.0, 2
      )

    check(
        simple_data,
        0.75, hint,
        1.0 + 0.75 * 3.0, 2
      )

    check(
        simple_data,
        0.9999, hint,
        1.0 + 0.9999 * 3.0, 2
      )

    check(
        simple_data,
        1.0, hint,
        1.0 + 0.0 * 3.0, 1
      )

    check(
        simple_data,
        -0.25, hint,
        1.0 + (-0.25 % 1.0) * 3.0, 2
      )

    check(
        simple_data,
        1.25, hint,
        1.0 + (1.25 % 1.0) * 3.0, 2
      )

    check(
        simple_data,
        2.0, hint,
        1.0 + 0.0 * 3.0, 1
      )

    local shifted_data = { [1.0] = 1.0; [2.0] = 4.0; }
    check(
        shifted_data,
        1.25, hint,
        1.0 + 0.25 * 3.0, 2
      )

    check(
        shifted_data,
        0.25, hint,
        1.0 + 0.25 * 3.0, 2
      )

    check(
        shifted_data,
        2.25, hint,
        1.0 + 0.25 * 3.0, 2
      )

    local shifted_data2 = { [0.5] = 1.0; [1.5] = 4.0; }
    check(
        shifted_data2,
        0.75, hint,
        1.0 + 0.25 * 3.0, 2
      )

    check(
        shifted_data2,
        -0.25, hint,
        1.0 + 0.25 * 3.0, 2
      )

    check(
        shifted_data2,
        1.75, hint,
        1.0 + 0.25 * 3.0, 2
      )

    local shifted_data3 = { [-1.0] = 1.0; [0.0] = 4.0; }
    check(
        shifted_data3,
        -0.75, hint,
        1.0 + 0.25 * 3.0, 2
      )
    check(
        shifted_data3,
        -1.75, hint,
        1.0 + 0.25 * 3.0, 2
      )
    check(
        shifted_data3,
        0.25, hint,
        1.0 + 0.25 * 3.0, 2
      )

    local shifted_data4 = { [0.5] = 1.0; [2.5] = 8.0; }
    check(
        shifted_data4,
        0.75, hint,
        1.0 + 0.25 * 7.0 / 2.0, 2
      )

    check(
        shifted_data4,
        -1.25, hint,
        1.0 + 0.25 * 7.0 / 2.0, 2
      )

    check(
        shifted_data4,
        2.75, hint,
        1.0 + 0.25 * 7.0 / 2.0, 2
      )

    local actual_bug_data = { [7.5] = 1.0; [17.5] = 2.0; }
    check(
        actual_bug_data,
        0.58620309829712, hint,
        1.308620, 2
      )
  end

  local complex_data = { [0.0] = 1.0; [1.0] = 2.0; [2.0] = 0.0; }

  local hints = { nil, 1, 2, 3 }
  for i = 1, 4 do
    local hint = hints[i]

    check(
        complex_data,
        -0.75, hint,
        1.5, 3
      )

    check(
        complex_data,
        0.0, hint,
        1.0, 1
      )

    check(
        complex_data,
        0.25, hint,
        1.25, 2
      )

    check(
        complex_data,
        1.0, hint,
        2.0, 2
      )

    check(
        complex_data,
        1.25, hint,
        1.5, 3
      )

    check(
        complex_data,
        1.9999, hint,
        2 - 0.9999 * 2, 3
      )

    check(
        complex_data,
        2.0, hint,
        1.0, 1
      )

    check(
        complex_data,
        2.25, hint,
        1.25, 2
      )
  end
end)

--------------------------------------------------------------------------------

assert(test:run())
