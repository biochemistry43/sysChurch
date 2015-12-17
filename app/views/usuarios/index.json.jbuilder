json.array!(@usuarios) do |usuario|
  json.extract! usuario, :id, :nombreUsuario, :contrasena, :persona_id, :tipoUsuario_id
  json.url usuario_url(usuario, format: :json)
end
