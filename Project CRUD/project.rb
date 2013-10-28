=begin
	
Script Name: project.rb
Description: Uses the Project_CRUD class to perform CRUD actions on type Project. 

Version: 1.0

Author: Rohan Dalvi (Rohan.Dalvi@emc.com)
Company: EMC Corporation
Date: 10/28/13

=end

require 'rally_api_emc_sso'
require './Project_CRUD.rb'

# Default workspace is set to "Workspace 1" and project is set to "Rohan-test"
def start
	@workspace = "Workspace 1"
	@project = "Rohan-test"
	exit = false
	puts "Spawning CRUD Object"
	project_crud = Project_CRUD.new(@workspace,@project)
	while exit!=true
		

		puts "\n\n1.Create Project\n2.Read Project\n3.Update Project\n4.Delete Project\n5.Exit\nEnter your choice"
		choice = gets.chomp
		
		case choice
			when "1"
				# get info, then spawn a new Project_CRUD object and call create .
				fields = {}
				
				puts "Enter the name of project"
				fields["Name"] = gets.chomp


				puts "Enter description of project"
				fields["Description"] = gets.chomp
				puts "Setting Project #{fields["Name"]}'s state to Open, it can be changed inside Rally or using the Update command"
				fields["State"]="Open"
				
				result = project_crud.create_project(fields)

				if(!result)
					puts "There was some problem processing your query, try again."
				end
				when "2"

					puts "Enter the Name of Project to be read"
					projectName = gets.chomp

					#project_crud = Project_CRUD.new(@workspace,@project)
					result = project_crud.read_project(projectName)

				when "3"
					fields={}
					puts "Enter name of project to be updated"
					projectName = gets.chomp
					if(project_crud.if_project(projectName))
						#project_crud = Project_CRUD.new(@workspace,@project)

						puts "Would you like to update Description? (Y/N)"
						
						option = gets.chomp
						
						if(option=='Y' || option=='y')
							puts "Ok, enter your new description"
							fields["Description"] = gets.chomp
						end

						puts "Would you like to update the State of the project #{projectName} ?\n"
						puts "(If you update the state to closed, the project would not be visible anymore)"

						option = gets.chomp
						if(option=='Y' || option=='y')
							puts "Ok, enter the new State of your project (Open/Closed)"
							fields["State"] = gets.chomp
							if(fields[State]!="Open" || fields["State"]!="open" || fields["State"]!="closed" || fields["State"]!="Closed")
								puts "The State can either be Open or Closed, please try again."
								exit
							end		
						end

						result = project_crud.update_project(projectName,fields)
						if(result)
							puts "\n\n#{projectName} successfully updated"
						end
					else
						puts "Project #{projectName} Not found!"
					end
				when "4"
					puts "Careful! You are about to delete a project, this project will no longer be visible"
					puts "Are you sure you want to delete the project? (Y/N)"

					option = gets.chomp
					if(option=="Y"||option=="y")
						puts "Enter the name of project you want to delete"
						projectName = gets.chomp

						#project_crud = Project_CRUD.new(@workspace,@project)
						project_crud.delete_project(projectName)


					end
				when "5"
					puts "Exiting..."
					exit = true
				else
					puts "Wrong condition, please check the prompt and enter proper choice"
					
			end

	end

end
start