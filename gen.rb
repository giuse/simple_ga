#!/usr/bin/env ruby
# Simple Genetic Algorithm for demonstrative purposes

class GA
	attr_reader :population, :popsize, :genosize

	def initialize popsize, genosize
		@popsize = popsize
		@genosize = genosize
		@population = init_pop
	end

	def init_pop
		popsize.times.collect {	genosize.times.collect { random_gene } }
	end

	def sort_pop_by_fit
		population.sort_by! { |gen| -(fitness gen) } # `#-@` for descending order
	end

	def select_parent ratio=2
		# uniformly choose one of the top ratio (e.g. half) of the pop
		population[rand(popsize)/ratio]
	end

	def select_parents ntries=10
		p1 = select_parent
		# loop do # stagnation could mess this up (when all parents identical)
		p2 = nil
		ntries.times do
			p2 = select_parent
			break if p1 != p2
		end
		[p1, p2]
	end

	def crossover p1, p2
		# choose cutpoint
		cutpoint = rand(genosize-1)
		# build children
		c1 = p1[0..cutpoint] + p2[cutpoint+1..-1]
		c2 = p2[0..cutpoint] + p1[cutpoint+1..-1]
		# return two children
		[c1, c2]
	end

	def make_love nchildren
		(nchildren/2.0).ceil.times.collect do
			crossover *select_parents
		end.flatten(1).take(nchildren)
	end

	def mutate ind, pos
		population[ind][pos] = 1 - population[ind][pos]
	end

	def run ngens
		ngens.times do |ngen|
			# sort based on fitness
			sort_pop_by_fit
			# fill with children (select parents + crossover)
			population = make_love popsize
			# mutate new pop (one mutation per gen, uniformly distributed)
			mutate rand(popsize), rand(genosize)
			puts "Generation #{ngen+1}\n#{self}"
		end
	end

	def to_s
		population.each_with_index.collect do |g, i|
			"#{format("%2d", i+1)}: #{g} => #{fitness g}"
		end.join("\n")
	end


	## Max-1 problem: binary genotype, maximize number of ones

	def random_gene
		# binary genotype
		rand 2
	end

	def fitness genotype
		genotype.inject :+
	end

end

if __FILE__ == $0
	ga = GA.new 6, 8
	ga.run 20
end
