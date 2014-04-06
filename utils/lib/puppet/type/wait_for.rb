# A type to wait for a command to return an expected output
# Borrowed from https://github.com/basti1302/puppet-wait-for
Puppet::Type.newtype(:wait_for) do
  @doc = "Waits for something to happen."

  # Borrowed from `exec` resource to implement `refreshonly`
  # Create a new check mechanism.  It's basically just a parameter that
  # provides one extra 'check' method.
  def self.newcheck(name, options = {}, &block)
    @checks ||= {}

    check = newparam(name, options, &block)
    @checks[name] = check
  end

  def self.checks
    @checks.keys
  end

   newcheck(:refreshonly) do
    desc <<-'EOT'
      The command should only be run as a
      refresh mechanism for when a dependent object is changed.  It only
      makes sense to use this option when this command depends on some
      other object; it is useful for triggering an action:

          # Pull down the main aliases file
          file { "/etc/aliases":
            source => "puppet://server/module/aliases"
          }

          # Rebuild the database, but only when the file changes
          exec { newaliases:
            path        => ["/usr/bin", "/usr/sbin"],
            subscribe   => File["/etc/aliases"],
            refreshonly => true
          }

      Note that only `subscribe` and `notify` can trigger actions, not `require`,
      so it only makes sense to use `refreshonly` with `subscribe` or `notify`.
    EOT

    newvalues(:true, :false)

    # We always fail this test, because we're only supposed to run
    # on refresh.
    def check(value)
      # We have to invert the values.
      if value == :true
        false
      else
        true
      end
    end
  end

  # Verify that we pass all of the checks.  The argument determines whether
  # we skip the :refreshonly check, which is necessary because we now check
  # within refresh
  def check_all_attributes(refreshing = false)
    self.class.checks.each { |check|
      next if refreshing and check == :refreshonly
      if @parameters.include?(check)
        val = @parameters[check].value
        val = [val] unless val.is_a? Array
        val.each do |value|
          return false unless @parameters[check].check(value)
        end
      end
    }
    true
  end

  newparam :name

  newparam(:query) do
    desc "The command to execute, the output of this command will be matched against regex."
  end

  newproperty(:exit_code) do
    desc "The exit code to expect."
    munge do |value|
      Integer(value)
    end
  end

  newproperty(:regex) do
    desc "The regex to match the commmand's output against."
    munge do |value|
      Regexp.new(value)
    end
  end

  newparam(:giveup_regex) do
    desc "Give up if the regex matches command output, with out waiting"
    munge do |value|
      Regexp.new(value)
    end
  end

  newparam(:polling_frequency) do
    desc "How long to sleep in between retries."
    defaultto 0.5
    munge do |value|
      Float(value)
    end
  end

  newparam(:max_retries) do
    desc "How often to retry the query before timing out."
    defaultto 119
    munge do |value|
      Integer(value)
    end
  end

  validate do
    unless self[:regex] or self[:exit_code]
      fail "Exactly one of regex or exit_code is required."
    end
    if self[:regex] and self[:exit_code]
      fail "Use either regex or exit_code, not both."
    end
  end
end
