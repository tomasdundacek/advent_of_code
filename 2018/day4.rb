require 'time'

LINES = File.read('data/day4.txt').lines.map(&:chomp).freeze
REGEXP = /\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2})\] (f|w|G)\S* #?(\d+)?/.freeze

def event_type(sym)
  case sym.to_sym
  when :f then :falls_asleep
  when :w then :wakes_up
  when :G then :begins_shift
  end
end

EVENTS = LINES.map do |line|
  line.match(REGEXP) do |matchgroup|
    {
      timestamp: Time.parse(matchgroup[1]),
      type: event_type(matchgroup[2]),
      guard_id: matchgroup[3] && matchgroup[3].to_i
    }
  end
end.sort_by { |e| e[:timestamp] }

guard_stats = EVENTS.inject(active_guard: nil, sleeps_from: nil, stats: {}) do |memo, event|
  case event[:type]
  when :begins_shift then
    memo[:active_guard] = event[:guard_id]
    memo[:stats][event[:guard_id]] ||= { sleep_time: 0, sleep_minutes: [] }
  when :falls_asleep then
    memo[:sleeps_from] = event[:timestamp]
  when :wakes_up then
    memo[:stats][memo[:active_guard]][:sleep_time] +=
      ((event[:timestamp] - memo[:sleeps_from]) / 60)
    memo[:stats][memo[:active_guard]][:sleep_minutes] <<
      (memo[:sleeps_from].min...event[:timestamp].min)
  end

  memo
end

# Solution 4a
most_sleeping_guard, sleep_stats = guard_stats[:stats].max_by do |_, v|
  v[:sleep_time]
end

minutes = sleep_stats[:sleep_minutes].map!(&:to_a).flatten.group_by(&:itself).transform_values(&:count).max_by{|k,v| v}[0]
puts "Solution 4a: #{most_sleeping_guard} * #{minutes} = #{most_sleeping_guard * minutes}"

# Solution 4b
guard_top = guard_stats[:stats].map do |guard, stats|
  minute, count = stats[:sleep_minutes].map!(&:to_a).flatten.group_by(&:itself).transform_values(&:count).max_by{|k,v| v}
  [guard, { minute: minute, count: count }]
end.to_h

top_minute_guard = guard_top.max_by do |_, stats|
  stats[:count] || 0
end

puts "Solution 4b: #{top_minute_guard[0]} * #{top_minute_guard[1][:minute]} = #{top_minute_guard[0] * top_minute_guard[1][:minute]}"
