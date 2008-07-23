#!/usr/bin/env ruby

include Math

def viterbi(seq, states, sp, tp, ep)
  t = sp.map {|(state, prob)| [state, [state], prob]}
  seq.inject(t) do |t, sym|
    states.inject([]) do |u, next_state|
      u << t.inject(nil) do |max, (state, path, prob)|
        prob += ep[state][sym] + tp[state][next_state]
        (max and prob <= max[2]) ? max : [next_state, path+[next_state], prob]
      end
    end
  end.max {|l,r| l[2] <=> r[2]}[1]
end

# Set up HMM.
states = [:B, :I]

start_probs = {:B => log(0.5), :I => log(0.5)}

transitions = { :B => {:B => log(0.7), :I => log(0.3)},
                :I => {:B => log(0.5), :I => log(0.5)} }

emissions = { :B => {:a => log(0.25), :t => log(0.40), :c => log(0.10), :g => log(0.25)},
              :I => {:a => log(0.25), :t => log(0.25), :c => log(0.25), :g => log(0.25)} }

# Build sequence from input.
sequence = []
ARGF.each do |line|
  next if line.strip! !~ /^\d/
  sequence.concat(line.scan(/[agct]/).map! {|c| c.to_sym})
end
abort "No sequence found in input!" if sequence.empty?

# Run Viterbi.
puts viterbi(sequence, states, start_probs, transitions, emissions).join
