json.array!(@categoria_gastos) do |categoria_gasto|
  json.extract! categoria_gasto, :id, :nombreCategoria, :descripcionCategoria, :idCategoriaPadre
  json.url categoria_gasto_url(categoria_gasto, format: :json)
end
