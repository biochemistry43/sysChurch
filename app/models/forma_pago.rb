class FormaPago < ActiveRecord::Base
	belongs_to :user
	has_many :campo_forma_pagos
	has_many :venta_forma_pagos
end
