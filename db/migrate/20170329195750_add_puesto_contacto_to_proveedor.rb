class AddPuestoContactoToProveedor < ActiveRecord::Migration
  def change
    add_column :proveedores, :puesto_contacto, :string
  end
end
