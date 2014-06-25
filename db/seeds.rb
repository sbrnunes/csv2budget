# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Category.delete_all
Category.create({:name => 'Incomes', :labels => [{:name => 'DIMENSION DATA'},{:name => 'EXPENSES'}]})
Category.create({:name => 'Expenses', :labels => [{:name => 'VDA'},{:name => 'VDP'},{:name => 'VODAFONE'}]})
Category.create({:name => 'Telecommunications', :labels => [{:name => 'VODAFONE'}]})