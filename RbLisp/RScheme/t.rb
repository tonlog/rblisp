class T < TrueClass
    def self.to_s; "#t" end
    def self.inspect; "#t" end
end

class F < FalseClass
    def self.to_s; "#f"  end
    def self.inspect; "#f" end
end