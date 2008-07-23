# Methods and variables for interacting with the gnuplot process.  Most of
# these methods are for sending data to a gnuplot process, not for reading from
# it.  Most of the methods are implemented as added methods to the built in 
# classes.

require 'matrix'
 
module Gnuplot

  # Open a gnuplot process that exists in the current PATH.  If the persist
  # flag is true then the -persist flag is added to the command line.  The
  # path to the gnuplot executable is determined using the 'which' command. 
  #
  # See the gnuplot documentation for information on the persist flag.
  #
  # <b>todo</b> Add a method to pass the gnuplot path to the function.
  
  def Gnuplot.open(persist=true)
    cmd = ""
    IO.popen( "which gnuplot" ) { |io| cmd = io.readline.chomp }
    cmd += " -persist" if persist
    
    IO::popen(cmd, "w") { |io| yield io }
  end 
    
    
  # Holds command information and performs the formatting of that command
  # information to a Gnuplot process.  When constructing a new plot for
  # gnuplot, this is the first object that must be instantiated.  On this
  # object set the various properties and add data sets.

  class Plot
    attr_accessor :cmd, :data, :sets

    QUOTED = [ "title", "output", "xlabel", "ylabel" ]

    def initialize (io = nil, cmd = "plot")
      @cmd = cmd
      @sets = []
      @data = []
      yield self if block_given?
      
      io << to_gplot if io
    end

    # Invoke the set method on the plot using the name of the invoked method
    # as the set variable and any arguments that have been passed as the
    # value. See the +set+ method for more details.

    def method_missing( methId, *args )
      set methId.id2name, *args
    end


    # Set a variable to the given value.  +Var+ must be a gnuplot variable and
    # +value+ must be the value to set it to.  Automatic quoting will be
    # performed if the variable requires it.  
    #
    # This is overloaded by the +method_missing+ method so see that for more
    # readable code.

    def set ( var, value = "" )
      #value = "'#{value}'" if QUOTED.include? var unless value =~ /^'.*'$/
      value = "\"#{value}\"" if QUOTED.include? var unless value =~ /^'.*'$/
      @sets << [ var, value ]
    end


    # Return the current value of the variable.  This will return the setting
    # that is currently in the instance, not one that's been given to a
    # gnuplot process.

    def [] ( var )
      v = @sets.assoc( var )
      v[1] || nil
    end


    def add_data ( ds )
      @data << ds
    end


    def to_gplot (io = "")
      @sets.each { |var, val| io << "set #{var} #{val}\n" }

      if @data.size > 0 then
        io << @cmd << " " << @data.collect { |e| e.plot_args }.join(", ")
        io << "\n"

	v = @data.collect { |ds| ds.to_gplot }
	io << v.compact.join("e\n")
      end

      io
    end
  end


  class SPlot < Plot

    def initialize (io = nil, cmd = "splot")
      super
    end
    
    def to_gplot (io = "")
      @sets.each { |var, val| io << "set #{var} #{val}\n" }

      if @data.size > 0 then
        io << @cmd << " " 
        io << @data.collect { |e| e.plot_args }.join(", ")
        io << "\n"

        @data.each do |ds| 
          io << ds.to_gsplot << "e\n"
        end
      end

      io
    end

  end



  # Container for a single dataset being displayed by gnuplot.  Each object
  # has a reference to the actual data being plotted as well as settings that
  # control the "plot" command.  The data object must support the to_gplot
  # command.
  # 
  # +data+ The data that will be plotted.  The only requirement is that the
  # object understands the to_gplot method.
  #
  # The following attributes correspond to their related string in the gnuplot
  # command. See the gnuplot documentation for more information on this.
  #
  #   title, with
  #
  # @todo Use the delegator to delegate to the data property.

  class DataSet 
    attr_accessor :title, :with, :using, :data, :linewidth, :matrix
  
    def initialize (data = nil)
      @data = data
      yield self if block_given?
    end
        
    def notitle
      @title = "notitle"
    end

    def plot_args (io = "")
      
      # Order of these is important or gnuplot barfs on 'em

      io << ( (@data.instance_of? String) ? @data : "'-'" )

      io << " using #{@using}" if @using
      
      io << case @title
            when /notitle/ then " notitle"
            when nil       then ""
            else " title '#{@title}'" 
            end

      io << " matrix" if @matrix
      io << " with #{@with}" if @with
      io << " linewidth #{@linewidth}" if @linewidth
      io
    end

    def to_gplot
      case @data
      when nil then nil
      when String then nil
      else @data.to_gplot
      end
    end

    def to_gsplot
      case @data
      when nil then nil
      when String then nil
      else @data.to_gplot
      end
    end
    
  end
end

class Array
  def to_gplot
    if ( self[0].kind_of? Array ) then
      tmp = self[0].zip( *self[1..-1] )
      tmp.collect { |a| a.join(" ") }.join("\n") + "\n"
    elsif ( self[0].kind_of? Numeric ) then
      s = ""
      self.length.times { |i| s << "#{self[i]}\n" }
      s
    else
      self[0].zip( *self[1..-1] ).to_gplot
    end
  end

  def to_gsplot
    f = ""
    
    if ( self[0].kind_of? Array ) then
      x = self[0]
      y = self[1]
      d = self[2]

      x.each_with_index do |xv, i|
        y.each_with_index do |yv, j|
          f << [ xv, yv, d[i][j] ].join(" ") << "\n"
        end
        # f << "\n"
      end
    elsif ( self[0].kind_of? Numeric ) then
      self.length.times do |i| f << "#{self[i]}\n" end
    else
      self[0].zip( *self[1..-1] ).to_gsplot
    end
    
    f
  end
end
   
class Matrix
  def to_gplot (x = nil, y = nil)
    xgrid = x || (0...self.column_size).to_a
    ygrid = y || (0...self.row_size).to_a
  
    f = ""
    ygrid.length.times do |j|
      y = ygrid[j]
      xgrid.length.times do |i|
        if ( self[j,i] ) then
          f << "#{xgrid[i]} #{y} #{self[j,i]}\n"
        end
      end
    end
    
    f
  end

end
