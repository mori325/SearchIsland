class FileManager
	def read_with_file_name(file_name)
		input_file = open(file_name)
		map_data = [island_number(input_file), islands(input_file)]
		input_file.close
		map_data
	end
	def island_number(input_file)
		input_file.gets.to_i
	end
	def islands(input_file)
		islands = []
		input_file.readlines.each do |data|
			islands << data.split(" ").map{|temp| temp.to_i}
		end
		islands
	end
	def write(object)
		output_file = open("stampsheet.txt","w")
		output_file << object.join("\n")
		output_file.close
	end
end

class Islands
	attr_reader :number, :all_island, :spent_islands
	def initialize(map_data)
		@number = map_data[0]
		@all_island = map_data[1]
		@spent_islands = []
	end
	def adjoin_islands_with_index(index)
		@all_island[index] - @spent_islands
	end
	def islands_route_number_with_index(select_island_index)
		island_route_number = []
		adjoin_islands_with_index(select_island_index).each do |index|
			route_number = adjoin_islands_with_index(index).length
			island_route_number << route_number
			break if route_number >= 1
		end
		island_route_number
	end
end

class Searcher 
	def initialize(islands)
		@islands = islands
	end
	def search_islands
		start_islands = make_start_islands
		stamp = []
		ideal_stamp = 0
		while stamp.length <= ideal_stamp && start_islands.length != 0
			start_island_index = start_islands.sample
			start_islands.delete(start_island_index)
			ideal_stamp = make_ideal_stamp_with_islands(@islands)
			stamp = search_route(start_island_index)	
		end
		stamp
	end
	def search_route(start_island_index)
		select_island_index = start_island_index
		@islands.spent_islands << select_island_index
		adjoin_islands = @islands.adjoin_islands_with_index(select_island_index)
		while adjoin_islands.length != 0
			islands_route_number = @islands.islands_route_number_with_index(select_island_index)
			select_island_index = adjoin_islands[islands_route_number.index(islands_route_number.max)]
			break if select_island_index.nil?
			adjoin_islands = @islands.adjoin_islands_with_index(select_island_index)
			@islands.spent_islands << select_island_index
		end
		@islands.spent_islands
	end
	def make_start_islands
		start_islands = []
		@islands.number.times do |count|
			start_islands = @islands.all_island.each_with_index.select{|island, index| island.length == (count + 1)}.map{|temp| temp[1]}
			break if start_islands.size >= 1
		end
		start_islands
	end
	def make_ideal_stamp_with_islands(islands)
		all_path = 0.00
		all_island = islands.all_island
		all_island.length.times do |x|
			all_path = all_path + (all_island.length - (x + 1))
		end
		island_path = all_island.flatten.length / 2
		ideal_stamp = all_island.length * island_path.to_f / all_path.to_f
		ideal_stamp.to_i
	end
end

fileManager = FileManager.new
map_data = fileManager.read_with_file_name("map.txt")
islands = Islands.new(map_data)
searcher = Searcher.new(islands)
stamp = searcher.search_islands
fileManager.write(stamp)