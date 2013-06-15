class Pair < Array
    def initialize(element1 = nil,element2 = nil)
        @elem1 = element1
        @elem2 = element2
    end

    def car; @elem1 || 'NIL' end
    def cdr; @elem2 || 'NIL' end

    def cadr
        raise Exception,Pair.not_pair_err(cdr)  if cdr.nil? || !cdr.is_a?(Pair)
        cdr.car
    end

    def cdar
        raise Exception, Pair.not_pair_err(car) if car.nil? || !car.is_a?(Pair)
        car.cdr
    end

    def caar
        raise Exception, Pair.not_pair_err(car) if car.nil? || !car.is_a?(Pair)
        car.car
    end

    def to_s
        first = @elem1 || 'NIL'
        if @elem2.nil?
            second = ''
        else
            elem2 = @elem2.to_s
            second = @elem2.is_a?(Pair) ? '  '+ elem2.to_s[1...elem2.length-1] : ' . ' + elem2
        end
        "(#{first}#{second})"
    end

    @@NOT_PAIR_ERR = ' is not a pair'

    def self.not_pair_err arg
        "#{arg}" + @@NOT_PAIR_ERR
    end
end

=begin
pair = Pair.new 1,2
pair2 = Pair.new pair,3
print pair2.method(:cdar).call
=end