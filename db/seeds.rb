# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'faker'

# Creé dos usuarios desde el formulario del sistema con los correos:
#   leinadlm95@gmail.com
#   michaelsking1993@gmail.com
# Puedes acceder al sistema con la contraseña 123456

usuario_michael = User.find(30)
usuario_michael.update(role: "root")

# Tu perfil (michaelsking1993@gmail.com)
usuario_michael.create_perfil!(
  nombre: Faker::Name.first_name,
  ape_materno: Faker::Name.middle_name,
  ape_paterno: Faker::Name.last_name,
  dir_calle: Faker::Address.street_name,
  dir_numero_ext: Faker::Address.building_number,
  dir_numero_int: Faker::Address.secondary_address,
  dir_colonia: Faker::Address.street_name ,
  dir_municipio: Faker::Address.street_name,
  dir_delegacion: Faker::Address.street_name,
  dir_estado: Faker::Address.state,
  dir_cp: Faker::Address.postcode
  # foto: Faker::Avatar.image(size: "150x150", format: "jpg")
)

# # Negocios y su dirección fiscal ( hay quienes manejan multiples direcciones. Ummm...lo pensaré, pero o creo)
nombre_del_negocio = Faker::Company.name
negocio = Negocio.create!(
  logo: Faker::Company.logo,
  nombre: nombre_del_negocio,
  representante: Faker::Name.name_with_middle,
  calle: Faker::Address.street_name,
  numExterior: Faker::Address.building_number,
  numInterior: Faker::Address.secondary_address,
  codigo_postal: Faker::Address.postcode,
  colonia: Faker::Address.street_name,
  municipio: Faker::Address.street_name,
  delegacion: Faker::Address.street_name,
  estado: Faker::Address.state,
  email: Faker::Internet.free_email(name: nombre_del_negocio),
  telefono: Faker::Number.number(10),
  pag_web: Faker::Internet.domain_name
)

# negocio.datos_fiscales_negocio.create(
#   nombreFiscal:
#   rfc: "AAA010101AAA" # Lo lo cambies, este RFC se usa solo en ambiente de pruebas.
#   calle: Faker::Address.street_name,
#   numExterior: Faker::Address.building_number,
#   numInterior: Faker::Address.secondary_address,
#   colonia: Faker::Address.street_name,
#   codigo_postal: Faker::Address.postcode,
#   municipio: Faker::Address.street_name,
#   delegacion: Faker::Address.street_name,
#   estado: Faker::Address.state,
#   email: Faker::Internet.domain_name,
#   path_cer: "#{nombre_del_negocio}/Certificados y llaves/certificado.cer"
#   path_key: "#{nombre_del_negocio}/Certificados y llaves/llave.pem"
#   password: "12345678a"
#   t.integer  regimen_fiscal_id:
#   t.string   localidad: Faker::Address.street_name,
#   t.text     referencia: Faker::Lorem.sentence(word_count: 10)
# )

# Sucursales y sus direcciones fiscales
# Anteriormente pensé que un negocio era como una matriz y que estos podian tener muchas sucursales, pero resulta que el loco del Javi me dijo que la matriz vine siendo la primer sucursal del negocio y que apartir del la segunda ya son sucusales XD. Te digo, está loco.

sucursal_name = Faker::Company.name
sucursal = negocio.sucursals.create!(
  nombre: sucursal_name,
  representante: Faker::Name.name_with_middle,
  calle: Faker::Address.street_name,
  numExterior: Faker::Address.building_number,
  numInterior: Faker::Address.secondary_address,
  colonia: Faker::Address.street_name,
  codigo_postal: Faker::Address.postcode,
  municipio: Faker::Address.street_name,
  delegacion: Faker::Address.street_name,
  estado: Faker::Address.state,
  email: Faker::Internet.free_email,
  clave: sucursal_name.slice(0...3),
  telefono: Faker::Number.number(10)
)

usuario_michael.update(negocio: negocio, sucursal: sucursal)


  # create_table "caja_chicas", force: :cascade do |t|
  #   t.decimal  "entrada"
  #   t.decimal  "saldo"
  #   t.string   "concepto"
  #   t.integer  "user_id"
  #   t.integer  "sucursal_id"
  #   t.integer  "negocio_id"
  #   t.datetime "created_at",  null: false
  #   t.datetime "updated_at",  null: false
  #   t.decimal  "salida"
  # end
  #
  # create_table "caja_sucursals", force: :cascade do |t|
  #   t.integer  "numero_caja"
  #   t.string   "nombre"
  #   t.integer  "sucursal_id"
  #   t.datetime "created_at",  null: false
  #   t.datetime "updated_at",  null: false
  #   t.decimal  "saldo"
  #   t.integer  "user_id"
  #   t.integer  "negocio_id"
  # end
