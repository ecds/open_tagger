# Merge duplicate entities
#
# == Parameters:
# options::
#  You can either pass named arguments `discard` and `to.
#    `discard` should be the `id` of the duplicate `:Entity`
#    `to` should be the `id` of the canonical `:Entity`
#
#  Or you can pass a list of `:Struct` objects to "to" and "discard" attributes.
#  The `discard` attribute should be the duplicate `:Entity`.
#  The `to` attribute should be the canonical `:Entity`.
#
#  Example of `:Array` of `:Struct`s:
#
#  ~~~
#  Merger = Struct.new(:discard, :keep)
#  merger = Merger.new(discard: Entity, to: Entity)
#  mergers = [merger]
#  ~~~
#
#  When initilized with an `:Array` of `:Struc`s, the mergers will
#  be executed upon initilization.
#

class Merge
  def initialize(options)
    @options = options
    if options.class == Array
      @mergers = options
      bulk_merge
    else
      @discard = Entity.by_type(options[:type]).find_by(legacy_pk: options[:discard])
      @keep = Entity.by_type(options[:type]).find_by(legacy_pk: options[:keep])
    end
  end

  def bulk_merge
    @mergers.each do |merge|
      @discard = Entity.by_type(merge[:type]).find_by(legacy_pk: merge[:discard])
      @keep = Entity.by_type(merge[:type]).find_by(legacy_pk: merge[:keep])
      merge_entity
    end
  end

  def merge_entity
    # Update tags
    if @discard.letters.present?
      @discard.letters.each do |letter|
        @keep.letters << letter
        doc = Nokogiri::XML(letter.content)
        if doc.content.empty?
          doc = Nokogiri::HTML(letter.content)
        end
        doc.xpath("//#{@discard.entity_type.label}").each do |tag|
          if tag['profile_id'] == @discard.id.to_s
            tag['profile_id'] = @keep.id.to_s
          end
        end
        letter.content = doc.to_xml
        letter.save
        letter.entities_mentioned.delete(@discard)
      end
    end

    # Update other letter associations
    if @discard.places_sent.present?
      @discard.places_sent.each do |letter|
        letter.places_sent << @keep
        letter.places_sent.delete(@discard)
      end
    end

    if @discard.senders.present?
      @form.senders.each do |letter|
        letter.senders << @keep
        letter.senders.delete(@discard)
      end
    end

    if @discard.letters_written_to_place.present?
      @form.letters_written_to_place.each do |letter|
        letter.places_written << @keep
        letter.places_written.delete(@discard)
      end
    end
    if @discard.letters_written_to_person.present?
      @form.letters_written_to_person.each do |letter|
        letter.recipients << @keep
        letter.recipients.delete(@discard)
      end
    end
  end
end