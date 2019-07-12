namespace :big_sam do
  task :letters_from_csv, [:csv] => :environment do |t, args|
    require 'csv'
    options = Rack::Utils.parse_nested_query(args[:csv])
    p options['csv']
    rows = CSV.read(options['csv'], headers: true)
    rows.each do |row|
      p row['ID']
      if row['Day'] == '0'
        row['Day'] = '1'
      end
      if row['Month'] == '0'
        row['Month'] = '1'
      end
      p "19#{row['Year']} #{row['Month']} #{row['Day']}"


      letter = Letter.new(
        code: row['Code'],
        date: DateTime.new("19#{row['Year']}".to_i, row['Month'].to_i, row['Day'].to_i),
        legacy_pk: row['ID'],
        addressed_to: row['Addressed to (Actual)'],
        addressed_from: row['Addressed from (Actual)'],
        # sender: row['Sender'],
        physical_desc: row['PhysDes'],
        physical_detail: row['phys descr detail'],
        physical_notes: row['PhysDes notes'],
        repository_info: row['Repository information'],
        postcard_image: row['Postcard Image'],
        leaves: row['leves'],
        sides: row['sides'],
        postmark: row['Postmark (Actual)'],
        notes: row['Additional'],
        letter_owner: LetterOwner.find_or_create_by(label: row['OwnerRights']),
        file_folder: FileFolder.find_or_create_by(label: row['File']),
        typed: row['Autograph or Typed'] == 'T' ? true : false,
        signed: row['initialed or signed'] == 'S' ? true : false,
        envelope: row['Envelope'] == 'E' ? true : false,
        verified: row['Verified'] == 'Y' ? true : false
      )

      from = Entity.find_or_create_by(
        label: "#{row['Reg. Place written']} #{row['Reg. Place written city']} #{row['Reg. Place written country']}",
        entity_type: EntityType.find_or_create_by(label: 'place')
      )

      letter.places_written << from

      if row['Reg. Place written, second city']
        second_city = Entity.find_or_create_by(
          label: row['Reg. Place written, second city'],
          entity_type: EntityType.find_or_create_by(label: 'place')
        )
        letter.places_written << second_city
      end

      letter.recipient = Entity.find_or_create_by(
        label: row['Reg. recipient'],
        entity_type: EntityType.find_or_create_by(label: 'person')
      )

      letter.destination = Entity.find_or_create_by(
        label: "#{row['Reg place sent']} #{row['Reg. PlaceSent City']} #{row['Reg. PlaceSent Country']}",
        entity_type: EntityType.find_or_create_by(label: 'place')
      )

      if row['First Repository']
        repo = Repository.find_or_create_by(label: row['First Repository'])
        repo.format = row['First Format']
        repo.american = row['Euro or Am?'] == 'American' ? true : false
        repo.public = row['First Public?'] == 'public' ? true : false
        if row['First Collection']
          repo.collections << Collection.find_or_create_by(label: row['First Collection'])
        end
        repo.save
        letter.repositories << repo
      end

      if row['Second Repository']
        repo = Repository.find_or_create_by(label: row['Second Repository'])
        repo.format = row['Second Format']
        repo.public = row['Second Public?'] == 'Public' ? true : false
        if row['Second Collection']
          repo.collections << Collection.find_or_create_by(label: row['Second Collection'])
        end
        repo.save
        letter.repositories << repo
      end

      if row['PlacePrevPubl']
        letter.letter_publisher = LetterPublisher.find_or_create_by(label: row['PlacePrevPubl'])
      end

      letter.typed = row['Autograph or Typed'] == 'T' ? true : false

      letter.signed = row['initialed or signed'] == 'S' ? true : false

      letter.envelope = row['Envelope'] == 'E' ? true : false

      letter.verified = row['Verified'] == 'Y' ? true : false

      letter.save
    end
  end
end