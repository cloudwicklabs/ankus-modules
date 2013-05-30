#!/usr/bin/env ruby

def main
  num_nodes = 6
  num_nodes.times do |n|
    puts 2**127 / num_nodes * n
  end
end

main if __FILE__ == $0