require 'fileutils'
require 'csv'
require 'json'
require 'Date'

class HomepageController < ApplicationController

  rescue_from InvalidStatementError do |exception|
    redirect_to :back, flash: {error: exception.message}
  end

  def index
    render layout: 'homepage'
  end

  def upload_file
    return redirect_to(:back, flash: {error: 'No file has been selected.'}) if params['csv_file'].nil?

    rows = parse(params['csv_file'])
    consolidate(rows)
    validate(rows)

    labels = find_all_labels

    json_data = rows.select {|row| !(row[2].nil? and row[3].nil?) }.map do |row|
      {
          :date => Date.parse(row[0]).strftime('%Y-%m-%d'),
          :description => row[1],
          :debit => row[2],
          :credit => row[3],
          :labels => labels.select { |label| label[:applied_to].any? { |applied_to| row[1].include? applied_to[:statement_fragment]} }.
              map { |label| label[:name] }
      }
    end

    directory = 'public/data'

    # create the file path
    path = File.join(directory, 'test_json.txt')

    FileUtils.mkpath File.dirname(path)

    # write the file
    File.open(path, 'wb') { |f| f.write(JSON.pretty_generate(json_data)) }

    redirect_to(:back, flash: {success: 'File has been uploaded successfuly'})
  end

  def parse(csv_file)
    CSV.parse(csv_file.read, :headers => true, :header_converters => :symbol, :converters => :all, :col_sep => ';')
  end

  # Iterates over each row, populates all the missing dates and merges related rows (ATM)
  def consolidate(rows)
    rows.each_cons(2) do |curr_row, next_row|
      next_row[0] = curr_row[0] if next_row[0].nil? unless curr_row[0].nil?
      curr_row[1] += ' ' + next_row[1] if next_row[2].nil? and next_row[3].nil? unless curr_row[2].nil? and curr_row[3].nil?
    end
  end

  # Asserts that each row contains all the required data
  def validate(rows)
    rows.each do |row|
      assert_date(row[0], 'The following statement does not contain a valid date: ' + row.to_hash.to_s)
      assert_description(row[1], 'The following statement does not contain a description field: ' + row.to_hash.to_s)
    end
  end

  def find_all_labels
    [{
         name: "Incomes",
         applied_to: [{statement_fragment: "DIMENSION DATA"},{statement_fragment: "EXPENSES"}]
     },
     {
         name: "Expenses",
         applied_to: [{statement_fragment: "VDA"},{statement_fragment: "VDP"}]
     },
     {
         name: "Vodafone",
         applied_to: [{statement_fragment: "VODAFONE"},{statement_fragment: "VDA"}]
     }]
  end

end

