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
    return redirect_to :back, flash: {error: 'No file has been selected.'} if params['csv_file'].nil?

    uploaded_file = params['csv_file'].read

    rows = CSV.parse(uploaded_file, :headers => true, :header_converters => :symbol, :converters => :all, :col_sep => ';')

    process_rows(rows)

    #Select only the rows that have a credit or a debit and map them to a json object
    json_data = rows.select { |row| is_not_nil(row[2]) || is_not_nil(row[3]) }.map { |row| row.to_hash }

    directory = 'public/data'

    # create the file path
    path = File.join(directory, 'test_json.txt')

    FileUtils.mkpath File.dirname(path)

    # write the file
    File.open(path, 'wb') { |f| f.write(JSON.pretty_generate(json_data)) }

    redirect_to :back, flash: {success: 'File has been uploaded successfuly'}
  end

  def process_rows(rows)
    rows.each_cons(2) do |curr_row, next_row|
      assert curr_row
      curr_row[0] = Date.parse(curr_row[0]).strftime('%Y-%m-%d')
      next_row[0] = curr_row[0] if next_row[0].nil? #every statement must contain a valid date
    end
  end

  def assert(row)
    begin
      assert_date row[0]
    rescue
      raise InvalidStatementError, 'The following statement does not contain a valid date: ' + row.to_hash.to_s
    end
  end

  def assert_date(str)
    Date.parse(str)
  end

  def is_not_nil(str)
    true unless str.nil?
  end

end

