class AddAcuseToFacturas < ActiveRecord::Migration
  def change
    add_reference :facturas, :acuse_cancelacion, index: true, foreign_key: true
  end
end
