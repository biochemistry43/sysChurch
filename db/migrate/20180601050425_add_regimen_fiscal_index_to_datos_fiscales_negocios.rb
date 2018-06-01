class AddRegimenFiscalIndexToDatosFiscalesNegocios < ActiveRecord::Migration
  def change
    add_reference :datos_fiscales_negocios, :regimen_fiscal, index: true, foreign_key: true
  end
end
