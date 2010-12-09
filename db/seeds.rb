# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

puts 'Creating settings...'
{"registeration_type"=>"2", "validity_period"=>"14"}.each do |key, value|
  InvitationSetting.find_or_create_by_key(key, :description=>"", :value=>value)
end