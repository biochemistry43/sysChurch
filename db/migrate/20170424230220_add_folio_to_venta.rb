class AddFolioToVenta < ActiveRecord::Migration
  def change
    add_column :ventas, :folio, :string
    add_column :ventas, :consecutivo, :int
  end
end
