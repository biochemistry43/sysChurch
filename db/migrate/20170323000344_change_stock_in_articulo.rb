class ChangeStockInArticulo < ActiveRecord::Migration
  def change
  	change_table :articulos do |t|
      t.change :stock, :decimal
    end
  end
end
