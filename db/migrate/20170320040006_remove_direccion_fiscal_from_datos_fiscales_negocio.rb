class RemoveDireccionFiscalFromDatosFiscalesNegocio < ActiveRecord::Migration
  def change
    remove_column :datos_fiscales_negocios, :direccionFiscal, :string
    add_column :datos_fiscales_negocios, :calle, :string
    add_column :datos_fiscales_negocios, :numExterior, :string
    add_column :datos_fiscales_negocios, :numInterior, :string
    add_column :datos_fiscales_negocios, :colonia, :string
    add_column :datos_fiscales_negocios, :codigo_postal, :string
    add_column :datos_fiscales_negocios, :municipio, :string
    add_column :datos_fiscales_negocios, :delegacion, :string
    add_column :datos_fiscales_negocios, :estado, :string
    add_column :datos_fiscales_negocios, :email, :string

  end
end
