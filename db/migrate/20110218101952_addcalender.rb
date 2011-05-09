class Addcalender < ActiveRecord::Migration
  def self.up
    
     add_column :users,:dob , :string
  end

  def self.down
  end
end
