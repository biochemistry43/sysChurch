# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
 ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
   inflect.irregular 'persona', 'personas'
   inflect.irregular 'usuario', 'usuarios'
   inflect.irregular 'tipoUsuario', 'tipoUsuarios'
   inflect.irregular 'articulo', 'articulos'
   inflect.irregular 'catArticulo', 'catArticulos'
   inflect.irregular 'perdida', 'perdidas'
   inflect.irregular 'proveedor', 'proveedores'
   inflect.irregular 'venta', 'ventas'
   inflect.irregular 'gasto', 'gastos'
   inflect.irregular 'inventario', 'inventario'
   inflect.irregular 'entradainventario', 'entradasinventario'
   inflect.irregular 'MovimientoCajaSucursal', 'movimientoscajasucursal'
#   inflect.uncountable %w( fish sheep )
 end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end
