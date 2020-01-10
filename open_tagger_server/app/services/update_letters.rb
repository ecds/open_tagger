class UpdateLetters
  def initialize
    @tags = [
      'attendance',
      'directing',
      'music',
      'organization',
      'person',
      'production',
      'place',
      'publication',
      'public_events',
      'reading',
      'translating',
      'writing',
      'works_of_art'
    ]
    @letters_dir = 'letters'
    @updated_letters_dir = 'updated_letters'
    @letters = Dir["#{@letters_dir}/*.xml"]
    @updated_letters = Dir["#{@updated_letters_dir}/*.xml"]
    @missing_entities = []
    @missing_letters = []
  end

# @updated_letters.each do |file_name|
#   doc = File.open(file_name) { |f| Nokogiri::XML(f) }
#   EntityType.all.each do |type|
#     doc.xpath("//#{type.label}").each do |tag|
#       if tag['class'] && tag['class'].include?('flagged')
#         p tag['class']
#       end
#     end
#   end
# end; nil

# @updated_letters.each do |file_name|
#   doc = File.open(file_name) { |f| Nokogiri::XML(f) }
#   doc.xpath("//directing").each do |tag|
#     p "#{tag.to_s} : #{file_name}"
#   end
# end; nil

# no_id = []
# @updated_letters.each do |file_name|
#   # letter_id = _get_id(file_name)
#   # letter = _get_letter(letter_id)
#   # next if letter.nil?
# doc = File.open(file_name) { |f| Nokogiri::XML(f) }
# EntityType.all.each do |type|
#   next if doc.xpath("//#{type.label}").empty?
#   doc.xpath("//#{type.label}").each do |tag|
#     next if tag['profile_id'].present?
#     no_id.push(file_name)
#   end
# end

  def flag_missing_ids
    @updated_letters.each do |file_name|
      letter_id = _get_id(file_name)
      letter = _get_letter(letter_id)
      next if letter.nil?
      doc = File.open(file_name) { |f| Nokogiri::XML(f) }
      EntityType.all.each do |type|
        next if doc.xpath("//#{type.label}").empty?
        doc.xpath("//#{type.label}").each do |tag|
          next if tag['profile_id'].present?
          tag['class'] = 'flagged'
          p file_name
        end
      end
      if letter.present?
        letter.content = doc.to_xml
        letter.save
        File.open("#{@updated_letters_dir}/#{file_name.split('/').last}", 'w') { |f| f.write(doc.to_xml) }
      end
    end
  end

  def flag_letters
    @updated_letters.each do |file_name|
      letter_id = _get_id(file_name)
      letter = _get_letter(letter_id)
      doc = File.open(file_name) { |f| Nokogiri::XML(f) }
      EntityType.all.each do |type|
        next if doc.xpath("//#{type.label}").empty?
        doc.xpath("//#{type.label}").each do |tag|
          if tag['class'] && tag['class'].include?('flagged')
            letter.flagged = true
            letter.save
          end
        end
      end
    end
  end

  def update
    @letters.each do |file_name|
      letter_id = _get_id(file_name)
      letter = _get_letter(letter_id)
      p "#{letter_id} : #{letter.nil?}"
      next if letter.nil?
      p "#{letter_id} : #{letter.content.present?}"
      next if letter.content.present?
      p "Updating #{letter_id}"
      doc = File.open(file_name) { |f| Nokogiri::XML(f) }

      # Update code
      # doc.xpath('//letter//metadata//code').first.content = letter_id.to_s

      # Update all the entity tags.
      updated_doc = _update_ids(doc, letter, letter_id, file_name)

      if letter.present?
        letter.content = updated_doc.to_xml
        letter.save
      end

      File.open("#{@updated_letters_dir}/#{file_name.split('/').last}", 'w') { |f| f.write(doc.to_xml) }
    end
    File.open('missingEntities.json', 'w') do |f|
      f.write(@missing_entities.to_json)
    end
    File.open('missingLetters.json', 'w') do |f|
      f.write(@missing_letters.to_json)
    end
  end

  private

    def _get_id(file)
      id = file.split('__').last.split('.').first.split(' ').first.to_i
    end

    def _get_letter(id)
      Letter.find_by(legacy_pk: id)
    end

    def _update_ids(doc, letter, id, file_name)
      EntityType.all.each do |type|
        next if doc.xpath("//#{type.label}").empty?
        doc.xpath("//#{type.label}").each do |tag|
          entity = Entity.find_by(legacy_pk: tag['profile_id'].to_i, entity_type: type)
          if entity.nil? && type != 'directing'
            @missing_entities.append(
              letter_legacy_id: id,
              entity_legacy_id: tag['profile_id'],
              entity_type: type,
              filename: file_name,
              text: tag.content
            )
            next
          else
            next if entity.nil?
            # p entity.id
            # next if tag['proile_id'].nil?
            p "UPDATING #{entity.label} id from #{tag['profile_id']} to #{entity.id}"
            tag['profile_id'] = entity.id.to_s
            literal = Literal.find_or_create_by(text: tag.content, entity: entity)
            if letter.nil?
              @missing_letters.append(doc.xpath('//letter//metadata//code').first.content)
            else
              letter.entities_mentioned << entity
            end
          end
        end
      end
      doc
    end

    def _get_code(doc)
      doc.xpath('//letter//metadata//code').first.content
    end

    def _get_letter(code)
      Letter.find_by(legacy_pk: code)
    end
end
