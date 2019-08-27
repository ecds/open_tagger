class TypeProperty < ApplicationRecord
  belongs_to :property
  belongs_to :entity_type
end

Entity.by_type('person').each do |p|
  if p.properties.nil?
    p.properties = {}
  end
EntityType.find_by(label: 'person').properties.each do |k|
p.properties[k.key] = p.properties[k] || ''
end
p.save
end