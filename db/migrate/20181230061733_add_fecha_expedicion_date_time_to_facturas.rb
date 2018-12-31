class AddFechaExpedicionDateTimeToFacturas < ActiveRecord::Migration
  def change
    add_column :facturas, :fecha_expedicion, :datetime
  end
end
