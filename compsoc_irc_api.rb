#!/usr/bin/ruby

require 'sinatra'
require 'json'
require './log_explorer.rb'
require 'cgi'

@logfile
@reader

before do
  logfile.reload
end

get '/all_lines' do
  content_type :json
  lines_response('all lines spoken on #compsoc', logfile.spoken_lines)
end

get '/all_lines/to/:target' do
  content_type :json
  target = CGI.unescape(params[:target])
  lines_response("all lines spoken on #compsoc addressed to #{target}", logfile.spoken_lines.find_all { |l| reader.target_name(l) =~ /#{target}/ }) 
end

get '/all_lines/by/:name' do
  content_type :json
  name = CGI.unescape(params[:name])
  lines_response("all lines spoken on #compsoc by #{name}", logfile.lines_spoken_by(name))
end

get '/all_lines/by/:name/to/:target' do
  content_type :json
  name = CGI.unescape(params[:name])
  target = CGI.unescape(param[:target])
  matching_lines = logfile.lines_spoken_by(name).find_all { |l| reader.target_name(l) =~ /#{target}/ }
  lines_response("all lines spoken on #compsoc by #{name} and addressed to #{target}", matching_lines)
end


get '/all_lines/matching/:filter' do
  content_type :json
  filter = CGI.unescape(params[:filter])
  matching_lines = logfile.spoken_lines.find_all { |l| reader.text_spoken(l) =~ /#{filter}/ }
  lines_response("all lines spoken on #compsoc matching '#{filter}'", matching_lines)
end

get '/all_lines/matching/:filter/to/:target' do
  content_type :json
  filter = CGI.unescape(params[:filter])
  target = CGI.unescape(params[:target])
  matching_lines = logfile.spoken_lines.find_all { |l| reader.text_spoken(l) =~ /#{filter}/ && reader.target_name(l) =~ /#{target}/ }
  lines_response("all lines spoken on #compsoc matching '#{filter}' and addressed to #{target}", matching_lines)
end

get '/all_lines/by/:name/matching/:filter' do
  content_type :json
  name = CGI.unescape(params[:name])
  filter = CGI.unescape(params[:filter])
  matching_lines = logfile.lines_spoken_by(name).find_all { |l| reader.text_spoken(l) =~ /#{filter}/ }
  lines_response("all lines spoken on #compsoc by #{name} and matching '#{filter}'", matching_lines)
end

get '/all_lines/by/:name/matching/:filter/to/:target' do
  content_type :json
  name = CGI.unescape(params[:name])
  filter = CGI.unescape(params[:filter])
  target = CGI.unescape(params[:target])
  matching_lines = logfile.lines_spoken_by(name).find_all { |l| reader.text_spoken(l) =~ /#{filter}/ && reader.target_name(l) =~ /#{target}/ }
  lines_response("all lines spoken on #compsoc by #{name}, matching '#{filter}' and addressed to #{target}", matching_lines)
end

get '/last_line' do
  content_type :json
  line_response('last line spoken on #compsoc', logfile.last_line_spoken)
end

get '/last_line/by/:name' do
  content_type :json
  name = CGI.unescape(name)
  line_response("last line spoken on #compsoc by #{name}", logfile.last_line_spoken_by(name))
end

get '/first_line' do
  content_type :json
  line_response('first line spoken on #compsoc', logfile.first_line_spoken)
end

get '/first_line/by/:name' do
  content_type :json
  name = CGI.unescape(name)
  line_response("first line spoken on #compsoc by #{name}", logfile.first_line_spoken_by(name))
end

private

def logfile
  @logfile ||= LogExplorer.new(COMPSOC_LOG_PATH)
end

def reader
  @reader ||= LogLineInterpretter.new
end

def line_response(description, line)
  response = Hash.new
  object = Hash.new
  response[:description] = description
  response[:size] = 1
  object[:username] = reader.speaker(line)
  object[:text] = reader.text_spoken(line)
  object[:time] = reader.time_spoken(line)
  object[:target_name] = reader.target_name(line)
  response[:object] = object
  JSON.pretty_generate(response)
end

def lines_response(description, lines, filter=nil)
  response = Hash.new
  response[:description] = description
  response[:size] = lines.size
  response[:object] = lines.map do |line|
    { username: reader.speaker(line),
      text: reader.text_spoken(line),
      time: reader.time_spoken(line),
      target_name: reader.target_name(line) }
  end
  JSON.pretty_generate(response)
end
