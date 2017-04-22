json.array!(@cat_venta_canceladas) do |cat_venta_cancelada|
  json.extract! cat_venta_cancelada, :id, :clave, :descripcion
  json.url cat_venta_cancelada_url(cat_venta_cancelada, format: :json)
end
