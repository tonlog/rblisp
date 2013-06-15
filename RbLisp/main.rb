#encoding = utf-8
require 'sxp'
require '../RbLisp/shell/interaction'

#SHELL::Interaction.irlb_with :scheme

#print SXP::Reader::Scheme.read '(define \'s #t)'

#begin
#SHELL::Interaction.display SXP.read '(* 1 2)'
SHELL::Interaction.display SXP.read <<-EOX
  (define (fact n)
    (if (= n 0)
      1
      (* n fact (- n 1)
      )
    )
  )
EOX

puts ''
#=end
