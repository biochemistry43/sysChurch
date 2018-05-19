class AddAtributosToFacturaRecurrentes < ActiveRecord::Migration
  def change
    add_column :factura_recurrentes, :fecha_inicio, :date
    add_reference :factura_recurrentes, :uso_cfdi, index: true, foreign_key: true
    add_column :factura_recurrentes, :frecuencia_num, :integer
    add_column :factura_recurrentes, :frecuencia_tiempo, :string
    add_column :factura_recurrentes, :duracion, :string
    add_column :factura_recurrentes, :total, :decimal
  end
end
