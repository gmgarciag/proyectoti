class ReporteController < ApplicationController
require 'rest-client'
require 'rubygems'
require 'base64'
require 'cgi'
require 'hmac-sha1'

def index
  semola = StockDiario.where(sku:19)
  cantidadesSemola = []
  fechaSemola = []
  dias = 0
  semola.each do |s|
    cantidadSemola = []
    aux = 0
    until aux >= dias do
      cantidadSemola << 0
      aux += 1
    end
    cantidadSemola << s.cantidad
    cantidadesSemola << cantidadSemola
    fechaSemola << s.fecha.to_s
    dias += 1
  end
  levadura = StockDiario.where(sku:27)
  cantidadesLevadura = []
  fechaLevadura = []
  dias = 0
  levadura.each do |s|
    cantidadLevadura = []
    aux = 0
    until aux >= dias do
      cantidadLevadura << 0
      aux += 1
    end
    cantidadLevadura << s.cantidad
    cantidadesLevadura << cantidadLevadura
    fechaLevadura << s.fecha.to_s
    dias += 1
  end
  queso = StockDiario.where(sku:40)
  cantidadesQueso = []
  fechaQueso = []
  dias = 0
  queso.each do |s|
    cantidadQueso = []
    aux = 0
    until aux >= dias do
      cantidadQueso << 0
      aux += 1
    end
    cantidadQueso << s.cantidad
    cantidadesQueso << cantidadQueso
    fechaQueso << s.fecha.to_s
    dias += 1
  end
  celulosa = StockDiario.where(sku:45)
  cantidadesCelulosa = []
  fechaCelulosa = []
  dias = 0
  celulosa.each do |s|
    cantidadCelulosa = []
    aux = 0
    until aux >= dias do
      cantidadCelulosa << 0
      aux += 1
    end
    cantidadCelulosa << s.cantidad
    cantidadesCelulosa << cantidadCelulosa
    fechaCelulosa << s.fecha.to_s
    dias += 1
  end
  vino = StockDiario.where(sku:47)
  cantidadesVino = []
  fechaVino = []
  dias = 0
  vino.each do |s|
    cantidadVino = []
    aux = 0
    until aux >= dias do
      cantidadVino << 0
      aux += 1
    end
    cantidadVino << s.cantidad
    cantidadesVino << cantidadVino
    fechaVino << s.fecha.to_s
    dias += 1
  end
  @graficoSemola = Gchart.bar(:size => '400x400', :theme => :keynote, :title => "Sémola", :bg => 'efefef', :axis_with_labels => 'y', :legend => fechaSemola, :data => cantidadesSemola, :axis_range => [[0,15000,1000]], :max_value => 15000)
  @graficoLevadura = Gchart.bar(:size => '400x400', :theme => :keynote, :title => "Levadura", :bg => 'efefef', :axis_with_labels => 'y', :legend => fechaSemola, :data => cantidadesLevadura, :axis_range => [[0,15000,1000]], :max_value => 15000)
  @graficoQueso = Gchart.bar(:size => '400x400', :theme => :keynote, :title => "Queso", :bg => 'efefef', :axis_with_labels => 'y', :legend => fechaSemola, :data => cantidadesQueso, :axis_range => [[0,15000,1000]], :max_value => 15000)
  @graficoCelulosa = Gchart.bar(:size => '400x400', :theme => :keynote, :title => "Celulosa", :bg => 'efefef', :axis_with_labels => 'y', :legend => fechaSemola, :data => cantidadesCelulosa, :axis_range => [[0,15000,1000]], :max_value => 15000)
  @graficoVino = Gchart.bar(:size => '400x400', :theme => :keynote, :title => "Vino", :bg => 'efefef', :axis_with_labels => 'y', :legend => fechaSemola, :data => cantidadesVino, :axis_range => [[0,15000,1000]], :max_value => 15000)
end
def bodegas
  espacioTotal = 0
  espacioUtilizado = 0
  almacenes = Almacen.where(pulmon:false)
  almacenes.each do |a|
    espacioTotal += (a.espacioTotal).to_i
    espacioUtilizado += (a.espacioUtilizado).to_i
  end
  espacioLibre = espacioTotal - espacioUtilizado
  @graficoBodegas = Gchart.pie(:title => 'porcentaje uso bodegas', :legend => ['Espacio libre', 'Espacio ocupado'], :theme => :keynote, :data => [espacioLibre, espacioUtilizado], :size => '400x200', :bg => 'efefef')
  ocupadoPrimero = almacenes.first.espacioUtilizado
  librePrimero = almacenes.first.espacioTotal - almacenes.first.espacioUtilizado
  ocupadoSegundo = almacenes.second.espacioUtilizado
  libreSegundo = almacenes.second.espacioTotal - almacenes.second.espacioUtilizado
  ocupadoTercero = almacenes.third.espacioUtilizado
  libreTercero = almacenes.third.espacioTotal - almacenes.third.espacioUtilizado
  ocupadoCuarto = almacenes.fourth.espacioUtilizado
  libreCuarto = almacenes.fourth.espacioTotal - almacenes.fourth.espacioUtilizado
  @graficoPrimero = Gchart.pie(:title => 'porcentaje uso almacén 1', :legend => ['Espacio libre', 'Espacio ocupado'], :theme => :keynote, :data => [librePrimero, ocupadoPrimero], :size => '400x200', :bg => 'efefef')
  @graficoSegundo = Gchart.pie(:title => 'porcentaje uso almacén 2', :legend => ['Espacio libre', 'Espacio ocupado'], :theme => :keynote, :data => [libreSegundo, ocupadoSegundo], :size => '400x200', :bg => 'efefef')
  @graficoTercero = Gchart.pie(:title => 'porcentaje uso almacén 3', :legend => ['Espacio libre', 'Espacio ocupado'], :theme => :keynote, :data => [libreTercero, ocupadoTercero], :size => '400x200', :bg => 'efefef')
  @graficoCuarto = Gchart.pie(:title => 'porcentaje uso almacén 4', :legend => ['Espacio libre', 'Espacio ocupado'], :theme => :keynote, :data => [libreCuarto, ocupadoCuarto], :size => '400x200', :bg => 'efefef')
end
def facturacion
  ventasTotales = 0
  ventasB2c = 0
  ventasB2b = 0
  ventasFtp = 0
  numVentasTotales = 0
  numVentasB2b = 0
  numVentasB2c = 0
  numVentasFtp = 0
  Ticket.all.each do |t|
    ventasTotales += (t.total).to_i
    ventasB2c += (t.total).to_i
    numVentasTotales += 1
    numVentasB2c += 1
  end
  Factura.where(clinte:'internacional').each do |f|
    ventasTotales += (f.total).to_i
    ventasFtp += (f.total).to_i
    numVentasTotales += 1
    numVentasFtp += 1 
  end
  Factura.where(clinte:'b2b').each do |f|
    ventasTotales += (f.total).to_i
    ventasB2b += (f.total).to_i
    numVentasTotales += 1
    numVentasB2b += 1
  end
  @graficoVentas = Gchart.bar(:size => '400x400', :theme => :keynote, :title => "Número de ventas por canal", :bg => 'efefef', :axis_with_labels => 'y', :legend => ['Ventas Totales', 'Ventas B2b', 'Ventas Ftp', 'Ventas B2c'], :data => [[numVentasTotales],[0, numVentasB2b], [0,0,numVentasFtp], [0,0,0,numVentasB2c]], :axis_range => [[0,numVentasTotales,numVentasTotales/10]], :max_value => numVentasTotales)
  @graficoVentasPesos = Gchart.bar(:size => '400x400', :theme => :keynote, :title => "Ingresos de ventas por canal", :bg => 'efefef', :axis_with_labels => 'y', :legend => ['Ventas Totales', 'Ventas B2b', 'Ventas Ftp', 'Ventas B2c'], :data => [[ventasTotales],[0, ventasB2b], [0,0,ventasFtp], [0,0,0,ventasB2c]], :axis_range => [[0,ventasTotales,ventasTotales/10]], :max_value => ventasTotales)
end 
end
