class CambiarColumnaToArticulo < ActiveRecord::Migration
  def change
  	rename_column :articulos, :sucursal, :suc_elegida
  end
end
