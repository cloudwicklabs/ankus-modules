require 'rubygems' if RUBY_VERSION < '1.9'
require 'fileutils'
require 'net/http'
# we need these gems installed on all nodes
require 'json'
require 'jsonpath'

Puppet::Type.type(:curl).provide(:ruby) do
  # limit the use of this resource to redhat and debian based systems
  confine :osfamily => [:redhat, :debian]

  def domain
    @domain
  end

  def get
    @uri
  end

  def post
    @uri
  end

  def delete
    @uri
  end

  def put
    @uri
  end

  def domain=(domain)
    @domain = domain
  end

  def get=(uri)
    @uri = uri
    process_params(@domain, 'get', @resource, uri)
  end

  def post=(uri)
    @uri = uri
    process_params(@domain, 'post', @resource, uri)
  end

  def delete=(uri)
    @uri = uri
    process_params(@domain, 'delete', @resource, uri)
  end

  def put=(uri)
    @uri = uri
    process_params(@domain, 'put', @resource, uri)
  end

  private
  # Helper to process/parse web parameters
  def process_params(domain, request_method, params, uri)
    begin
      error = nil

      # Actually run the request and verify the result
      Puppet.debug "Initializing curl class with domain='#{domain}', " \
        " username='#{params[:username]}', password='#{params[:password]}'"
      curl = Curl.new(domain, params[:username], params[:password])

      # verify that we should actually run the request
      if skip_request?(curl, params, uri)
        Puppet.debug "Skipping request"
        return
      else
        Puppet.debug "Moving on to make requst"
      end

      result = curl.request(
        request_method.to_sym,
        uri,
        params[:request_type] || 'json',
        eval(params[:parameters])
      )

      result_body = result.body

      verify_result(
        curl,
        result,
        :returns          => params[:returns],
        :does_not_return  => params[:does_not_return],
        :contains         => params[:contains],
        :does_not_contain => params[:does_not_contain],
        :contains_key     => params[:contains_key],
        :contains_value   => params[:contains_value]
      )
    rescue Exception => e
      error = e
      Puppet.debug e.backtrace.join('\n')
      raise Puppet::Error, "An exception was raised when invoking web" \
                           " request: #{e} (#{e.class})"
    ensure
      unless result.nil?
        log_response(
          :result => result_body,
          :method => request_method,
          :uri => uri,
          :puppet_params => params,
          :error => error
        )
      end
    end
  end

  # Helper to determine if we should skip the request
  # @param [Curl] curl object to process on
  # @param [Hash] parameters passed in from puppet (@resource)
  # @param [String] uri to make the call on top of domain
  def skip_request?(curl, params, uri)
    [:only_if, :unless].each do |c|
      # if/unless specific parameters
      condition = params[c]
      unless condition.nil?
        method = (condition.keys & ['get', 'post', 'delete', 'put']).first

        result = curl.request(
          method.to_sym,
          condition[method],  # make the request passed by the method in the condition
          params[:request_type] || 'json',
          condition[:parameters] && eval(condition[:parameters]) || {} # parse the params if any
        )
        result_succeeded = true

        begin
          verify_result(curl, result, condition)
        rescue Puppet::Error => ex
          Puppet.debug ex.message
          result_succeeded = false
        end
        if (c == :only_if && !result_succeeded) ||
          (c == :unless && result_succeeded)
          return true
        end
      end
    end
    return false
  end

  # Helper to verify the response from web request
  def verify_result(curl, result, verify = {})
    if verify[:returns].nil? && !verify['returns'].nil?
      verify[:returns] = verify['returns']
    end
    if verify[:does_not_return].nil?  && !verify['does_not_return'].nil?
      verify[:does_not_return]  = verify['does_not_return']
    end
    if verify[:contains].nil? && !verify['contains'].nil?
      verify[:contains] = verify['contains']
    end
    if verify[:does_not_contain].nil? && !verify['does_not_contain'].nil?
      verify[:does_not_contain] = verify['does_not_contain']
    end
    if verify[:contains_key].nil? && !verify['contains_key'].nil?
      verify[:contains_key] = verify['contains_key']
      verify[:contains_value] = verify['contains_value']
    end
    Puppet.debug "Parsed verify hash: " + verify.inspect

    #
    # validates the status codes user is expecting
    #
    if !verify[:returns].nil? && !curl.valid_status_code?(result, verify[:returns])
      raise Puppet::Error, "Invalid HTTP Return Code: #{result.code},"\
        "was expecting one of #{verify[:returns]}"
    end

    if !verify[:does_not_return].nil? && curl.valid_status_code?(result, verify[:does_not_return])
      raise Puppet::Error, "Invalid HTTP Return Code: #{result.code},"\
         "was not expecting one of #{verify[:does_not_return]}"
    end

    if !verify[:contains].nil? && !curl.valid_json_path?(result, verify[:contains])
      raise Puppet::Error, "Expecting #{verify[:contains]} in the result"
    end

    if !verify[:does_not_contain].nil? && curl.valid_json_path?(result, verify[:does_not_contain])
      raise Puppet::Error, "Not expecting #{verify[:does_not_contain]} in the result"
    end

    if !verify[:contains_key].nil? && !curl.valid_key_value?(result, verify[:contains_key], verify[:contains_value])
      raise Puppet::Error, "Key '#{verify[:contains_key]}' does not match value '#{verify[:contains_value]}' in the result"
    end
  end

  # Logs the reponse to a specific file, creates the directory if does not exists
  # @param [Hash] parameters of the curl resouce (@resource)
  def log_response(params)
    method  = params[:method]
    uri     = params[:uri]
    result  = params[:result]
    error   = params[:error]
    puppet_params = params[:puppet_params]

    if puppet_params[:log_to]
      logfile = puppet_params[:log_to].strip
      exists = File.exists?(logfile)
      isfile = File.file?(logfile) || (!exists && (logfile[-1].chr != '/'))
      if !isfile
        FileUtils.mkdir_p(logfile) if !exists
        logfile += puppet_params[:name]
      end

      f = File.open(logfile, 'a')
      f.write("=====BEGIN=====\n")
      f.write(Time.now.strftime("%Y-%m-%d %H:%M:%S"))
      f.write(" #{method} request to #{uri} with params: #{params}\n")
      f.write(result.to_s)
      f.write("\n=====END=====\n\n")
      f.close
    end
  end
end

# Back port from 1.9 to make working with 1.8 similar to 1.9
if RUBY_VERSION < '1.9'
  module Net
    module HTTPHeader
      def set_form_data(params, sep = '&')
        query = URI.encode_www_form(params)
        query.gsub!(/&/, sep) if sep != '&'
        self.body = query
        self.content_type = 'application/x-www-form-urlencoded'
      end
      alias form_data= set_form_data
    end
  end

  module URI
    def self.encode_www_form(enum)
      enum.map do |k,v|
        if v.nil?
          k
        elsif v.respond_to?(:to_ary)
          v.to_ary.map do |w|
            str = k.to_s.dup
            unless w.nil?
              str << '='
              str << w
            end
          end.join('&')
        else
          str = k.to_s.dup
          str << '='
          str << v
        end
      end.join('&')
    end
  end
end

# Borrowed from HTTParty
class HashConversions
  # @return <String> This hash as a query string
  #
  # @example
  #   { :name => "Bob",
  #     :address => {
  #       :street => '111 Ruby Ave.',
  #       :city => 'Ruby Central',
  #       :phones => ['111-111-1111', '222-222-2222']
  #     }
  #   }.to_params
  #     #=> "name=Bob&address[city]=Ruby Central&address[phones][]=111-111-1111&address[phones][]=222-222-2222&address[street]=111 Ruby Ave."
  def self.to_params(hash)
    params = hash.map { |k,v| normalize_param(k,v) }.join
    params.chop! # trailing &
    params
  end

  # @param key<Object> The key for the param.
  # @param value<Object> The value for the param.
  #
  # @return <String> This key value pair as a param
  #
  # @example normalize_param(:name, "Bob Jones") #=> "name=Bob%20Jones&"
  def self.normalize_param(key, value)
    param = ''
    stack = []

    if value.is_a?(Array)
      param << value.map { |element| normalize_param("#{key}[]", element) }.join
    elsif value.is_a?(Hash)
      stack << [key,value]
    else
      param << "#{key}=#{URI.encode(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}&"
    end

    stack.each do |parent, hash|
      hash.each do |k, v|
        if v.is_a?(Hash)
          stack << ["#{parent}[#{k}]", v]
        else
          param << normalize_param("#{parent}[#{k}]", v)
        end
      end
    end

    param
  end
end

# Monkey patch Hash to find nested key/value pairs
class Hash
  # finds and returns a key in a nested hash
  def deep_return(key, object=self, found=nil)
    if object.respond_to?(:key?) && object.key?(key)
      return object[key]
    elsif object.is_a? Enumerable
      object.find { |*a| found = deep_return(key, a.last) }
      return found
    end
  end

  # retunrs if a key is present in the nested hash
  def deep_find(key)
    if key?(key)
      true
    else
      self.values.inject(nil) do |memo, v|
        memo ||= v.deep_find(key) if v.respond_to?(:deep_find)
      end
    end
  end
end

# Class to handle web requests using 'net/http' and 'uri', specifically modelled
# to handle json based web requests
#
# Examples:
#
# # to emulate this get request: https://www.google.com/search?q=ashrithmekala
# Curl.new('http://www.google.com').web_request(:get, '/search', {:q => 'ashrithmekala'})
#
# root = Curl.new("http://#{@cm_server}:#{@cm_port}", 'admin', 'admin')
# #=== Get ===
# api = root.get('/api/version', request_type = 'json')
# p api.body
#
# clusters = root.get("/api/#{api.body}/clusters", request_type = 'json')
# p clusters.body
#
# #=== Post ===
# cluster = root.post("/api/#{api.body}/clusters",
#   request_type = 'json',
#   { :items => [ { :name => 'test', :version => 'CDH4' } ] }
# )
# p cluster.body
class Curl
  VERB_MAP = {
    :get    => Net::HTTP::Get,
    :post   => Net::HTTP::Post,
    :put    => Net::HTTP::Put,
    :delete => Net::HTTP::Delete
  }

  def initialize(endpoint, username = nil, password = nil)
    uri = URI.parse(endpoint)
    @http = Net::HTTP.new(uri.host, uri.port)
    @username = username
    @password = password
  end

  def request(method, path, request_type = nil, params = {})
    case method.to_sym
    when :get
      get(path, request_type, params)
    when :post
      post(path, request_type, params)
    when :put
      put(path, request_type, params)
    when :delete
      delete(path, request_type, params)
    end
  end

  def get(path, request_type = nil, params = {})
    make_request :get, path, request_type, params
  end

  def post(path, request_type = nil, params = {})
    make_request :post, path, request_type, params
  end

  def put(path, request_type = nil, params = {})
    make_request :put, path, request_type, params
  end

  def delete(path, request_type = nil, params = {})
    make_request :delete, path, request_type, params
  end

  def valid_status_code?(response, valid_values = [])
    valid_values.include?(response.code)
  end

  # Verifies if a value is returned with the input jpath
  # @param [String] valid json string
  # @param [String] valid jpath like following
  # Usage:
  #  1. To find if the price of any element is less than 20
  #    valid_json_path? '{"books":[{"title":"A Tale of Two Somethings","price":18.88}]}', '$..price[?(@ < 20)]'
  #  2. To find if a name key has value 'dfs_replication'
  #    valid_json_path? '{"items":[{"name":"dfs_replication","value":"1"}}', "$..name[?(@ == 'dfs_replication')]"
  def valid_json_path?(response, jpath)
    Puppet.debug "JPath: " + jpath.inspect
    Puppet.debug "Valid JsonPath: " + JsonPath.on(response.body, jpath).inspect
    !JsonPath.on(response.body, jpath).empty?
  end

  def valid_key_value?(response, key, value)
    Puppet.debug "Validating if key(#{key}) has value(#{value})"
    parsed_response = JSON.parse(response.body)
    valid = false
    if parsed_response.deep_find(key)
      # key is present, now validate if value is same as user
      valid = true if parsed_response.deep_return(key) == value
    end
    return valid
  end

  # Parses the json string and wraps it using openstruct object so that it's
  # parsable
  def json_response(response)
    body = JSON.parse(response.body)
    OpenStruct.new(:code => response.code, :body => body)
  rescue JSON::ParserError
    response
  end

  private
  # Makes a request to the provided uri with specified path
  def make_request(method, path, request_type = 'json', params = {})
    Puppet.debug "Initializing request with method:'#{method}', path: '#{path}', req_type: '#{request_type}', params: #{params.inspect}"
    header = if request_type == 'json'
               { 'Content-Type' => 'application/json' }
             else
               nil
             end

    Puppet.debug "Invoking #{method.to_sym}"
    case method
    when :get
      full_path = encode_path_params(path, params)
      request = VERB_MAP[method.to_sym].new(full_path, initheader = header)
    else
      request = VERB_MAP[method.to_sym].new(path, initheader = header)
      if request_type == 'json'
        Puppet.debug "params hash: #{params.to_json}"
        request.body = params.to_json
      else # request format is not json
        params.is_a?(Hash) ? HashConversions.to_params(params) : params
        request.set_form_data(params)
      end
    end

    unless @username.nil? || @password.nil?
      request.basic_auth @username, @password
    end

    # make the actual request
    @http.request(request)
  end

  def encode_path_params(path, params)
    encoded = URI.encode_www_form(params)
    [path, encoded].join("?")
  end
end
