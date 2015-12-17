json.array!(@personas) do |persona|
  json.extract! persona, :id, :nombre, :telefono1, :telefono2, :email, :direccion, :cargo
  json.url persona_url(persona, format: :json)
end
