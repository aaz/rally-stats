require 'time_diff'

def cycle_time(timeline)
  total = 0.0
  started = false
  timing = false
  last_timestamp = nil

  timeline.each do |rev|
    if (started) then
      if (timing) then
        if (rev.include? 'Blocked') then
          elapsed = Time.diff(rev[0], last_timestamp, '%m')[:diff].to_i
          total += elapsed
          timing = false
        elsif (rev.include? 'Completed') then
          elapsed = Time.diff(rev[0], last_timestamp, '%m')[:diff].to_i
          total += elapsed
          timing = false
          break
        end
      else # Not timing
        if (rev.include? 'Unblocked') then
          last_timestamp = rev[0]
          timing = true
        end
      end
    elsif (rev.include? 'In-Progress') then
      started = timing = true
      last_timestamp = rev[0]
    end
  end

  return (total / 60.0).round(1) # Convert from minutes to hours
end

def blocked_time(timeline)
  total = 0.0
  timing = false
  last_timestamp = nil

  timeline.each do |rev|
    if (timing) then
      if (rev.include? 'Unblocked') then
        elapsed = Time.diff(rev[0], last_timestamp, '%m')[:diff].to_i
        total += elapsed
        timing = false
      elsif (rev.include? 'Completed') then
        elapsed = Time.diff(rev[0], last_timestamp, '%m')[:diff].to_i
        total += elapsed
        timing = false
        break
      end
    else # Not timing
      if (rev.include? 'Blocked') then
        last_timestamp = rev[0]
        timing = true
      end
    end
  end

  return (total / 60.0).round(1) # Convert from minutes to hours
end
