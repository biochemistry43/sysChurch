class AddFoliofiscalToFacturas < ActiveRecord::Migration
  def change
    add_column :facturas, :folio_fiscal, :string
  end
end
