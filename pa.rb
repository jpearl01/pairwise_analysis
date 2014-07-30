	#!/usr/bin/env ruby

	#Program to analyze a pairwise presence absence matrix
	#usage: ruby pa.rb presence_absence.txt

	require 'yaml'
	require 'gruff'

	class PA_vector
		attr_accessor :name, :clusters

		def initialize(name)
			self.name = name
			self.clusters = {}
		end

		def num_clusters
			total = 0
			self.clusters.each_value do |value|
				total += value
			end
			total
		end

	end

	#Read in the input file and return an array of 
	def input_matrix(file_name)
		c_arr = []
		File.open(file_name, "r").each_line do |line|
			#If this is  the first line, initialize each strain and add it to the array
			if $. == 1
				line.split.each do |strain|
					c_arr.push(PA_vector.new(strain)) unless strain == 'cluster_names'
				end
				#otherwise, add the cluster to each strain vector
			else
				cluster = line.split
				(1..cluster.length-1).each do |i|
					c_arr[i-1].clusters[cluster[0]] = cluster[i].to_i
				end
			end
		end
		c_arr
	end

	#Return a hash of a cluster from an array of PA_vectors
	def get_cluster(arr, clust)
		cluster_hash = {}
		arr.each do |strain|
			cluster_hash[strain.name] = strain.clusters[clust]
		end
		cluster_hash
	end

	#Return the number of strains that have a representative in a cluster
	def sum_cluster(arr, clust)
		total = 0
		arr.each do |strain|
			total += strain.clusters[clust]
		end
		total
	end

	#Return an array of values for each gene class
	def calc_histogram(arr, list=nil)
		
		histo = []
		if list.nil?
			arr[0].clusters.each_key do |clust|
				gene_class = sum_cluster(arr, clust)
				if histo[gene_class].nil? 
					histo[gene_class] = 1
				else
					histo[gene_class] += 1
				end
			end
		else
			new_array = []
			arr.each do |strain|
				if list.include? strain.name
					new_array.push(strain)
					new_array[0].clusters.each_key do |clust|
						gene_class = sum_cluster(new_array, clust)
						if histo[gene_class].nil? 
							histo[gene_class] = 1
						else
							histo[gene_class] += 1
						end
					end
				end
			end
		end
		histo
	end

	pa_matrix =	input_matrix(ARGV[0])
#	puts	get_cluster(pa_matrix, "103P14B1_20").to_yaml
#	puts sum_cluster(pa_matrix, "103P14B1_20").to_s
	puts calc_histogram(pa_matrix)
