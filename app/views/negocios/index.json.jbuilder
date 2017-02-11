json.array!(@negocios) do |negocio|
  json.extract! negocio, :id, :logo, :nombre, :representante, :direccion, :user_id
  json.url negocio_url(negocio, format: :json)
end
