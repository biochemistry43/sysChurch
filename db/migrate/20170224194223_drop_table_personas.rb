class DropTablePersonas < ActiveRecord::Migration
  def change
  	drop_table :personas
  end
end
