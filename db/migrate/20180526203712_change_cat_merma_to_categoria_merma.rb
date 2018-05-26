class ChangeCatMermaToCategoriaMerma < ActiveRecord::Migration
  def change
  	rename_column :mermas, :cat_merma_id, :categoria_merma_id
  end
end
