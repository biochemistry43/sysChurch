class RenameUsuarioIdToPagoProveedor < ActiveRecord::Migration
  def change
  	rename_column :pago_proveedores, :usuario_id, :user_id
  end
end
