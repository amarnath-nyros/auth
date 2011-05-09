class Addfile < ActiveRecord::Migration
  def self.up
    
      add_column :users,:file , :binary
      add_column :users,:filename , :string
      
    
    
  end

  def self.down
  end
end
