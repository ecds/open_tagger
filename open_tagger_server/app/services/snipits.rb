Letter.all.each do |l|
  next if l.content.nil?
  doc = Nokogiri::XML(l.content)
  EntityType.all.each do |type|
    next if doc.xpath("//#{type.label}").empty?
    doc.xpath("//#{type.label}").each do |tag|
      if tag.attributes.has_key? 'star'
        stars.push(l)
      end
    end
  end
end

lt = []
gt = []
Letter.all.each do |l|
next if l.content.nil?
doc = Nokogiri::XML(l.content)
if doc.content.empty?
  doc = Nokogiri::HTML(l.content)
end
  tags = 0
  EntityType.all.each do |type|
    next if doc.xpath("//#{type.label}").empty?
    doc.xpath("//#{type.label}").each do |tag|
      tags += 1
    end
  end
  if l.entities_mentioned.length > tags
    gt.push(l)
  elsif l.entities_mentioned.length < tags
    lt.push(l)
  end
end

Letter.all.each do |l|
  next if l.content.nil?
  doc = Nokogiri::XML(l.content)
  if doc.content.empty?
    doc = Nokogiri::HTML(l.content)
  end
  next if doc.content.empty?
  EntityType.all.each do |type|
    next if doc.xpath("//#{type.label}").empty?
    doc.xpath("//#{type.label}").each do |tag|
      if tag.has_attribute? 'profile_id'
        entity = Entity.find_by(id: tag['profile_id'], entity_type: type)
        next if entity.nil?
        Mention.find_or_create_by(letter: l, entity: entity)
      end
    end
  end
end

letters = []

lpks =[ '5',
'7',
'35',
'40',
'42',
'54',
'56',
'61',
'62']

letters = {}

lpks.each do |pk|
  count = []
  Letter.all.each do |l|
    next if l.content.nil?
    doc = Nokogiri::XML(l.content)
    if doc.content.empty?
      doc = Nokogiri::HTML(l.content)
    end
    next if doc.content.empty?
    next if doc.xpath("//directing").empty?
    letters.push(l)
    # doc.xpath('//directing').each do |tag|
    #   if tag['profile_id'] == pk
    #     count.push(l)
    #   end
    # end
  end
  letters[pk] = count.count
end; nil


rev = []
Letter.all.each do |l|
  next if l.content.nil?
  doc = Nokogiri::XML(l.content)
  next if doc.xpath('//*[@revision]').empty?
  rev.push(l)
end

rev.each do |r|
  if r.xpath('//*[@revision]').length > 1
    revs.push(r)
  end
end; nil

Letter.all.each do |l|
  next if l.content.nil?
  doc = Nokogiri::XML(l.content)
  if doc.content.empty?
    doc = Nokogiri::HTML(l.content)
  end
  next if doc.xpath("//work-of-art").empty?
  doc.xpath("//work-of-art").each do |tag|
    tag.name = 'work_of_art'
    p tag.to_s
    l.content = doc.to_s
    l.save
  end
end; nil

stars = []
Letter.all.each do |l|
  next if l.content.nil?
  doc = Nokogiri::XML(l.content)
  EntityType.all.each do |type|
    next if doc.xpath("//#{type.label}").empty?
    doc.xpath("//#{type.label}").each do |tag|
      if tag.attributes.has_key? 'star'
        l.tag_list.add('star')
        l.save
      end
    end
  end
end

flags = []
Letter.all.each do |l|
  next if l.content.nil?
  doc = Nokogiri::XML(l.content)
  EntityType.all.each do |type|
    next if doc.xpath("//#{type.label}").empty?
    doc.xpath("//#{type.label}").each do |tag|
      if tag.attributes.has_key? 'open_issue'
        if tag.attributes.has_key? 'call'
          tag['class'] = "#{tag['class']} flagged"
        else
          tag['class'] = 'flagged'
        end
        l.content = doc.to_xml
        l.save
      end
    end
  end
end

Letter.all.each do |l|
  next if l.content.nil?
  doc = Nokogiri::XML(l.content)
  EntityType.all.each do |type|
    next if doc.xpath("//#{type.label}").empty?
    doc.xpath("//#{type.label}").each do |tag|
      if tag.attributes.has_key? 'revision'
        l.tag_list.add('star')
        l.save
      end
    end
  end
end

Letter.all.each do |l|
  next if l.content.nil?
  doc = Nokogiri::XML(l.content)
  if doc.content.empty?
    doc = Nokogiri::HTML(l.content)
  end
  next if doc.content.empty?
  next if doc.xpath('//directing').empty?
  l.tag_list.add('directing')
  l.save
end


dups = Mention.select(:entity_id, :letter_id).group(:entity_id, :letter_id).having('count(*) > 1').size

# remove tag around text
require 'nokogiri'

doc = Nokogiri::XML(letter.content)

node = doc.at('some tag')
node.replace(node.text)
# delete mention

letter.save


no_id = []
Letter.all.each do |l|
  next if l.content.nil?
  doc = Nokogiri::XML(l.content)
  if doc.content.empty?
    doc = Nokogiri::HTML(l.content)
  end
  next if doc.content.empty?
  EntityType.all.each do |type|
    next if doc.xpath("//#{type.label}").empty?
    doc.xpath("//#{type.label}").each do |tag|
      if !tag.has_attribute? 'profile_id'
        no_id.push(l)
      end
    end
  end
end

Letter.all.each do |l|
  next if l.content.nil?
  doc = Nokogiri::XML(l.content)
  if doc.content.empty?
    doc = Nokogiri::HTML(l.content)
  end
  next if doc.content.empty?
  EntityType.all.each do |type|
    next if doc.xpath("//#{type.label}").empty?
    doc.xpath("//#{type.label}").each do |tag|
      if tag.has_attribute? 'profile_id'
        next if Entity.find_by(id: tag['profile_id']).nil?
        Mention.find_or_create_by(letter: l, entity: Entity.find(tag['profile_id']))
      end
    end
  end
end

props = []
Entity.all.each do |e|
  if e.properties.present?
    e.properties.each do |k, v|
      TypeProperty.find_or_create_by(property: Property.find_by(label: k), entity_type: e.entity_type)
    end
  end
end

props.uniq.each { |p| Property.create(label: p }

  a = 'array'
  h = 'hash'
  s = 'string'

  strings = [
    'publication',
    'last_name',
    'first_name',
    'life_dates',
    'description',
    'profile',
    'city',
    'date',
    'reason',
    'theatre',
    'director',
    'proposal',
    'response',
    'author',
    'comments',
    'translator',
    'translated_into',
    'translated_title',
    'event_type',
    'place_date',
    'performed_by',
    'alternative_spellings',
    'owner',
    'artist',
    'location',
    'composer',
    'notes',
    'place'
  ]

  arrays = [
    'authors',
    'links',
    'alternate_names_spellings',
    'alternate_spellings',
    'alternative_titles'
  ]

  hashes = [
    'media'
  ]

  Property.all.each do |p|
    if strings.include? p.label
      p.prop_type = 's'
    elsif arrays.include? p.label
      p.prop_type = 'a'
    elsif hashes.include? p.label
      p.prop_type = 'h'
    end
    p.save
  end

Entity.all.each do |e|
  if e.properties.nil?
    e.properties = {}
  end
  e.entity_type.properties.each do |p|
    if !e.properties.has_key? p.label
      if p.prop_type == 'a'
        e.properties[p.label] = []
      elsif p.prop_type == 'h'
        e.properties[p.label] = {}
      elsif p.prop_type == 's'
        e.properties[p.label] = ''
      end
    end
    e.save
  end
end


missing = []
letters = Dir["letters/*.xml"]
letters.each do |file_name|
  doc = File.open(file_name) { |f| Nokogiri::XML(f) }
  next if doc.xpath('//production').empty?
  doc.xpath('//production').each do |tag|
    if tag['profile_id'] == '262'
      missing.push(file_name)
    end
  end
end; nil
missing.count


EntityType.all.each do |type|
  next if doc.xpath("//#{type.label}").empty?
  doc.xpath("//#{type.label}").each do |tag|
    if tag['class'] && tag['class'].include?('flagged')
      p "&&&&&&&&&&&&&&&&&&&&&&&&"
      p tag['class']
      p "&&&&&&&&&&&&&&&&&&&&&&&&"
    end
  end
end
``

start = Date.new(1957)
end_date = Date.new(1966)
l = Letter.between(start, end_date).where(flagged: true).order('date ASC')
require 'csv'
CSV.open("flaggedReportSorted.csv", "w") do |csv|
l.each do |c|
csv << [c.date.strftime("%d-%m-%Y"), c.recipients.collect(&:label).join(' ')]
end
end

start = Date.new(1969)
end_date = Date.new(1970)
l = Letter.between(start, end_date).where(flagged: true).order('date ASC')
require 'csv'
CSV.open("flaggedReportSorted.csv", "ab") do |csv|
l.each do |c|
csv << [c.date.strftime("%d-%m-%Y"), c.recipients.collect(&:label).join(' ')]
end
end

start = Date.new(1957)
end_date = Date.new(1966)
l = Letter.between(start, end_date).where(flagged: true).order('date ASC')
require 'csv'
CSV.open("flagged1957-1966-9-8-2020.csv", "ab") do |csv|
l.each do |c|
csv << [c.date.strftime("%d-%m-%Y"), c.recipients.collect(&:label).join(' '), '', '']
end
end

flags = []
start = Date.new(1958)
end_date = Date.new(1959)
letters = Letter.between(start, end_date).order('date ASC')
CSV.open('flagged1958-1-7-2020-alt.csv', 'ab') do |csv|
  letters.each do |l|
    next if l.content.nil?
    if l.content.downcase.include? 'flag'
      csv << [l.date.strftime("%d-%m-%Y"), l.recipients.collect(&:label).join(' ')]
    end
  end
end


nested_tags = []
correctd_tags = []
removed_tags = []

Letter.all.each do |l|
  next if l.content.nil?
  doc = Nokogiri::XML(l.content)
  if doc.content.empty?
    doc = Nokogiri::HTML(l.content)
  end
  next if doc.content.empty?
  EntityType.all.each do |type|
    next if doc.xpath("//#{type.label}").empty?
    doc.xpath("//#{type.label}").each do |tag|
      if tag.children.empty? || tag['calss'].present? && tag['class'].include?('flag')
        p '&&&&&&&&&&'
        p tag.to_xml
        p '&&&&&&&&&&'
      elsif tag['class'] && tag['class'].include?('flag') && tag.children.first.name == tag.name
        p l.id
        p tag.to_xml
        node = tag.children.first
        if node['class'].present?
          node['class'] = node['class'].split(' ').push('flagged').join(' ')
        else
          node['class'] = 'flagged'
        end
        tag.replace(node)
        p node.to_xml
        p '########'
      end
    end
  end
end

# l.versions.collect(&:object).each do |v|
#   if v && l.id == v['id']
#     p '*************'
#     p v.id
#     p v['content']
#   end
# end; nil

l.versions.each do |v|
  if v.object && l.id == v.object['id']
    10.times { p '*************' }
    p v.id
    p v.object['content']
  end
end; nil

l.versions.each do |v|
  if v.object && l.id == v.object['id']
    if v.id == 75760
      l.content = v.object['content']
    end
  end
end; nil

Entity.where(legacy_pk: 99999999)

sanitizer = Rails::Html::FullSanitizer.new
bs = Entity.where(legacy_pk: 99999999).map {|m| {label: m.label, letters: m.letters._public.map {|l| {id: l.id, date: l.date, recipients: l.recipients.map {|r| r.label}.join(',')}}} unless m.letters.empty?}.reject{|p| p.nil?}.reject {|y| y[:letters].empty?}
CSV.open('non_google_entities.csv', 'ab') do |csv|
  bs.each do |e|
    label = sanitizer.sanitize(e[:label])
    e[:letters].each do |l|
      csv << [l[:id], l[:date].strftime("%d-%m-%Y"), l[:recipients], label]
    end
  end
end

Repository.all.each do |r|
  puts(r.id)
  next if r.public_letters_hash.empty?
  puts(r.public_letters_hash.sort_by {|l| l[:recipients].first[:name]}.map {|l| l})
end; nil


def public_letters_hash
  public_letters = letters._public.map { |letter| {
  id: letter.id,
  date: letter.formatted_date,
  recipients: letter.recipients.map { |r| {
    id: r.id,
    name: r.label
  }}
}}
return public_letters if public_letters.empty?
  public_letters.each do |letter|
    if letter[:recipients].empty?
      letter[:recipients].push({ name: 'unknown' })
    end
  end
public_letters.sort_by {|l| l[:recipients].first[:name]}.map {|l| l}
end



properties = [{
  "entity_type": "person",
  "properties": [{
    "key": "links",
    "value": []
  }, {
    "key": "media",
    "value": {}
  }, {
    "key": "profile",
    "value": ""
  }, {
    "key": "last_name",
    "value": ""
  }, {
    "key": "first_name",
    "value": ""
  }, {
    "key": "life_dates",
    "value": ""
  }]
}, {
  "key": "description",
  "value": ""
}, {
  "key": "alternate_names_spellings",
  "value": []
}, {
  "key": "alternate_names_spelling",
  "value": []
}, {
  "entity_type": "organization",
  "properties": [{
    "key": "description",
    "value": ""
  }, {
    "key": "alternate_spellings",
    "value": []
  }, {
    "key": "links",
    "value": []
  }, {
    "key": "profile",
    "value": ""
  }]
}, {
  "entity_type": "place",
  "properties": [{
      "key": "links",
      "value": []
    },
    {
      "key": "description",
      "value": ""
    },
    {
      "key": "alternate_spellings",
      "value": []
    },
    {
      "key": "coordinates",
      "value": {}
    }
  ]
}, {
  "entity_type": "production",
  "properties": [{
    "key": "cast",
    "value": []
  }, {
    "key": "city",
    "value": ""
  }, {
    "key": "date",
    "value": ""
  }, {
    "key": "notes",
    "value": ""
  }, {
    "key": "theatre",
    "value": ""
  }, {
    "key": "director",
    "value": ""
  }, {
    "key": "proposal",
    "value": ""
  }, {
    "key": "response",
    "value": ""
  }, {
    "key": "links",
    "value": []
  }, {
    "key": "reason",
    "value": ""
  }, {
    "key": "staff",
    "value": ""
  }, {
    "key": "description",
    "value": ""
  }, {
    "key": "personnel",
    "value": []
  }]
}, {
  "entity_type": "writing",
  "properties": [{
    "key": "date",
    "value": ""
  }, {
    "key": "links",
    "value": []
  }, {
    "key": "notes",
    "value": ""
  }, {
    "key": "proposal",
    "value": ""
  }, {
    "key": "beckett_digital_manuscript_project",
    "value": ""
  }, {
    "key": "description",
    "value": ""
  }]
}, {
  "type": "translating",
  "key": "author",
  "value": ""
}, {
  "entity_type": "translating",
  "properties": [{
    "key": "translator",
    "value": ""
  }, {
    "key": "translated_into",
    "value": ""
  }, {
    "key": "translated_title",
    "value": ""
  }, {
    "key": "comments",
    "value": ""
  }, {
    "key": "links",
    "value": []
  }, {
    "key": "description",
    "value": ""
  }]
}, {
  "entity_type": "reading",
  "properties": [{
    "key": "authors",
    "value": []
  }, {
    "key": "links",
    "value": []
  }, {
    "key": "publication",
    "value": ""
  }, {
    "key": "publication_format",
    "value": ""
  }, {
    "key": "comment",
    "value": ""
  }, {
    "key": "description",
    "value": ""
  }]
}, {
  "entity_type": "attendance",
  "properties": [{
    "key": "event_type",
    "value": ""
  }, {
    "key": "place_date",
    "value": ""
  }, {
    "key": "attended_with",
    "value": []
  }, {
    "key": "alternate_spellings",
    "value": []
  }, {
    "key": "links",
    "value": []
  }, {
    "key": "performed_by",
    "value": ""
  }, {
    "key": "alternative_spellings",
    "value": []
  }, {
    "key": "description",
    "value": ""
  }]
}, {
  "entity_type": "music",
  "properties": [{
    "type": "music",
    "key": "links",
    "value": []
  }, {
    "type": "music",
    "key": "composer",
    "value": ""
  }, {
    "type": "music",
    "key": "description",
    "value": ""
  }, {
    "type": "music",
    "key": "performed_by",
    "value": ""
  }, {
    "type": "music",
    "key": "alternative_titles",
    "value": []
  }, {
    "type": "music",
    "key": "notes",
    "value": ""
  }]
}, {
  "entity_type": "publication",
  "properties": [{
    "key": "links",
    "value": []
  }, {
    "key": "notes",
    "value": ""
  }, {
    "key": "place",
    "value": ""
  }, {
    "key": "author",
    "value": ""
  }, {
    "key": "translator",
    "value": ""
  }, {
    "key": "publication_information",
    "value": ""
  }, {
    "key": "description",
    "value": ""
  }]
}, {
  "entity_type": "work_of_art",
  "properties": [{
    "key": "links",
    "value": []
  }, {
    "key": "owner",
    "value": ""
  }, {
    "key": "artist",
    "value": ""
  }, {
    "key": "location",
    "value": ""
  }, {
    "key": "description",
    "value": ""
  }, {
    "key": "alternate_spellings",
    "value": []
  }, {
    "key": "alternative_spellings",
    "value": []
  }, {
    "key": "artist_alternate_spellings",
    "value": []
  }, {
    "key": "owner_location_accession_number_current",
    "value": ""
  }, {
    "key": "owner_location_accession_number_contemporaneous",
    "value": ""
  }]
}, {
  "entity_type": "public_event",
  "properties": [{
    "key": "date",
    "value": ""
  }, {
    "key": "links",
    "value": []
  }, {
    "key": "description",
    "value": ""
  }]
}]

properties.each do |type|
  Entity.by_type(type[:entity_type]).each do |entity|
    type[:properties].each do |prop|
      if entity.properties[prop[:key]].nil?
        entity.properties[prop[:key]] = prop[:value]
        puts(entity.properties[prop[:key]].class)
        # entity.save
      else
        # puts('skip')
      end
    end
  end
end
properties.each do |type|
  puts type
  Entity.by_type(type[:entity_type]).each do |entity|
    type[:properties].each do |prop|
      if entity.properties[prop[:key]].nil?
        entity.properties[prop[:key]] = prop[:value]
        puts(entity.properties[prop[:key]].class)
      # else
      #   puts('skip')
      end
      entity.save
    end
  end
end; nil

Entity.by_type('production').each do |entity|
  properties.each do |prop|
    if entity.properties[prop[:key]].nil?
      entity.properties[prop[:key]] = prop[:value]
      puts(entity.properties[prop[:key]].class)
    else
      puts('skip')
    end
    entity.save
  end
end; nil

profiles.each do |p|
  person = Entity.by_type('person').find_by(legacy_pk: p[:id])
  person.properties['profile'] = p[:content]
  person.save
end; nil

Entity.by_type('person').each do |p|
  p.properties['links'] = p.properties['links'].uniq
  if p.properties['media']['images'] && p.properties['media']['images'].count > 1
    p.properties['media']['images'] = [p.properties['media']['images'].shift]
  end
  p.save
end

Entity.all.each do |e|
  e.e_type = e.entity_type.label
  e.save
end