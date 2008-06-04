# Include hook code here
require 'acts_as_linkable'
ActiveRecord::Base.send(:include,Acts::Linkable)
