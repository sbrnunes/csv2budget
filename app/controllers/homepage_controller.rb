require 'fileutils'
require 'csv'
require 'json'
require 'Date'
require 'digest/md5'

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

    # fetch the categories catalog
    categories = Category.all

    # translate each csv row to a statement with labels applied
    statements = Statement.create_from_csv_with_labels(rows, categories)

    # save the document
    CsvDocument.save_document(Time.now, Digest::MD5.hexdigest(statements.map{ |statement| statement.data }.to_s))

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

end

