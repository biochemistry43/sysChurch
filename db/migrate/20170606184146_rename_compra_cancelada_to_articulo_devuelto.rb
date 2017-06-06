class RenameCompraCanceladaToArticuloDevuelto < ActiveRecord::Migration
  def change
  	rename_table :compra_canceladas, :compra_articulos_devueltos
  end
end
