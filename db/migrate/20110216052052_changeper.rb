class Changeper < ActiveRecord::Migration
  def self.up
    
    rename_column :users, :has_permalink, :permalink
    
    
    
  end

  def self.down
  end
end
