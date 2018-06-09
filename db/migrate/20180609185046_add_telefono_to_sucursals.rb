class AddTelefonoToSucursals < ActiveRecord::Migration
  def change
    add_column :sucursals, :telefono, :string
  end
end
