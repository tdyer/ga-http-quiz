require 'rubygems'
require 'rack'
require 'pry'

class HandleRequest
  def get(env, path)
    mime_type = env['HTTP_ACCEPT'].split(',').first

    file_name = "./#{path[1..-1]}"
    contents = []
    begin
      contents << File.open(file_name, 'r') do |file|
        file.read
      end
    rescue Errno::ENOENT => e
      puts "get: exception is #{e.message}"
      contents << e.message
      return [404, {"Content-Type" => mime_type}, contents]
    end

    return [200, {"Content-Type" => mime_type}, contents]

  end

  def post(env)
    # http://rack.rubyforge.org/doc/classes/Rack/Request.html
    request = Rack::Request.new(env)

    # binding.pry
    
    body_hash = request.POST
    reply_str = "<html><head></head><body><h2>Post Body is</h2><ul>"

    puts "URL Parameters are:\n"

    body_hash.each do |key, value|
      puts "key = #{key}"
      puts "value = #{value}"
      reply_str << "<li>key is #{key}, value is #{value}</li>"
    end
    reply_str << "</ul></body><html>"
    puts "Yep, it's form data" if request.form_data?

    return [200, {"Content-Type" => "text/html"}, [reply_str]]
  end

  def call(env)
    env.each do |k,v|
      puts "#{k} = #{v}"
    end

    if env['REQUEST_METHOD'] == 'GET'
      reply = self.get(env, env['PATH_INFO'])
    elsif env['REQUEST_METHOD'] == 'POST'
      reply = self.post(env)
    else
      # error response
      reply =  [500, {"Content-Type" => "text/html"}, "<p>Error:</p>"][]
    end
    return reply

  end
end
Rack::Handler::Thin.run HandleRequest.new, :Port => 1234
