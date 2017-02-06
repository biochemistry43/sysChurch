class AddNombreToCampoFormaPagos < ActiveRecord::Migration
  def change
    add_column :campo_forma_pagos, :nombreCampo, :string
  end
end
