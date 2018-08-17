class AddAcuseToFacturas < ActiveRecord::Migration
  def change
    add_column :facturas, :ref_acuse_cancelacion, :integer
  end
end
