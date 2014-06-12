class ApplicationController < ActionController::Base
  include Errors

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def assert_date(date, error_message)
    begin
      Date.parse(date)
    rescue
      raise InvalidStatementError, error_message
    end
  end

  def assert_description(description, error_message)
    raise InvalidStatementError, error_message if description.nil?
  end

  def is_not_nil(str)
    true unless str.nil?
  end

end
