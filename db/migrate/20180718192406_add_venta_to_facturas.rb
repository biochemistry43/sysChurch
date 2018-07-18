class AddVentaToFacturas < ActiveRecord::Migration
  def change
    add_reference :facturas, :venta, index: true, foreign_key: true
  end
end
