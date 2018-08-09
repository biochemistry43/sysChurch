class RemoveVentaFromFacturas < ActiveRecord::Migration
  def change
    remove_reference :facturas, :venta, index: true, foreign_key: true
  end
end
