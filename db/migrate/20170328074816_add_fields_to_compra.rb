class AddFieldsToCompra < ActiveRecord::Migration
  def change
    add_column :compras, :periodo_plazo, :string
    add_column :compras, :fecha_limite_pago, :date
  end
end
