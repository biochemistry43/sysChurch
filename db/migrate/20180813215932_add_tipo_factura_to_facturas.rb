class AddTipoFacturaToFacturas < ActiveRecord::Migration
  def change
    add_column :facturas, :tipo_factura, :string
  end
end
