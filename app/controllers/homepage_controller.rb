require 'fileutils'
require 'csv'
require 'json'
# require "fastercsv"

class HomepageController < ApplicationController

  # require 'csv'
  # require 'json'
  #
  # csv_string = CSV.generate do |csv|
  #   JSON.parse(File.open("foo.json").read).each do |hash|
  #     csv << hash.values
  #   end
  # end

  def index
    render layout: 'homepage'
  end

  def upload_file
    uploaded_file = params['csv_file'].read

    json_data = CSV.parse(uploaded_file, :headers => true, :header_converters => :symbol, :converters => :all).map { |row| row.to_hash }

    directory = 'public/data'

    # create the file path
    path = File.join(directory, 'test_json.txt')

    FileUtils.mkpath File.dirname(path)

    # write the file
    File.open(path, 'wb') { |f| f.write(JSON.pretty_generate(json_data)) }

    redirect_to :back, flash: {success: 'File has been uploaded successfuly'}
  end

end

