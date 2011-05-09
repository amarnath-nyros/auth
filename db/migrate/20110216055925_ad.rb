class Ad < ActiveRecord::Migration
  def self.up
    
    
change_column :users, :permalink, :bigint
    
    
  end

  def self.down
  end
end
