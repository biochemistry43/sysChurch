class Articulo < ActiveRecord::Base
	mount_uploader :fotoProducto, FotoProductoUploader
	belongs_to :cat_articulo
	belongs_to :negocio
	belongs_to :sucursal
end
