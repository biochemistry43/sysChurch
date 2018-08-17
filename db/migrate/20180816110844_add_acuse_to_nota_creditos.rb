class AddAcuseToNotaCreditos < ActiveRecord::Migration
  def change
    add_reference :nota_creditos, :acuse_cancelacion, index: true, foreign_key: true
  end
end
