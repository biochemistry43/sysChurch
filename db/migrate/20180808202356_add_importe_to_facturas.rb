class AddImporteToFacturas < ActiveRecord::Migration
  def change
    add_column :facturas, :monto, :decimal
  end
end
