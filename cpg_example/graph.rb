#!/usr/bin/env ruby

require 'gnuplot'

percents = ARGF.read.strip.split(",")

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.term "png"
    plot.title  "Daniel Amelang\\'s CpG Islands"
    plot.ylabel "Percentage of \\'I\\' states"
    plot.xlabel "Base number"
    plot.data << Gnuplot::DataSet.new(percents) do |ds|
      ds.with = "lines"
      ds.notitle
    end
  end
end


