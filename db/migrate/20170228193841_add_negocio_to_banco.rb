class AddNegocioToBanco < ActiveRecord::Migration
  def change
    add_column :bancos, :negocio_id, :integer
  end
end
