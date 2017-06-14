class AddRazonEdicionToHistorialEdicionCompra < ActiveRecord::Migration
  def change
    add_column :historial_ediciones_compras, :razon_edicion, :text
  end
end
