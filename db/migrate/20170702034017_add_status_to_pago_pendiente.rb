class AddStatusToPagoPendiente < ActiveRecord::Migration
  def change
    add_column :pago_pendientes, :status, :string
  end
end
