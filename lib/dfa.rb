
class BlockedError < ArgumentError
end

class WordNotInAlphabetError < ArgumentError
end

class DeterministicFiniteAutomaton
  attr_accessor :states, :final_states, :initial_state
  attr_accessor :delta, :alphabet, :states_transformation

  # Nothing but a constructor
  def initialize
    @final_states = []
    @alphabet = []
    @states = []
    @initial_state = ''
    @states_transformation = []
  end

  # Generates a deterministic finite automata from the given file
  def self.from_file(file_name)
    file = File.new(file_name, 'r')
    file_lines = file.readlines
    dfa = new

    dfa.alphabet = file_lines[0].to_s.split
    dfa.states = file_lines[1..-1].map { |line| line.to_s.split[0] }
    

    dfa.states.each do |state|
      if state.include? '-'
        state.sub! '-', ''
        dfa.initial_state = state
      elsif state.include? '+'
        state.sub! '+', ''
        dfa.final_states.push(state)
      end
    end

    alphabet_characters = file_lines[0].split

    file_lines[1..-1].each do |line|
      line_chars = line.split[1..-1]
      line_chars.each_with_index do |line_char, lc_index|
        dfa.states_transformation.push(
          input_state: line.split[0].sub('-', '').sub('+', '-'),
          char: alphabet_characters[lc_index],
          output_state: line_char
        )
      end
    end
    dfa
  end

  # well
  def to_s
    "AFD: stari - #{@states}, alfabet: #{@alphabet}, stari finale: #{@final_states}, stare initiala: #{@initial_state}."
  end

  def check(word)
    word_chars = word.chars

    raise WordNotInAlphabetError unless word_chars.all? { |char| @alphabet.include? char }

    current_state = @initial_state
    until word_chars.empty?
      character = word_chars.shift
      next_state = @states_transformation.select do |state_trans|
        state_trans[:input_state] == current_state && state_trans[:char] == character
      end


      # if no next_state has been found and this isn't a final state,
      # it means it is blocked
      raise BlockedError if next_state.empty?

      current_state = next_state[0][:output_state]
    end

    @final_states.include? current_state
  end
end
