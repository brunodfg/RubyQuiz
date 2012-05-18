require '../graphs/graphs'

module RubyQuizSolvers

	# Solver for Ruby Quiz #27 - Knight's Travails. 
	# => http://www.rubyquiz.com/quiz27.html
	# 
	# Created by Bruno Gonçalves <brunodfg@gmail.com>
	# Created on 10/05/2012
	#
	class KnightSolver

		ROWS = (1..8).to_a.reverse
		COLUMNS = ("a".."h").to_a

		def initialize
		end

		# Determines the shortest path to move a knight from start position (i.e a3) to final position (i.e h5) 
		# on a chess board without landing on positions listed on forbidden_nodes.
		# Rows are represented by numbers (1, 2, 3, ...) and columns by letters (i.e. 'a', 'b', 'c', ...)
		def solve(start_node, end_node, forbidden_nodes = [])

			graph = UndirectedGraph.new

			for x in COLUMNS
				for y in ROWS

					u = "#{x}#{y}"

					# Do not add a node to the graph if it is one of the positions on which the knigth may not land
					if (!forbidden_nodes.include?(u))
						possible_moves = get_possible_moves(u)
						possible_moves.each do |v|
							if (!forbidden_nodes.include?(v))
								graph.add_edge(u, v)
							end
						end
					end

				end
			end

			return graph.find_shortest_path(start_node, end_node)
			
		end

		private

		# Get all valid moves a knight may perform from the given node.
		# A knight's movement is in shape of an L (2x3)
		def get_possible_moves(node)

			destinations = []

			if (node && node.size == 2)

				x = COLUMNS.index(node[0])
				y = node[1].to_i

				if (x >= 0 && x < COLUMNS.size && y >= 0 && y < ROWS.size)

					all_moves = [
						[x + 1, y + 2], [x + 1, y - 2], [x - 1, y + 2], [x - 1, y - 2],
						[x + 2, y + 1], [x + 2, y - 1], [x - 2, y + 1], [x - 2, y - 1]
					]

					# Discard positions out of the board
					destinations = all_moves.select { |d| d[0] >= 0 && d[0] < COLUMNS.size && ROWS.include?(d[1].to_i) }
					destinations = destinations.map { |d| "#{COLUMNS[d[0]]}#{d[1]}" }

				end

			end

			return destinations

		end

	end

end

start_node = "a1"
end_node = "h6"
forbidden_nodes = ["g4", "f5", "f7", "g9"]

solver = RubyQuizSolvers::KnightSolver.new
shortest_path = solver.solve(start_node, end_node, forbidden_nodes).to_s

puts "Shortest path for a chess knight between #{start_node} and #{end_node} avoiding positions #{forbidden_nodes} is: #{shortest_path}"