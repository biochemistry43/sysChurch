class AddDatosContactoToNegocios < ActiveRecord::Migration
  def change
    add_column :negocios, :telefono, :string
    add_column :negocios, :pag_web, :string
  end
end
