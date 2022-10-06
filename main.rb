#!/usr/bin/env ruby

require 'process/metrics/command/summary'
require_relative 'app'

ppid = Process.pid

command = Process::Metrics::Command::Summary["--ppid", ppid]

puts "** BEFORE WARMUP **"
command.call

App.warmup

puts nil, "** BEFORE FORK **"
command.call

child_pid = fork do
	puts nil, "** AFTER FORK **"
	command.call
	
	# This line appears to invalidate all constant cache...
	M = Module.new
	
	# ... causing this to invalidate all shared memory pages with the parent:
	App.warmup
	
	puts nil, "** AFTER WARMUP **"
	command.call
end

Process.wait(child_pid)

puts nil, "** AFTER CHILD **"
command.call
