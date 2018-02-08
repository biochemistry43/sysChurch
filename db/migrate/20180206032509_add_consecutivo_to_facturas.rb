class AddConsecutivoToFacturas < ActiveRecord::Migration
  def change
    add_column :facturas, :consecutivo, :integer
  end
end
