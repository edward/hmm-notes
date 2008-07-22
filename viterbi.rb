# From http://en.wikipedia.org/wiki/Viterbi_algorithm (ported from the Python version)

# The key idea here is that the Viterbi algorithm is used when you know the parameters of the HMM and a string of observation symbols, but you don’t know the sequence of hidden states that produced those observations. This algorithm guesses at what that sequence of hidden states was. This sequence of hidden paths is also known as the Viterbi path.

# Note that the Forward and Viterbi algorithms are different, but closely related enough that we can roll them into one:
#   Forward: “What’s the probability of a sequence of observed events?”
#   Viterbi: “What’s the most likely sequence of hidden states?”

# The function forward_viterbi takes the following arguments: y is the sequence of observations, e.g. ['walk', 'shop', 'clean']; X is the set of hidden states; sp is the start probability; tp are the transition probabilities; and ep are the emission probabilities.
# 
# The algorithm works on the mappings T and U. Each is a mapping from a state to a triple (prob, v_path, v_prob), where prob is the total probability of all paths from the start to the current state, v_path is the Viterbi path up to the current state, and v_prob is the probability of the Viterbi path up to the current state. The mapping T holds this information for a given point t in time, and the main loop constructs U, which holds similar information for time t+1. Because of the Markov property, information about any point in time prior to t is not needed.
# 
# The algorithm begins by initializing T to the start probabilities: the total probability for a state is just the start probability of that state; and the Viterbi path to a start state is the singleton path consisting only of that state; the probability of the Viterbi path is the same as the start probability.
# 
# The main loop considers the observations from y in sequence. Its loop invariant is that T contains the correct information up to but excluding the point in time of the current observation. 
# 
# The algorithm then computes the triple (prob, v_path, v_prob) for each possible next state. 
# 
# The total probability of a given next state, total, is obtained by adding up the probabilities of all paths reaching that state. More precisely, the algorithm iterates over all possible source states. 
# 
# For each source state, T holds the total probability of all paths to that state. This probability is then multiplied by the emission probability of the current observation and the transition probability from the source state to the next state. The resulting probability prob is then added to total.
# 
# The probability of the Viterbi path is computed in a similar fashion, but instead of adding across all paths one performs a discrete maximization. Initially the maximum value valmax is zero. For each source state, the probability of the Viterbi path to that state is known. This too is multiplied with the emission and transition probabilities and replaces valmax if it is greater than its current value. The Viterbi path itself is computed as the corresponding argmax of that maximization, by extending the Viterbi path that leads to the current state with the next state. The triple (prob, v_path, v_prob) computed in this fashion is stored in U and once U has been computed for all possible next states, it replaces T, thus ensuring that the loop invariant holds at the end of the iteration.
# 
# In the end another summation/maximization is performed (this could also be done inside the main loop by adding a pseudo-observation after the last real observation).

hidden_states = %w(Rainy Sunny)
observations = %w(walk shop clean)
start_probability = {'Rainy' => 0.6, 'Sunny' => 0.4}

transition_probabilities = {
  'Rainy' => {'Rainy' => 0.7, 'Sunny' => 0.3},
  'Sunny' => {'Rainy' => 0.4, 'Sunny' => 0.6},
}

emission_probabilties = {
  'Rainy' => {'walk' => 0.1, 'shop' => 0.4, 'clean' => 0.5},
  'Sunny' => {'walk' => 0.6, 'shop' => 0.3, 'clean' => 0.1},
}

def forward_viterbi(observations, hidden_states, start_probability,
                    transition_probabilities, emission_probabilties)

  # Both t and u are mappings of a state to a triple (prob, v_path, v_prob)
  # where prob: total probability of all paths from the start to the current state
  #       v_path: path of hidden states up to the current
  #       v_prob: probability of path up to the current state
  #
  # t starts out at the first state, so give it the start probabilities
  t = {}
  for state in hidden_states
    #          prob.                      V. path  V. prob
    t[state] = [start_probability[state], [state], start_probability[state]]
  end
  
  
  # Find the next state by computing u for each possible next state
  # (Look through each observable emission)
  for emission in observations
    
    u = {}
    for next_state in hidden_states
      
      # total probability of a given next state (sum of probabilities of paths leading there)
      total = 0
      argmax = nil
      valmax = 0
      
      # Get total prob. of next state by adding up the probabilities of all 
      # paths reaching that state. (Prob so far is carried in t[source_state])
      for source_state in hidden_states
        prob, v_path, v_prob = t[source_state]
        p = emission_probabilties[source_state][emission] * 
              transition_probabilities[source_state][next_state]
        prob *= p
        v_prob *= p
        total += prob
        if v_prob > valmax
          argmax = v_path + [next_state]
          valmax = v_prob
        end
      end
      u[next_state] = [total, argmax, valmax]
    end
    t = u
  end
  
  # apply sum/max to the final states
  total = 0
  argmax = nil
  valmax = 0
  for state in hidden_states
    prob, v_path, v_prob = t[state]
    total += prob
    if v_prob > valmax
      argmax = v_path
      valmax = v_prob
    end
  end
  return [total, argmax, valmax]
end

puts forward_viterbi(observations, hidden_states, start_probability, transition_probabilities, emission_probabilties).inspect

# This reveals that the total probability of ['walk', 'shop', 'clean'] is 0.033612 and that the Viterbi path is ['Sunny', 'Rainy', 'Rainy', 'Rainy']. The Viterbi path contains four states because the third observation was generated by the third state and a transition to the fourth state. In other words, given the observed activities, it was most likely sunny when your friend went for a walk and then it started to rain the next day and kept on raining.