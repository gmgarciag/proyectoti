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
end
