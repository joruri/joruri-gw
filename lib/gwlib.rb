#利用法
# require 'gwlib'
#
# GwLib::foo()
# GwLib.foo()
# 
# include GwLib
# foo()


module GwLib
	def add(a, b)
		return a + b
	end

  def nz(value, valueifnull='')
    value.blank? ? valueifnull : value
  end
	
	module_function :nz
	module_function :add
end
