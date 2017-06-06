class AddDetalleCompraToCompraCancelada < ActiveRecord::Migration
  def change
  	remove_column :compra_canceladas, :detalle_compra, :integer
  	add_column :compra_canceladas, :detalle_compra_id, :integer
  end
end
