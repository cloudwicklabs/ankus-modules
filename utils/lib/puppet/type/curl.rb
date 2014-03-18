# Custom puppet type for making a web-request
require 'uri'

Puppet::Type.newtype(:curl) do
  desc 'Custom puppet resource to make web requests'

  newparam :name

  newproperty(:domain) do
    desc "Doamin uri to use, ex: http://server:port"
    validate do |value|
      Puppet::Type::Curl.validate_uri(value)
    end
  end

  newproperty(:get) do
    desc "Issue get request to the specified uri"
    validate do |value|
      Puppet::Type::Curl.validate_url(value)
    end
  end

  newproperty(:post) do
    desc "Issue post request to the specified uri"
    validate do |value|
      Puppet::Type::Curl.validate_url(value)
    end
  end

  newproperty(:delete) do
    desc "Issue delete request to the specified uri"
    validate do |value|
      Puppet::Type::Curl.validate_url(value)
    end
  end

  newproperty(:put) do
    desc "Issue put request to the specified uri"
    validate do |value|
      Puppet::Type::Curl.validate_url(value)
    end
  end

  newparam(:parameters) do
    desc "Hash of parameters to include in the web request"
  end

  newparam(:file_parameters) do
    desc "Hash of file parameters to include in the web request"
  end

  newparam(:follow) do
    desc "Boolean indicating if redirects should be followed"
    newvalues(:true, :false)
  end

  newparam(:returns) do
    desc "Expected http return codes of the request"
    defaultto ["200"]
    validate do |value|
      Puppet::Type::Curl.validate_http_status(value)
    end
    munge do |value|
      Puppet::Type::Curl.munge_array_params(value)
    end
  end

  newparam(:does_not_return) do
    desc "Unexecpected http return codes of the request"
    validate do |value|
      Puppet::Type::Curl.validate_http_status(value)
    end
    munge do |value|
      Puppet::Type::Curl.munge_array_params(value)
    end
  end

  newparam(:contains) do
    desc "JPath to verify as part of the result"
    munge do |value|
      Puppet::Type::Curl.munge_array_params(value)
    end
  end

  newparam(:contains_key) do
    desc "check the json output for a specific key"
  end

  newparam(:contains_value) do
    desc "check the json output for a specific value matching the key"
  end

  newparam(:does_not_contain) do
    desc "JPath to verify as not being part of the result"
    munge do |value|
      Puppet::Type::Curl.munge_array_params(value)
    end
  end

  newparam(:log_to) do
    desc "Log requests/responses to the specified file or directory"
  end

  newparam(:only_if) do
    desc "Invoke request only if the specified request returns true"
  end

  newparam(:unless) do
    desc "Invoke request unless the specified request returns true"
  end

  newparam(:username) do
    desc "HTTP authentication username"
  end

  newparam(:password) do
    desc "HTTP authentication password"
  end

  newparam(:request_type) do
    desc "Request header type"
    defaultto :json
  end

  private
  # Validates uris passed in
  def self.validate_uri(url)
    begin
      uri = URI.parse(url)
      unless [URI::HTTP, URI::HTTPS].include?(uri.class)
        Puppet.debug "uri specified #{url} is of type #{uri.class}, expecting HTTP or HTTPS"
        raise ArgumentError, "Specified uri #{url} is not valid"
      end
    rescue URI::InvalidURIError
      Puppet.debug "uri specified #{url} is of type #{uri.class}, expecting HTTP or HTTPS"
      raise ArgumentError, "Specified uri #{url} is not valid"
    end
  end

  def self.validate_url(url)
    url = URI.parse(url)
    unless [URI::Generic].include?(url.class)
      raise ArgumentError, "Specified url #{url} is not valid"
    end
  rescue URI::InvalidURIError
    raise ArgumentError, "Specified url #{url} is not valid"
  end

  # Validates http statuses passed in
  def self.validate_http_status(status)
    status = [status] unless status.is_a?(Array)
    status.each { |stat|
      stat = stat.to_s
      unless ['100', '101', '102', '122', '200', '201', '202', '203', '204',
              '205', '206', '207', '226', '300', '301', '302', '303', '304',
              '305', '306', '307', '400', '401', '402', '403', '404', '405',
              '406', '407', '408', '409', '410', '411', '412', '413', '414',
              '415', '416', '417', '418', '422', '423', '424', '425', '426',
              '444', '449', '450', '499', '500', '501', '502', '503', '504',
              '505', '506', '507', '508', '509', '510'
              ].include?(stat)
        raise ArgumentError, "Invalid http status code #{stat} specified"
      end
    }
  end

  # Convert singular params into arrays of strings
  def self.munge_array_params(value)
    value = [value] unless value.is_a?(Array)
    value = value.collect { |val| val.to_s }
    value
  end
end
