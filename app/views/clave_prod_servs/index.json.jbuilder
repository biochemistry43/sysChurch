json.array!(@clave_prod_servs) do |clave_prod_serv|
  json.extract! clave_prod_serv, :id, :clave, :nombre
  json.url clave_prod_serv_url(clave_prod_serv, format: :json)
end
