module CFDI
   class Impuesto #< Base #REVISAR LOS METODOS DE LA CLASE PADRE
     @cadenaOriginal =[:traslados]#, :detained
     attr_accessor(*@cadenaOriginal)
     attr_accessor :traslados_cadena_original#,:resummen_traslados_cadena_original

     def initialize
       @traslados = []
       @traslados_cadena_original=[]
       #@resummen_traslados_cadena_original=[]
       #@detained = []
     end
     # retorna el total de impuestos trasladados
     def total_traslados
       return 0 unless @traslados.any?
       @traslados.map(&:import).reduce(:+) #suma el importe de todos los impuestos trasladados
     end
     # retorna el numero total de los impuestos(trasladados y retenidos), pero como ya borré los retenidos pues no jaja :P
     def count_impuestos
       @traslados.count #+ @detained.count
     end
     #Esta es la función principal para agregar los impuestos a los conceptos
     def traslados=(data)
       if data.is_a? Array #En caso de que sea un arreglo
         data.map do |c|
           c = Traslado.new(c) unless c.is_a? Traslado
           @traslados << c
         end
       elsif data.is_a? Hash #O en el caso de quehtml_document sea un hash
         @traslados << Traslado.new(data)
       elsif data.is_a? Traslado
         @traslados << data
       end
       @traslados
     end

     def traslados_cadena_original
       #os = []
       @traslados.each do |trans|
         @traslados_cadena_original << trans.cadena_original #Mejor como un arreglo para relacionar cada concepto con su impuesto a la hora de iterar
       end
       @traslados_cadena_original
     end

  #   def resummen_traslados_cadena_original
  #     @traslados.each do |resumen_t|

  #       resummen_traslados_cadena_original<<  resumen_t[:tax]
#     end
#     end

     class Traslado
       attr_accessor  :base, :tax, :type_factor, :rate, :import #solo eran {impuesto, tasa, importe} pero como al SAT se le ocurrieron otros dos jaja
       #:Base, :Impuesto, :TipoFactor, :TasaOCuota, :Importe
       def initialize(args = {})
         args.each { |key, value| send("#{key}=", value) }
       end
       def base=(base)
         @base=format('%.2f', base).to_f
       end

       def rate=(rate)
         @rate = rate
       end

       def import
         @import = format('%.2f', @rate*@base).to_f
       end

       def cadena_original
         [ @base, @tax, @type_factor, @rate, import] #Se le pasa la función y no el atributo para que sea parte de la cadena_original.
       end
     end

#POR SI SE LLEGAN A IMPLEMENTAR LOS IMPUESTOS RETENIDOS

     # return total of all detained taxes.
     #def total_detained
       #return 0 unless @detained.any?
       #@detained.map(&:import).reduce(:+)
     #end

=begin
     def detained=(data)
       if data.is_a? Array
         data.map do |c|
           c << Detained.new(c) unless c.is_a? Detained
           @detained << c
         end
       elsif data.is_a? Hash
         @detained << Detained.new(data)
       elsif data.is_a? Detained
         @detained << data
       end
       @detained
     end
=end
     # devulve la cadena original de todos los impuestos trasladados

=begin
      return original string of all detained taxes.
     def detained_original_string
       os = []
       @detained.each do |detaind|
         os += detaind.original_string
       end
       os
     end
   end
=end

=begin
   class Detained
     attr_accessor :tax, :rate, :import

     def initialize(args = {})
       args.each { |key, value| send("#{key}=", value) }
     end

     def rate=(rate)
       @rate = format('%.2f', rate).to_f
     end

     def import=(import)
       @import = format('%.2f', import).to_f
     end

     def original_string
       [@tax, @rate, @import]
     end
   end
=end
  end
end
