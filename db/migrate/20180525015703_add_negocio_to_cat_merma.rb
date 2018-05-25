class AddNegocioToCatMerma < ActiveRecord::Migration
  def change
    add_column :cat_mermas, :negocio_id, :integer
  end
end
