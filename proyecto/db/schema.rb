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

ActiveRecord::Schema.define(version: 20160507091422) do

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
    t.decimal  "tiempoMedio"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "formulas", force: :cascade do |t|
    t.string   "productoProducir"
    t.string   "insumo"
    t.integer  "cantidadRequerida"
    t.integer  "loteProducido"
    t.integer  "skuInsumo"
    t.integer  "skuProducto"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
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

  create_table "id_grupos", force: :cascade do |t|
    t.integer  "numeroGrupo"
    t.string   "idGrupo"
    t.string   "idBanco"
    t.string   "idBodegaRecepcion"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "idgrupo_produccions", force: :cascade do |t|

    t.integer  "numeroGrupo"
    t.string   "idGrupo"
    t.string   "idBanco"
    t.string   "idBodegaRecepcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "inventarios", force: :cascade do |t|
    t.string   "sku"
    t.string   "cantidadBodega"
    t.string   "cantidadVendida"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "nuestro_productos", force: :cascade do |t|
    t.integer  "sku"
    t.string   "descripcion"
    t.integer  "precio"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "orden_compras", force: :cascade do |t|
    t.string   "idOC"
    t.integer  "sku"
    t.integer  "cantidad"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ordens", force: :cascade do |t|
    t.string   "idOrden"
    t.datetime "fechaCreacion"
    t.string   "canal"
    t.string   "cliente"
    t.string   "sku"
    t.string   "cantidad"
    t.string   "despachada"
    t.integer  "precioUnitario"
    t.datetime "fechaEntrega"
    t.string   "estado"
    t.string   "rechazo"
    t.string   "anulacion"
    t.string   "idFactura"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
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

  create_table "precios_productos", force: :cascade do |t|
    t.integer  "sku"
    t.string   "nombre"
    t.integer  "precio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "productos", force: :cascade do |t|
    t.string   "idProducto"
    t.string   "sku"
    t.string   "almacenId"
    t.decimal  "costos"
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

  create_table "proveedors", force: :cascade do |t|
    t.string   "materiaPrima"
    t.integer  "skuMateriaPrima"
    t.integer  "skuProducto"
    t.string   "productoProcesar"
    t.integer  "grupoProveedor"
    t.integer  "cantidadRequerida"
    t.integer  "precio"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "xmls", force: :cascade do |t|
    t.string   "nombreArchivo"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

end
