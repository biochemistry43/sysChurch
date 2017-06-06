class AddCatCompraCanceladaToCompraCancelada < ActiveRecord::Migration
  def change
  	remove_column :compra_canceladas, :cat_compra_cancelada, :integer
  	add_column :compra_canceladas, :cat_compra_cancelada_id, :integer
  end
end
