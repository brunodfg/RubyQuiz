module Utilities

  class RandomUtilities
  
    # Multiple random - returns an array with n random numbers up until a max value
    def self.mrand(n, max)

        numbers = Array.new(n, nil)
        return numbers.map { |x| rand(max) }

    end

  end

  # Randomly selects array items based on weights specified for each itemg
  # The heigher the weight, more chances are for the item to be randomly selected
  class RouletteWheel

      # Initialized with a list of items and their weights.
      def initialize(slots = [], weights = [])

        raise "slots and weights must have same size" if slots.size != weights.size && weights.size > 0

        weights = Array.new(slots.size, 1) if !weights  || weights.size == 0
        total = weights.inject { |sum, item| sum + item}

        @slots = slots
        @probabilities = weights.map { |item| item.to_f / total.to_f} # percentage of item's fitness in the array

      end

      # Returns an array with n items from the specified array randomly selected based on their weights
      def roll(n)

        tmp = [@probabilities[0]]
        for i in 1...@probabilities.size
          tmp[i] = tmp[i-1] + @probabilities[i]
        end

        results = []
        n.times do          
          lucky_number = rand(0.0..1.0)
          i = 0
          while i < tmp.size
            if lucky_number <= tmp[i]
              results << @slots[i]
              break
            end
            i += 1
          end
        end

        return results

      end

  end

end