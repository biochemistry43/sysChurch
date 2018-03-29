class AddImpuestoToArticulos < ActiveRecord::Migration
  def change
    add_reference :articulos, :impueto, index: true, foreign_key: true
  end
end
