class Addgender < ActiveRecord::Migration
  def self.up
    
    add_column :users,:gender, :string, :limit => 1

    
  end

  def self.down
  end
end
