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