class Category
  include Mongoid::Document
  field :name, type: String
  embeds_many :labels
  index({ name: 1 }, { unique: true, name: 'unique_name'})
end
