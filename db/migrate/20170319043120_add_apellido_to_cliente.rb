class AddApellidoToCliente < ActiveRecord::Migration
  def change
    add_column :clientes, :ape_pat, :string
    add_column :clientes, :ape_mat, :string
  end
end
