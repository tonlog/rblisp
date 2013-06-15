module RSCHEME_INFO
  load '../util/toolkit.rb'

  ERRMSG = {
       :Undefined_symbol => 'unknown value of symbol: ',
       :Not_operator => 'is not an operator.',
  }

  INIT_GLOBAL = {
    :+ => Toolkit::make_num_compu(lambda {|a1,a2| a1 + a2}, value_for_start = 0),
    :- => Toolkit::make_num_compu(lambda {|a1,a2| a1 - a2}, value_for_start = 0),
    :* => Toolkit::make_num_compu(lambda {|a1,a2| a1 * a2}, value_for_start = 1),
    :/ => Toolkit::make_num_compu(lambda {|a1,a2| a1 / a2}, value_for_start = 1, value_for_nonargs = 0),
  }

  def self.init_global
    INIT_GLOBAL
  end

  def self.get_err err_sym
    ERRMSG[err_sym]
  end

end

