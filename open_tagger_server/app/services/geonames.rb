require 'nokogiri'
require 'open-uri'

class Geonames
  def  add_lat_lng
    Entity.by_type('place').each do |p|
      next if p.properties.nil?
      if p.properties.has_key?('links')
        next if p.properties['links'].nil?
        if p.properties['links'].is_a?(String)
          p.properties['links'] = [p.properties['links']]
        end
        next if p.properties['links'].first.nil?
        geoid = p.properties['links'].first.split('/')[3]
        doc = Nokogiri::XML(open("http://api.geonames.org/get?geonameId=#{geoid}&username=jayvarner"))
        lat = doc.xpath('//lat').first
        lng = doc.xpath('//lng').first
        next if lng.nil? || lng.nil?
        p.properties['coordinates'] = {
          lat: lat.inner_text,
          lng: lng.inner_text
        }
        p.save
      end
    end
  end
end
