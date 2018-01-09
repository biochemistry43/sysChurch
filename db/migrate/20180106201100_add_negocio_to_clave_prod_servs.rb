class AddNegocioToClaveProdServs < ActiveRecord::Migration
  def change
    add_reference :clave_prod_servs, :negocio, index: true, foreign_key: true
  end
end
