class RenameCatMermaToCategoriaMermas < ActiveRecord::Migration
  def change
  	rename_table :cat_mermas, :categoria_mermas
  end
end
