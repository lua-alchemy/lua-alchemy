-- interpolator.lua -- animation interpolators
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

-- TODO: Try to abstract from time

local assert, next, ipairs = assert, next, ipairs
local math_min, math_max, math_huge = math.min, math.max, math.huge
local table_sort = table.sort

local lower_bound = import 'lua-nucleo/algorithm.lua' { 'lower_bound' }

-- Need to check value to preserve ordering (table.sort() does not preserve
-- ordering for equal values).
local time_value_less = function(lhs, rhs)
  return (lhs.time < rhs.time) or ((lhs.time == rhs.time) and (lhs.value < rhs.value))
end

-- Assumes looped timeline
local times_and_values_looped = function(time_offset, time_scale)
  return function(data)
    local result = {}

    assert(next(data))

    local min_time = math_huge
    local max_time = -math_huge
    for time, value in pairs(data) do
      time = (time + time_offset) * time_scale -- Normalize time
      min_time = math_min(time, min_time)
      max_time = math_max(time, max_time)
      result[#result + 1] = { time = time; value = value; }
    end

    local period = max_time - min_time
    assert(period > 0, "bad data")

    for i, keyframe in ipairs(result) do
      -- Ensure we always use first loop of our period.
      -- Looks like this properly handles negative numbers as well.
      if keyframe.time ~= max_time then
        keyframe.time = (keyframe.time - min_time) % period
                      + (min_time % period)
      else
        -- TODO: ?! Preserving borderline value to get proper width
        keyframe.time = (keyframe.time - min_time) % period
                      + (min_time % period)
                      + period
      end
    end

    table_sort(result, time_value_less)

    result.period = period
    result.min_time = min_time % period

    return result
  end
end

local find_frame_interval_looped = function(keyframes, time, interval_hint)
  local period = assert(keyframes.period)
  local min_time = assert(keyframes.min_time)

  time = ((time - min_time) % period) + min_time

  -- TODO: Some frame iterator could be good here.

  local next_pos = interval_hint or lower_bound(keyframes, "time", time)
  local next_frame = keyframes[next_pos]
  if not next_frame then
    next_pos = 1
    next_frame = assert(keyframes[next_pos])
  end

  local prev_pos = next_pos - 1
  local prev_frame = keyframes[prev_pos]
  if not prev_frame then
    prev_pos = #keyframes
    prev_frame = assert(keyframes[prev_pos])
  end

  if interval_hint then
    -- We need to check if we're still in hinted interval.
    -- Optimized for case when time increases linearly, and rarely skips frames.
    -- TODO: WTF with that range check?! Note we ought to imitate lower_bound() behavior above.
    local n = 1
    while
      not (
          (time == next_frame.time) or
          (time > prev_frame.time and time < next_frame.time)
        )
    do
      prev_pos = next_pos
      prev_frame = next_frame

      next_pos = prev_pos + 1
      next_frame = keyframes[next_pos]
      if not next_frame then
        next_pos = 1
        next_frame = assert(keyframes[next_pos])
      end

      n = n + 1
      assert(n <= #keyframes, "infinite seeking loop detected") -- Sanity check
    end
  end

  return time, prev_pos, prev_frame, next_pos, next_frame
end

local looped_linear_interpolator = function(keyframes, time, interval_hint)
  local time, prev_pos, prev_frame, next_pos, next_frame = find_frame_interval_looped(keyframes, time, interval_hint)

  local prev_value, next_value = prev_frame.value, next_frame.value
  local prev_time, next_time = prev_frame.time, next_frame.time

  local value =
    prev_value +
    (time - prev_time) *
    (next_value - prev_value) / (next_time - prev_time)

  return value, next_pos
end

local nearest_left_interpolator = function(keyframes, time, interval_hint)
  local time, prev_pos, prev_frame, next_pos, next_frame = find_frame_interval_looped(keyframes, time, interval_hint)

  local value
  if time == next_frame.time then
    value = next_frame.value
  else
    value = prev_frame.value
  end

  return value, next_pos
end

return
{
  times_and_values_looped = times_and_values_looped;
  looped_linear_interpolator = looped_linear_interpolator;
  nearest_left_interpolator = nearest_left_interpolator;
}
