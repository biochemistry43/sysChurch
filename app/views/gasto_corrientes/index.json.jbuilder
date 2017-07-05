json.array!(@gastos) do |gasto|
  json.extract! gasto, :id, :montoGasto, :fechaGasto, :descripcionGasto, :lugarCompraGasto, :persona_id, :categoria_gasto_id
  json.url gasto_url(gasto, format: :json)
end
