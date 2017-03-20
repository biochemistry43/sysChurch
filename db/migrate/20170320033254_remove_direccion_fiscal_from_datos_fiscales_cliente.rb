class RemoveDireccionFiscalFromDatosFiscalesCliente < ActiveRecord::Migration
  def change
    remove_column :datos_fiscales_clientes, :direccionFiscal, :string
    add_column :datos_fiscales_clientes, :calle, :string
    add_column :datos_fiscales_clientes, :numExterior, :string
    add_column :datos_fiscales_clientes, :numInterior, :string
    add_column :datos_fiscales_clientes, :colonia, :string
    add_column :datos_fiscales_clientes, :codigo_postal, :string
    add_column :datos_fiscales_clientes, :municipio, :string
    add_column :datos_fiscales_clientes, :delegacion, :string
    add_column :datos_fiscales_clientes, :estado, :string
    add_column :datos_fiscales_clientes, :email, :string
  end
end
