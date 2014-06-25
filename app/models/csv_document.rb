class CsvDocument
  include Mongoid::Document
  field :date_submitted, type: DateTime
  field :document_digest, type: String
  index({ document_digest: 1 }, { unique: true, name: 'unique_document'})

  def self.save_document(date, digest)
    document = CsvDocument.new( date_submitted: date, document_digest: digest )
    document.save
    document
  end

end
