class RemoveDireccionFromNegocio < ActiveRecord::Migration
  def change
    remove_column :negocios, :direccion, :string
    add_column :negocios, :calle, :string
    add_column :negocios, :numExterior, :string
    add_column :negocios, :numInterior, :string
    add_column :negocios, :colonia, :string
    add_column :negocios, :codigo_postal, :string
    add_column :negocios, :municipio, :string
    add_column :negocios, :delegacion, :string
    add_column :negocios, :estado, :string
    add_column :negocios, :email, :string
  end
end
