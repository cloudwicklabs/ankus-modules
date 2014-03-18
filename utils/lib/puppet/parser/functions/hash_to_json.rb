module Puppet::Parser::Functions
  newfunction(:hash_to_json, :type => :rvalue, :doc => <<-EOS
    Puppet function to convert a ruby hash to json string, this function
    depends on 'json' ruby gem
  EOS
  ) do |arguments|
    if arguments.empty?
      return '{}'
    end

    require 'json'
    begin
      return arguments.to_json
    rescue Exception => ex
      raise TypeError, "hash_to_json(): error converting hash to json string"
    end
  end
end
