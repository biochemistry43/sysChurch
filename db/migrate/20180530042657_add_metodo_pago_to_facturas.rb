class AddMetodoPagoToFacturas < ActiveRecord::Migration
  def change
    add_column :facturas, :cve_metodo_pagoSAT, :string
  end
end
