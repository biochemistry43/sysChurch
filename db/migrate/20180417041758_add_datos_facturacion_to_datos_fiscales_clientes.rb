class AddDatosFacturacionToDatosFiscalesClientes < ActiveRecord::Migration
  def change
    add_column :datos_fiscales_clientes, :calle, :string
    add_column :datos_fiscales_clientes, :numExterior, :string
    add_column :datos_fiscales_clientes, :numInterior, :string
    add_column :datos_fiscales_clientes, :colonia, :string
    add_column :datos_fiscales_clientes, :codigo_postal, :string
    add_column :datos_fiscales_clientes, :municipio, :string
    add_column :datos_fiscales_clientes, :delegacion, :string
    add_column :datos_fiscales_clientes, :estado, :string
    add_column :datos_fiscales_clientes, :email, :string
    add_column :datos_fiscales_clientes, :localidad, :string
  end
end
