class GastoGeneral < ActiveRecord::Base
	belongs_to :gasto
	belongs_to :user
	belongs_to :sucursal
	belongs_to :negocio

    #El proveedor al que pertenece este gasto general puede ser distinto de los proveedores normales de 
    #productos. El proveedor puede ser por ejemplo CFE, el agua, etc.
	belongs_to :proveedor


end
