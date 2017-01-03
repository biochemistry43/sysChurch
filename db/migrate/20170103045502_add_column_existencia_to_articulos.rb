class AddColumnExistenciaToArticulos < ActiveRecord::Migration
  def change
    add_column :articulos, :existencia, :decimal
  end
end
