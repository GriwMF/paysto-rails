require 'rails'
require 'paysto/version'

module Paysto
  if defined?(Rails)
    require 'paysto/base'
    require 'paysto/controller'
  else
    raise 'Rails framework not found.'
  end
end
