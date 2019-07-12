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
      # 'recipient',
      'translating',
      'writing',
      'works_of_art'
    ]
    @letters_dir = 'letters'
    @letters = Dir["#{@letters_dir}/*.xml"]
    @missing_entities = []
    @missing_letters = []
  end

  def update
    @letters.each do |file_name|
      letter_id = _get_id(file_name)
      letter = _get_letter(letter_id)
      doc = File.open(file_name) { |f| Nokogiri::XML(f) }

      # Update code
      doc.xpath('//letter//metadata//code').first.content = letter_id.to_s

      # Update all the entity tags.
      updated_doc = _update_ids(doc, letter, letter_id, file_name)

      if letter.present?
        letter.content = updated_doc.to_xml
        letter.save
      end

      File.open("updated_letters/#{file_name.split('/').last}", 'w') { |f| f.write(doc.to_xml) }
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
      @tags.each do |type|
        next if doc.xpath("//#{type}").empty?
        doc.xpath("//#{type}").each do |tag|
          entity = Entity.find_by(legacy_pk: tag['profile_id'].to_i, entity_type: EntityType.find_by(label: type))
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
              letter.literals << literal
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
