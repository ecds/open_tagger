namespace :legacy_import do
  desc 'Import legacy data from Djano dump.'
  task :people, [:dump] => :environment do |t, args|
    options = Rack::Utils.parse_nested_query(args[:dump])
    file = File.read(options['dump'])
    d = JSON.parse(file)

    p 'Creating People'
    count = 0
    d.select { |d1| d1['model'] == 'people.person' }.each do |person|
      next unless Person.find_by(legacy_pk: person['pk']).nil?
      p = Person.new(first: person['fields']['first_name'], last: person['fields']['last_name'])
      p.legacy_pk = person['pk']
      p.notes = person['fields']['description'] unless person['fields']['description'].empty?
      count += 1
      puts count
      next unless p.valid?
      legacy_viaf = person['fields']['VIAF_reference'].nil? ? nil : person['fields']['VIAF_reference'].split('/')[4]
      p.review = !legacy_viaf.nil? && p.viaf_id != legacy_viaf
      p.review = true if person['fields']['bio_dates'] != p.bio_dates
      puts "#{person['pk']}: #{p.simple_name}"
      p.save
    end
    puts 'DONE!!!!'
  end

  task :people_entities, [:dump] => :environment do |t, args|
    options = Rack::Utils.parse_nested_query(args[:dump])
    file = File.read(options['dump'])
    d = JSON.parse(file)

    p 'Creating People'
    count = 0
    d.select { |d1| d1['model'] == 'people.person' }.each do |person|
      next unless Person.find_by(legacy_pk: person['pk']).nil?
      p = Entity.new(label: "#{person['fields']['first_name']} #{person['fields']['last_name']}")
      p.entity_type = EntityType.find_by(label: 'Person')
      p.legacy_pk = person['pk']
      p.save
    end
    puts 'DONE!!!!'
  end

  # task :letters, [:dump] => :environment do |t, args|
  #   require 'date'
  #   options = Rack::Utils.parse_nested_query(args[:dump])
  #   file = File.read(options['dump'])
  #   d = JSON.parse(file)

  #   p 'Creating Letters'
  #   count = 0
  #   d.select { |d1| d1['model'] == 'letters.letter' }.each do |letter|
  #     # next unless Person.find_by(legacy_pk: person['pk']).nil?
  #     l = Letter.new
  #     unknown = Entity.search_by_label('unknown').by_type('Person').first
  #     sender = Entity.find_by('lower(label) = ?', letter['fields']['sender'].downcase)
  #     recipient = Entity.find_by('lower(label) = ?', letter['fields']['addressed_to_actual'].downcase)
  #     l.sender = sender.nil? ? sender : unknown
  #     # ecipiennil
  #       l.recipients << unknown
  #     else
  #       l.recipients << recipient
  #     end
  #     l.date = Date.new("19#{letter['fields']['year']}".to_i, letter['fields']['month'], letter['fields']['day'])
  #     l.save
  #   end
  #   puts 'DONE!!!!'
  # end

  task :places, [:dump] => :environment do |t, args|
    options = Rack::Utils.parse_nested_query(args[:dump])
    file = File.read(options['dump'])
    d = JSON.parse(file)

    p 'Creating Places'
    count = 0
    d.select { |d1| d1['model'] == 'geo.place' }.each do |place|
      next unless Place.find_by(legacy_pk: place['pk']).nil?
      p = Place.new(title_en: place['fields']['name'], legacy_pk: place['pk'])
      p.notes = place['fields']['description'] unless place['fields']['description'].empty?
      count += 1
      puts "#{place['pk']}: #{p.title_en}"
      p.save
    end
    puts 'DONE!!!!'
  end

  # task :orgs, [:dump] => :environment do |t, args|
  #   options = Rack::Utils.parse_nested_query(args[:dump])
  #   file = File.read(options['dump'])
  #   d = JSON.parse(file)

  #   p 'Creating Organizations'
  #   count = 0
  #   d.select { |d1| d1['model'] == 'people.organization' }.each do |org|
  #     next unless Organization.find_by(legacy_pk: org['pk']).nil?
  #     p = Organization.new(title: org['fields']['name'], legacy_pk: org['pk'])
  #     p.description = org['fields']['description'] unless org['fields']['description'].empty?
  #     count += 1
  #     puts "#{org['pk']}: #{p.title}"
  #     p.save
  #   end
  #   puts 'DONE!!!!'
  # end

  task :addresses, [:dump] => :environment do |t, args|
    options = Rack::Utils.parse_nested_query(args[:dump])
    file = File.read(options['dump'])
    d = JSON.parse(file)

    p 'Creating Addresses'
    count = 0
    d.select { |d1| d1['model'] == 'letters.letter' }.each do |l|
      next if l['fields']['reg_place_sent'].nil?
      next unless Address.find_by(title: l['fields']['reg_place_sent']).nil?
      p = Address.new(text: l['fields']['reg_place_sent'])
      count += 1
      puts "#{p.title}"
      p.save
    end
    puts 'DONE!!!!'
  end

  task :litrialnames, [:dump] => :environment do |t, args|
    options = Rack::Utils.parse_nested_query(args[:dump])
    file = File.read(options['dump'])
    d = JSON.parse(file)

    p 'Creating Literal Names'
    count = 0
    d.select { |d1| d1['model'] == 'letters.letter' }.each do |l|
      next if l['fields']['addressed_to_actual'].nil?
      text = l['fields']['addressed_to_actual']
      text.split(',').first if texinclude? ','
      next unless Literal.find_by(text: l['fields']['addressed_to_actual']).nil?
      peps = Person.search_by_name(text)
      p = peps.empty? ? nil : peps.first
      r = Literal.new(text: text, person: p)
      count += 1
      puts r.text
      puts "-- #{r.person.label}" if r.person.present?
      r.save
    end
    puts 'DONE!!!!'
  end

  task :orgs, [:dump] => :environment do |t, args|
    options = Rack::Utils.parse_nested_query(args[:dump])
    file = File.read(options['dump'])
    d = JSON.parse(file)

    p 'Creating Addresses'
    count = 0
    d.select { |d1| d1['model'] == 'people.organization' }.each do |l|
      next if l['fields']['name'].nil?
      org = Organization.find_or_create_by(title: l['fields']['name'], legacy_pk: l['pk'])
      org.description = l['fields']['description']
      org.save
      puts org.title
      if org.title != l['fields']['name']
        Literal.create(text: l['fields']['name'], organization: org)
        puts "created literal #{l['fields']['name']} for #{org.title}"
      end
      count += 1
    end
    puts 'DONE!!!!'
  end

  task :litrialnames_update, [:dump] => :environment do |t, args|
    options = Rack::Utils.parse_nested_query(args[:dump])
    file = File.read(options['dump'])
    d = JSON.parse(file)

    p 'Creating Literal Names'
    count = 0
    # d.select { |d1| d1['model'] == 'letters.letter' }.each do |l|
    #   next if l['fields']['addressed_to_actual'].nil?
    #   text = l['fields']['addressed_to_actual']
    #    texsplit(',').first if texinclude? ','
    #   lit = Literal.find_or_create_by(text: text)
    #   fliperson.present?
    #   peps = Person.search_by_name(text)
    #   p = peps.empty? ? nil : peps.first
    #    p      count += 1
    #   itext      --#{liperson.label}" if liperson.present?
    #      end    puts 'DONE!!!!'
  end

  # dinstance_of.firstitle

  # task :create_countries => :environment do
  #   # require 'sparql'
  #    SPARQL:Cliennew('http://dbpedia.org/sparql')

  #   offset = 0

  #   query = %(
  #     PREFIX dbo: <http://dbpedia.org/ontology/>
  #     PREFIX owl: <http://www.w3.org/2002/07/owl#>
  #     PREFIX foaf: <http://xmlns.com/foaf/0.1/>
  #     SELECT DISTINCT ?s, ?name, ?same
  #     WHERE  {
  #       ?s a dbo:Country .
  #       ?s foaf:name ?name .
  #       ?s owl:sameAs ?same .
  #       ?s a ?type .
  #       FILTER regex(str(?same), "wikidata.org")
  #     }
  #     ORDER BY ?name
  #     OFFSET #{offset}
  #   )

  #   results = sparql.query(query)
  #   results.each do |c|
  #     puts "From dbpedia: #{c[:name]}"
  #     next unless Place.find_by(wikidata_id: c[:same].value.split('/').last).nil?
  #     country = Place.new(wikidata_id: c[:same].value.split('/').last)
  #     next unless country.valid?
  #     country.save
  #     puts country.title_en
  #   end
  #   p 'DONE!!!!'
  # end
 
  # task :create_cities => :environment do
  #   offset = 0
  #   results = []
  #   def query(offset)
  #      SPARQL:Cliennew('http://dbpedia.org/sparql')
  #     query = %(
  #       PREFIX dbo: <http://dbpedia.org/ontology/>
  #       PREFIX owl: <http://www.w3.org/2002/07/owl#>
  #       PREFIX foaf: <http://xmlns.com/foaf/0.1/>
  #       SELECT DISTINCT ?s, ?name, ?same
  #       WHERE  {
  #         ?s a dbo:City .
  #         ?s foaf:name ?name .
  #         ?s owl:sameAs ?same .
  #         ?s a ?type .
  #         FILTER regex(str(?same), "wikidata.org")
  #       }
  #       ORDER BY ?name
  #       OFFSET #{offset}
  #     )
  #     sparql.query(query)
  #   end

  #   until results.length > 0 && offset != results.length do
  #     query(results.length).each {|r| results.push(r)}
  #     offset += 10000
  #     puts offset
  #     puts results.length
  #   end

  #   results.each do |c|
  #     puts "From dbpedia: #{c[:name]}"
  #     next unless City.find_by(wikidata_id: c[:same].value.split('/').last).nil?
  #     city = City.new(wikidata_id: c[:same].value.split('/').last)
  #     next unless city.valid?
  #     city.save
  #     puts city.title_en
  #   end
  #   p 'DONE!!!!'
  # end

  # task :create_cities_backwards => :environment do
  #   offset = 0
  #   results = []
  #   def query(offset)
  #      SPARQL:Cliennew('http://dbpedia.org/sparql')
  #     query = %(
  #       PREFIX dbo: <http://dbpedia.org/ontology/>
  #       PREFIX owl: <http://www.w3.org/2002/07/owl#>
  #       PREFIX foaf: <http://xmlns.com/foaf/0.1/>
  #       SELECT DISTINCT ?s, ?name, ?same
  #       WHERE  {
  #         ?s a dbo:City .
  #         ?s foaf:name ?name .
  #         ?s owl:sameAs ?same .
  #         ?s a ?type .
  #         FILTER regex(str(?same), "wikidata.org")
  #       }
  #       ORDER BY ?name
  #       OFFSET #{offset}
  #     )
  #     sparql.query(query)
  #   end

  #   until results.length > 0 && offset != results.length do
  #     query(results.length).each {|r| results.push(r)}
  #     offset += 10000
  #   end

  #   results.reverse.each do |c|
  #     puts "From dbpedia: #{c[:name]}"
  #     next unless City.find_by(wikidata_id: c[:same].value.split('/').last).nil?
  #     city = City.new(wikidata_id: c[:same].value.split('/').last)
  #     next unless city.valid?
  #     city.save
  #     puts city.title_en
  #   end
  #   p 'DONE!!!!'
  # end

  # task :create_admin_areas => :environment do
  #   offset = 0
  #   results = []
  #   def query(offset)
  #   sparql= SPARQL::Cliennew('http://dbpedia.org/sparql')
  #     query = %(
  #       PREFIX dbo: <http://dbpedia.org/ontology/>
  #       PREFIX owl: <http://www.w3.org/2002/07/owl#>
  #       PREFIX foaf: <http://xmlns.com/foaf/0.1/>
  #       SELECT DISTINCT ?s, ?name, ?same
  #       WHERE  {
  #         ?s a dbo:AdministrativeRegion .
  #         ?s foaf:name ?name .
  #         ?s owl:sameAs ?same .
  #         ?s a ?type .
  #         FILTER regex(str(?same), "wikidata.org")
  #       }
  #       ORDER BY ?name
  #       OFFSET #{offset}
  #     )
  #     sparql.query(query)
  #   end

  #   until results.length > 0 && offset != results.length do
  #     query(results.length).each {|r| results.push(r)}
  #     offset += 10000
  #     puts offset
  #     puts results.length
  #   end

  #   results.each do |c|
  #     puts "From dbpedia: #{c[:name]}"
  #     next unless AdminArea.find_by(wikidata_id: c[:same].value.split('/').last).nil?
  #     aa = AdminArea.new(wikidata_id: c[:same].value.split('/').last)
  #     next unless aa.valid?
  #     aa.save
  #     puts aa.title_en
  #   end
  #   p 'DONE!!!!'
  # end

  # task :create_admin_areas => :environment do
    # countries = Country.all

    # countries.each do |country|
    #   country.make_subs
    # end
    # AdminArea.find(339).create_subs
    # wd = Wikidata::Item.find AdminArea.find(339).wikidata_id
    # wd.properties('P150').collect(&:id).each do |s|
    #   sd = Wikidata::Item.find s
    #   puts sd.title
    # end

    # AdminArea.all.each do |c|
    #   next unless c.end_year.nil?
    #   wd = Wikidata::Item.find c.wikidata_id
    #   next if wd.nil? || wd.properties('p150').empty?
    #   wd.properties('P150').collect(&:id).each do |s|
    #     aa = AdminArea.new(wikidata_id: s, part_of: c)
    #     aa.save
    #   end
    # end
  #   AdminArea.all.reverse.each {|aa| aa.save}
  # end

  task :import_letters, [:dump] => :environment do |t, args|
    options = Rack::Utils.parse_nested_query(args[:dump])
    file = File.read(options['dump'])
    # d = JSON.parse(file)

    p 'Creating Letters'
    count = 0
    d.select { |d1| d1['model'] == 'letters.letter' }.each do |letter|
      next unless Letter.find_by(legacy_pk: letter['pk']).nil?
      l = Letter.new(legacy_pk: letter['pk'], code: letter['fields']['code'])
      sender = letter['fields']['sender'].split(' ')
      l.sender = Person.find_or_create_by(first: sender.first, last: sender.last)

      recipients = l['fields']['reg_recipient']
      if recipients.titlecase.include?(" And ")
        parts = recipients.titlecase.gsub(" And ", " ").split(" ")
        l.recipients = [
          Person.find_or_create_by(first: parts.first, last: parts.last),
          Person.find_or_create_by(first: parts[1], last: parts.last)  
        ]
      else
        pats = recipients.titlecase.split(" ")
        l.recipients = [Person.find_or_create_by(first: parts.first, last: parts.last)]
      end

      l.date = Date.new("19#{letter['fields']['year']}".to_i,letter['fields']['month'],letter['fields']['day'])
    end
    puts 'DONE!!!!'
  end

  task :add_repos, [:dump] => :environment do |t, args|
    options = Rack::Utils.parse_nested_query(args[:dump])
    file = File.read(options['dump'])
    d = JSON.parse(file)
    d.select { |d1| d1['model'] == 'letters.letter' }.each do |letter|
      Repository.find_or_create_by(label: letter['fields']['repository'])
      Repository.find_or_create_by(label: letter['fields']['second_repository'])
    end
  end

  task :add_collections, [:dump] => :environment do |t, args|
    options = Rack::Utils.parse_nested_query(args[:dump])
    file = File.read(options['dump'])
    d = JSON.parse(file)
    d.select { |d1| d1['model'] == 'letters.letter' }.each do |letter|
      Collection.find_or_create_by(
        label: letter['fields']['collection'],
        repository: Repository.find_by(label: letter['fields']['repository'])
      ) if letter['fields']['collection'].present?
    end
  end

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
