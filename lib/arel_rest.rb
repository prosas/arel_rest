require 'active_record'

module ArelRest
  require_relative 'parser'
  require_relative 'query'
  
  class << self
    attr_accessor :time_zone
  end
end
