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

ActiveRecord::Schema.define(version: 20180107004036) do

  create_table "articulos", force: :cascade do |t|
    t.string   "clave"
    t.string   "nombre"
    t.string   "descripcion"
    t.decimal  "stock"
    t.integer  "cat_articulo_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.decimal  "existencia"
    t.decimal  "precioCompra"
    t.decimal  "precioVenta"
    t.string   "fotoProducto"
    t.integer  "negocio_id"
    t.integer  "sucursal_id"
    t.integer  "marca_producto_id"
    t.integer  "presentacion_producto_id"
    t.string   "suc_elegida"
    t.string   "tipo"
    t.integer  "unidad_medida_id"
    t.integer  "clave_prod_serv_id"
  end

  add_index "articulos", ["clave_prod_serv_id"], name: "index_articulos_on_clave_prod_serv_id"
  add_index "articulos", ["unidad_medida_id"], name: "index_articulos_on_unidad_medida_id"

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

  create_table "caja_chicas", force: :cascade do |t|
    t.decimal  "entrada"
    t.decimal  "saldo"
    t.string   "concepto"
    t.integer  "user_id"
    t.integer  "sucursal_id"
    t.integer  "negocio_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.decimal  "salida"
  end

  create_table "caja_sucursals", force: :cascade do |t|
    t.integer  "numero_caja"
    t.string   "nombre"
    t.integer  "sucursal_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.decimal  "saldo"
    t.integer  "user_id"
    t.integer  "negocio_id"
  end

  create_table "campo_forma_pago_items", force: :cascade do |t|
    t.integer  "campo_forma_pago_id"
    t.string   "valor_item"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
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

  create_table "cat_compra_canceladas", force: :cascade do |t|
    t.string   "clave"
    t.string   "descripcion"
    t.integer  "negocio_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "cat_venta_canceladas", force: :cascade do |t|
    t.string   "clave"
    t.string   "descripcion"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "negocio_id"
  end

  create_table "categoria_gastos", force: :cascade do |t|
    t.string   "nombre_categoria"
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

  create_table "clave_prod_servs", force: :cascade do |t|
    t.integer  "clave"
    t.string   "nombre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "negocio_id"
  end

  add_index "clave_prod_servs", ["negocio_id"], name: "index_clave_prod_servs_on_negocio_id"

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
    t.date     "fecha_nac"
    t.string   "nombreFiscal"
    t.string   "rfc"
  end

  create_table "compra_articulos_devueltos", force: :cascade do |t|
    t.integer  "articulo_id"
    t.integer  "compra_id"
    t.integer  "user_id"
    t.date     "fecha"
    t.string   "observaciones"
    t.integer  "negocio_id"
    t.integer  "sucursal_id"
    t.decimal  "cantidad_devuelta"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "detalle_compra_id"
    t.integer  "cat_compra_cancelada_id"
  end

  create_table "compra_canceladas", force: :cascade do |t|
    t.integer  "compra_id"
    t.integer  "cat_compra_cancelada_id"
    t.integer  "user_id"
    t.string   "observaciones"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "negocio_id"
    t.integer  "sucursal_id"
  end

  create_table "compras", force: :cascade do |t|
    t.date     "fecha"
    t.string   "tipo_pago"
    t.string   "plazo_pago"
    t.string   "folio_compra"
    t.integer  "proveedor_id"
    t.integer  "user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "forma_pago"
    t.text     "articulos"
    t.decimal  "monto_compra"
    t.string   "periodo_plazo"
    t.date     "fecha_limite_pago"
    t.integer  "sucursal_id"
    t.integer  "negocio_id"
    t.string   "ticket_compra"
    t.string   "status"
    t.string   "observaciones"
  end

  create_table "datos_fiscales_clientes", force: :cascade do |t|
    t.string   "nombreFiscal"
    t.string   "rfc"
    t.string   "cliente_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "datos_fiscales_negocios", force: :cascade do |t|
    t.string   "nombreFiscal"
    t.string   "rfc"
    t.integer  "negocio_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "calle"
    t.string   "numExterior"
    t.string   "numInterior"
    t.string   "colonia"
    t.string   "codigo_postal"
    t.string   "municipio"
    t.string   "delegacion"
    t.string   "estado"
    t.string   "email"
    t.string   "regimen_fiscal"
  end

  create_table "datos_fiscales_sucursals", force: :cascade do |t|
    t.string   "nombreFiscal"
    t.text     "direccionFiscal"
    t.string   "rfc"
    t.integer  "sucursal_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "detalle_compras", force: :cascade do |t|
    t.decimal  "cantidad_comprada"
    t.decimal  "precio_compra"
    t.decimal  "importe"
    t.integer  "compra_id"
    t.integer  "articulo_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "status"
  end

  create_table "entrada_almacens", force: :cascade do |t|
    t.decimal  "cantidad"
    t.date     "fecha"
    t.boolean  "isEntradaInicial"
    t.integer  "articulo_id"
    t.integer  "compra_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
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

  create_table "factura_recurrentes", force: :cascade do |t|
    t.string   "folio"
    t.date     "fecha_expedicion"
    t.string   "estado_factura"
    t.integer  "tiempo_recurrente"
    t.integer  "user_id"
    t.integer  "negocio_id"
    t.integer  "sucursal_id"
    t.integer  "cliente_id"
    t.integer  "forma_pago_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "factura_recurrentes", ["cliente_id"], name: "index_factura_recurrentes_on_cliente_id"
  add_index "factura_recurrentes", ["forma_pago_id"], name: "index_factura_recurrentes_on_forma_pago_id"
  add_index "factura_recurrentes", ["negocio_id"], name: "index_factura_recurrentes_on_negocio_id"
  add_index "factura_recurrentes", ["sucursal_id"], name: "index_factura_recurrentes_on_sucursal_id"
  add_index "factura_recurrentes", ["user_id"], name: "index_factura_recurrentes_on_user_id"

  create_table "facturas", force: :cascade do |t|
    t.string   "folio"
    t.date     "fecha_expedicion"
    t.string   "estado_factura"
    t.integer  "venta_id"
    t.integer  "user_id"
    t.integer  "negocio_id"
    t.integer  "sucursal_id"
    t.integer  "cliente_id"
    t.integer  "forma_pago_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "facturas", ["cliente_id"], name: "index_facturas_on_cliente_id"
  add_index "facturas", ["forma_pago_id"], name: "index_facturas_on_forma_pago_id"
  add_index "facturas", ["negocio_id"], name: "index_facturas_on_negocio_id"
  add_index "facturas", ["sucursal_id"], name: "index_facturas_on_sucursal_id"
  add_index "facturas", ["user_id"], name: "index_facturas_on_user_id"
  add_index "facturas", ["venta_id"], name: "index_facturas_on_venta_id"

  create_table "forma_pagos", force: :cascade do |t|
    t.string   "nombre"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gasto_corrientes", force: :cascade do |t|
    t.decimal  "monto"
    t.string   "concepto"
    t.integer  "gasto_id"
    t.integer  "user_id"
    t.integer  "sucursal_id"
    t.integer  "negocio_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "proveedor_id"
    t.string   "folio_gasto"
    t.string   "ticket_gasto"
  end

  create_table "gasto_generals", force: :cascade do |t|
    t.string   "folio_gasto"
    t.string   "ticket_gasto"
    t.decimal  "monto"
    t.string   "concepto"
    t.integer  "gasto_id"
    t.integer  "user_id"
    t.integer  "sucursal_id"
    t.integer  "negocio_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "proveedor_id"
  end

  create_table "gastos", force: :cascade do |t|
    t.decimal  "monto"
    t.string   "concepto"
    t.string   "tipo"
    t.integer  "categoria_gasto_id"
    t.integer  "caja_chica_id"
    t.integer  "caja_sucursal_id"
    t.integer  "user_id"
    t.integer  "sucursal_id"
    t.integer  "negocio_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "historial_ediciones_compras", force: :cascade do |t|
    t.integer  "compra_id"
    t.integer  "sucursal_id"
    t.integer  "negocio_id"
    t.integer  "user_id"
    t.decimal  "monto_anterior"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.text     "razon_edicion"
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
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.decimal  "cantidad"
    t.string   "status"
    t.decimal  "precio_venta"
    t.decimal  "monto"
  end

  create_table "marca_productos", force: :cascade do |t|
    t.string   "nombre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "negocio_id"
  end

  create_table "metodo_pagos", force: :cascade do |t|
    t.string   "clave"
    t.string   "descripcion"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "movimiento_caja_sucursals", force: :cascade do |t|
    t.decimal  "entrada"
    t.decimal  "salida"
    t.integer  "user_id"
    t.integer  "sucursal_id"
    t.integer  "negocio_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "caja_sucursal_id"
    t.integer  "venta_id"
    t.integer  "gasto_id"
    t.integer  "retiro_caja_venta_id"
    t.string   "tipo_pago"
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

  create_table "pago_devolucions", force: :cascade do |t|
    t.decimal  "monto"
    t.integer  "venta_cancelada_id"
    t.integer  "gasto_id"
    t.integer  "user_id"
    t.integer  "sucursal_id"
    t.integer  "negocio_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "pago_pendientes", force: :cascade do |t|
    t.date     "fecha_vencimiento"
    t.decimal  "saldo"
    t.integer  "compra_id"
    t.integer  "proveedor_id"
    t.integer  "sucursal_id"
    t.integer  "negocio_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "status"
  end

  create_table "pago_proveedores", force: :cascade do |t|
    t.decimal  "monto"
    t.integer  "compra_id"
    t.integer  "gasto_id"
    t.integer  "proveedor_id"
    t.integer  "user_id"
    t.integer  "sucursal_id"
    t.integer  "negocio_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "statusPago"
    t.integer  "pago_pendiente_id"
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
    t.integer  "negocio_id"
  end

  create_table "proveedores", force: :cascade do |t|
    t.string   "nombre"
    t.string   "telefono"
    t.string   "email"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "sucursal_id"
    t.string   "nombreContacto"
    t.string   "telefonoContacto"
    t.string   "emailContacto"
    t.string   "celularContacto"
    t.decimal  "limite_credito"
    t.decimal  "compra_minima_mensual"
    t.date     "fecha_alta"
    t.string   "pagina_web"
    t.text     "observaciones"
    t.decimal  "saldo_deuda"
    t.string   "puesto_contacto"
    t.integer  "negocio_id"
  end

  create_table "retiro_caja_ventas", force: :cascade do |t|
    t.decimal  "monto_retirado"
    t.integer  "user_id"
    t.integer  "sucursal_id"
    t.integer  "negocio_id"
    t.integer  "caja_ventas_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
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
    t.string   "clave"
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

  create_table "unidad_medidas", force: :cascade do |t|
    t.string   "clave"
    t.string   "nombre"
    t.text     "descripcion"
    t.string   "simbolo"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "negocio_id"
  end

  add_index "unidad_medidas", ["negocio_id"], name: "index_unidad_medidas_on_negocio_id"

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

  create_table "uso_cfdis", force: :cascade do |t|
    t.string   "clave"
    t.text     "descripcion"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "usuarios", force: :cascade do |t|
    t.string   "nombreUsuario"
    t.string   "contrasena"
    t.integer  "persona_id"
    t.integer  "tipo_usuario_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "email"
  end

  create_table "venta_canceladas", force: :cascade do |t|
    t.integer  "articulo_id"
    t.integer  "item_venta_id"
    t.integer  "venta_id"
    t.integer  "cat_venta_cancelada_id"
    t.integer  "user_id"
    t.date     "fecha"
    t.text     "observaciones"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "negocio_id"
    t.integer  "sucursal_id"
    t.decimal  "cantidad_devuelta"
    t.decimal  "monto"
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
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "caja_sucursal_id"
    t.integer  "user_id"
    t.integer  "sucursal_id"
    t.integer  "cliente_id"
    t.integer  "negocio_id"
    t.string   "status"
    t.text     "observaciones"
    t.string   "folio"
    t.integer  "consecutivo"
  end

end
