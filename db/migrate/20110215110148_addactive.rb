class Addactive < ActiveRecord::Migration
  def self.up
    add_column :users,:status , :boolean
  end

  def self.down
  end
end
