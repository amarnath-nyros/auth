class Addfck < ActiveRecord::Migration
  def self.up
    add_column :users,:description,:string
   
  end

  def self.down
  end
end
