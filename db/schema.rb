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

ActiveRecord::Schema.define(version: 20160107212452) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cat_articulos", force: :cascade do |t|
    t.string   "nombreCatArticulo"
    t.string   "descripcionCatArticulo"
    t.integer  "idCategoriaPadre"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "categoria_gastos", force: :cascade do |t|
    t.string   "nombreCategoria"
    t.string   "descripcionCategoria"
    t.integer  "idCategoriaPadre"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "categoria_perdidas", force: :cascade do |t|
    t.string   "nombreCatPerdida"
    t.string   "descripcionCatPerdida"
    t.integer  "idCategoriaPadre"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
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
  end

  create_table "personas", force: :cascade do |t|
    t.string   "nombre"
    t.string   "telefono1"
    t.string   "telefono2"
    t.string   "email"
    t.string   "direccion"
    t.string   "cargo"
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

  create_table "usuarios", force: :cascade do |t|
    t.string   "nombreUsuario"
    t.string   "contrasena"
    t.integer  "persona_id"
    t.integer  "tipo_usuario_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
