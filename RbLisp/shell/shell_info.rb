module SHELL_INFO

  require 'sxp'
  require_relative 'interaction.rb'
  require_relative '../util/punct'
  require_relative '../util/toolkit'

  LANGUAGES = {
      :scheme => SXP::Reader::Scheme,
      :commonlisp => SXP::Reader::CommonLisp,
  }

  ERR_MSG = {
      :File_missed => 'file missed.',
      :NotImplementedError => 'unknown',
      :NoSuchDialect => 'sorry, the lisp dialect you require is not supported by this language',
      :EOF => 'Invalid expression.',
  }

  CONFIG = {
      :Welcome_file => './txt/welcome.txt',
      :Help_file => './txt/help.txt',
  }

  COMMAND_SET = {
      :Quit => {
          :pattern => /\(quit\)/,
          :action => lambda {puts}
      },
      :Help => {
          :pattern => /\(help\)/,
          :action => Toolkit::map_with_(CONFIG[:Help_file],
                                        lambda {|each_line| puts each_line},
                                        lambda {puts  ERR_MSG[:File_missed]},
                                        lambda {puts Punct::Newline})
      },
  }

  def self.select_lang lang
    LANGUAGES[lang]
  end

  def self.get_all_lang
    LANGUAGES.keys
  end

  def self.get_err err_sym
    ERR_MSG[err_sym]
  end

  def self.config_of config_key
    CONFIG[config_key]
  end

  def self.command_of com_sym
    COMMAND_SET[com_sym]
  end

end