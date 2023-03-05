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