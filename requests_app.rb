require 'rubygems'
require 'rack'

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
    puts "post: path is #{ENV['PATH']}"
  end

  def call(env)
    # show all the HTTP parameters
    # env.each do |k,v|
    #   puts "#{k} = #{v}"
    # end

    # reply =  [500, {"Content-Type" => "text/html"}, "<p>Error:</p>"][]

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
