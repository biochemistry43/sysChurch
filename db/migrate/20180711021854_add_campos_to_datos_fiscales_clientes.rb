class AddCamposToDatosFiscalesClientes < ActiveRecord::Migration
  def change
    add_column :datos_fiscales_clientes, :pais, :string
    add_column :datos_fiscales_clientes, :referencia, :text
  end
end
