# This demos an HMM answering the question “Given a sequence, how probable is
# it?”, or “how well does this match?”

# The story is that you’re in a casino, and based on what you’ve seen by just watching the dealer is that the bastard uses both a fair coin and a biased one. Not only that, but you’ve determined the probabilities of each coin’s observable states: how often it’s heads or tails.

# Your job is to take this HMM (really just a table of the hidden, unknown
# states and their observable probabilities) and given a sequence of coin flips
# if the dealer has switched coins on you so you can rightfully beat the crap
# out of him.

require "pp"
include Math

def flip_fair_coin
  rand < 0.5 ? "H" : "T"
end

def flip_biased_coin
  rand < 0.75 ? "H" : "T"
end

class String
  def is_biased?
    log_odds_ratio(self) < 0 ? true : false
  end
end

# By taking the log(Probability of a fair coin) - log(Probability of a biased
# coin), we can make a good guess at which coin was used: if it's below 0,
# then the list was probably produced using a biased coin.
def log_odds_ratio(flip_list)
  flip_list.length - flip_list.count("H") * (log(3)/log(2))
end

puts "Welcome to the Fair Bet casino! We only use fair coins around here..."

# generate array of 10 flips using a fair coin
true_flips = String.new
10.times {true_flips << flip_fair_coin}

pp true_flips

biased_flips = String.new
10.times {biased_flips << flip_biased_coin}

pp biased_flips

puts "Log odds ratio for the fair list: #{log_odds_ratio(true_flips)}"

true_flips.is_biased? ? puts("This list is biased") : puts("This list is fair")

puts "Log odds ratio for the biased list: #{log_odds_ratio(biased_flips)}"

biased_flips.is_biased? ? puts("This list is biased") : puts("This list is fair")