#!/usr/bin/ruby

require 'rubygems'
require 'rack'

class Jules
  def initialize
  end

  def call(env)
    req = Rack::Request.new(env)
    begin
      [200, {'Content-Type' => 'application/json'}, [{}.to_json]]
    rescue
      [500, {'Content-Type' => 'application/json'}, [{error: 'Something went wrong.'}.to_json]]
    end
  end
end
