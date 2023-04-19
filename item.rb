# FILE: item.rb
# AUTHOR: Matthew Riccci
# DESCRIPTION:
# This class will represent a single Item; a food item that has information about
# its name and macros. The Goal itself is also an Item. 

class Item
    def initialize name, carbs, protein, fat, calories
        @name = name
        @carbs = carbs
        @fat = fat
        @protein = protein
        @calories = calories
        @used = false
    end

    def clone
        newItem = Item.new(@name, @carbs, @fat, @protein, @calories)
    end

    def inspect
        "Item name: #{@name}. This item contains #{@carbs} grams of carbs, #{@fat} grams of fat, #{@protein} grams of protein, and #{@calories} calories.\n"
    end

    attr_accessor :name, :carbs, :protein, :fat, :calories, :used
end