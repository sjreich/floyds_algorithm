require 'pry'
require 'csv'

class BestRouteFinder
  def initialize

    @initial_data = []
    CSV.foreach('data_set.csv') do |row|
      @initial_data.push(
        {
          point_a: row[0],
          point_b: row[1],
          distance: row[2].to_i,
        }
      )
    end

    @best_route_data = []
  end

  def shortest_path(start, terminus)
    loop do
      shortest_path = paths(start).min_by { |path| path[:total_distance] }
      @best_route_data.push(shortest_path)
      break if shortest_path[:ultimate_destination] == terminus
    end

    puts @best_route_data.last
  end

  private

  def paths(node, already_checked=[])
    edges_to_immediate_neighbors(node).each_with_object([]) do |first_edge, paths|
      point_b = first_edge[:point_b]
      next if already_checked.include?(point_b)

      if analyzed_nodes.include?(point_b)
        paths(point_b, already_checked.push(node)).each do |next_section|
          paths << intermediate_path_section(first_edge, next_section)
        end
      else
        paths << final_path_section(first_edge)
      end
    end
  end

  def edges_to_immediate_neighbors(node)
    @initial_data.select { |edge| edge[:point_a] == node }
  end

  def analyzed_nodes
    @best_route_data.map { |path| path[:ultimate_destination] }
  end

  def intermediate_path_section(first_edge, next_section)
    {
      start: first_edge[:point_a],
      immediate_destination: first_edge[:point_b],
      ultimate_destination: next_section[:ultimate_destination],
      total_distance: first_edge[:distance] + next_section[:total_distance],
      steps: next_section[:steps].unshift(first_edge[:point_a]),
    }
  end

  def final_path_section(first_edge)
    {
      start: first_edge[:point_a],
      immediate_destination: first_edge[:point_b],
      ultimate_destination: first_edge[:point_b],
      total_distance: first_edge[:distance],
      steps: [first_edge[:point_a], first_edge[:point_b]],
    }
  end
end

BestRouteFinder.new.shortest_path('bB', 'eE')