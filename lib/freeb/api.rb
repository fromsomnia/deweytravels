require 'httparty'
require 'uri'
require 'json'
require 'freeb/freeb_topic'
require 'freeb/freeb_exceptions'

module Freeb
  class API
    @base_url = "https://www.googleapis.com/freebase/v1/"
    
    def self.get(id)
      mql = {
        "id" => id,
        "name" => nil
      }
      topic(mql)
    end

    def self.topic(mql)
      result = mqlread(mql)
      return nil if result.blank?
      if result.is_a?(Array)
        result.collect { |r| FreebTopic.new(r) }
      else
        FreebTopic.new(result)
      end
    end

    def self.get_image(id)
      url = "#{@base_url}topic#{id}"
      params = {
        "limit" => 1,
        "filter" => "/common/topic/image"
      }
      result = get_result(url, params)
      unless result['property'].blank? or result['property']['/common/topic/image'].blank?
        return result['property']['/common/topic/image']['values'][0]['id']
      end
    end

    def self.search(params)
      log "Search Request: #{params}"
      url = "#{@base_url}search"
      result = get_result(url, params)
      log "Search Response: #{result}"
      result["result"].collect { |r| FreebTopic.new(r) }
    end

    def self.mqlread(mql)
      log "MQL Request: #{mql}"
      url = "#{@base_url}mqlread"
      result = get_result(url, :query => mql.to_json)
      log "MQL Response: #{result}"
      return nil if result["result"].blank?
      result["result"]
    end

    def self.description(id)
      url = "#{@base_url}text#{id}"
      result = get_result(url, nil)
      result["result"]
    end

    def self.get_result(url, params={})
      params[:key] = "AIzaSyBkoufuKh0rimMiJLjkKenQy9GDP9FudUE"
      # Config.settings[:api_key] unless Config.settings[:api_key].blank?
      url = "#{url}?#{params.to_query}"
      log "Url: #{url}"
      get_uncached_result(url)
    end

    def self.get_uncached_result(url)
      response = HTTParty.get(url)
      if response.code == 200
        return JSON.parse(response.body)
      end
      raise ResponseException, "Freebase Response #{response.code}: #{JSON.parse(response.body).inspect}"
      nil
    end

    private

    def self.cache_key_for_url(url)
      {:gem => "Freeb", :class => "API", :key => "get_result", :url => url}
    end

    def self.log(message)
      Rails.logger.debug("Freeb: #{message}")
    end
  end
end
