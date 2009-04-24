require 'rest_client'
require 'json'

class Foo < ActiveRecord::Base
  include ActiveRecordFallback

  @@fallback_options = {
    :url => "http://www.citobi.be/BRD01/ws",
    :class_name => 'Foo',
    :action => 'detail'
  }

  private
  def self.find_initial_fallback(options)
    logger.debug("find_initial_fallback(#{options.inspect})")
    url = build_url( @@fallback_options.merge( {:conditions=>options[:conditions]} ) )
    logger.debug("find_initial_fallback requesting resource: #{url} ")
    begin
      result = JSON.parse( RestClient.get( url ) )
    rescue RestClient::ResourceNotFound, JSON::ParserError
      logger.debug("find_initial_fallback total failure, giving up: #{$!.inspect}")
      return nil
    end
    logger.debug("find_initial_fallback result: #{result.inspect}")
    # FIXME insert the real deal here
    # return create( :something => result[:something] )
    return nil 
  end

  # FIXME insert the real deal here
  # this function builds the REST-resource request url, including parameters
  def self.build_url(options)
    url = [ "#{options[:url]}" ]
    url << ( options[:class_name] || self.to_s.downcase )
    url << "#{options[:action]}" if options[:action]
    url = "#{url.join('/')}#{ActiveRecordFallback::uri_params(options[:conditions])}"
  end
  
end
