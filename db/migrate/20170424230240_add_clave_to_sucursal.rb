class AddClaveToSucursal < ActiveRecord::Migration
  def change
    add_column :sucursals, :clave, :string
  end
end
