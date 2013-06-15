require_relative 'shell_info.rb'
require_relative '../util/punct'

module SHELL

  def self.then_do
    yield
  end

  class Interaction
    include Punct
    include Toolkit
    def self.display(content='', *more)
      print content, Punct::Space
      more.each do |element|
        print element, Punct::Space
      end
    end

    def self.irlb_with dialect
      lang_parser = SHELL_INFO::select_lang dialect
      raise SHELL_INFO::get_err :NoSuchDialect if lang_parser.nil?
      quit_cmd = SHELL_INFO::command_of :Quit
      help_cmd = SHELL_INFO::command_of :Help
      self.make_greeting
      loop do
        display Punct::Prompt
        begin
          case input = gets
            when quit_cmd[:pattern];    SHELL::then_do &quit_cmd[:action];return
            when help_cmd[:pattern];    SHELL::then_do &help_cmd[:action]
            else
              #actually, the interpreter will be executed here
              display (lang_parser.read input), Punct::Newline
          end
        rescue SXP::Reader::EOF;                display SHELL_INFO::get_err(:EOF), Punct::Newline
        rescue NotImplementedError;             display SHELL_INFO::get_err(:NotImplementedError), Punct::Newline
        end
      end
    end

    def self.make_greeting
      puts Dir.pwd
      task = Toolkit::map_with_ SHELL_INFO::config_of(:Welcome_file),
                                lambda {|each_line| display each_line}, lambda {display  SHELL_INFO::config_of :File_missed}
      task.call
      display Punct::Newline
    end

    def self.support_languages
      SHELL_INFO::get_all_lang
    end

    def self.is_supported?(dialect)
      !SHELL_INFO::select_lang(dialect).nil?
    end

    def initialize; end
    #set as pure static Object
    private :initialize; :welcome
  end
end


