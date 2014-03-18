# A type to wait for a command to return an expected output
# Borrowed from https://github.com/basti1302/puppet-wait-for
Puppet::Type.newtype(:wait_for) do
  @doc = "Waits for something to happen."

  newparam(:query, :namevar => true) do
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
