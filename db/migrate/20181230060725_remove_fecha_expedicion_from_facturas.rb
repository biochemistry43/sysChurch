class RemoveFechaExpedicionFromFacturas < ActiveRecord::Migration
  def change
    remove_column :facturas, :fecha_expedicion, :date
  end
end
