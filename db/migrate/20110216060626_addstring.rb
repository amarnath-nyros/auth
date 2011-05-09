class Addstring < ActiveRecord::Migration
  def self.up
    
    change_column :users, :permalink, :string
    
    
    
  end

  def self.down
  end
end
