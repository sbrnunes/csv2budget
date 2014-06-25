class Statement
  include Mongoid::Document
  field :data, type: Hash

  def self.create_from_csv_with_labels(rows, categories)
    rows.select { |row| !(row[2].nil? and row[3].nil?) }.map do |row|
      statement = Statement.new(
          data: {
              :date => Date.parse(row[0]).strftime('%Y-%m-%d'),
              :description => row[1],
              :debit => row[2],
              :credit => row[3],
              :labels => categories.select { |category| category[:labels].any? { |label| row[1].include? label[:name] } }.
                  map { |category| category[:name] }
          })
      statement.save
      statement
    end
  end
end
