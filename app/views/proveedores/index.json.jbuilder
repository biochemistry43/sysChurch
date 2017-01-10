json.array!(@proveedores) do |proveedor|
  json.extract! proveedor, :id, :nombre, :telefono, :email
  json.url proveedor_url(proveedor, format: :json)
end
