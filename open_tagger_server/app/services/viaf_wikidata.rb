require 'httparty'

class ViafWikidata
  def initialize
    @people = people_on_viaf
  end

  def add_wikidata_link
    @people.each do |person|
      viaf_id = get_viaf_id(person)
      viaf_api_url = viaf_endpoint(viaf_id)
      viaf_data = get_viaf_data(viaf_api_url)
      next if viaf_data.nil?
      wikidata_id = get_wd_id_from_viaf(viaf_data)
      next if wikidata_id.nil?
      p "************ #{wikidata_id} ***************"
      person.properties['links'].append("https://www.wikidata.org/wiki/#{wikidata_id}")
      person.properties['media'] = add_image(wikidata_id)
      person.save
    end
  end

  def get_viaf_id(person)
    person.properties['links'].select { |l| l.include?('viaf') }.first.split('/')[4]
  end

  def get_wd_id_from_viaf(viaf_data)
    sources = viaf_data['sources']
    if sources.nil? || sources['source'].nil?
      return nil
    end
    if sources['source'].select { |source| source['#text'].present? }.empty?
      return nil
    end
    if sources['source'].is_a?(Array)
      wd = sources['source'].select { |source| source['#text'].start_with?('WKP') }
      if wd.first.nil?
        return nil
      end
      return wd.first['@nsid']
    elsif sources['sources'].is_a?(Hash)
      return sources['source'][['@nsid']]
    end
    nil
  end

  def viaf_endpoint(viaf_id)
    "http://viaf.org/viaf/#{viaf_id.strip.split(' ').first}/viaf.json"
  end

  def get_viaf_data(url)
    p "^^^^^^^^^^^ #{url} ^^^^^^^^^^^^^"
    response = HTTParty.get(url)
    if response.code != 200
      return nil
    end
    JSON.parse(response.body)
  end

  private

    def people_on_viaf
      people_with_links = Entity.by_type('person').where('properties ?| array[:keys]', keys: ['links']).select { |p| p.properties['links'].first.present? }
      people_with_links = people_with_links.select { |p| p.properties['links'].select { |q| q.include?('viaf') }.first }
      people_with_links.select { |p| p.properties['links'].select { |q| !q.include?('wiki') }.last }
    end

    def add_image(wikidata_id)
      wd = Wikidata::Item.find wikidata_id
      return if wd.image.nil?
      image = { link: wd.image.url, attribution: 'Wikimedia Commons' }
      { images: [image] }
    end
end


# people_with_links.each do |p|
#   wid = p.properties['links'].last.split('/').last
#   wd = Wikidata::Item.find wid
#   next if wd.nil?
#   next if wd.image.nil?
#   image = { link: wd.image.url, attribution: 'Wikimedia Commons'}
#   p.properties['media'] = { images: [image] }
#   p.save
# end
