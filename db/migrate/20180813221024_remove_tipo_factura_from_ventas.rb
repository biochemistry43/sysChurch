class RemoveTipoFacturaFromVentas < ActiveRecord::Migration
  def change
    remove_column :ventas, :tipo_factura, :string
  end
end
