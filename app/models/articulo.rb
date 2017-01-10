class Articulo < ActiveRecord::Base
	mount_uploader :fotoProducto, FotoProductoUploader
	belongs_to :cat_articulo
end
