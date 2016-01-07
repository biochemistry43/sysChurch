class ChangeNameOfColumnsTperdidas < ActiveRecord::Migration
  def change
  	rename_column :perdidas, :categoriaPerdida_id, :categoria_perdida_id
  	rename_column :perdidas, :catArticulo_id, :cat_articulo_id
  end
end
