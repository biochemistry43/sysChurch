class Articulo < ActiveRecord::Base
	mount_uploader :fotoProducto, FotoProductoUploader
	belongs_to :cat_articulo
	belongs_to :negocio
	belongs_to :sucursal

	validates :clave, :nombre, :precioCompra, :precioVenta, :presence => { message: "No puede dejarse vacío este campo" }
	validates :cat_articulo_id, :presence => { message: "Debe elegir alguna opción"}
	validates :precioCompra, :precioVenta, :numericality => { message: "Campo numérico", greater_than: 1}
    validates :clave, :nombre, uniqueness: { message: "Ya existe este registro en la base de datos" }
end
