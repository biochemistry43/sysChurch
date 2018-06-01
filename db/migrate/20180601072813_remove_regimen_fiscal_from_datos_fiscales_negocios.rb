class RemoveRegimenFiscalFromDatosFiscalesNegocios < ActiveRecord::Migration
  def change
    remove_column :datos_fiscales_negocios, :regimen_fiscal, :string
  end
end
