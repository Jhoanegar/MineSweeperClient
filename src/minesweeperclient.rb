#!/usr/bin/env ruby
require_relative 'lib/client'
require_relative 'lib/interpreter'
require_relative 'lib/agent'
require_relative 'lib/mysocket'
require_relative 'lib/core_ext'
require_relative 'lib/mylogger'

#TODO: Deal with Options


client = Client.new(MyLogger.new_logger('log.txt'))
client.start

