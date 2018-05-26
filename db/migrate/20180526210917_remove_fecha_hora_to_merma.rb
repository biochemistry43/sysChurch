class RemoveFechaHoraToMerma < ActiveRecord::Migration
  def change
  	remove_column :mermas, :fecha_hora
  end
end
