class AddDireccionToDatosFiscalesSucursals < ActiveRecord::Migration
  def change
    add_column :datos_fiscales_sucursals, :calle, :string
    add_column :datos_fiscales_sucursals, :numExt, :integer
    add_column :datos_fiscales_sucursals, :numInt, :integer
    add_column :datos_fiscales_sucursals, :colonia, :string
    add_column :datos_fiscales_sucursals, :localidad, :string
    add_column :datos_fiscales_sucursals, :codigo_postal, :integer
    add_column :datos_fiscales_sucursals, :municipio, :string
    add_column :datos_fiscales_sucursals, :estado, :string
    add_column :datos_fiscales_sucursals, :referencia, :text
  end
end
