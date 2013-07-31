require 'pathname'

Puppet::Type.newtype(:mkdir_p) do

  desc <<-EOT
    Custom puppet resource to create a set of directories recursively

    Example:

    mkdir_p { "/tmp/test/1":
      ensure => present
    }

    $dirs = ["/tmp/test/1", "/tmp/test/2"]
    mkdir_p { $dirs:
      ensure => present
    }
    exec { "/bin/echo hi":
      require Mkdir_p[$dirs]
    }

    mkdir_p { "/tmp/test/1":
      ensure => absent
    }

  EOT

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:path, :namevar => true) do
    desc 'dir path to create'
    validate do |value|
      unless Pathname.new(value).absolute?
        fail "Invalid absolute path #{value}"
      end
    end
  end

end