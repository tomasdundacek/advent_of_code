LINES = File.read('data/day7.txt').lines.map(&:chomp).freeze
REGEXP = /Step ([A-Z]).+ step ([A-Z]).+$/.freeze

INSTRUCTIONS = LINES.map do |line|
  line.match(REGEXP) do |matchdata|
    { step: matchdata[1], before: matchdata[2] }
  end
end.freeze

all_steps = INSTRUCTIONS.flat_map { |i| [i[:step], i[:before]] }.uniq
task_dependencies = all_steps.map { |i| [i, []] }.sort.to_h

INSTRUCTIONS.each do |instruction|
  task_dependencies[instruction[:before]] << instruction[:step]
  task_dependencies[instruction[:before]].sort!
end

# PART A
output = ''

until task_dependencies.empty?
  # find first available step (with no dependencies)
  next_task = task_dependencies.detect { |_, v| v.empty? }[0]
  # Debug
  # pp task_dependencies
  # puts "Next task: #{next_task}"

  # remove/process the task
  task_dependencies.delete(next_task)
  # remove this dependency for all tasks
  task_dependencies.each do |_, dependencies|
    dependencies.delete(next_task)
  end

  output << next_task
end

# Solution 7A can also be reproduced by altering solution 7B by
# - setting WORKERS to 1
# - setting DELAY to 0
# - outputting completed_tasks.join instead of time
puts "Solution 7A: #{output}"

# PART B
DELAY = 60
WORKERS = (0...4).map { |w| [w, task: nil] }.to_h
completed_tasks = []
time = (0..Float::INFINITY)

task_dependencies = all_steps.map do |i|
  [
    i,
    { dependencies: [], time_left: i.ord - 64 + DELAY }
  ]
end.sort.to_h

INSTRUCTIONS.each do |instruction|
  task_dependencies[instruction[:before]][:dependencies] << instruction[:step]
  task_dependencies[instruction[:before]][:dependencies].sort!
end

time.step do |t|
  # puts "Time #{t}" # for debugging

  # Assignment of workers
  available_workers = WORKERS.find_all { |_, w| w[:task].nil? }
  available_workers.each do |worker|
    worked_on_tasks = WORKERS.map { |_, w| w[:task] }
    available_tasks = task_dependencies.select do |name, info|
      (task_dependencies.keys - worked_on_tasks).include?(name)
    end

    next if available_tasks.empty?

    task_id, = available_tasks.detect { |_, v| v[:dependencies].empty? }
    WORKERS[worker[0]][:task] = task_id
  end

  # Work on tasks!
  assigned_tasks = WORKERS.map { |_, w| w[:task] }
  # pp WORKERS
  task_dependencies.slice(*assigned_tasks).each do |name, _|
    task_dependencies[name][:time_left] -= 1
  end

  # Remove done tasks
  task_dependencies.delete_if do |name, task|
    task[:time_left].zero? && completed_tasks << name
  end

  # Remove done tasks from dependencies
  task_dependencies.each do |_, task|
    completed_tasks.each do |c|
      task[:dependencies].delete(c)
    end
  end

  # Remove tasks from workers
  WORKERS.each do |k, v|
    WORKERS[k][:task] = nil if completed_tasks.include?(v[:task])
  end

  if task_dependencies.empty?
    puts "Solution 7B: #{(t + 1).to_i}"
    break
  end
end