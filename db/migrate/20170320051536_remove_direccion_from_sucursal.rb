class RemoveDireccionFromSucursal < ActiveRecord::Migration
  def change
    remove_column :sucursals, :direccion, :string
    add_column :sucursals, :calle, :string
    add_column :sucursals, :numExterior, :string
    add_column :sucursals, :numInterior, :string
    add_column :sucursals, :colonia, :string
    add_column :sucursals, :codigo_postal, :string
    add_column :sucursals, :municipio, :string
    add_column :sucursals, :delegacion, :string
    add_column :sucursals, :estado, :string
    add_column :sucursals, :email, :string
  end
end
