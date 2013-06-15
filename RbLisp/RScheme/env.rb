class Env < Hash
  attr_accessor :super_env
  alias :hash_get :[]

  def initialize(init_env)
    @super_env = init_env[:super_env]
    raise Exception unless @super_env.nil? || @super_env.is_a?(Env)
  end

  def escape_env; @super_env = nil end

  def [](symbol)
    hash_get symbol || @super_env.nil? || @super_env[symbol]
  end
end





