require 'fileutils'

Puppet::Type.type(:mkdir_p).provide(:ruby) do

  # In order to support 'ensure' property, provider should implemnt
  # 'exists', 'create' and 'destroy'

  def exists?
    # should return a boolean specifying whether a resource exists on
    # the system or not
    File.exists? resource[:name]
  end

  def create
    FileUtils.mkdir_p resource[:name]
  end


  def destroy
    FileUtils.rm_rf resource[:name]
  end

end