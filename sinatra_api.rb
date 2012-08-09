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

get '/last_line' do
  content_type :json
  line_response('last line spoken on #compsoc', logfile.last_line_spoken)
end

get '/first_line' do
  content_type :json
  line_response('first line spoken on #compsoc', logfile.first_line_spoken)
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

def lines_response
end
