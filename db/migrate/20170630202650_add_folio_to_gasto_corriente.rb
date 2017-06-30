class AddFolioToGastoCorriente < ActiveRecord::Migration
  def change
    add_column :gasto_corrientes, :folio_gasto, :string
  end
end
