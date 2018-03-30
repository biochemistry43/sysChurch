class AddImpuestoToArticulos < ActiveRecord::Migration
  def change
    add_reference :articulos, :impuesto, index: true, foreign_key: true
  end
end
