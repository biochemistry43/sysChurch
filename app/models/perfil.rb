class Perfil < ActiveRecord::Base
	mount_uploader :foto, FotoProductoUploader
	belongs_to :user

	def nombre_completo
      "#{nombre} #{ape_paterno} #{ape_materno}"
	end
end
