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
        range: 'A2:I'
      },
      {
        sheet_id: '1yuQykRVY4S-FQuOg1P-nRQ9C5Ma439e5v9_uVALs2ns',
        type: 'writing',
        range: 'A2:F'
      },
      {
        sheet_id: '1FUAzp9McmDOK8-xIZk-JdSfomxQYmrjGoBNrhYLkZF4',
        type: 'translating',
        range: 'A2:H'
      },
      {
        sheet_id: '1lIYE6gGQcq5mbwilzWqOLJchLrc4iAwH0WMdM53axps',
        type: 'reading',
        range: 'A2:D'
      },
      {
        sheet_id: '1b1J0Gt9NPLsrfXJ-agc2GjCRb-7Upq7w1ddW40dV4i4',
        type: 'attendance',
        range: 'A2:G'
      },
      {
        sheet_id: '13RbWm78OXzNt6AfjvXzY7b6ldIsFtIrBFaw01v9ciQs',
        type: 'public_events',
        range: 'A2:C'
      },
      {
        sheet_id: '1DVByIJWiDNi78yUs81eidPQYAqL9E6ovsCztimwnCTg',
        type: 'works_of_art',
        range: 'A2:G'
      },
      {
        sheet_id: '1fOuJX-w3Tv6ZfK8_d6JRM29PIYaZk7i-_5Qdt3AtSck',
        type: 'music',
        range: 'A2:G'
      },
      {
        sheet_id: '1HeTeJqueJR4TWqgSCMJOgOglLLyYGfKux8YL57OYfg8',
        type: 'publication',
        range: 'A2:F'
      }
    ]
    @people_profiles = '1s_dkTpJJCxs5XOhbH6SwYka317buWLTJDw8GXCqsVx8'
    @orgs_profiles = '1jwgrdOzDVU36pmwNAdhJ2MGR8-IGQa4BZthwDiniy6c'
  end

  def bulk_import
    @sheets.each do |sheet|
      p sheet
      @options[:entity_type] = sheet[:type]
      response = @service.get_spreadsheet(sheet[:sheet_id], ranges: sheet[:range], include_grid_data: true)
      @sheet = response.sheets[0]
      import
    end
    person_profiles
    org_profiles
    label_people
  end

  def import
    @sheet.data[0].row_data.each do |row_data|
      next if !row_data.values[0]
      next if !row_data.values[1]
      entity = Entity.new(entity_type: EntityType.find_or_create_by(label: @options[:entity_type]), properties: {})

      row_data.values.each_with_index do |column, index|
        # p "#{column.text_format_runs} : #{column.formatted_value}"
        value = column.text_format_runs ? format_column(column) : column.formatted_value
        value = value.class == String ? value.tr('"', '').strip : value
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
        when 'works_of_art'
          entity = _art(row_values)
        when 'translating'
          entity = _translating(row_values)
        when 'writing'
          entity = _writing(row_values)
        when 'public_events'
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
      entity.properties['profile'] = row_data.values[1].formatted_value
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

    def _attendance(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.properties['event_type'] = values[:value]
      elsif values[:index] == 2
        entity.label = values[:value]
      elsif values[:index] == 3 && !values[:value].nil?
        entity.properties['alternative_spellings'] = values[:value].split(';').map { |e| e.strip }
      elsif values[:index] == 4
        entity.properties['place_date'] = values[:value]
      elsif values[:index] == 5 && !values[:value].nil?
        entity.properties['performed_by'] = values[:value].split(';').map { |e| e.strip }
      end
      entity
    end

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
      elsif values[:index] == 5 && values[:value] != nil
        # values[:value].split(';').each do |v|
        #   Literal.find_or_create_by(text: v.tr('"', '').strip, entity: entity)
        # end
        entity.properties['alternate_names_spellings'] = values[:value].split(',').map { |e| e.tr('"', '').strip }
      elsif values[:index] == 6
        entity.properties['links'] = [values[:value]]
      end
      entity
    end

    def _organization(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.label = values[:value]
      elsif values[:index] == 2 && values[:value] != nil
        # values[:value].split(';').each do |v|
        #   Literal.find_or_create_by(text: v.tr('"', '').strip, entity: entity)
        # end
        entity.properties['alternate_spellings'] = values[:value].split(',').map {|e| e.tr('"', '').strip}
      elsif values[:index] == 3
        entity.properties['description'] = values[:value]
      end
      entity
    end

    def _place(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.label = values[:value]
      elsif values[:index] == 2
        entity.properties['links'] = values[:value]
      elsif values[:index] == 3
        entity.properties['description'] = values[:value]
      elsif values[:index] == 4 && values[:value] != nil
        # values[:value].split(';').each do |v|
        #   Literal.find_or_create_by(text: v.tr('"', '').strip, entity: entity)
        # end
        entity.properties['alternate_spellings'] = values[:value].split(',').map { |e| e.tr('"', '').strip }
      end
      entity
    end

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
      end
      entity
    end

    def _production(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.label = values[:value]
      elsif values[:index] == 2
        entity.properties['proposal'] = values[:value]
      elsif values[:index] == 3
        entity.properties['response'] = values[:value]
      elsif values[:index] == 4
        entity.properties['reason'] = values[:value]
      elsif values[:index] == 5
        entity.properties['director'] = values[:value]
      elsif values[:index] == 6
        entity.properties['theatre'] = values[:value]
      elsif values[:index] == 7
        entity.properties['city'] = values[:value]
      elsif values[:index] == 8
        entity.properties['date'] = values[:value]
      elsif values[:index] == 9 && !values[:value].nil?
        entity.properties['cast'] = values[:value].split(',').map { |c| { actor: c.split('(')[0].strip, role: c.split('(')[-1].tr(')', '').strip } }
      elsif values[:index] == 10
        entity.properties['notes'] = values[:value]
      elsif values[:index] == 11
        entity.properties['staging_beckett'] = values[:value]
      end
      entity
    end

    def _art(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.properties['artist'] = values[:value]
      elsif values[:index] == 3
        entity.label = values[:value]
      elsif values[:index] == 4 && !values[:value].nil?
        entity.properties['alternative_spellings'] = values[:value].split(',').map { |a| a.strip }
      elsif values[:index] == 5
        entity.properties['location'] = values[:value]
      elsif values[:index] == 6
        entity.properties['owner'] = values[:value]
      end
      entity
    end

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
      end
      entity
    end

    def _event(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.label = values[:value]
      elsif values[:index] == 2
        entity.properties['date'] = values[:value]
      end
      entity
    end

    def _music(values)
      entity = values[:entity]
      if values[:index] == 0
        entity.legacy_pk = values[:value].to_i
      elsif values[:index] == 1
        entity.properties['composer'] = values[:value]
      elsif values[:index] == 2
        entity.label = values[:value]
      elsif values[:index] == 3
        entity.properties['alternative_titles'] = [values[:value]]
      elsif values[:index] == 4
        entity.properties['performed_by'] = [values[:value]]
      elsif values[:index] == 5
        entity.properties['description'] = [values[:value]]
      end
      entity
    end

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
        entity.properties['place'] = values[:value]
      elsif values[:index] == 5
        entity.properties['notes'] = values[:value]
      end
      entity
    end
end
