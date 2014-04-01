module Freeb
  class FreebTopic
    @raw_data = nil

    def initialize(id_or_hash)
      if id_or_hash.is_a?(String)
        response = API.get(id)
      else
        response = id_or_hash
      end
      init_with_response(response)
      return nil if @raw_data.blank?
      self
    end

    def init_with_response(response)
      @raw_data = response
    end

    def description
      @raw_data["description"] ||= API.description(id)
    end

    def raw_data
      @raw_data
    end

    def mid
      get_property("mid")
    end

    def id
      get_property("id")
    end

    def name
      get_property("name")
    end

    def image_url
      if not @raw_data['id'].blank?
        image_id = API.get_image(self['id'])
      elsif not @raw_data['mid'].blank?
        image_id = API.get_image(self['mid'])
      end

      if image_id
        "https://usercontent.googleapis.com/freebase/v1/image#{image_id}?maxwidth=225&maxheight=225&mode=fillcropmid"
      else
        nil
      end
    end

    def get_property(property)
      property = property.to_s
      return nil if property == "instance"
      return nil if @raw_data.blank?
      return description if property == "description"
      return @raw_data[property] unless @raw_data[property].blank?

      unless @raw_data['type'].blank?
        id = "#{@raw_data['type']}/#{property}"
        return @raw_data[id] unless @raw_data[id].blank?
      end
      
      mql = {
        "id" => get_property(:id),
        property => nil
      }

      result = API.mqlread(mql)
      @raw_data[property] = result[property]
      return @raw_data[property]
    end

    def [](key)
      get_property(key)
    end

    private

    def method_missing(method, *args)
      get_property(method)
    end
  end
end
