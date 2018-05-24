json.array!(@clientes) do |cliente|
  json.extract! cliente, :id, :nombre, :direccionCalle, :direccionNumeroExt, :direccionNumeroInt, :direccionColonia, :telefono1, :email, :ape_pat, :ape_mat
  json.url cliente_url(cliente, format: :json)
end
