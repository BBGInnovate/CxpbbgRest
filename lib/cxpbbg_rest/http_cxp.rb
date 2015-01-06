module CxpbbgRest #:nodoc:
    #
    # http=Cxpbbg::Rest.http_cxp
    # http.payload = <json string of the content to be pushed to CXP>
    # http.push #=> post the payload to CXP server configured in
    # config/bbg_cxp.yml
    #
    class HttpCxp
     attr_accessor :payload, :topic_id
     
     def initialize content, topic_id=nil
       self.payload = content
       self.topic_id = topic_id
     end
     
     def push
       if Hash === self.payload
         @contents = self.payload.to_json
       elsif String === self.payload
         @contents = self.payload
       else
         msg = "  Error: payload is not set for"
         msg += "  #{conf.endpoint}"
         raise msg
       end
       response = self.do_push
     end  

     protected
     def conf 
       @conf ||= CxpbbgRest.configuration
     end
     def do_push
       opt = make_header
       resp = post(conf.endpoint, opt)
       code = resp.code.to_i
       if (code < 200) && (code > 204)
      
       end
       # resp.message
       resp
     end
   
     def fake_response(code, message)
       resp = OpenStruct.new
       resp.code = code
       resp.message = message
       resp
     end
   
     def fetch(url, data, headers, limit = 3)
       raise ArgumentError, 'HTTP redirect too deep' if limit == 0
       uri = URI.parse(url)
       req = Net::HTTP::Post.new(uri)
       req.basic_auth(conf.username, conf.password)
       # set request header
       headers.each do |k,v|
         req[k] = v
       end
       # set raw_data
       req.body = data
       res = Net::HTTP.start(uri.hostname, uri.port) do |http|
         if uri.scheme == 'https'
           http.use_ssl = true
           http.verify_mode = OpenSSL::SSL::VERIFY_NONE
         end
         http.read_timeout = conf.read_timeout
         http.open_timeout = conf.open_timeout
         response = http.request(req)
         case response
           when (Net::HTTPOK || Net::HTTPSuccess)
             return response
           when Net::HTTPRedirection
             new_url = redirect_url(response)
             Rails.logger.debug "Redirect to " + new_url
             return fetch(new_url, data, headers,limit - 1)
           else
             response.error!
         end
       end
     end

     def make_header
       opt = {'headers' => 
            {'format'=>'json',
             'method' => 'POST',
             'user-agent'=>'Ruby/Rails',
            },
            'body'=>@contents
           }
       opt['headers']['Content-Type'] = 'application/json'
       opt['headers']['Content-Type'] += '; charset=UTF-8'
	     opt
     end
  
     def post(url, opt={})
       data = opt.delete('body' )
       headers = opt['headers']
       begin
         resp = fetch(url, data, headers, 3)
       rescue Net::HTTPServerException => e
         Rails.logger.warn "Authorization Required"
         code = 401
         msg = 'Authorization Required'
         resp = fake_response(code, msg)
       rescue Timeout::Error => e
         Rails.logger.error "post timeout error"
         code = 408
         msg = 'timeout error'
         resp = fake_response(code, msg)
       rescue Net::HTTPFatalError => e
         code = /(\d*) \w+/.match("#{$!}")[1]
         Rails.logger.error "Post TopicId: #{self.topic_id} #{url} Fatal #{code} #{e.message}"
         msg = "#{$!} : #{url}"
         resp = fake_response(code, msg)
       rescue Exception=>e
         code = /(\d*) \w+/.match("#{$!}")[1]
         msg = "#{$!} : #{url}"
         Rails.logger.error "  #{url} TopicId: #{self.topic_id} Post Fatal #{code} #{e.message}"
         resp = fake_response(code, msg)
       end
       resp
     end
   end
end
