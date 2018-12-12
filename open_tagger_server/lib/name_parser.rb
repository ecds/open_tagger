#
# A silly wrapper to use Python's `nameparser` library.
#
module NameParser
  #
  # Method to return symbolized hash of parsed name using Python's `nameparser` library.
  #
  # @param [String] name A name to parse.
  #
  # @return [Hash] Parsed name with symbolized keys.
  #
  def self.parse(name)
    include JSON
    pyscript = 'lib/names.py'
    JSON.parse(`python #{pyscript} "#{name}"`).symbolize_keys
  end
end
