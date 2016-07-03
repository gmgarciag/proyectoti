# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
ProductoConPagina.create(sku: '19', nombre: 'Semola', enlace:'http://www.cl.all.biz/img/cl/catalog/6295.jpeg')
ProductoConPagina.create(sku: '27', nombre: 'Levadura', enlace: 'http://www.cocinillas.es/wp-content/uploads/2011/09/impulsor.jpg')
ProductoConPagina.create(sku: '40', nombre: 'Queso', enlace:'http://thumbs.dreamstime.com/z/queso-suizo-6679128.jpg')
ProductoConPagina.create(sku: '45', nombre: 'Celulosa', enlace:'http://www.mycopaes.com/images/papel.jpg')
ProductoConPagina.create(sku: '47', nombre: 'Vino', enlace:'http://ocucaje.com/dev/wp-content/uploads/2012/05/TIPS-SOBRE-VINOS.jpg')

proveedor = Proveedor.create([{ materiaPrima: 'Leche',skuMateriaPrima: 7,skuProducto: 40 ,productoProcesar:'Queso',grupoProveedor: 12,cantidadRequerida: 1000,precio: 1307 },
								{ materiaPrima: 'Levadura',skuMateriaPrima: 27,skuProducto: 47,productoProcesar:'Vino',grupoProveedor: 1,cantidadRequerida: 570,precio: 1376 },
								{ materiaPrima: 'Uva',skuMateriaPrima: 39,skuProducto: 47,productoProcesar:'Vino',grupoProveedor: 7,cantidadRequerida: 495,precio: 1217},
								{ materiaPrima: 'Suero de Leche',skuMateriaPrima: 41,skuProducto: 40,productoProcesar:'Queso',grupoProveedor: 10,cantidadRequerida: 800,precio: 3148 },
								{ materiaPrima: 'Azucar',skuMateriaPrima: 25,skuProducto: 47,productoProcesar:'Vino',grupoProveedor: 6,cantidadRequerida: 1000,precio: 1016 }])

formula = Formula.create([{productoProducir: 'Queso',insumo:'Leche',cantidadRequerida: 1000,loteProducido: 900,skuInsumo: 7,skuProducto: 40},
							{productoProducir: 'Queso',insumo:'Suero de Leche',cantidadRequerida: 800,loteProducido: 900,skuInsumo: 41,skuProducto: 40},
							{productoProducir: 'Vino',insumo:'Uva',cantidadRequerida: 495,loteProducido: 1000,skuInsumo: 39,skuProducto: 47},
							{productoProducir: 'Vino',insumo:'Levadura',cantidadRequerida: 570,loteProducido: 1000,skuInsumo: 27,skuProducto: 47},
							{productoProducir: 'Vino',insumo:'Azucar',cantidadRequerida: 1000,loteProducido: 1000,skuInsumo: 25,skuProducto: 47}])

costoProduccion = CostoProduccion.create([
{skuProducto: 19,nombreProducto: 'Sémola',tipoProducto: 'Materia prima',costoProdUnitario: 1428,loteProduccion: 1420,tiempoMedio: 4.033},
{skuProducto: 27,nombreProducto: 'Levadura',tipoProducto: 'Materia prima',costoProdUnitario: 1084,loteProduccion: 620,tiempoMedio: 2.717},
{skuProducto: 40,nombreProducto: 'Queso',tipoProducto: 'Producto procesado',costoProdUnitario: 2324,loteProduccion: 900,tiempoMedio: 3.589},
{skuProducto: 45,nombreProducto: 'Celulosa',tipoProducto: 'Materia prima',costoProdUnitario: 1500,loteProduccion: 800,tiempoMedio: 0.759},
{skuProducto: 47,nombreProducto: 'Vino',tipoProducto: 'Producto procesado',costoProdUnitario: 1921,loteProduccion: 1000,tiempoMedio: 0.677}])

idGrupos = IdGrupo.create([
	{numeroGrupo:'1' ,idGrupo:'571262b8a980ba030058ab4f',idBanco:'571262c3a980ba030058ab5b',idBodegaRecepcion:'571262aaa980ba030058a147'},
	{numeroGrupo:'2' ,idGrupo:'571262b8a980ba030058ab50',idBanco:'571262c3a980ba030058ab5c',idBodegaRecepcion:'571262aaa980ba030058a14e'},
	{numeroGrupo:'3' ,idGrupo:'571262b8a980ba030058ab51',idBanco:'571262c3a980ba030058ab5d',idBodegaRecepcion:'571262aaa980ba030058a1f1'},
	{numeroGrupo:'4' ,idGrupo:'571262b8a980ba030058ab52',idBanco:'571262c3a980ba030058ab5f',idBodegaRecepcion:'571262aaa980ba030058a240'},
	{numeroGrupo:'5' ,idGrupo:'571262b8a980ba030058ab53',idBanco:'571262c3a980ba030058ab61',idBodegaRecepcion:'571262aaa980ba030058a244'},
	{numeroGrupo:'6' ,idGrupo:'571262b8a980ba030058ab54',idBanco:'571262c3a980ba030058ab62',idBodegaRecepcion:''},
	{numeroGrupo:'7' ,idGrupo:'571262b8a980ba030058ab55',idBanco:'571262c3a980ba030058ab60',idBodegaRecepcion:''},
	{numeroGrupo:'8' ,idGrupo:'571262b8a980ba030058ab56',idBanco:'571262c3a980ba030058ab5e',idBodegaRecepcion:'571262aaa980ba030058a31e'},
	{numeroGrupo:'9' ,idGrupo:'571262b8a980ba030058ab57',idBanco:'571262c3a980ba030058ab66',idBodegaRecepcion:'571262aaa980ba030058a3b0'},
	{numeroGrupo:'10' ,idGrupo:'571262b8a980ba030058ab58',idBanco:'571262c3a980ba030058ab63',idBodegaRecepcion:'571262aaa980ba030058a40c'},
	{numeroGrupo:'11' ,idGrupo:'571262b8a980ba030058ab59',idBanco:'571262c3a980ba030058ab64',idBodegaRecepcion:'571262aaa980ba030058a488'},
	{numeroGrupo:'12' ,idGrupo:'571262b8a980ba030058ab5a',idBanco:'571262c3a980ba030058ab65',idBodegaRecepcion:'571262aba980ba030058a5c6'}])

idGruposProduccion = IdGrupoProduccion.create([
	{numeroGrupo:'1' ,idGrupo:'572aac69bdb6d403005fb042',idBanco:'572aac69bdb6d403005fb04e',idBodegaRecepcion:'572aad41bdb6d403005fb066'},
	{numeroGrupo:'2' ,idGrupo:'572aac69bdb6d403005fb043',idBanco:'572aac69bdb6d403005fb04f',idBodegaRecepcion:'572aad41bdb6d403005fb0ba'},
	{numeroGrupo:'3' ,idGrupo:'572aac69bdb6d403005fb044',idBanco:'572aac69bdb6d403005fb050',idBodegaRecepcion:'572aad41bdb6d403005fb1bf'},
	{numeroGrupo:'4' ,idGrupo:'572aac69bdb6d403005fb045',idBanco:'572aac69bdb6d403005fb051',idBodegaRecepcion:'572aad41bdb6d403005fb208'},
	{numeroGrupo:'5' ,idGrupo:'572aac69bdb6d403005fb046',idBanco:'572aac69bdb6d403005fb052',idBodegaRecepcion:'572aad41bdb6d403005fb278'},
	{numeroGrupo:'6' ,idGrupo:'572aac69bdb6d403005fb047',idBanco:'572aac69bdb6d403005fb053',idBodegaRecepcion:'572aad41bdb6d403005fb2d8'},
	{numeroGrupo:'7' ,idGrupo:'572aac69bdb6d403005fb048',idBanco:'572aac69bdb6d403005fb054',idBodegaRecepcion:'572aad41bdb6d403005fb3b9'},
	{numeroGrupo:'8' ,idGrupo:'572aac69bdb6d403005fb049',idBanco:'572aac69bdb6d403005fb056',idBodegaRecepcion:'572aad41bdb6d403005fb416'},
	{numeroGrupo:'9' ,idGrupo:'572aac69bdb6d403005fb04a',idBanco:'572aac69bdb6d403005fb057',idBodegaRecepcion:'572aad41bdb6d403005fb4b8'},
	{numeroGrupo:'10' ,idGrupo:'572aac69bdb6d403005fb04b',idBanco:'572aac69bdb6d403005fb058',idBodegaRecepcion:'572aad41bdb6d403005fb542'},
	{numeroGrupo:'11' ,idGrupo:'572aac69bdb6d403005fb04c',idBanco:'572aac69bdb6d403005fb059',idBodegaRecepcion:'572aad41bdb6d403005fb5b9'},
	{numeroGrupo:'12' ,idGrupo:'572aac69bdb6d403005fb04d',idBanco:'572aac69bdb6d403005fb05a',idBodegaRecepcion:'572aad42bdb6d403005fb69f'}])

nuestrosProductos = NuestroProducto.create([
{sku:19, descripcion:'Sémola', precio:1613},
{sku:27, descripcion:'Levadura', precio:1376},
{sku:40, descripcion:'Queso', precio:8744}, 
{sku:45, descripcion:'Celulosa', precio:1695}, 
{sku:47, descripcion:'Vino', precio:7244}])




Spree::Core::Engine.load_seed if defined?(Spree::Core)
Spree::Auth::Engine.load_seed if defined?(Spree::Auth)
