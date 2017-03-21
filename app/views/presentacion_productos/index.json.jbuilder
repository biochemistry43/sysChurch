json.array!(@presentacion_productos) do |presentacion_producto|
  json.extract! presentacion_producto, :id, :nombre
  json.url presentacion_producto_url(presentacion_producto, format: :json)
end
