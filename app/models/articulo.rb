class Articulo < ActiveRecord::Base
	mount_uploader :fotoProducto, FotoProductoUploader
	belongs_to :cat_articulo
	belongs_to :negocio
	belongs_to :sucursal
	belongs_to :marca_producto
	belongs_to :presentacion_producto
	has_many :entrada_almacens
	has_many :detalle_compras
	has_many :venta_canceladas
	has_many :compra_articulos_devueltos
	has_many :mermas


	validates :clave, :nombre, :precioCompra, :precioVenta, :presence => { message: "No puede dejarse vacío este campo" }
	validates :precioCompra, :precioVenta, :stock, numericality: { message: "campo numérico debe ser mayor que cero " }
	validates :sucursal_id, :presence => true
	validates :negocio_id, :presence => true
	#validates :precioCompra, :precioVenta, :stock, 
	validates :existencia, numericality: true
    validates :clave, :nombre, uniqueness: { scope: :sucursal_id, message: "Ya existe este registro en la base de datos", :case_sensitive => false }
end