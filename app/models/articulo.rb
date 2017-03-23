class Articulo < ActiveRecord::Base
	mount_uploader :fotoProducto, FotoProductoUploader
	belongs_to :cat_articulo
	belongs_to :negocio
	belongs_to :sucursal
	belongs_to :marca_producto
	belongs_to :presentacion_producto

	validates :clave, :nombre, :precioCompra, :precioVenta, :presence => { message: "No puede dejarse vacío este campo" }
	validates :precioCompra, :precioVenta, :stock, :existencia, :numericality => { message: "Campo numérico", greater_than: 1}
    validates :clave, :nombre, uniqueness: { scope: :sucursal_id, message: "Ya existe este registro en la base de datos" }
end
