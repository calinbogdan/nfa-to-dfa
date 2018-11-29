require_relative '../lib/dfa'

class NondeterministicFiniteAutomaton
  attr_accessor :states, :final_states, :initial_states
  attr_accessor :delta, :alphabet, :states_transitions

# Nothing but a constructor
  def initialize
    @final_states = []
    @alphabet = []
    @states = []
    @initial_states = []
    @states_transitions = []
  end

# Generates a deterministic finite automata from the given file
  def self.from_file(file_name)
    file = File.new(file_name, 'r')
    file_lines = file.readlines
    nfa = new

    nfa.alphabet = file_lines[0].to_s.split
    nfa.states = file_lines[1..-1].map { |line| line.to_s.split[0] }


    nfa.states.each do |state|
      if state.include? '-'
        state.sub! '-', ''
        nfa.initial_states.push(state)
      elsif state.include? '+'
        state.sub! '+', ''
        nfa.final_states.push(state)
      end
    end

    file_lines[1..-1].each do |line|
      line_chars = line.split[1..-1]
      line_chars.each_with_index do |line_char, lc_index|
        nfa.states_transitions.push(
            from: line.split[0].sub('-', '').sub('+', ''),
            char: nfa.alphabet[lc_index],
            to: line_char.split(',')
        )
      end
    end
    nfa
  end

# well
  def to_s
    "AFN: stari - #{@states}, alfabet: #{@alphabet}, stari finale: #{@final_states}, stare initiala: #{@initial_states}."
  end

  def to_dfa
    dfa = DeterministicFiniteAutomaton.new

    checked_states = [@initial_states]
    states = []

    until checked_states.empty?
      state = checked_states.shift

      @alphabet.each do |letter|
        results = []

        @states_transitions.select{|t| state.include? t[:from]}.each do |tr|
          tr[:to].each do |to|
            results.push(to) if tr[:char] == letter && to != '#' && !results.include?(to)
          end
        end

        next unless !checked_states.include?(results) && !states.include?(results)

        state_transition = {from: state, char: letter, to: results}
        dfa.states_transitions.push(state_transition) unless dfa.states_transitions.include? state_transition
        checked_states.push(results)
      end

      states.push(state) unless states.include? state
    end

    dfa.alphabet = @alphabet
    dfa.states = states.uniq
    dfa.final_states = states.select{|state| (state & @final_states).any?}
    dfa.initial_state = @initial_states
    dfa.minimize!

    dfa
  end

  def check(word)
    to_dfa.check(word)
  end
end