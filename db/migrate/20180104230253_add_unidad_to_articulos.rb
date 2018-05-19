class AddUnidadToArticulos < ActiveRecord::Migration
  def change
    add_reference :articulos, :unidad_medida, index: true, foreign_key: true
  end
end
