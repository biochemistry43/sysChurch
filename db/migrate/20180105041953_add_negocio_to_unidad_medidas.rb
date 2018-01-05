class AddNegocioToUnidadMedidas < ActiveRecord::Migration
  def change
    add_reference :unidad_medidas, :negocio, index: true, foreign_key: true
  end
end
