#!/usr/bin/ruby

require 'rubygems'
require 'rack'
require 'json'
require 'thin'
require './log_explorer.rb'
require 'cgi'

class Jules
  def initialize
    @compsoc_logs = LogExplorer.new(COMPSOC_LOG_PATH)
    @reader = LogLineInterpretter.new
  end

  def handle_request(req)
    path = req.path
    puts "Request: #{path}"
    if path.split('/')[1] == 'logstat'
      @compsoc_logs.reload
      response = Hash.new
      object = Hash.new
      if (path.split('/')[2] == 'last_line') || (path.split('/')[2] == 'first_line')
        if path.split('/')[2] == 'last_line'
          if path.split('/')[3] == nil
            response[:description] = 'last line spoken on #compsoc'
            line = @compsoc_logs.last_line_spoken
          elsif path.split('/')[3] == 'by' && !path.split('/')[4].nil?
            name = CGI.unescape(path.split('/')[4])
            response[:description] = "last line spoken on #compsoc by #{name}"
            line = @compsoc_logs.last_line_spoken_by(name)
          else
            return [404, {'Content-Type' => 'application/json'}, [{error: 'Page not found'}.to_json,"\n"]]
          end
        else
          if path.split('/')[3] == nil
            response[:description] = 'first line spoken on #compsoc'
            line = @compsoc_logs.first_line_spoken
          elsif path.split('/')[3] == 'by' && !path.split('/')[4].nil?
            name = CGI.unescape(path.split('/')[4])
            response[:description] = "first line spoken on #compsoc by #{name}"
            line = @compsoc_logs.first_line_spoken_by(name)
          else
            return [404, {'Content-Type' => 'application/json'}, [{error: 'Page not found'}.to_json,"\n"]]
          end
        end
        if !line.nil?
          object[:username] = @reader.speaker(line)
          object[:text] = @reader.text_spoken(line)
          object[:time] = @reader.time_spoken(line)
          object[:target_name] = @reader.target_name(line)
          response[:size] = 1
          response[:object] = object
        else
          response[:size] = 0
          response[:object] = nil
        end
      elsif path.split('/')[2] == 'all_lines'
        if path.split('/')[3].nil?
          response[:description] = 'all lines spoken on #compsoc'
          lines = @compsoc_logs.spoken_lines
        elsif path.split('/')[3] == 'by' && !path.split('/')[4].nil?
          name = CGI.unescape(path.split('/')[4])
          response[:description] = "all lines spoken on #compsoc by #{name}"
          lines = @compsoc_logs.lines_spoken_by(name)
          if path.split('/')[5] == 'matching' && !path.split('/')[6].nil?
            filter = CGI.unescape(path.split('/')[6])
            response[:filter] = filter
            lines = lines.find_all { |l| l =~ /#{filter}/ }
          end
        elsif path.split('/')[3] == 'matching' && !path.split('/')[4].nil?
          filter = CGI.unescape(path.split('/')[4])
          response[:description] = "all lines spoken on #compsoc"
          response[:filter] = filter
          lines = @compsoc_logs.spoken_lines.find_all { |l| l =~ /#{filter}/ }
        else
            return [404, {'Content-Type' => 'application/json'}, [{error: 'Page not found'}.to_json,"\n"]]
        end
        puts "Processing #{lines.size} lines"
        response[:size] = lines.size
        response[:object] = lines.map { |line| { username: @reader.speaker(line), text: @reader.text_spoken(line), time: @reader.time_spoken(line), target_name: @reader.target_name(line) } } 
      else
        return [404, {'Content-Type' => 'application/json'}, [{error: 'Page not found'}.to_json,"\n"]]
      end
      [200, {'Content-Type' => 'application/json'}, [JSON.pretty_generate(response),"\n"]]
    else
      [404, {'Content-Type' => 'application/json'}, [{error: 'Page not found'}.to_json,"\n"]]
    end
  end

  def call(env)
    req = Rack::Request.new(env)
    begin
      handle_request(req)
    rescue Exception => e
      puts e
      [500, {'Content-Type' => 'application/json'}, [{error: 'Something went wrong.'}.to_json,"\n"]]
    end
  end
end

Rack::Handler::Thin.run Jules.new, :Port => 8080
