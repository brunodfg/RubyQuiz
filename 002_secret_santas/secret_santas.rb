module RubyQuizSolvers

	class Person

		attr_reader :first_name, :last_name, :email, :gift_person
		attr_accessor :secret_santa

		def initialize(args)
			tokens = args.split()

			if tokens.length == 3
				@first_name = tokens[0]
				@last_name = tokens[1]
				@email = tokens[2]			
			else
				raise "Invalid person initialization - 3 tokens required (first_name last_name email) separated by space"
			end
		end

		def give_gift_to(person)
			@gift_person = person
			@gift_person.secret_santa = self
		end

		# Wether the current person may be the secret santa of the specified person
		def can_be_santa_of?(person)
			return self.last_name != person.last_name
		end

		def fullname
			return "#{@first_name} #{@last_name}"
		end

		def to_s
			return "#{fullname} #{@email}"		
		end

	end

	# Solver for RubyQuiz problem 2 - Secret Santas
	# => http://www.rubyquiz.com/quiz2.html
	# 
	# Created by Bruno Gonçalves <brunodfg@gmail.com>
	# Created on 01/05/2012
	#
	class SecretSantaSolver

		def initialize(filename)
			file = File.open(filename, "r")
			file_content = file.lines.to_a
			file.close
			
			if file_content.empty?
				raise "Invalid problem input - empty file"
			end

			@people = file_content.map { |line| Person.new(line) }
		end

		# Returns a collection of person, each of which is assigned with a secret santa
		# Raises an exception if it is not possible to assign a secret santa of a different family to each person (when a family represents more than 50% of the group)
		def solve	

			# Group people by families
			# Santa attribution will be done between persons of different families
			families = {}
			@people.each do |p|
				if !families.has_key?(p.last_name)
					families[p.last_name] = []
				end
				families[p.last_name] << p
			end

			# Validate families distribution
			# One family may not have more than half of the size of the group
			families.values.each do |f|
				if (f.size > (@people.size / 2))
					raise "Family #{f[0].last_name} represents more than 50% of the group. No solution possible."
				end
			end

			# Sort families by their size.
			families = families.values.sort_by { |f| f.size }
			available_families = families.map { |f| f.dup }

			for i in 0...families.size

				source_family = families[i]

				# Assign each member of the current family as the secret santa of first available person on the largest available family
				for j in 0...source_family.size

					secret_santa = source_family[j]

					# The target family is the family with most elements which does not have the same last name as the current secret santa
					target_family = available_families.last
					target_family = available_families[available_families.size - 2] if !secret_santa.can_be_santa_of?(target_family.first)
					
					# Assign the secret santa to the first available person of the target family. 
					# Removes that person from the target family so that it may not be assigned a secret santa in the next iteration
					target_person = target_family.delete_at(0)
					target_person.secret_santa = secret_santa

					# Remove the target family from the available families collection when all elements of that family have been assigned a secret santa
					if (target_family.size == 0)
						available_families.delete(target_family)
					end

				end

			end

			return families.flatten

		end
	end

end

solver = RubyQuizSolvers::SecretSantaSolver.new("secret_santas.txt")
assigned_santas = solver.solve

if assigned_santas
	assigned_santas.each do |p|
		puts "#{p.secret_santa.fullname} is the secret_santa of #{p.fullname}"
	end
end
