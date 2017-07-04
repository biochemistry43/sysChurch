class RemoveGastoCorrienteFromPagoPendiente < ActiveRecord::Migration
  def change
    remove_column :pago_pendientes, :gasto_corriente_id, :integer
  end
end
