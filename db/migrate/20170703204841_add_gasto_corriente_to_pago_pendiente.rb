class AddGastoCorrienteToPagoPendiente < ActiveRecord::Migration
  def change
    add_column :pago_pendientes, :gasto_corriente_id, :integer
  end
end
