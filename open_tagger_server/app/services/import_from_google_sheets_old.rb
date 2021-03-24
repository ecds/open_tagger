require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'

class ImportFromGoogleSheets
  def initialize(options)
    @options = options
    @service = Google::Apis::SheetsV4::SheetsService.new
    @service.client_options.application_name = 'Becket Import'
    @service.authorization = authorize
    if options[:sheet_id]
      response = @service.get_spreadsheet(options[:sheet_id], ranges: options[:range], include_grid_data: true)
      @sheet = response.sheets[0]
    end
    @sheets = [
      {
        sheet_id: '1lrbBrMM3cV9d_foQfi5VyJO4gwtl4UkL4N3JWa-fjeo',
        type: 'person',
        range: 'A2:H'
      },
      {
        sheet_id: '1nd88cZegFqC_IbjY2G8C5nejmkgNCtDlsf-4oMmSykU',
        type: 'organization',
        range: 'A2:D'
      },
      {
        sheet_id: '1JvjvU-70ApkYCXcIXRLGiagASmYih8mfYxuo9kqP_Sg',
        type: 'place',
        range: 'A2:E'
      },
      {
        sheet_id: '1SvYsRQVRlo-ZTVYuJaFt9oCJYpbb3NJm7cijM86GbQg',
        type: 'production',
        range: 'A2:M'
      },
      {
        sheet_id: '1yuQykRVY4S-FQuOg1P-nRQ9C5Ma439e5v9_uVALs2ns',
        type: 'writing',
        range: 'A2:F'
      },
      {
        sheet_id: '1FUAzp9McmDOK8-xIZk-JdSfomxQYmrjGoBNrhYLkZF4',
        type: 'translating',
        range: 'A2:G'
      },
      {
        sheet_id: '1lIYE6gGQcq5mbwilzWqOLJchLrc4iAwH0WMdM53axps',
        type: 'reading',
        range: 'A2:F'
      },
      {
        sheet_id: '1b1J0Gt9NPLsrfXJ-agc2GjCRb-7Upq7w1ddW40dV4i4',
        type: 'attendance',
        range: 'A2:G'
      },
      {
        sheet_id: '13RbWm78OXzNt6AfjvXzY7b6ldIsFtIrBFaw01v9ciQs',
        type: 'public_event',
        range: 'A2:D'
      },
      {
        sheet_id: '1DVByIJWiDNi78yUs81eidPQYAqL9E6ovsCztimwnCTg',
        type: 'work_of_art',
        range: 'A2:H'
      },
      {
        sheet_id: '1fOuJX-w3Tv6ZfK8_d6JRM29PIYaZk7i-_5Qdt3AtSck',
        type: 'music',
        range: 'A2:G'
      },
      {
        sheet_id: '1HeTeJqueJR4TWqgSCMJOgOglLLyYGfKux8YL57OYfg8',
        type: 'publication',
        range: 'A2:G'
      }
    ]
    @people_profiles = '1s_dkTpJJCxs5XOhbH6SwYka317buWLTJDw8GXCqsVx8'
    @orgs_profiles = '1jwgrdOzDVU36pmwNAdhJ2MGR8-IGQa4BZthwDiniy6c'
    @people_sheet = '1lrbBrMM3cV9d_foQfi5VyJO4gwtl4UkL4N3JWa-fjeo'
  end

  def bulk_import
    @sheets.each do |sheet|
      @options[:entity_type] = sheet[:type]
      response = @service.get_spreadsheet(sheet[:sheet_id], ranges: sheet[:range], include_grid_data: true)
      @sheet = response.sheets[0]
      if @sheet.data
        import
      end
    end
    #person_profiles
    #org_profiles
    label_people
  end

  def import
    @sheet.data[0].row_data.each do |row_data|
      next if !row_data.values
      next if !row_data.values[0]
      next if !row_data.values[1]
      entity = Entity.find_or_create_by(legacy_pk: row_data.values[0].formatted_value.to_i, entity_type: EntityType.find_or_create_by(label: @options[:entity_type]))

      # if entity.properties.nil?
      #entity.properties = {}
      # end

      row_data.values.each_with_index do |column, index|
        next if column.formatted_value.nil?
        # p "#{column.text_format_runs} : #{column.formatted_value}"
        value = column.text_format_runs ? format_column(column) : column.formatted_value
        value = value.class == String ? value.strip : value
        value = column.effective_format.text_format.italic ? "<i>#{value}</i>" : value
        p value
        row_values = {
          "entity": entity,
          "index": index,
          "value": value
        }
        p row_values
        case @options[:entity_type]
        when 'attendance'
          entity = _attendance(row_values)
        when 'person'
          entity = _people(row_values)
        when 'organization'
          entity = _organization(row_values)
        when 'place'
          entity = _place(row_values)
        when 'reading'
          entity = _reading(row_values)
        when 'production'
          entity = _production(row_values)
        when 'work_of_art'
          entity = _art(row_values)
        when 'translating'
          entity = _translating(row_values)
        when 'writing'
          entity = _writing(row_values)
        when 'public_event'
          entity = _event(row_values)
        when 'music'
          entity = _music(row_values)
        when 'publication'
          entity = _publication(row_values)
        else
          'Entity type in missing or invalid.'
        end
      end
      next if entity.legacy_pk == 0
      entity.save
    end
  end

  def person_profiles
    response = @service.get_spreadsheet(@people_profiles, ranges: 'A2:B', include_grid_data: true)
    @sheet = response.sheets[0]
    @sheet.data[0].row_data.each do |row_data|
      next if !row_data.values[0]
      entity = Entity.by_type('person').find_by(legacy_pk: row_data.values[0].formatted_value.to_i)
      p entity
      next if entity.nil?
      column = row_data.values[1]
      value = column.text_format_runs ? format_column(column) : column.formatted_value
      entity.properties['profile'] = value
      entity.save
    end
  end

  def org_profiles
    response = @service.get_spreadsheet(@orgs_profiles, ranges: 'A2:B', include_grid_data: true)
    @sheet = response.sheets[0]
    @sheet.data[0].row_data.each do |row_data|
      next if !row_data.values[0]
      entity = Entity.by_type('organization').find_by(legacy_pk: row_data.values[0].formatted_value.to_i)
      next if entity.nil?
      entity.properties['profile'] = row_data.values[1].formatted_value
      entity.save
    end
  end

  def add_alt_spellings_people
    response = @service.get_spreadsheet(@people_sheet, ranges: 'A2:BH', include_grid_data: true)
    @sheet = response.sheets[0]
    @sheet.data[0].row_data.each do |row_data|
      next if !row_data.values[0]
      p row_data.values[0].formatted_value.to_i
      entity = Entity.by_type('person').find_by(legacy_pk: row_data.values[0].formatted_value.to_i)
      next if entity.nil?
      next if !entity.properties['alternate_names_spellings'].empty?
      p entity.label
      if row_data.values[5].formatted_value.nil?
        entity.properties['alternate_names_spellings'] = []
        entity.save
        next
      end
      p row_data.values[5].formatted_value
      entity.properties['alternate_names_spellings'] = row_data.values[5].formatted_value.split(';').map { |e| e.tr('"', '').strip }
      p entity.properties['alternate_names_spellings']
      entity.save
    end
  end

  def add_cast_to_attendance
    response = @service.get_spreadsheet('1b1J0Gt9NPLsrfXJ-agc2GjCRb-7Upq7w1ddW40dV4i4', ranges: 'A2:G', include_grid_data: true)
    @sheet = response.sheets[0]
    @sheet.data[0].row_data.each do |row_data|
      next if !row_data.values[0]
      entity = Entity.by_type('attendance').find_by(legacy_pk: row_data.values[0].formatted_value.to_i)
      next if entity.nil?
      next if entity.label.nil?
      if !row_data.values[6].nil?
        column = row_data.values[6]
        cast = column.text_format_runs ? format_column(column) : column.formatted_value
        next if cast.nil?
        entity.properties['performed_by'] = cast.split(';').map { |e| e.tr('"', '').strip }
        # entity.properties['performed_by'] = cast.split(';').map { |c| { actor: c.split('(')[0].strip, role: c.split('(')[-1].tr(')', '').strip } }
        p entity.properties['performed_by']
        entity.save
      end
    end
  end

  def add_cast_to_production
    response = @service.get_spreadsheet('1SvYsRQVRlo-ZTVYuJaFt9oCJYpbb3NJm7cijM86GbQg', ranges: 'A2:L', include_grid_data: true)
    @sheet = response.sheets[0]
    @sheet.data[0].row_data.each do |row_data|
      next if !row_data.values[0]
      entity = Entity.by_type('production').find_by(legacy_pk: row_data.values[0].formatted_value.to_i)
      next if entity.nil?
      cast_col = row_data.values[9]
      notes_col = row_data.values[10]
      stbk_col = row_data.values[11]
      cast = cast_col.text_format_runs ? format_column(cast_col) : cast_col.formatted_value
      notes = notes_col.text_format_runs ? format_column(notes_col) : notes_col.formatted_value
      stbk = stbk_col.formatted_value
      if entity.properties.nil?
        entity.properties = {}
      end
      if !cast.nil?
        entity.properties['cast'] = cast.split(';').map { |e| e.tr('"', '').strip }
      else
        entity.properties['cast'] = []
      end
      entity.properties['notes'] = notes
      entity.properties['staging_beckett'] = stbk
      entity.save
    end
  end

  def split_art_title_desc
    response = @service.get_spreadsheet('1DVByIJWiDNi78yUs81eidPQYAqL9E6ovsCztimwnCTg', ranges: 'A2:H', include_grid_data: true)
    @sheet = response.sheets[0]
    @sheet.data[0].row_data.each do |row_data|
      next if !row_data.values[0]
      entity = Entity.find_or_create_by(legacy_pk: row_data.values[0].formatted_value.to_i, entity_type: EntityType.find_by(label: 'work_of_art'))
      next if entity.nil?
      row_data.values.each_with_index do |column, index|
        value = column.text_format_runs ? format_column(column) : column.formatted_value
        value = value.class == String ? value.tr('"', '').strip : value
        p value
        row_values = {
          "entity": entity,
          "index": index,
          "value": value
        }
        entity = _art(row_values)
      end
      column = row_data.values[3]
      title_desc = column.text_format_runs ? format_column(column) : column.formatted_value
      next if title_desc.nil?
      title_desc = title_desc.split('(')
      entity.label = title_desc.shift
      entity.properties['description'] = title_desc.join(' ').gsub(')', '')
      entity.save
      p "Label: #{entity.label}"
      p "Description: #{entity.properties['description']}"
    end
  end

  def label_people
    Entity.by_type('person').each do |p|
      next if p.properties.nil?
      p.label = "#{p.properties['first_name']} #{p.properties['last_name']}"
      p.save
    end
  end

  private

    def format_column(column)
      start_indicies = []
      parts = []
      italic_parts = []
      column.text_format_runs.each_with_index do |tr, index|
        start_indicies.push(tr.start_index.to_i)
        if tr.format.italic?
          italic_parts.push(index)
        end
      end

      start_indicies.each_with_index do |start, index|
        last = index != start_indicies.length - 1 ? start_indicies[index + 1] : column.formatted_value.length
        parts.push(column.formatted_value[start...last])
      end

      italic_parts.each do |part|
        parts[part] = "<i>#{parts[part]}</i>"
      end

      parts.join
    end

    def authorize
      oob_uri = 'urn:ietf:wg:oauth:2.0:oob'.freeze
      credentials = 'credentials.json'.freeze
      token = 'token.yaml'.freeze
      scope = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY

      client_id = Google::Auth::ClientId.from_file(credentials)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: token)
      authorizer = Google::Auth::UserAuthorizer.new(client_id, scope, token_store)
      user_id = 'default'
      credentials = authorizer.get_credentials(user_id)
      if credentials.nil?
        url = authorizer.get_authorization_url(base_url: oob_uri)
        puts 'Open the following URL in the browser and enter the ' \
            "resulting code after authorization:\n" + url
        code = gets
        credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: oob_uri
        )
      end
      credentials
    end

    # updated
    def _attendance(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.properties['event_type'] = values[:value]
      elsif values[:index] == 2
        entity.label = values[:value]
      elsif values[:index] == 3 && !values[:value].nil?
        entity.properties['alternate_spellings'] = values[:value].split(';').map { |e| e.strip }
      elsif values[:index] == 3 && values[:value].nil?
        entity.properties['alternate_spellings'] = []
      elsif values[:index] == 4
        entity.properties['place_date'] = values[:value]
      elsif values[:index] == 4 && values[:value].nil?
        entity.properties['place_date'] = ''
      elsif values[:index] == 5 && !values[:value].nil?
        entity.properties['attended_with'] = values[:value].split(',').map { |e| e.strip }
      elsif values[:index] == 5 && values[:value].nil?
        entity.properties['attended_with'] = []
      elsif values[:index] == 6
        entity.properties['director'] = values[:value]
      elsif values[:index] == 6 && values[:value].nil?
        entity.properties['director'] = ''
      elsif values[:index] == 7 && !values[:value].nil?
        entity.properties['performed_by'] = values[:value].split(';').map { |e| e.strip }
      elsif values[:index] == 7 && values[:value].nil?
        entity.properties['performed_by'] = []
      # elsif values[:index] == 8 && !values[:value].nil?
      #   entity.properties['citation'] = values[:value]
      # elsif values[:index] == 8 && values[:value].nil?
      #   entity.properties['citation'] = ''
      end
      entity
    end

    # updated
    def _people(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.properties['last_name'] = values[:value]
      elsif values[:index] == 2
        entity.properties['first_name'] = values[:value]
      elsif values[:index] == 3
        entity.properties['life_dates'] = values[:value]
      elsif values[:index] == 4
        entity.properties['description'] = values[:value]
      elsif values[:index] == 5 && !values[:value].nil?
        entity.properties['alternate_names_spellings'] = values[:value].split(';').map { |e| e.tr('"', '').strip }
      elsif values[:index] == 5 && values[:value].nil?
        entity.properties['alternate_names_spellings'] = []
      elsif values[:index] == 6
        entity.properties['links'] = [values[:value]]
      end
      entity
    end

    # updated
    def _organization(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.label = values[:value]
      elsif values[:index] == 2 && !values[:value].nil?
        entity.properties['alternate_spellings'] = values[:value].split(';').map {|e| e.tr('"', '').strip}
      elsif values[:index] == 2 && values[:value].nil?
        entity.properties['alternate_spellings'] = []
      elsif values[:index] == 3
        entity.properties['description'] = values[:value]
      elsif values[:index] == 4
        entity.properties['profile'] = values[:value]
      end
      entity
    end

    # updated
    def _place(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.label = values[:value]
      elsif values[:index] == 2
        entity.properties['links'] = [values[:value]]
      elsif values[:index] == 3
        entity.properties['description'] = values[:value]
      elsif values[:index] == 4 && !values[:value].nil?
        entity.properties['alternate_spellings'] = values[:value].split(';').map { |e| e.tr('"', '').strip }
      elsif values[:index] == 4 && values[:value].nil?
        entity.properties['alternate_spellings'] = []
      end
      entity
    end

    # updated
    def _reading(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.properties['authors'] = [values[:value]]
      elsif values[:index] == 2
        entity.label = values[:value]
      elsif values[:index] == 3
        entity.properties['publication'] = values[:value]
      elsif values[:index] == 4
        entity.properties['comment'] = values[:value]
      elsif values[:index] == 5
        entity.properties['publication_format'] = values[:value]
      end
      entity
    end

    def _production(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
        entity.properties['links'] = []
        entity.properties['proposal'] = ''
        entity.properties['response'] = ''
        entity.properties['reason'] = ''
        entity.properties['director'] = ''
        entity.properties['personnel'] = []
        entity.properties['theatre'] = ''
        entity.properties['city'] = ''
        entity.properties['date'] = ''
        entity.properties['cast'] = []
        entity.properties['notes'] = ''
        entity.properties['staging_beckett'] = ''
      elsif values[:index] == 1
        entity.label = values[:value]
      elsif values[:index] == 2 && !values[:value].nil?
        entity.properties['proposal'] = values[:value]
      elsif values[:index] == 3 && !values[:value].nil?
        entity.properties['response'] = values[:value]
      elsif values[:index] == 4 && !values[:value].nil?
        entity.properties['reason'] = values[:value]
      elsif values[:index] == 5 && !values[:value].nil?
        entity.properties['director'] = values[:value]
      elsif values[:index] == 6 && !values[:value].nil?
        entity.properties['personnel'] = values[:value].split(';').map { |e| e.strip }
      elsif values[:index] == 7 && !values[:value].nil?
        entity.properties['theatre'] = values[:value]
      elsif values[:index] == 8 && !values[:value].nil?
        entity.properties['city'] = values[:value]
      elsif values[:index] == 9 && !values[:value].nil?
        entity.properties['date'] = values[:value]
      elsif values[:index] == 10 && !values[:value].nil?
        entity.properties['cast'] = values[:value].split(';').map { |e| e.strip }
      elsif values[:index] == 11 && !values[:value].nil?
        entity.properties['notes'] = values[:value]
      elsif values[:index] == 12 && !values[:value].nil?
        entity.properties['staging_beckett'] = values[:value]
      end
      entity
    end

    # updated
    def _production_old(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.label = values[:value]
      elsif values[:index] == 2
        entity.properties['cast'] = values[:value]
      elsif values[:index] == 3
        entity.properties['response'] = values[:value]
      elsif values[:index] == 4
        entity.properties['reason'] = values[:value]
      elsif values[:index] == 5
        entity.properties['director'] = values[:value]
      elsif values[:index] == 6
        entity.properties['staff'] = values[:value]
      elsif values[:index] == 7
        entity.properties['theatre'] = values[:value]
      elsif values[:index] == 8
        entity.properties['city'] = values[:value]
      elsif values[:index] == 9
        entity.properties['date'] = values[:value]
      elsif values[:index] == 10 && !values[:value].nil?
        # entity.properties['cast'] = values[:value].split(';').map { |c| { actor: c.split('(')[0].strip, role: c.split('(')[-1].tr(')', '').strip } }
        entity.properties['cast'] = values[:value].split(';').map { |e| e.strip }
      elsif values[:index] == 10 && values[:value].nil?
        entity.properties['cast'] = []
      elsif values[:index] == 11
        entity.properties['notes'] = values[:value]
      elsif values[:index] == 12
        entity.properties['staging_beckett'] = values[:value]
      end
      entity
    end

    # updated
    def _art(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.properties['artist'] = values[:value]
      elsif values[:index] == 2
        entity.properties['artist_alternate_spellings'] = values[:value].split(';').map { |a| a.strip }
      elsif values[:index] == 3
        entity.label = values[:value]
      elsif values[:index] == 4
        entity.properties['description'] = values[:value]
      elsif values[:index] == 5 && !values[:value].nil?
        entity.properties['alternate_spellings'] = values[:value].split(';').map { |a| a.strip }
      elsif values[:index] == 5 && values[:value].nil?
        entity.properties['alternate_spellings'] = []
      elsif values[:index] == 6
        entity.properties['owner_location_accession_number_contemporaneous'] = values[:value]
      elsif values[:index] == 7
        entity.properties['owner_location_accession_number_current'] = values[:value]
      elsif values[:index] == 8
        entity.properties['notes'] = values[:value]
      end
      entity
    end

    # updated
    def _translating(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.label = values[:value]
      elsif values[:index] == 2
        entity.properties['author'] = values[:value]
      elsif values[:index] == 3
        entity.properties['translated_into'] = values[:value]
      elsif values[:index] == 4
        entity.properties['translator'] = values[:value]
      elsif values[:index] == 5
        entity.properties['translated_title'] = values[:value]
      elsif values[:index] == 6
        entity.properties['comments'] = values[:value]
      end
      entity
    end

    # updated
    def _writing(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.label = values[:value]
      elsif values[:index] == 2
        entity.properties['date'] = values[:value]
      elsif values[:index] == 3
        entity.properties['proposal'] = values[:value]
      elsif values[:index] == 4
        entity.properties['notes'] = values[:value]
      elsif values[:index] == 5
        entity.properties['beckett_digital_manuscript_project'] = values[:value]
      end
      entity
    end

    # updated
    def _event(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.label = values[:value]
      elsif values[:index] == 2
        entity.properties['description'] = values[:value]
      elsif values[:index] == 3
        entity.properties['date'] = values[:value]
      end
      entity
    end

    def _music(values)
      entity = values[:entity]
      entity.properties['links'] = entity.properties['links'].nil? ? [] : entity.properties['links']
      if values[:index] == 5
	 entity.properties['description'] = ''
      end
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1 && !values[:value].nil?
        entity.properties['composer'] = values[:value]
      elsif values[:index] == 1 && values[:value].nil?
        entity.properties['composer'] = ''
      elsif values[:index] == 2
        entity.label = values[:value]
      elsif values[:index] == 3 && !values[:value].nil?
        entity.properties['alternative_titles'] = values[:value].split(';').map { |a| a.strip }
      elsif values[:index] == 3 && values[:value].nil?
        entity.properties['alternative_titles'] = []
      elsif values[:index] == 4 && !values[:value].nil?
        entity.properties['performed_by'] = values[:value]
      elsif values[:index] == 4 && values[:value].nil?
        entity.properties['performed_by'] = ''
      elsif values[:index] == 5 && !values[:value].nil?
        entity.properties['description'] = values[:value]
      elsif values[:index] == 5 && values[:value].nil?
        entity.properties['description'] = ''
      elsif values[:index] == 6 && !values[:value].nil?
        entity.properties['notes'] = values[:value]
      elsif values[:index] == 6 && values[:value].nil?
        entity.properties['notes'] = ''
      end
      entity
    end

    # updated
    def _music_old(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.properties['composer'] = values[:value]
      elsif values[:index] == 2
        entity.label = values[:value]
      elsif values[:index] == 3
        entity.properties['alternative_titles'] = values[:value].split(';').map { |a| a.strip }
      elsif values[:index] == 4
        entity.properties['performed_by'] = values[:value]
      elsif values[:index] == 5
        entity.properties['description'] = values[:value]
      elsif values[:index] == 6
        entity.properties['notes'] = values[:value]
      end
      entity
    end

    # updated
    def _publication(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.label = values[:value]
      elsif values[:index] == 2
        entity.properties['author'] = values[:value]
      elsif values[:index] == 3
        entity.properties['translator'] = values[:value]
      elsif values[:index] == 4
	entity.properties['publication_information'] = values[:value]
      elsif values[:index] == 5
        entity.properties['notes'] = values[:value]
      elsif values[:index] == 5
        entity.properties['notes'] = values[:value]
      end
      entity
    end
end

# attendance: 'event_type', 'alternative_spellings', 'place_date', 'performed_by', 'attended_with'
# person: 'last_name', 'first_name', 'life_dates', 'description', 'profile', 'alternate_names_spellings', 'links', 'media'
# place: 'links'

# Entity.all.each do |e|
#   if e.properties && e.properties['alternate_names_spellings']
#     alts = e.properties['alternate_names_spellings']
#     # e.properties['alternate_names_spellings'] = []
#     # alts.each do |a|
#     #   new_alts = alts.split(';')
#     #   new_alts.each { |na| e.properties['alternate_name_spellings'].push(na.strip!) }
#     # end
#     p e.properties['alternate_names_spellings']
#     e.save
#   end
# end

# Entity.all.each do |e|
#   if e.properties && e.properties['alternate_names_spellings']
#     alts = e.properties['alternate_names_spellings']
#     # e.properties['alternate_names_spellings'] = []
#     # alts.each do |a|
#     #   new_alts = alts.split(';')
#     #   new_alts.each { |na| e.properties['alternate_name_spellings'].push(na.strip!) }
#     # end
#     p e.properties['alternate_names_spellings']
#     e.save
#   end
# end