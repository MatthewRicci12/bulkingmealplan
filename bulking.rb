require_relative 'item.rb'
#Carbs, fat, protein, calories.

$include = false
$exclude = false
$subtract = false
$noRecipe = false
$oneRecipe = false
$numRecipes = 0

FILEPATH = "foodlist/foodlist.csv"
CARBS_INDEX = 0
FAT_INDEX = 1
PROTEIN_INDEX = 2
CALORIES_INDEX = 3

# Include items in goal, deleting their macros from the goal as well as removing
# those items from the list.

# PARAMS
# Item goal, the original goal.
# Item[] itemList, the list of Items from the file.
# String includeItemsLine, the argument passed to the -i flag.
def includeItemsInGoal(goal, itemList, includeItemsLine)
    x = includeItemsLine.split(',')
    i = 0
    curItem = x[i]

    # For every item in our item list, if its name matches one of ours, we will
    # pre-subtract it from the goal, delete that item from the main list, and 
    # then try the next item.
    j = 0
    while j < itemList.length do
        item = itemList[j]
        if item.name == curItem then
            goal.carbs -= item.carbs
            goal.fat -= item.fat
            goal.protein -= item.protein
            goal.calories -= item.calories

            itemList.delete_at(j)

            i += 1
            curItem = x[i]

            if i == x.length then break end
        else
            j += 1
        end
    end
end

#TODO
def subtractFromGoal(goal, subtractMacrosLine)
    x = subtractMacrosLine.split(",")
    y = []
    x.each{|macro| y << macro.to_i}
    
    goal.carbs -= y[CARBS_INDEX]
    goal.fat -= y[FAT_INDEX]
    goal.protein -= y[PROTEIN_INDEX]
    goal.calories -= y[CALORIES_INDEX]
end

#TODO
def excludeItemsFromList(itemList, excludeItemsLine)
    x = excludeItemsLine.split(',')
    i = 0
    curItem = x[i]

    # For every item in our item list, if its name matches one of ours, we will
    # pre-subtract it from the goal, delete that item from the main list, and 
    # then try the next item.
    j = 0
    while j < itemList.length do
        item = itemList[j]
        if item.name == curItem then
            itemList.delete_at(j)

            i += 1
            curItem = x[i]

            if i == x.length then break end
        else
            j += 1
        end
    end
end




#Return an Item object, representing the macros of the item.
def extractItemFromLine(itemLine)
    itemName, itemCarbs, itemFat, itemProtein, itemCalories = itemLine.split(',')
    item = Item.new(itemName, itemCarbs.to_i, itemFat.to_i, itemProtein.to_i, itemCalories.to_i)
end

#Return an array of Items, from the .csv file.
def extractItemList(file)
    itemList = []

    file.each do
        |line|

        if (line[0] == line[0].upcase) then 
            if $noRecipe then next
            else $numRecipes += 1
            end
        end

        itemList << extractItemFromLine(line)
    end

    return itemList
end

# Given the goal and items list, generate a meal plan, until the macros are met.

# PARAMS
# Item goal, the goal item.
# Item[] itemList, the list of items from the .csv file.
def f(goal, itemList)

    # Save the original goal, to calculate the remainder at the end.
    # Otherwise, just clone the goal/itemList, because they will be consumed.
    originalGoal = goal.clone()
    copyOfGoal = goal.clone()
    copyOfItemList = []
    itemList.each{|item| copyOfItemList << item.clone()}

    oneRecipeUsed = $oneRecipe ? true : false;

    size = copyOfItemList.size
    metCarbsGoal, metFatGoal, metProteinGoal, metCaloriesGoal = copyOfGoal.carbs <= 0, copyOfGoal.fat <= 0, copyOfGoal.protein <= 0, \
        copyOfGoal.calories <= 0

    
    totalCarbs = 0
    totalFat = 0
    totalProtein = 0
    totalCalories = 0

    while !metCarbsGoal && !metProteinGoal && !metCaloriesGoal
        # Grab a random index, index into the item list. Use linear probing, if
        # item has already been used.
        if oneRecipeUsed then 
            if $oneRecipe then 
                randIndex = rand($numRecipes)
                $oneRecipe = false
            else
                randIndex = rand(size - $numRecipes) + $numRecipes
            end
        else
            randIndex = rand(size)
        end


        randItem = copyOfItemList[randIndex]
        while randItem.used
            randIndex += 1
            randItem = copyOfItemList[randIndex % size]
        end
        randItem.used = true

        #Print out name of item, subtract its macros from the goal, add to the
        # macro totals.
        puts randItem.name
        totalCarbs += randItem.carbs
        totalFat += randItem.fat
        totalProtein += randItem.protein
        totalCalories += randItem.calories

        copyOfGoal.carbs -= randItem.carbs
        copyOfGoal.fat -= randItem.fat
        copyOfGoal.protein -= randItem.protein
        copyOfGoal.calories -= randItem.calories

        # Re-calculate loop condition.
        metCarbsGoal, metFatGoal, metProteinGoal, metCaloriesGoal = copyOfGoal.carbs <= 0, copyOfGoal.fat <= 0, copyOfGoal.protein <= 0, \
        copyOfGoal.calories <= 0    
    end

    # Print out final results.
    puts "Total carbs: #{totalCarbs}, total fat: #{totalFat}, total protein: #{totalProtein}, total calories: #{totalCalories}."
    puts "Remaining carbs: #{copyOfGoal.carbs <= 0 ? 0 : originalGoal.carbs -  totalCarbs}, remaining fat: #{copyOfGoal.fat <= 0 ? 0 : originalGoal.fat -  totalFat}, remaining protein: #{copyOfGoal.protein <= 0 ? 0 : originalGoal.protein -  totalProtein}, remaining calories: #{copyOfGoal.calories <= 0 ? 0 :  originalGoal.calories -  totalCalories}."

    $oneRecipe = oneRecipeUsed ? true : false 
end

if __FILE__ == $0
    puts "INSTRUCTIONS:
    -i/--include \"Item1,Item2,Item3\"
    -e/--exclude \"Item1,Item2,Item3\"
    -s/--subtract carbs,fat,protein,calories
    -n/--no-recipe
    -o/--one-recipe"

    includeItemsLine = nil
    excludeItemsLine = nil
    subtractMacrosLine = nil

    # Grab command line arguments, and set them, as well as their respective 
    # arguments.
    for i in 0..ARGV.length
        if ARGV[i] == '-i' or ARGV[i] == '--include' then
            $include = true
            includeItemsLine = ARGV[i+1]
        elsif ARGV[i] == '-e' or ARGV[i] == '--exclude' then
            $exclude = true
            excludeItemsLine = ARGV[i+1]
        elsif ARGV[i] == '-s' or ARGV[i] == '--subtract' then
            $subtract = true
            subtractMacrosLine = ARGV[i+1]
        elsif ARGV[i] == '-n' or ARGV[i] == '--no-recipe' then
            $noRecipe = true
        elsif ARGV[i] == '-o' or ARGV[i] == '--one-recipe' then
            $oneRecipe = true
        end
    end

    file = File.open(FILEPATH, "r")

    # Set the goal Item object, as well as populate the item list with Item 
    # objects of the file.
    goal = extractItemFromLine(file.readline.chomp!)
    itemList = extractItemList(file)

    #TODO
    # INCLUDE: Subtract certain items from goal already + delete from list.
    # SUBTRACT: Lower the goal.
    # EXCLUDE: Exclude certain items from goal + delete them from list.
    if $include then includeItemsInGoal(goal, itemList, includeItemsLine) end
    if $subtract then subtractFromGoal(goal, subtractMacrosLine) end
    if $exclude then excludeItemsFromList(itemList, excludeItemsLine) end
    
    # Make new mealplans, until user types "q".
    while STDIN.gets.chomp != "q"
        f(goal, itemList)
    end

    file.close()
end