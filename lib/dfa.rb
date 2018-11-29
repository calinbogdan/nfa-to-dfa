require 'set'

class BlockedError < ArgumentError
end

class WordNotInAlphabetError < ArgumentError
end

class DeterministicFiniteAutomaton
  attr_accessor :states, :final_states, :initial_state
  attr_accessor :alphabet, :states_transitions

  # Nothing but a constructor
  def initialize
    @final_states = []
    @alphabet = []
    @states = []
    @initial_state = ''
    @states_transitions = []
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
        dfa.initial_state = [state]
      elsif state.include? '+'
        state.sub! '+', ''
        dfa.final_states.push([state])
      end
    end

    dfa.states.map! { |state| [state] }

    file_lines[1..-1].each do |line|
      line_chars = line.split[1..-1]
      line_chars.each_with_index do |line_char, lc_index|
        dfa.states_transitions.push(
          from: [line.split[0].sub('-', '').sub('+', '')],
          char: dfa.alphabet[lc_index],
          to: [line_char]
        )
      end
    end
    dfa
  end

  # well
  def to_s
    "AFD: stari - #{@states}, alfabet: #{@alphabet}, stari finale: #{@final_states}, stare initiala: #{@initial_state}."
  end

  def delta(from, char)
    query = @states_transitions.select{|t| t[:from] == from && t[:char] == char}

    if query.empty?
      '#'
    else
      query.first[:to]
    end
  end

  def minimize!
    partitions = []

    first_partition = []
    first_partition.push(@final_states)
    first_partition.push(@states - @final_states)

    partitions.push(first_partition)

    until partitions.size != partitions.uniq.size
      partition = partitions.last.dup


      partition.each do |partition_element|
        similarity_check = []

        partition_element.each do |state|
          @alphabet.each do |letter|
            check = {state: state, char: letter, result: delta(state, letter)}
            similarity_check.push(check) unless check[:result] == '#'
          end
        end

        duplicates = similarity_check
                    .group_by{|sc| sc[:result]}

        duplicates.each do |key, states|
          partition.push([partition_element.delete(states.first[:state])]) if states.size > 1
        end
      end

      partitions.push(partition)
    end


  end

  def check(word)
    word_chars = word.chars

    raise WordNotInAlphabetError unless word_chars.all? { |char| @alphabet.include? char }

    current_state = @initial_state
    until word_chars.empty?
      character = word_chars.shift
      next_state = @states_transitions.select do |state_trans|
        state_trans[:from] == current_state && state_trans[:char] == character
      end


      # if no next_state has been found and this isn't a final state,
      # it means it is blocked
      raise BlockedError if next_state.empty?

      current_state = next_state[0][:to]
    end

    @final_states.include? current_state
  end
end
