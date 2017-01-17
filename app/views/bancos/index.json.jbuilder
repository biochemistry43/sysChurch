json.array!(@bancos) do |banco|
  json.extract! banco, :id, :tipoCuenta, :nombreCuenta, :numeroCuenta, :saldoInicial, :fecha, :descripcion
  json.url banco_url(banco, format: :json)
end
