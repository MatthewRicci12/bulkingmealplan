# FILE: bulking.rb
# AUTHOR: Matthew Riccci
# DESCRIPTION:
# The main logic for the meal-plan helper. This program is not intended to 
# completely make meal plans, but to reduce the amount of manual meal planning
# that is to be done. It is best used when you include a recipe and leave room,
# so that you may customize a subset of a total meal plan. Upon starting the
# program, it will give a quick rundown on its usage and the command line 
# arguments.

require_relative 'item.rb'

#Command line flags
$include = false
$exclude = false
$subtract = false
$noRecipe = false
$numRecipes = 0

FILEPATH = "foodlist/foodlist.csv"
CARBS_INDEX = 0
FAT_INDEX = 1
PROTEIN_INDEX = 2
CALORIES_INDEX = 3

# Include items in goal, deleting their macros from the goal as well as removing
# those items from the list.
#
# PARAMS
# Item goal, the original goal.
# Item[] itemList, the list of Items from the file.
# String includeItemsLine, the argument passed to the -i flag.
def includeItemsInGoal(goal, itemList, includeItemsLine)
    itemsToInclude = includeItemsLine.split(',')
    i = 0
    curItem = itemsToInclude[i]

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
            curItem = itemsToInclude[i]

            if i == itemsToInclude.length then break end
        else
            j += 1
        end
    end
end

# Given a line of macros as requested for this command line argument, convert the
# line into integers, so their macro values may be subtracted from the base goal.
#
# PARAMS
# goal, the Item representing the goal value.
# subtractMacrosLine, the line passed in by the user for the macros they wish to
#     subtract.
def subtractFromGoal(goal, subtractMacrosLine)
    macrosList = subtractMacrosLine.split(",")
    macrosAsIntegers = []
    macrosList.each{|macro| macrosAsIntegers << macro.to_i}
    
    goal.carbs -= macrosAsIntegers[CARBS_INDEX]
    goal.fat -= macrosAsIntegers[FAT_INDEX]
    goal.protein -= macrosAsIntegers[PROTEIN_INDEX]
    goal.calories -= macrosAsIntegers[CALORIES_INDEX]
end

# Handler for the command line argument to exclude a certain item. It works by 
# simply deleting this Item from the itemList.
#
# PARAMS
# itemList, the complete list of Item objects.
# excludeItemsLine, a string representing what the user passed in.
def excludeItemsFromList(itemList, excludeItemsLine)
    listOfItemsToExclude = excludeItemsLine.split(',')
    i = 0
    curItem = listOfItemsToExclude[i]

    # For every item in our item list, if its name matches one of ours, we will
    # pre-subtract it from the goal, delete that item from the main list, and 
    # then try the next item.
    j = 0
    while j < itemList.length do
        item = itemList[j]
        if item.name == curItem then
            itemList.delete_at(j)

            i += 1
            curItem = listOfItemsToExclude[i]

            if i == listOfItemsToExclude.length then break end
        else
            j += 1
        end
    end
end




# Return an Item object, representing the macros of the item.
#
# PARAMS
# itemLine, a line in the format "Recipe,Carbs,Fat,Protein,Calories" that will
#       be converted to an Item object.
def extractItemFromLine(itemLine)
    itemName, itemCarbs, itemFat, itemProtein, itemCalories \
        = itemLine.split(',')
    item = Item.new(itemName, itemCarbs.to_i, itemProtein.to_i, itemFat.to_i, \
        itemCalories.to_i)
end

# Return an array of Items, from the .csv file.
#
# PARAMS
# file, a File object containing all the recipes.
#
# RETURNS
# A list of Item objects, one for each item in the file.
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
def generateMealPlan(goal, originalGoal, itemList)

    # Clone the goal/itemList, because they will be consumed.
    copyOfGoal = goal.clone()
    copyOfItemList = []
    itemList.each{|item| copyOfItemList << item.clone()}

    size = copyOfItemList.size
    metCarbsGoal, metFatGoal, metProteinGoal, metCaloriesGoal = copyOfGoal.carbs <= 0, copyOfGoal.fat <= 0, copyOfGoal.protein <= 0, \
        copyOfGoal.calories <= 0

    recipeUsed = false

    
    totalCarbs = 0
    totalFat = 0
    totalProtein = 0
    totalCalories = 0

    while !metCarbsGoal && !metProteinGoal && !metCaloriesGoal
        # Grab a random index, index into the item list. Use linear probing, if
        # item has already been used.
        
        if !recipeUsed then
            recipeUsed = true
            randIndex = rand($numRecipes)
        else
            randIndex = rand(size - $numRecipes) + $numRecipes
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

    remainingCarbs = originalGoal.carbs -  totalCarbs
    remainingFat = originalGoal.fat -  totalFat
    remainingProtein = originalGoal.protein -  totalProtein
    remainingCalories = originalGoal.calories -  totalCalories

    print "Remaining carbs: "
    print remainingCarbs unless remainingCarbs <= 0
    print ", remaining fat: "
    print remainingFat unless remainingFat <= 0
    print ", remaining protein: "
    print remainingProtein unless remainingProtein <= 0
    print ", remaining calories: "
    print remainingCalories unless remainingCalories <= 0
    puts
end

if __FILE__ == $0
    puts "INSTRUCTIONS:
    -i/--include \"Item1,Item2,Item3\"
    -e/--exclude \"Item1,Item2,Item3\"
    -s/--subtract carbs,fat,protein,calories
    -n/--no-recipe"

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
        end
    end

    file = File.open(FILEPATH, "r")

    # Set the goal Item object, as well as populate the item list with Item 
    # objects of the file. Keep original goal because final goal may change.
    finalGoal = extractItemFromLine(file.readline.chomp!)
    itemList = extractItemList(file)
    originalGoal = finalGoal.clone()

    #TODO
    # INCLUDE: Subtract certain items from goal already + delete from list.
    # SUBTRACT: Lower the goal.
    # EXCLUDE: Exclude certain items from goal + delete them from list.
    if $include then includeItemsInGoal(finalGoal, itemList, includeItemsLine) end
    if $subtract then subtractFromGoal(finalGoal, subtractMacrosLine) end
    if $exclude then excludeItemsFromList(itemList, excludeItemsLine) end
    
    # Make new mealplans, until user types "q".
    while STDIN.gets.chomp != "q"
        generateMealPlan(finalGoal, originalGoal, itemList)
    end

    file.close()
end