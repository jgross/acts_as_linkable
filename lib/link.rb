class Link < ActiveRecord::Base
  belongs_to :linkable, :polymorphic => true
  after_create :log_create
  
  def to_icon
    "/images/icons/link.gif"
  end
  def target
    self.target_type.constantize.find(target_id)
  end
  
  def source
   self.linkable_type.constantize.find(linkable_id)
  end
  # NOTE: Links belong to a member
  belongs_to :member
  
  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  def self.find_links_by_member(member)
    find(:all,
      :conditions => ["member_id = ?", member.id],
      :order => "created_at DESC"
    )
  end
  
  # Helper class method to look up all comments for 
  # commentable class name and commentable id.
  def self.find_links_for_linkable(linkable_str, linkable_id)
    find(:all,
      :conditions => ["linkable_type = ? and linkable_id = ?", linkable_str, linkable_id],
      :order => "created_at DESC"
    )
  end

  # Helper class method to look up a linkable object
  # given the commentable class name and id 
  def self.find_linkable(linkable_str, linkable_id)
    linkable_str.constantize.find(linkable_id)
  end
  
  def log_create
   puts "link observer"
   log_item = Activity.new
   log_item.model_type = "Link"
   log_item.model_id = self.id
   log_item.action = "A new #{linkable_type} - #{target_type} link was created"
   log_item.description = "between #{source.title} and #{target.title}"
   log_item.save
   log_item
  end
end