require_relative './lib/dfa'

dfa = DeterministicFiniteAutomaton.from_file('source.txt')

puts dfa

while true
  print 'Cuvant: '
  word = gets.strip
  break if word.to_s.casecmp("QUIT").zero?

  begin
    puts "Cuvantul #{word} este #{dfa.check(word) ? 'acceptat' : 'respins'}."
  rescue WordNotInAlphabetError
    puts 'Cuvantul este respins.'
  rescue BlockedError
    puts 'Cuvantul este blocat.'
  end
end
