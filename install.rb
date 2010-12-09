require "fileutils"

# Create Migrations folder
src = File.dirname(__FILE__)+"/db/migrate"
dest = File.dirname(__FILE__)+"/../../.."
unless File.exist?("#{dest}/db/migrate")
	FileUtils.mkdir "#{dest}/db/migrate" 
	puts "Creating new '/db/migrate' directory for migrations."
end


# Move the invitations Migrations
migrations_folder =  "#{dest}/db/migrate"
FileUtils.cp "#{src}/20101206094245_create_invitations.rb", migrations_folder
FileUtils.cp "#{src}/20101206102149_create_invitation_settings.rb", migrations_folder
FileUtils.cp "#{src}/20101206103422_add_invitations_count_and_expiration_to_users.rb", migrations_folder
puts "Moving migrations."


# Add method to user.rb
file_path = "#{dest}/app/models/user.rb"
content = File.read(file_path)
unless content.match(/current_invitations_count/)
new_lines = %Q(
  has_many :invitations, :dependent => :destroy
  validates_presence_of :invitations_count
  
  def current_invitations_count
	User.find(self.id).invitations_count
  end
)
new_content = content.sub(/^(end\s*)$/) {|match| "#{new_lines}\n#{match}" }
File.open(file_path, 'wb') { |file| file.write(new_content) }
puts "Insert new method to user.rb"
end


# Add method to seeds.rb
file_path = "#{dest}/db/seeds.rb"
content = File.read(file_path)
unless content.match(/Creating settings\.{3}/)
new_lines = %Q(
puts 'Creating settings...'
{"registration_type"=>"2", "validity_period"=>"14", "email_subject"=>"Invitation", "email_from"=>"noreply@noreply.com"}.each do |key, value|
  InvitationSetting.find_or_create_by_key(key, :description=>"", :value=>value)
end
)
new_content = content.sub(/^#\s+Examples:\s*$/) {|match| "#{match}\n#{new_lines}" }
File.open(file_path, 'wb') { |file| file.write(new_content) }
puts "Insert new method to seeds.rb"
end

puts "Installation done."