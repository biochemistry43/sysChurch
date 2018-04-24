class AddRutaStorageToFacturas < ActiveRecord::Migration
  def change
    add_column :facturas, :ruta_storage, :string
  end
end
