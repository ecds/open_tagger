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

    if row[:exclude] == 'y' && letter.present?
      letter.delete
      next
    end

    next if row[:exclude] == 'y'

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
      leaves: row[:leves].to_i,
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

    # if letter_owner.present? && letter_owner.legacy_pk == 99999999
    #   letter_owner.legacy_pk = 8888888
    #   letter_owner.save
    # end

    begin
      if row[:year] != 0
        letter.date = DateTime.new(row[:year], row[:month], row[:day])
      end
    rescue ArgumentError, NoMethodError
      puts 'Bad date'
    end

    if row[:reg_place_written]
      begin
      from = get_entity(row[:reg_place_written], 'place')
        unless letter.places_written.include?(from)
          letter.places_written << from
        end
      rescue ActiveRecord::RecordInvalid, Elasticsearch::Transport::Transport::Errors::BadRequest, Elasticsearch::Transport::Transport::Errors::NotFound
        #
      end
      # if row[:addressed_from_actual] && row[:addressed_from_actual] != from.label
      #   from.alternate_spellings << AlternateSpelling.find_or_create_by(label: row[:addressed_from_actual])
      # end
    end

    if row[:reg_place_written_city]
      begin
        place = get_entity(row[:reg_place_written_city], 'place')
        unless letter.places_written.include?(place)
          letter.places_written << place
        end
      rescue ActiveRecord::RecordInvalid, Elasticsearch::Transport::Transport::Errors::BadRequest, Elasticsearch::Transport::Transport::Errors::NotFound
        #
      end
    end

    if row[:reg_place_written_country]
      begin
        place = get_entity(row[:reg_place_written_country], 'place')
        unless letter.places_written.include?(place)
          letter.places_written << place
        end
      rescue ActiveRecord::RecordInvalid, Elasticsearch::Transport::Transport::Errors::BadRequest, Elasticsearch::Transport::Transport::Errors::NotFound
        #
      end
    end

    if row[:reg_place_written_second_city]
      begin
        place = get_entity(row[:reg_place_written_second_city], 'place')
        unless letter.places_written.include?(place)
          letter.places_written << place
        end
      rescue ActiveRecord::RecordInvalid, Elasticsearch::Transport::Transport::Errors::BadRequest, Elasticsearch::Transport::Transport::Errors::NotFound
        #
      end
    end

    if row[:reg_recipient]
      letter.recipients = []
      row[:reg_recipient].split(';').each do |recipient|
        p recipient.downcase.strip.gsub(/[\[!@%&?"\]]/, '')
        begin
          entity = get_entity(recipient, 'person')
          unless letter.recipients.include?(entity)
            letter.recipients << entity #unless letter.recipients.include? entity
          end
        rescue ActiveRecord::RecordInvalid, Elasticsearch::Transport::Transport::Errors::BadRequest, Elasticsearch::Transport::Transport::Errors::NotFound
          #
        end
        # if row[:addressed_to_actual]
        #   parts = row[:addressed_to_actual].split(',')
        #   person = parts.shift
        #   if person != entity.label
        #     entity.alternate_spellings << AlternateSpelling.find_or_create_by(label: person)
        #   end
        # end
      end

      if row[:reg_placesent_sent]
        begin
        destination = get_entity(row[:reg_placesent_sent], 'place')
          unless letter.places_sent.include?(destination)
            letter.places_sent << destination
          end
        rescue ActiveRecord::RecordInvalid, Elasticsearch::Transport::Transport::Errors::BadRequest, Elasticsearch::Transport::Transport::Errors::NotFound
          #
        end
        # if row[:reg_recipient]
        #   parts = row[:addressed_to_actual].split(',')
        #   person = parts.shift
        #   if parts.first
        #     destination.alternate_spellings << AlternateSpelling.find_or_create_by(label: person)
        #   end
        # end
      end

      if row[:reg_placesent_city]
        begin
          entity = get_entity(row[:reg_placesent_city], 'place')
          unless letter.places_sent.include?(entity)
            letter.places_sent << entity
          end
        rescue ActiveRecord::RecordInvalid, Elasticsearch::Transport::Transport::Errors::BadRequest, Elasticsearch::Transport::Transport::Errors::NotFound
          #
        end
      end

      if row[:reg_placesent_country]
        begin
          entity = get_entity(row[:reg_placesent_country], 'place')
          unless letter.places_sent.include?(entity)
            letter.places_sent << entity
          end
        rescue ActiveRecord::RecordInvalid, Elasticsearch::Transport::Transport::Errors::BadRequest, Elasticsearch::Transport::Transport::Errors::NotFound
          #
        end
      end
    end

    if row[:first_repository]
      repo = Repository.find_or_create_by(label: row[:first_repository])
      repo.format = row[:first_format]
      repo.american = row[:euro_or_am] == 'American' ? true : false
      repo.public = row[:first_public] == 'public' ? true : false
      begin
        if row[:first_collection]
          collection = Collection.find_or_create_by(label: row[:first_collection])
          unless repo.collections.include?(collection)
            repo.collections << collection
          end
          unless letter.collections.include?(collection)
            letter.collections << collection
          end
        end
        repo.save
        unless letter.repositories.include?(repo)
          letter.repositories << repo
        end
      rescue ActiveRecord::RecordInvalid, Elasticsearch::Transport::Transport::Errors::BadRequest, Elasticsearch::Transport::Transport::Errors::NotFound
        #
      end
  end

    if row[:second_repository]
      repo = Repository.find_or_create_by(label: row[:second_repository])
      repo.format = row[:second_format]
      repo.public = row[:second_public] == 'Public' ? true : false
      begin
        if row[:second_collection]
          collection = Collection.find_or_create_by(label: row[:second_collection])
          unless repo.collections.include?(collection)
            repo.collections << collection
          end
          unless letter.collections.include?(collection)
            letter.collections << collection
          end
        end
        repo.save
        unless letter.repositories.include?(repo)
          letter.repositories << repo
        end
      rescue ActiveRecord::RecordInvalid, Elasticsearch::Transport::Transport::Errors::BadRequest, Elasticsearch::Transport::Transport::Errors::NotFound
        #
      end
  end

    if row[:placeprevpubl]
      letter.letter_publisher = LetterPublisher.find_or_create_by(label: row[:placeprevpubl])
    end

    if row[:sender]
      row[:sender].split(';').each do |sender|
        begin
          entity = get_entity(sender, 'person')
          unless letter.senders.include?(entity)
            letter.senders << entity
          end
        rescue ActiveRecord::RecordInvalid, Elasticsearch::Transport::Transport::Errors::BadRequest, Elasticsearch::Transport::Transport::Errors::NotFound
          #
        end
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
  entity = Entity.by_type(type)
        .where('LOWER(entities.label) = ?', label.downcase.strip.gsub(/[\[!@%&?"\]]/, ''))
        .first_or_create(
          label: label.strip.gsub(/[\[!@%&?"\]]/, ''),
          entity_type: EntityType.find_by(label: type)
        )
  if entity.legacy_pk == 99999999
    entity.legacy_pk = 88888888
    entity.save
  end

  entity
end
end

# rows.each do |row|
#   next if row[:reg_recipient].nil?
#   letter = Letter.find_by(legacy_pk: row[:id])
#   next if letter.nil?
#   row[:reg_recipient].split(';').each do |rep|
#     entity = get_entity(rep, 'person')
#     if !letter.recipients.include? entity
#       p letter.id
#       p entity.label
#       p letter.recipients.count
#       letter.recipients << entity
#       p letter.recipients.count
#     end
#   end
# end

# Letter.all.each do |l|
#   if l.recipients
#     l.recipients.each do |r|
#       if r.label = ' '
#         l.recipients.delete(r)
#       end
#     end
#   end
# end