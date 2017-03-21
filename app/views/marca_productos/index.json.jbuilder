json.array!(@marca_productos) do |marca_producto|
  json.extract! marca_producto, :id, :nombre
  json.url marca_producto_url(marca_producto, format: :json)
end
