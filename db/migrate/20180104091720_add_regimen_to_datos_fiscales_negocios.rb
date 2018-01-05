class AddRegimenToDatosFiscalesNegocios < ActiveRecord::Migration
  def change
    add_column :datos_fiscales_negocios, :regimen_fiscal, :string
  end
end
