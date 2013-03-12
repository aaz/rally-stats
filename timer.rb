require 'time_diff'

TIMESTAMP = 0
EVENT = 1

def weekend?(date)
  return (date.saturday? || date.sunday?)
end

def read_timeline(timeline)
  started, timing = false, false
  last_ts = nil

  cycle_time = 0.0
  days = 0
  hours_diff = 0.0

  # Advance through timeline until 'start' point ('In-Progress')
  while((timeline.first)[EVENT] != 'In-Progress') do
    timeline.shift
  end

  started, timing = true, true
  last_ts = DateTime.parse(timeline.first[TIMESTAMP])

  timeline[1, (timeline.count-1)].each do |t, e|
    
    next_ts = DateTime.parse(t)

    while (last_ts.to_date < next_ts.to_date) do
      last_ts = last_ts.next
      days += 1 unless (timing == false || weekend?(last_ts))
    end

    time_diff = next_ts.to_time - last_ts.to_time # Units: seconds
    hours_diff = (time_diff /= 3600.0).round(1)

    if (e.eql? "Completed") then
      cycle_time += (24.0 * days) + hours_diff
      break
    elsif (e.eql? "Blocked") then
      cycle_time += (24.0 * days) + hours_diff
      days = 0
      timing = false
    elsif (e.eql? "Unblocked") then
      last_ts = DateTime.parse(t)
      days = 0
      timing = true
    end
  end

  return cycle_time
end

def old_cycle_time(timeline)
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

alias :cycle_time :read_timeline

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
