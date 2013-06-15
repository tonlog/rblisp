#encoding = utf-8
require 'sxp'
require '../RbLisp/shell/interaction'

SHELL::Interaction.irlb_with :scheme

=begin
SHELL::Interaction.display SXP.read '(* 1 2)'
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
=end
