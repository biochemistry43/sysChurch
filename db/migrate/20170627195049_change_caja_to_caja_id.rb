class ChangeCajaToCajaId < ActiveRecord::Migration
  def change
  	rename_column :ventas, :caja, :caja_id
  end
end
