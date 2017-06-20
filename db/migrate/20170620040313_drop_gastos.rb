class DropGastos < ActiveRecord::Migration
  def change
  	drop_table :gastos
  end
end
