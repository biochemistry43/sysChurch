class AddCamposToDatosFiscalesNegocios < ActiveRecord::Migration
  def change
    add_column :datos_fiscales_negocios, :localidad, :string
    add_column :datos_fiscales_negocios, :referencia, :text
  end
end
