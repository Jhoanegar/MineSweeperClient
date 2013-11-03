#!/usr/bin/env ruby
require_relative 'lib/client'
require_relative 'lib/interpreter'
require_relative 'lib/agent'
require_relative 'lib/mysocket'
require_relative 'lib/core_ext'
require 'logger'
file = File.open("log.txt","w")
log = Logger.new(file)
log.level = Logger::DEBUG
log.debug "Program Started"
#TODO: Deal with Options

client = Client.new(log)
client.start



