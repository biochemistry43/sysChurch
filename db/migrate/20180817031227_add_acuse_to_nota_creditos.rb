class AddAcuseToNotaCreditos < ActiveRecord::Migration
  def change
    add_column :nota_creditos, :ref_acuse_cancelacion, :integer
  end
end
