class UndirectedGraph

	def initialize
		# Hash of hashes containing for each node (key) a list of edges (value) to other nodes
		@edges = {}
	end	

	# Adds the nodes to the graph if they haven't already been added and
	# adds an edge from node u to node v with the specified weight (defaults to 1).
	# Since this is an undirected graph, this edge exists both ways u->v and v->u
	def add_edge(u, v, weight = 1)
		@edges[u] = {} unless @edges.has_key?(u)
		@edges[v] = {} unless @edges.has_key?(v)
		@edges[u].update({v => Edge.new(u, v, weight)})
		@edges[v].update({u => Edge.new(v, u, weight)})
	end

	# Uses Dijkstra's algorithm to find the shortest path from start_node to end_node
	def find_shortest_path(start_node, end_node)

		if (!start_node || !end_node)
			raise "start and end nodes must be specified"
		end

		queue = Hash[@edges.keys.map { |k| [k, nil] }]
		queue[start_node] = 0

		distances = queue.dup
		crumbs = {}

		while queue.size > 0

			expanded_node = get_min(queue)

			# Check if the current path to each neighbor of the expanded_node
			# is shorter than the path currently stored on the distances hash
			@edges[expanded_node].each do |node, edge|

				if distances[expanded_node]
				
					current_path_distance = distances[expanded_node] + edge.weight

					# The distance to node is shorter via the current path or the distance to node hasn't yet been computed.
					# Either way, the distance from start_node->node is updated with the current distance (since it is shorter)
					if (!distances[node] || current_path_distance < distances[node])
						distances[node], queue[node] = current_path_distance, current_path_distance
						crumbs[node] = expanded_node
					end

				end

			end

			queue.delete(expanded_node)

		end

		# List of edges representing the shortest path from start_node to end_node
		shortest_path = []
		current_node = end_node

		while (current_node && current_node != start_node && crumbs.size > 0)
			previous_node = crumbs[current_node]
			if (previous_node)
				shortest_path << @edges[previous_node][current_node]
				crumbs.delete(current_node)
			end
			current_node = previous_node
		end

		return shortest_path.reverse

	end

	def to_s
		return @edges.values.map { |x| x.values.join(" | ") }.join { " | "}
	end

	private

	# TODO: Refactor to use a PriorityQueue
	def get_min(pq)
		min_distance = nil
		min_key = nil
		if (pq.size > 0)
			min_distance = pq[pq.keys.first]
			min_key = pq.keys.first
			pq.each do |k,v|
				if (v && (!min_distance || v <= min_distance))
					min_distance = v
					min_key = k
				end
			end
		end
		return min_key
	end

end

class Edge

	attr_reader :source, :destination
	attr_accessor :weight

	def initialize(u, v, weight)
		@source = u;
		@destination = v;
		@weight = weight;
	end

	def to_s
		return "#{@source} -> #{@destination} (#{@weight})"		
	end
end