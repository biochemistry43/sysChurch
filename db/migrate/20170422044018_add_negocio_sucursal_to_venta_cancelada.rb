bundclass AddNegocioSucursalToVentaCancelada < ActiveRecord::Migration
  def change
    add_column :venta_canceladas, :negocio_id, :integer
    add_column :venta_canceladas, :sucursal_id, :integer
  end
end
