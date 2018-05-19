json.array!(@metodo_pagos) do |metodo_pago|
  json.extract! metodo_pago, :id, :clave, :descripcion
  json.url metodo_pago_url(metodo_pago, format: :json)
end
