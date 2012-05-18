require '../utils/utils'

module RubyQuizSolvers

  # Square grid (order n**2, where n is an integer > 1). Grid points are
  # spaced on the unit lattice with (0, 0) at the lower left corner and
  # (n-1, n-1) at the upper right.
  class Grid
     attr_reader :n, :pts, :min
     def initialize(n)
        raise ArgumentError unless Integer === n && n > 1
        @n = n
        @pts = []
        n.times do |i|
           x = i
           n.times { |j| @pts << [x, j] }
        end
        # @min is length of any shortest tour traversing the grid.
        @min = n * n
        @min += Math::sqrt(2.0) - 1 if @n & 1 == 1
     end
  end

  # Solver for RubyQuiz problem 142 - Itinerary for a Traveling Salesman.
  # => http://www.rubyquiz.com/quiz142.html
  #
  # This solution uses a genetic algorithm with randomly selected genetic operators to search for a solution
  # 
  # Created by Bruno Gonçalves <brunodfg@gmail.com>
  # Created on 10/05/2012
  #
  class TravelingSalesmanSolver

      POPULATION_SIZE = 100
      MAX_MUTATION_RATE = 0.3
      MAX_GENERATIONS = 50000
      GENETIC_OPERATORS = [:middle_swap, :random_mutation, :partially_mapped_crossover]

      def initialize(n)
        @grid = Grid.new(n)
      end

      # Returns an array with three positions containing:
      # => [0] The itinerary which minimizes the distance traveled by the salesman
      # => [1] The distance of the itinerary
      # => [2] The generation on which the itinerary was found
      #
      # Returns an empty array if no solution has been found after the configured number of generations.
      def solve()
        
        target_fitness = @grid.min * 1.05
        generation = 0
        solution = nil
        population = initialize_population()
        fitnesses  = population.map { |p| get_fitness(p) }

        # Evolve population
        while generation < MAX_GENERATIONS && !solution

            generation = generation + 1
            next_generation = []

            # Reproduce to make the next generation of solutions
            while next_generation.size < POPULATION_SIZE do

              # Random selection of parents
              parents = [population[rand(population.size)], population[rand(population.size)]]

              # Reproduction / Mutation
              operator = method(GENETIC_OPERATORS[rand(GENETIC_OPERATORS.size)])

              if operator.arity == 1
                next_generation << operator.call(parents[0])
              else
                next_generation << operator.call(parents[0], parents[1])
              end

            end

            # Concatenate parents and new children and make the new generation the most fit elements
            population = next_generation + population
            population = population.sort_by { |x| get_fitness(x) }.take(POPULATION_SIZE)
            fitnesses  = population.map { |p| get_fitness(p) }

            # Check solution in current population
            min_fitness = fitnesses.min           
            solution = population[fitnesses.index(min_fitness)] if min_fitness <= target_fitness

        end

        return [solution, min_fitness, generation]

      end

      private

      def initialize_population()

        population = []
        POPULATION_SIZE.times do |i|
          population << random_itinerary()
        end

        return population

      end

      def random_itinerary()
        
        itinerary = []
        available_nodes = Array.new(@grid.pts)

        while available_nodes.size > 0
          itinerary << available_nodes.delete_at(rand(available_nodes.size))
        end

        return itinerary

      end

      ###########################################
      # Generic Operators - [Start]
      ###########################################

      # Randomly generates three mutation points and swaps the two middle blocks
      def middle_swap(parent)
      
        p1, p2, p3 = Utilities::RandomUtilities.mrand(3, parent.size).sort
        return parent[0...p1] + parent[p2..p3] + parent[p1...p2] + parent[(p3+1)..-1]

      end

      # Given the configured mutation rate, randomly chooses n nodes and swaps them between each other
      def random_mutation(parent)
       
        mutation_size = (parent.size * MAX_MUTATION_RATE).to_i
        source_mutation_points = Utilities::RandomUtilities.mrand(mutation_size, parent.size)
        target_mutation_points = Utilities::RandomUtilities.mrand(mutation_size, parent.size)
        
        # Asexual reproduction
        child = parent.dup

        # Mutation
        for i in 0...mutation_size
          s, t = source_mutation_points[i], target_mutation_points[i]
          child[s], child[t] = child[t], child[s]
        end

        return child

      end

      def partially_mapped_crossover(a, b)

        crossover_point = rand(a.size)
        child = a.dup

        for i in 0...crossover_point
          new_gene = b[i] 
          old_gene = child[i]
          duplicated_gene_index = child.index(new_gene)
          child[i] = new_gene
          child[duplicated_gene_index] = old_gene
        end

        return child

      end

      ###########################################
      # Generic Operators - [End]
      ###########################################

      # Given an itinerary for the salesman, the fitness of the solution is the path's distance.
      # An itinerary is a list of nodes.
      def get_fitness(itinerary)

        fitness = 0
        for i in 0...(itinerary.size-1)
          fitness += get_distance(itinerary[i], itinerary[i+1])
        end
        fitness += get_distance(itinerary.last, itinerary.first)
        
        return fitness

      end

      # Calculates the euclidean distance between two points in the grid.
      def get_distance(a, b)

        dist_x = (a[0] - b[0]).abs
        dist_y = (a[1] - b[1]).abs

        return Math::sqrt(dist_x**2 + dist_y**2)

      end
  end

end

beginning_time = Time.now
solver = RubyQuizSolvers::TravelingSalesmanSolver.new(7)
solution = solver.solve()
end_time = Time.now

if solution
  puts "Time: #{(end_time - beginning_time)} seconds | Fitness: #{solution[1]} | Generation: #{solution[2]} | Solution: #{solution[0]}"
else
  puts "No solution found"
end




