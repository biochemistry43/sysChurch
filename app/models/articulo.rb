class Articulo < ActiveRecord::Base
	mount_uploader :fotoProducto, FotoProductoUploader
	belongs_to :impuesto
	belongs_to :unidad_medida
	belongs_to :clave_prod_serv

	belongs_to :cat_articulo
	belongs_to :negocio
	belongs_to :sucursal
	belongs_to :marca_producto
	belongs_to :presentacion_producto
	has_many :entrada_almacens
	has_many :detalle_compras
	has_many :venta_canceladas
	has_many :compra_articulos_devueltos


	validates :clave, :nombre, :precioCompra, :precioVenta, :unidad_medida_id,:clave_prod_serv_id, :presence => { message: "No puede dejarse vacío este campo" }
	validates :precioCompra, :precioVenta, :stock, numericality: { message: "campo numérico debe ser mayor que cero " }
	validates :sucursal_id, :presence => true
	validates :negocio_id, :presence => true
	#validates :precioCompra, :precioVenta, :stock,
	validates :existencia, numericality: true
    validates :clave, :nombre, uniqueness: { scope: :sucursal_id, message: "Ya existe este registro en la base de datos", :case_sensitive => false }
end
