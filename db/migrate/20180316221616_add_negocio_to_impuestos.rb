class AddNegocioToImpuestos < ActiveRecord::Migration
  def change
    add_reference :impuestos, :negocio, index: true, foreign_key: true
  end
end
