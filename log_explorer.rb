#!/usr/bin/ruby

COMPSOC_LOG_PATH = '/home/cronin/irclogs/org/#compsoc.log'

class LogLineInterpretter
  def initialize
  end

  def speaker(spoken_line)
    spoken_line.sub(/^\d\d:\d\d <./, '').split('>').first
  end

  def text_spoken(spoken_line)
    text = spoken_line.sub(/^\d\d:\d\d <.(\w)*> /, '')
    text.sub(/^(\w)*: /,'').chomp
  end

  def target_name(spoken_line)
    text = spoken_line.sub(/^\d\d:\d\d <.(\w)*> /, '')
    if text =~ /^(\w)*: /
      text.split(':')[0]
    else
      nil
    end
  end

  def time_spoken(spoken_line)
    spoken_line.split(/ <./).first
  end

  def details(spoken_line)
    puts "\"#{text_spoken(spoken_line)}\" - #{speaker(spoken_line)}"
  end
end

class LogExplorer
  def initialize(path)
    @log_path = path
    self.reload
    puts "Opened #{@log_path}, file is #{`wc -l #{@log_path}`.split.first} lines long."
  end

  def reload
    @log_lines = File.open(@log_path).readlines.map { |l| l.force_encoding("ISO-8859-1").encode('UTF-8', replace: nil)}
  end

  def anyone_speaking_regex
    /^\d\d:\d\d </
  end

  def speaking_regex(username)
    /^\d\d:\d\d <.#{username}>/
  end

  def random_spoken_line
    spoken_lines.sample.chomp
  end

  def spoken_lines
    @log_lines.find_all { |l| l =~ /^\d\d:\d\d </ }
  end

  def lines_spoken_by(username)
    @log_lines.find_all { |l| l =~ speaking_regex(username) }
  end

  def first_line_spoken_by(username)
    @log_lines.each { |l| return l if (l =~ speaking_regex(username)) }
    return nil
  end

  def last_line_spoken_by(username)
    @log_lines.reverse.each { |l| return l if (l =~ speaking_regex(username)) }
    return nil
  end

  def first_line_spoken
    @log_lines.each { |l| return l if (l =~ anyone_speaking_regex) }
  end

  def last_line_spoken
    @log_lines.reverse.each { |l| return l if (l =~ anyone_speaking_regex) }
    raise "No people spoke in entire log"
  end
end

if __FILE__ == $0
  start = Time.now
  compsoc_logs = LogExplorer.new(COMPSOC_LOG_PATH)
  reader = LogLineInterpretter.new
  reader.details(compsoc_logs.first_line_spoken)
  reader.details(compsoc_logs.last_line_spoken)
  reader.details(compsoc_logs.first_line_spoken_by('wenqi'))
  reader.details(compsoc_logs.last_line_spoken_by('wenqi'))
  reader.details(compsoc_logs.random_spoken_line)
  puts "Log processing took: #{Time.now - start} on #{`uname -p`.chomp}"
end
