class AddDatosFiscalesToClientes < ActiveRecord::Migration
  def change
    add_column :clientes, :nombreFiscal, :string
    add_column :clientes, :rfc, :string
  end
end
