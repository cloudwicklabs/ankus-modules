# Append a string to every element of an array

Puppet::ConfigParser::Functions::newfunction(:append_each, :type => :rvalue) do |args|
  suffix = (args[0].is_a? Array) ? args[0].join("") : args[0]
  inputs = (args[1].is_a? Array) ? args[1] : [ args[1] ]
  inputs.map { |item| item + suffix }
end