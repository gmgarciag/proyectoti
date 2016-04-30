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

ActiveRecord::Schema.define(version: 20160429230919) do

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

  create_table "formulas_productos", force: :cascade do |t|
    t.integer  "skuProducto"
    t.string   "nombreProducto"
    t.integer  "lote"
    t.string   "unidadProducto"
    t.integer  "skuIngrediente"
    t.string   "nombreIngrediente"
    t.integer  "requerimiento"
    t.string   "unidadIngrediente"
    t.integer  "precioIngrediente"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "orden_compras", force: :cascade do |t|
    t.string   "idOC"
    t.integer  "sku"
    t.integer  "cantidad"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "precios_productos", force: :cascade do |t|
    t.integer  "sku"
    t.string   "nombre"
    t.integer  "precio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "productosMercado", force: :cascade do |t|
    t.integer  "sku"
    t.string   "nombre"
    t.string   "tipo"
    t.integer  "grupo"
    t.string   "unidades"
    t.integer  "costoProduccion"
    t.integer  "loteProduccion"
    t.float    "tiempoProduccion"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "productosMercados", force: :cascade do |t|
    t.integer  "sku"
    t.string   "nombre"
    t.string   "tipo"
    t.integer  "grupo"
    t.string   "unidades"
    t.integer  "costoProduccion"
    t.integer  "loteProduccion"
    t.float    "tiempoProduccion"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "productos_mercados", force: :cascade do |t|
    t.integer  "sku"
    t.string   "nombre"
    t.string   "tipo"
    t.integer  "grupo"
    t.string   "unidades"
    t.integer  "costoProduccion"
    t.integer  "loteProduccion"
    t.float    "tiempoProduccion"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

end
