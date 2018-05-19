class RemoveDireccionFsicalToDatosFiscalesClientes < ActiveRecord::Migration
  def change
    remove_column :datos_fiscales_clientes, :calle, :string
    remove_column :datos_fiscales_clientes, :numExterior, :string
    remove_column :datos_fiscales_clientes, :numInterior, :string
    remove_column :datos_fiscales_clientes, :colonia, :string
    remove_column :datos_fiscales_clientes, :codigo_postal, :string
    remove_column :datos_fiscales_clientes, :municipio, :string
    remove_column :datos_fiscales_clientes, :delegacion, :string
    remove_column :datos_fiscales_clientes, :estado, :string
    remove_column :datos_fiscales_clientes, :email, :string
  end
end
