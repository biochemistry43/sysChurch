class Proveedor < ActiveRecord::Base
	 has_many :entradasinventario
	 belongs_to :sucursal
end
