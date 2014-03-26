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
	attr_reader :number, :all_island
	def initialize(map_data)
		@number = map_data[0]
		@all_island = map_data[1]
	end
	def islands_with_index(index)
		@all_island[index]
	end
end

class Searcher 
	def initialize(islands)
		@islands = islands
	end
	def search
		stamp = []
		start_islands = make_start_islands
		ideal_stamp = make_ideal_stamp_with_islands(@islands)
		while stamp.length <= ideal_stamp && start_islands.length != 0
			spent_islands = [] 
			next_islands = [] 
			island_weight = []
			select_island_index = start_islands.sample
			start_islands.delete(select_island_index)
			spent_islands << select_island_index 
			adjoin_islands = @islands.islands_with_index(select_island_index) - spent_islands
			while adjoin_islands.length != 0
				adjoin_islands.each do |index|
					next_islands = @islands.islands_with_index(index) - spent_islands
					island_weight << next_islands.length
					break if next_islands.length >= 1
				end
				select_island_index = adjoin_islands[island_weight.index(island_weight.max)]
				break if select_island_index.nil?
				spent_islands << select_island_index
				adjoin_islands = @islands.islands_with_index(select_island_index) - spent_islands
			end
			if stamp.length < spent_islands.length
				stamp = spent_islands
			end
		end
		stamp
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
stamp = searcher.search
fileManager.write(stamp)