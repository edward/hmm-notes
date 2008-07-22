# I don’t remember if I (Edward Ocampo-Gooding) wrote this or not. If I didn’t,
#  please give me a shoutout.
# This code is massaged out of Sean R. Eddy’s “What is a hidden Markov model?”, which I’ll throw in this repo.

# When you run this thing, the key idea is that we’re taking a genomic sequence
# (the top sequence), and trying to decode that to find where the end of the
# gene is (or at least, that’s what I loosely remember).
# 
# The end of a gene (again, I’m probably wrong, but whatever) corresponds to
# 
#   [some E states] [5' (five-prime) splice site] [some I states (for intron)]
# 
#   An E state is an exon, or stuff that gets genetically expressed
#   A 5' state (pronounced “five-prime”) is the splice site (between E and I)
#     An I state is an intron, representing intragenic regions which don’t get
#     genetically expressed

# Note that this is just an exercise in demonstrating Viterbi decoding

# Represents states in a Markov model
#
# Example usage:
#
#    e = State.new("E")
#    five = State.new("5")
#    i = State.new("I")
#
#    e.emissions = {"A" => 0.25, "C" => 0.25, "G" => 0.25, "T" => 0.25}
#    e.transitions = {:E => 0.9, :"5" => 0.1}
#    puts e.emit
#    puts e.transmit
#
#    five.emissions = {"A" => 0.05, "C" => 0.0, "G" => 0.95, "T" => 0.0}
#    five.transitions = {:I => 1.0}
#
#    i.emissions = {"A" => 0.4, "C" => 0.1, "G" => 0.1, "T" => 0.4}
#    i.transitions = {:end => 0.1, :I => 0.9}
#

# Move the check for prob = 1.0 to initialize, emissions(), and transitions()

class State
  def initialize(name, emissions = nil, transitions = nil)
    @name = name.to_sym
  end
  attr_accessor :name, :emissions, :transitions
  
  # Based on the emission probabilities, emit something
  def emit
    probs_choose(@emissions)
  end
  
  def transmit
    probs_choose(@transitions)
  end
  
  def to_s
    @name.to_s
  end
  
  private
  
  # Takes a probabilities hash +h+ and returns a symbol
  def probs_choose(h)
    # Seriously lame but simple way to choose: use an array of size 100
    p = []
    h.each do |key, val|
      # insert probabilities into the array
      (val * 100).to_int.times { p << key  } 
    end
    raise "Probabilities don't add up to 100" if p.size != 100
    p[rand(100)]
  end
end 

# Represents a Markov model
class MModel
  def initialize(state_list)
    @state_list = state_list
    sanity_check
  end
    
  # Step through the machine, transitioning according to each state's
  # probabilities; used to generate a string of states
  def transit_and_emit
    # Contains an array of tuples [observed state, hidden state]
    chains = []
    
    s_list = @state_list
    
    # print "States: "
    # s_list.each {|s| print s.to_s + " "}
    # print "\n"
    
    current_state = s_list.first
    loop do
      # puts "Current state: #{current_state}"
            
      emitted = current_state.emit
      # puts "Emitted state: #{emitted}"
      
      chains << [emitted, current_state.name]

      next_state = current_state.transmit

      # puts "Transitioning to " + next_state.inspect
      
      break if next_state == :end

      if next_state.nil?
        raise "Transition to non-existant state; no can do"
      end
      
      current_state = s_list.find do |s|
        s.name == next_state
      end
    end
    return chains
  end
  
  # # Given a list of observable emissions, calculate its probability/likelihood by multiplying the probabilities of each emission from each matching (hidden) state
  # def forward(emissions)
  #   emissions = emissions.split if emissions.class? == String
  #   probs = []
  #   emissions.each do |emission|
  #     state_list.each do |state|
  # 
  #     end
  #   end
  # end
  
  # Align a sequence of emissions to the model by matching each emission with the most likely (hidden) state.
  def viterbi(emissions)
    emissions = emissions.split if emissions.class? == String
    viterbi_path = []
    viterbi_probability = 0

    # Look at each emission
    emissions.each do |emission|
      
      # Look at each possible next state
      
        # Choose the most likely next state and add it to the Viterbi path
        # Choose by multiplying the transition and emission probabilities of the possible next state and choosing the state that scores best
      
      
    end        
        
    return [viterbi_path, viterbi_probability]
  end
  
  private
  
# Check that each state's emmission and transition probabilities add up to 1.0
# and that there's at least one :end symbol in a transition somewhere
  def sanity_check
    # Check probabilities
    @state_list.each do |s|
      if (s.emissions.values.inject { |sum, p| sum + p }) < 1.0
        raise "Emission probabilities don't add up to 1.0" 
      end
      
      if (s.transitions.values.inject { |sum, p| sum + p }) < 1.0
        raise "Transition probabilities don't add up to 1.0"
      end
    end
    
    # Check for :end
    unless @state_list.find { |s| s.transitions[:end] }
      raise "Cannot find a transition to a final state."
    end
  end
end

e = State.new("E")
five = State.new("5")
i = State.new("I")

e.emissions = {"A" => 0.25, "C" => 0.25, "G" => 0.25, "T" => 0.25}
e.transitions = {:E => 0.9, :"5" => 0.1}

five.emissions = {"A" => 0.05, "C" => 0.0, "G" => 0.95, "T" => 0.0}
five.transitions = {:I => 1.0}

i.emissions = {"A" => 0.4, "C" => 0.1, "G" => 0.1, "T" => 0.4}
i.transitions = {:end => 0.1, :I => 0.9}

m = MModel.new([e, five, i])

answer = m.transit_and_emit

def print_answer(answer)
  answer.each { |o| print o[0].to_s + " "} ; print "\n"
  answer.each { |h| print h[1].to_s + " " }  
end

print_answer(answer)