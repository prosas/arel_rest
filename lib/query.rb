require "active_support/concern"

module ArelRest
	module Query
		extend ActiveSupport::Concern
		included do
	    def self.filter(query)
	    	where(ArelRest::Parser.parse_filter_to_arel(query))
	    end
	  end
	end
end