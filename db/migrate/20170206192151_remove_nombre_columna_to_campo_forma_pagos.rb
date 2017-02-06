class RemoveNombreColumnaToCampoFormaPagos < ActiveRecord::Migration
  def change
    remove_column :campo_forma_pagos, :nombreCampo, :string
  end
end
