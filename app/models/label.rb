class Label
  include Mongoid::Document
  field :name, type: String
  embedded_in :category
  index({ name: 1 }, { unique: true, name: 'unique_name'})
end
