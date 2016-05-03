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


ActiveRecord::Schema.define(version: 20160503012538) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "almacens", force: :cascade do |t|
    t.string   "almacenId"
    t.integer  "espacioUtilizado"
    t.integer  "espacioTotal"
    t.boolean  "recepcion"
    t.boolean  "depacho"
    t.boolean  "pulmon"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "costo_produccions", force: :cascade do |t|
    t.integer  "skuProducto"
    t.string   "nombreProducto"
    t.string   "tipoProducto"
    t.integer  "costoProdUnitario"
    t.integer  "loteProduccion"
    t.integer  "tiempoMedio"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "formulas", force: :cascade do |t|
    t.string   "productoProducir"
    t.string   "insumo"
    t.integer  "cantidadRequerida"
    t.integer  "loteProducido"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "skuInsumo"
    t.integer  "skuProducto"
  end

  create_table "id_grupos", force: :cascade do |t|
    t.integer  "numeroGrupo"
    t.string   "idGrupo"
    t.string   "idBanco"
    t.string   "idBodegaRecepcion"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false

  create_table "inventarios", force: :cascade do |t|
    t.string   "sku"
    t.string   "cantidadBodega"
    t.string   "cantidadVendida"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false

  end

  create_table "orden_compras", force: :cascade do |t|
    t.string   "idOrden"
    t.datetime "creacion"
    t.string   "cliente"
    t.string   "sku"
    t.integer  "cantidad"
    t.integer  "despachado"
    t.integer  "fechaEntrega"
    t.string   "estado"
    t.boolean  "transaccion"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "pedidos", force: :cascade do |t|
    t.string   "idPedido"
    t.datetime "creacion"
    t.string   "proveedor"
    t.integer  "cantidad"
    t.integer  "despachado"
    t.integer  "fechaEntrega"
    t.string   "estado"
    t.boolean  "transaccion"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "productos", force: :cascade do |t|
    t.string   "idProducto"
    t.string   "sku"
    t.string   "almacenId"
    t.decimal  "costos"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "proveedors", force: :cascade do |t|
    t.string   "materiaPrima"
    t.string   "productoProcesar"
    t.integer  "grupoProveedor"
    t.integer  "cantidadRequerida"
    t.integer  "precio"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "skuMateriaPrima"
    t.integer  "skuProducto"
  end

  create_table "xmls", force: :cascade do |t|
    t.string   "nombreArchivo"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false

  end

end
