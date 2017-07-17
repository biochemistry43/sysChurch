class AddNegocioToCajaSucursal < ActiveRecord::Migration
  def change
    add_column :caja_sucursals, :negocio_id, :integer
  end
end
