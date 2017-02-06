class AddNombreColumnaToCampoFormaPagos < ActiveRecord::Migration
  def change
    add_column :campo_forma_pagos, :nombrecampo, :string
  end
end
