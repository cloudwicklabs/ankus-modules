require 'rubygems' if RUBY_VERSION < '1.9'
require 'open-uri'
require 'net/http'
require 'json'

Puppet::Type.type(:cm_command).provide(:ruby) do
  desc "Executes a cm command."

  def url
    @url
  end

  def url=(url)
    @url = url
    fetch_parameters
    info "Processing command with params 'base_url': #{url}, 'post_req': #{@post}, 'params': #{@params}"
    process_requset(@url)
  end

  private
  def fetch_parameters
    @post = resource[:post]
    @wait = resource[:wait]
    @username = resource[:username]
    @password = resource[:password]
    @params = resource[:params]
  end

  def process_request(url)
    response = nil
    cmd_ids = []
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(@post)
    req.add_field('Content-Type', 'application/json')
    req.basic_auth(@username, @password)
    req.body = @params.to_json
    response = http.request(req)
    if response.code == '200'
      pjson = JSON.parse(response.body)
      cmd_ids << pjson['items'].first['id']
      if @wait
        wait_for_command(cmd_ids)
      end
    else
      fail "Command execution failed, base_url: #{url} & post_req: #{@post}"
    end
  end

  def wait_for_command(cmd_ids)
    cmd_ids.each do |cmd_id|
      uri = URI.parse("http://localhost:7180")
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Get.new("/api/v6/commands/#{cmd_id}")
      req.basic_auth('admin', 'admin')
      res = http.request(req)
      while JSON.parse(res.body)['active']
        debug "Command with id: #{cmd_id} is still running, re-trying in 5 seconds"
        sleep 5
        res = http.request(req)
      end
      unless JSON.parse(res.body['success'])
        fail "Failed command, reason: #{JSON.parse(res.body['resultMessage'])}"
      else
        debug "Sucessfully executed command: #{JSON.parse(res.body['name'])}"
      end
    end
  end
end
