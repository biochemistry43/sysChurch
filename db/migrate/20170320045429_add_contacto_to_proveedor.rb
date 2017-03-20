class AddContactoToProveedor < ActiveRecord::Migration
  def change
    add_column :proveedores, :nombreContacto, :string
    add_column :proveedores, :telefonoContacto, :string
    add_column :proveedores, :emailContacto, :string
    add_column :proveedores, :celularContacto, :string
  end
end
