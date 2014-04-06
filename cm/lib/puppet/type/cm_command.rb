# A type to execute scm command and wait until the command gets executed
Puppet::Type.newtype(:cm_command) do
  @doc = "Executes cloudera manager api command and waits till the command gets executed."

  newparam :name

  newproperty(:url) do
    desc "The url to execute."
  end

  newparam(:post) do
    desc "Post request path."
  end

  newparam(:username) do
    desc "Username for basic authentication"
  end

  newparam(:password) do
    desc "Password for basic authentication"
  end

  newparam(:params) do
    desc "Parameters for the requset body"
    munge do |value|
      Hash.new(value)
    end
  end

  newparam(:wait) do
    desc "Waits until the command gets executed"
  end

  validate do
    unless self[:url] && self[:post]
      fail "url and post path are required."
    end
  end
end
