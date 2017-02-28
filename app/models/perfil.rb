class Perfil < ActiveRecord::Base
	mount_uploader :foto, FotoProductoUploader
	belongs_to :user
end
