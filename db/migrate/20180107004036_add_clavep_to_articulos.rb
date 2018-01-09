class AddClavepToArticulos < ActiveRecord::Migration
  def change
    add_reference :articulos, :clave_prod_serv, index: true, foreign_key: true
  end
end
