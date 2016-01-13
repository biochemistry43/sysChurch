class Entradainventario < ActiveRecord::Base
	belongs_to :proveedor
	belongs_to :articulo
end
