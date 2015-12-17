class CambiaNombreColumnaTipoUsuarioEnTablaUsuario < ActiveRecord::Migration
  def change
  	rename_column :usuarios, :tipoUsuario_id, :tipo_usuario_id
  end
end
