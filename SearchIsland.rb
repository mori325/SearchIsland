class FileManager
	def read(file_name)
		@input_file = open(file_name)
		map_data = [island_number, islands]
		@input_file.close
		map_data
	end
	def write(data)
		output_file = open("stampsheet.txt","w")
		output_file << data.join("\n")
		output_file.close
	end

	private
	def island_number
		@input_file.gets.to_i
	end
	def islands
		islands = []
		@input_file.readlines.each do |data|
			islands << data.split(" ").map{|temp| temp.to_i}
		end
		islands
	end
	
end

class Islands
	attr_reader :number, :all_island, :spent_islands
	def initialize(map_data)
		@number = map_data[0]
		@all_island = map_data[1]
	end
	def adjoin_islands(index)
		@all_island[index] - @spent_islands
	end
	def islands_route_number(select_island_index)
		island_route_number = []
		adjoin_islands(select_island_index).each do |index|
			route_number = adjoin_islands(index).length
			island_route_number << route_number
			break if route_number >= 1
		end
		island_route_number
	end
	def init_with_spend_islands
		@spent_islands = []
	end
end

class Searcher 
	def initialize(islands)
		@islands = islands
	end
	def search_islands
		start_islands = make_start_islands
		ideal_stamp = make_ideal_stamp(@islands)
		stamp = []
		while stamp.length <= ideal_stamp && !start_islands.empty?
			@islands.init_with_spend_islands
			start_island_index = start_islands.sample
			start_islands.delete(start_island_index)
			stamp = search_route(start_island_index)	
		end
		stamp
	end
	def search_route(start_island_index)
		select_island_index = start_island_index
		@islands.spent_islands << select_island_index
		adjoin_islands = @islands.adjoin_islands(select_island_index)
		while !adjoin_islands.empty?
			islands_route_number = @islands.islands_route_number(select_island_index)
			select_island_index = adjoin_islands[islands_route_number.index(islands_route_number.max)]
			adjoin_islands = @islands.adjoin_islands(select_island_index)
			@islands.spent_islands << select_island_index
		end
		@islands.spent_islands
	end
	def make_start_islands
		start_islands = []
		@islands.number.times do |count|
			start_islands = @islands.all_island.each_with_index.select{|island, index| island.length == (count + 1)}.map{|temp| temp[1]}
			break if start_islands.size >= 2
		end
		start_islands
	end
	def make_ideal_stamp(islands)
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
map_data = fileManager.read("map.txt")
islands = Islands.new(map_data)
searcher = Searcher.new(islands)
stamp = searcher.search_islands
fileManager.write(stamp)