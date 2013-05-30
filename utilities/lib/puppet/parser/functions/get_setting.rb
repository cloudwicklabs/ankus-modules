# Retrieve a value from Puppet.settings (systemwide puppet configuration)
Puppet::ConfigParser::Functions::newfunction(:get_setting, :type => :rvalue) do |args|
  ret = Puppet[args[0].to_sym]  
  ret.nil? ? :undef : ret
end