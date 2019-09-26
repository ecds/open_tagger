namespace :big_sam do
  task :letters_from_csv, [:csv] => :environment do |t, args|
    require 'csv'
    options = Rack::Utils.parse_nested_query(args[:csv])
    rows = CSV.table(options['csv'], headers: true)
    rows.each do |row|
      if row[:day] == '0'
        row[:day] = '1'
      end
      if row[:month] == '0'
        row[:month] = '1'
      end
      if row[:year] == '0'
        row[:year] = '99'
      end

      if row[:day].is_a?(String)
        row[:day] = row[:day].gsub(/[\[!@%&?"\]]/, '').to_i
      end
      if row[:month].is_a?(String)
        row[:month] = row[:month].gsub(/[\[!@%&?"\]]/, '').to_i
      end
      if row[:year].is_a?(String)
        row[:year] = "19#{row[:year]}".gsub(/[\[!@%&?"\]]/, '').to_i
      end

      if row[:year].to_s.size == 2
        row[:year] = row[:year] + 1900
      end

      # existing = Letter.find_by(legacy_pk: row['ID'])
      # next if existing

      letter = Letter.find_or_create_by(legacy_pk: row[:id])

      letter.attributes = {
        code: row[:code],
        legacy_pk: row[:id],
        addressed_to: row[:addressed_to_actual],
        addressed_from: row[:addressed_from_actual],
        physical_desc: row[:physdes],
        physical_detail: row[:phys_descr_detail],
        physical_notes: row[:physdes_notes],
        repository_info: row[:repository_information],
        postcard_image: row[:postcard_image],
        leaves: row[:leves],
        sides: row[:sides],
        postmark: row[:postmark_actual],
        notes: row[:dditional],
        letter_owner: LetterOwner.find_or_create_by(label: row[:ownerrights]),
        file_folder: FileFolder.find_or_create_by(label: row[:file]),
        typed: row[:autograph_or_typed] == 'T' ? true : false,
        signed: row[:initialed_or_signed] == 'S' ? true : false,
        envelope: row[:envelope] == 'E' ? true : false,
        verified: row[:verified] == 'Y' ? true : false
      }

      begin
        if row[:year] != 0
          letter.date = DateTime.new(row[:year], row[:month], row[:day])
        end
      rescue ArgumentError
        puts 'Bad date'
      end

      if row[:reg_place_written]
        from = get_entity(row[:reg_place_written], 'place')
        begin
          letter.places_written << from
        rescue ActiveRecord::RecordInvalid
          #
        end
        if row[:addressed_from_actual] && row[:addressed_from_actual] != from.label
          from.alternate_spellings << AlternateSpelling.find_or_create_by(label: row[:addressed_from_actual])
        end
      end

      if row[:reg_place_written_city]
        begin
          letter.places_written << get_entity(row[:reg_place_written_city], 'place')
        rescue ActiveRecord::RecordInvalid
          #
        end
      end

      if row[:reg_place_written_country]
        begin
          letter.places_written << get_entity(row[:reg_place_written_country], 'place')
        rescue ActiveRecord::RecordInvalid
          #
        end
      end

      if row[:reg_place_written_second_city]
        begin
          letter.places_written << get_entity(row[:reg_place_written_second_city], 'place')
        rescue ActiveRecord::RecordInvalid
          #
        end
      end

      if row[:reg_recipient]
        row[:reg_recipient].split(';').each do |recipient|
          p recipient.downcase.strip.gsub(/[\[!@%&?"\]]/, '')
          entity = get_entity(row[:reg_recipient], 'person')
          begin
            letter.recipients << entity
          rescue ActiveRecord::RecordInvalid
            #
          end
          if row[:addressed_to_actual]
            parts = row[:addressed_to_actual].split(',')
            person = parts.shift
            if person != entity.label
              entity.alternate_spellings << AlternateSpelling.find_or_create_by(label: person)
            end
          end
        end

        if row[:reg_placesent_sent]
          destination = get_entity(row[:reg_placesent_sent], 'place')
          letter.places_sent << destination
          if row[:reg_recipient]
            parts = row[:addressed_to_actual].split(',')
            person = parts.shift
            if parts.first
              destination.alternate_spellings << AlternateSpelling.find_or_create_by(label: person)
            end
          end
        end

        if row[:reg_placesent_city]
          begin
            letter.places_sent << get_entity(row[:reg_placesent_city], 'place')
          rescue ActiveRecord::RecordInvalid
            #
          end
        end

        if row[:reg_placesent_country]
          begin
            letter.places_sent << get_entity(row[:reg_placesent_country], 'place')
          rescue ActiveRecord::RecordInvalid
            #
          end
        end
      end

      if row[:first_repository]
        repo = Repository.find_or_create_by(label: row[:first_repository])
        repo.format = row[:first_format]
        repo.american = row[:euro_or_am] == 'American' ? true : false
        repo.public = row[:first_public] == 'public' ? true : false
        if row[:first_collection]
          collection = Collection.find_or_create_by(label: row[:first_collection])
          repo.collections << collection
          letter.collections << collection
        end
        repo.save
        letter.repositories << repo
      end

      if row[:second_repository]
        repo = Repository.find_or_create_by(label: row[:second_repository])
        repo.format = row[:second_format]
        repo.public = row[:second_public] == 'Public' ? true : false
        if row[:second_collection]
          collection = Collection.find_or_create_by(label: row[:second_collection])
          repo.collections << collection
          letter.collections << collection
        end
        repo.save
        letter.repositories << repo
      end

      if row[:placeprevpubl]
        letter.letter_publisher = LetterPublisher.find_or_create_by(label: row[:placeprevpubl])
      end

      if row[:sender]
        row[:sender].split(';').each do |sender|
          entity = get_entity(sender, 'person')
          letter.senders << entity
        end
      end

      if row[:primarylang]
        lang = Language.where('LOWER(languages.label) = ?', row[:primarylang].downcase.strip)
                       .first_or_create(
                         label: row[:primarylang]
                       )
        letter.language = lang
      end

      letter.typed = row[:autograph_or_typed] == 'T' ? true : false

      letter.signed = row[:initialed_or_signed] == 'S' ? true : false

      letter.envelope = row[:envelope] == 'E' ? true : false

      letter.verified = row[:verified] == 'Y' ? true : false

      # letter.validate!

      letter.save
    end

  end
  def get_entity(label, type)
    Entity.by_type(type)
          .where('LOWER(entities.label) = ?', label.downcase.strip.gsub(/[\[!@%&?"\]]/, ''))
          .first_or_create(
            label: label.strip.gsub(/[\[!@%&?"\]]/, ''),
            entity_type: EntityType.find_by(label: type)
          )
  end
end
