class AddNegocioToCompraCancelada < ActiveRecord::Migration
  def change
    add_column :compra_canceladas, :negocio_id, :integer
    add_column :compra_canceladas, :sucursal_id, :integer
  end
end
