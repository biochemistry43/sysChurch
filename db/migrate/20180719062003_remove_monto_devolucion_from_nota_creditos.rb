class RemoveMontoDevolucionFromNotaCreditos < ActiveRecord::Migration
  def change
    remove_column :nota_creditos, :monto_devolucion, :decimal
    remove_column :nota_creditos, :motivo, :string
  end
end
