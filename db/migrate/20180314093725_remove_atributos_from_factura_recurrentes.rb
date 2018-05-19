class RemoveAtributosFromFacturaRecurrentes < ActiveRecord::Migration
  def change
    remove_column :factura_recurrentes, :fecha_expedicion, :date
    remove_column :factura_recurrentes, :tiempo_recurrente, :integer
    remove_column :factura_recurrentes, :estado_factura, :string
  end
end
