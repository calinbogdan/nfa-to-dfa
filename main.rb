require_relative './lib/dfa'
require_relative './lib/nfa'

# dfa = DeterministicFiniteAutomaton.from_file('source.txt')
#
# puts dfa
#
# while true
#   print 'Cuvant: '
#   word = gets.strip
#   break if word.to_s.casecmp("QUIT").zero?
#
#   begin
#     puts "Cuvantul #{word} este #{dfa.check(word) ? 'acceptat' : 'respins'}."
#   rescue WordNotInAlphabetError
#     puts 'Cuvantul este respins.'
#   rescue BlockedError
#     puts 'Cuvantul este blocat.'
#   end
# end


nfa = NondeterministicFiniteAutomaton.from_file('source2.txt')
puts nfa

while true
  print 'Cuvant: '
  word = gets.strip
  break if word.to_s.casecmp("QUIT").zero?

  begin
    puts "Cuvantul #{word} este #{nfa.check(word) ? 'acceptat' : 'respins'}."
  rescue WordNotInAlphabetError
    puts 'Cuvantul este respins.'
  rescue BlockedError
    puts 'Cuvantul este blocat.'
  end
end
