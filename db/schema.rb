# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170321042934) do

  create_table "articulos", force: :cascade do |t|
    t.string   "clave"
    t.string   "nombre"
    t.string   "descripcion"
    t.integer  "stock"
    t.integer  "cat_articulo_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.decimal  "existencia"
    t.decimal  "precioCompra"
    t.decimal  "precioVenta"
    t.string   "fotoProducto"
    t.integer  "negocio_id"
    t.integer  "sucursal_id"
  end

  create_table "bancos", force: :cascade do |t|
    t.string   "tipoCuenta"
    t.string   "nombreCuenta"
    t.integer  "numeroCuenta"
    t.decimal  "saldoInicial"
    t.date     "fecha"
    t.text     "descripcion"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "negocio_id"
  end

  create_table "campo_forma_pagos", force: :cascade do |t|
    t.integer  "forma_pago_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "nombrecampo"
  end

  create_table "cat_articulos", force: :cascade do |t|
    t.string   "nombreCatArticulo"
    t.string   "descripcionCatArticulo"
    t.integer  "idCategoriaPadre"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "negocio_id"
    t.integer  "cat_articulo_id"
  end

  create_table "categoria_gastos", force: :cascade do |t|
    t.string   "nombreCategoria"
    t.string   "descripcionCategoria"
    t.integer  "idCategoriaPadre"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "negocio_id"
  end

  create_table "categoria_perdidas", force: :cascade do |t|
    t.string   "nombreCatPerdida"
    t.string   "descripcionCatPerdida"
    t.integer  "idCategoriaPadre"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "negocio_id"
  end

  create_table "clientes", force: :cascade do |t|
    t.string   "nombre"
    t.string   "direccionCalle"
    t.string   "direccionNumeroExt"
    t.string   "direccionNumeroInt"
    t.string   "direccionColonia"
    t.string   "direccionMunicipio"
    t.string   "direccionDelegacion"
    t.string   "direccionEstado"
    t.string   "direccionCp"
    t.string   "foto"
    t.string   "telefono1"
    t.string   "telefono2"
    t.string   "email"
    t.integer  "negocio_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "ape_pat"
    t.string   "ape_mat"
  end

  create_table "datos_fiscales_clientes", force: :cascade do |t|
    t.string   "nombreFiscal"
    t.string   "rfc"
    t.string   "cliente_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "calle"
    t.string   "numExterior"
    t.string   "numInterior"
    t.string   "colonia"
    t.string   "codigo_postal"
    t.string   "municipio"
    t.string   "delegacion"
    t.string   "estado"
    t.string   "email"
  end

  create_table "datos_fiscales_negocios", force: :cascade do |t|
    t.string   "nombreFiscal"
    t.string   "rfc"
    t.integer  "negocio_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "calle"
    t.string   "numExterior"
    t.string   "numInterior"
    t.string   "colonia"
    t.string   "codigo_postal"
    t.string   "municipio"
    t.string   "delegacion"
    t.string   "estado"
    t.string   "email"
  end

  create_table "datos_fiscales_sucursals", force: :cascade do |t|
    t.string   "nombreFiscal"
    t.text     "direccionFiscal"
    t.string   "rfc"
    t.integer  "sucursal_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "entradasInventario", force: :cascade do |t|
    t.float    "precioCompra"
    t.float    "precioVenta"
    t.integer  "cantidadComprada"
    t.string   "unidadMedida"
    t.date     "fechaIngreso"
    t.integer  "articulo_id"
    t.integer  "proveedor_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "forma_pagos", force: :cascade do |t|
    t.string   "nombre"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gastos", force: :cascade do |t|
    t.float    "montoGasto"
    t.date     "fechaGasto"
    t.string   "descripcionGasto"
    t.string   "lugarCompraGasto"
    t.integer  "persona_id"
    t.integer  "categoria_gasto_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "sucursal_id"
  end

  create_table "inventario", force: :cascade do |t|
    t.integer  "cantidad"
    t.string   "unidad"
    t.integer  "articulo_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "item_ventas", force: :cascade do |t|
    t.integer  "venta_id"
    t.integer  "articulo_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.decimal  "cantidad"
  end

  create_table "marca_productos", force: :cascade do |t|
    t.string   "nombre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "negocios", force: :cascade do |t|
    t.string   "logo"
    t.string   "nombre"
    t.string   "representante"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "calle"
    t.string   "numExterior"
    t.string   "numInterior"
    t.string   "colonia"
    t.string   "codigo_postal"
    t.string   "municipio"
    t.string   "delegacion"
    t.string   "estado"
    t.string   "email"
  end

  create_table "perdidas", force: :cascade do |t|
    t.string   "descripcionPerdida"
    t.date     "fechaPerdida"
    t.string   "nombreArticuloPerdida"
    t.float    "precioCompraArticuloPerdida"
    t.float    "precioVentaArticuloPerdida"
    t.integer  "categoria_perdida_id"
    t.integer  "cat_articulo_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "sucursal_id"
  end

  create_table "perfils", force: :cascade do |t|
    t.string   "nombre"
    t.string   "ape_materno"
    t.string   "ape_paterno"
    t.string   "dir_calle"
    t.string   "dir_numero_ext"
    t.string   "dir_numero_int"
    t.string   "dir_colonia"
    t.string   "dir_municipio"
    t.string   "dir_delegacion"
    t.string   "dir_estado"
    t.string   "dir_cp"
    t.string   "foto"
    t.integer  "user_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "presentacion_productos", force: :cascade do |t|
    t.string   "nombre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "proveedores", force: :cascade do |t|
    t.string   "nombre"
    t.string   "telefono"
    t.string   "email"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "sucursal_id"
    t.string   "nombreContacto"
    t.string   "telefonoContacto"
    t.string   "emailContacto"
    t.string   "celularContacto"
  end

  create_table "sucursals", force: :cascade do |t|
    t.string   "nombre"
    t.string   "representante"
    t.integer  "negocio_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "calle"
    t.string   "numExterior"
    t.string   "numInterior"
    t.string   "colonia"
    t.string   "codigo_postal"
    t.string   "municipio"
    t.string   "delegacion"
    t.string   "estado"
    t.string   "email"
  end

  create_table "telefono_personas", force: :cascade do |t|
    t.string   "telefono"
    t.string   "persona_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tipo_usuarios", force: :cascade do |t|
    t.string   "nombreTipo"
    t.string   "descripcionTipo"
    t.boolean  "isVentas"
    t.boolean  "isInventarios"
    t.boolean  "isPerdidas"
    t.boolean  "isPersonas"
    t.boolean  "isGastos"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",       null: false
    t.string   "encrypted_password",     default: "",       null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,        null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "negocio_id"
    t.integer  "sucursal_id"
    t.string   "role",                   default: "cajero"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "usuarios", force: :cascade do |t|
    t.string   "nombreUsuario"
    t.string   "contrasena"
    t.integer  "persona_id"
    t.integer  "tipo_usuario_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "email"
  end

  create_table "venta_forma_pago_campos", force: :cascade do |t|
    t.integer  "venta_forma_pago_id"
    t.integer  "campo_forma_pago_id"
    t.string   "ValorCampo"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "venta_forma_pagos", force: :cascade do |t|
    t.integer  "venta_id"
    t.integer  "forma_pago_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "ventas", force: :cascade do |t|
    t.date     "fechaVenta"
    t.float    "montoVenta"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "caja"
    t.integer  "user_id"
    t.integer  "sucursal_id"
    t.integer  "cliente_id"
  end

end
