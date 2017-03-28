class AddFieldsToProveedor < ActiveRecord::Migration
  def change
    add_column :proveedores, :limite_credito, :decimal
    add_column :proveedores, :compra_minima_mensual, :decimal
    add_column :proveedores, :fecha_alta, :date
    add_column :proveedores, :pagina_web, :string
    add_column :proveedores, :observaciones, :text
    add_column :proveedores, :saldo_deuda, :decimal
  end
end
