# ActsAsLinkable
  module Acts #:nodoc:
    module Linkable #:nodoc:

      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_linkable
          has_many :links, :as => :linkable, :dependent => :destroy, :order => 'created_at ASC'
          include Acts::Linkable::InstanceMethods
          extend Acts::Linkable::SingletonMethods
        end
      end
      
      # This module contains class methods
      module SingletonMethods
        # Helper method to lookup for links for a given object.
        # This method is equivalent to obj.links.
        def find_links_for(obj)
          linkable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
         
          Link.find(:all,
            :conditions => ["linkable_source = ? and linkable_source_type = ?", obj.id, linkable],
            :order => "created_at DESC"
          )
        end
        
        # Helper class method to lookup comments for
        # the mixin commentable type written by a given user.  
        # This method is NOT equivalent to Comment.find_comments_for_user
        def find_links_by_user(user) 
          linkable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          
          Link.find(:all,
            :conditions => ["user_id = ? and linkable_source_type = ?", user.id, linkable],
            :order => "created_at DESC"
          )
        end
      end
      
      # This module contains instance methods
      module InstanceMethods
      
     
        def incomming_links
          Link.find(:all,:conditions=>["target_type = ? and target_id = ?",self.class.name, self.id ])
        end
        
        #returns a collection of object to which this is linked
        def linked
            ret = []
            self.links.inject(ret){|arr , link| arr << link.target}
            self.incomming_links.inject(ret){|arr , link| arr << link.source}
            ret
        end
          
        # Helper method that defaults the submitted time.
        def add_link(target)
          link = Link.new
          link.target_type = target.class.to_s
          link.target_id = target.id
          #adding a link to the link collection should set the polymorphic assosication
          links << link
          link
        end
      end
      
    end
  end

