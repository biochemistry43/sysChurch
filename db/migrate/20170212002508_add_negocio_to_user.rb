class AddNegocioToUser < ActiveRecord::Migration
  def change
    add_column :users, :negocio_id, :integer
  end
end
