json.array!(@clientes) do |cliente|
  json.extract! cliente, :nombre, :direccionCalle, :direccionNumeroExt, :direccionNumeroInt, :direccionColonia, :telefono1
  json.url cliente_url(cliente, format: :json)
end