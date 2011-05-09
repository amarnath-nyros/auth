class Addpermalink < ActiveRecord::Migration
  def self.up
    
    
add_column :users,:has_permalink , :integer
      

    
    
    
    
  end

  def self.down
    
  end
end
