#!/usr/bin/ruby

require 'rubygems'
require 'daemons'

module Daemons
  class Application
    def logfile;        '/opt/kibana/kibana.log'; end
    def output_logfile; '/opt/kibana/kibana-out.log'; end
  end
end

pwd = Dir.pwd

Daemons.run_proc('kibana.rb', {
  :dir_mode => :normal,
  :dir      => "/var/run/sinatra/pid",
  :log_output => true}) do
    Dir.chdir(pwd)
    exec "ruby kibana.rb"
end