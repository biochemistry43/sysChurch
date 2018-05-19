class AddCerKeyToDatosFiscalesNegocios < ActiveRecord::Migration
  def change
    add_column :datos_fiscales_negocios, :path_cer, :string
    add_column :datos_fiscales_negocios, :path_key, :string
    add_column :datos_fiscales_negocios, :password, :string
  end
end
