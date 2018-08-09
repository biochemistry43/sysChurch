class AddFactToVentas < ActiveRecord::Migration
  def change
    add_reference :ventas, :factura, index: true, foreign_key: true
    add_column :ventas, :tipo_factura, :string
  end
end
