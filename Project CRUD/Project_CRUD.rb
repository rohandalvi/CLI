=begin

Class Name: Project_CRUD
Description: Allows to perform CRUD commands on the type Project. Read the README file for more information
on using this script.

Author: Rohan Dalvi (Rohan.Dalvi@emc.com)
Company: EMC Corporation

Date: 10/28/13.

=end

require 'rally_api_emc_sso'

class Project_CRUD

	def initialize(workspace,project)
		headers = RallyAPI::CustomHttpHeader.new()
		headers.name = "My Utility"
		headers.vendor = "MyCompany"
		headers.version = "1.0"

		@workspace = workspace
		@project = project

		config = {:base_url => "https://rally1.rallydev.com/slm"}
		config[:workspace]  = @workspace
		config[:project]    = @project
		config[:headers]    = headers #from RallyAPI::CustomHttpHeader.new()

		#config[:version] = "v2.0"

		@rally = RallyAPI::RallyRestJson.new(config)
		

	end

	def create_project(params)

		fields = {}
		params.each{|key,value|
			fields[key]=value
		}
		if(fields["Name"]!=nil)
			@rally.create("project",fields);
			puts "Project #{fields["Name"]} successfully created}"

			return true
		else
			return false
		end

	end

	def read_project(projectName)

		result = build_query("project","Name,Description,Owner,State,Children","(Name = \"#{projectName}\")")
		if(result.length>0)

			result.each{
				|res|
				puts "Name: #{res["Name"]}"
				puts "Description: #{res["Description"]}"
				puts "Owner: #{res["Owner"]}"
				puts "State: #{res["State"]}"
				puts "Children: #{res["Children"].results}"

				puts "END OF RECORD\n\n"
			}

			puts "End Reading Project\n\n"

		end

	end

	def build_query(type,fetch,string)
		query = RallyAPI::RallyQuery.new()

		query.type = type
		query.fetch = fetch
		query.query_string = string


		result = @rally.find(query)
		if(result.length>0)
			return result
		else
			puts "There are no results to display, please check the query/Project Name again."
			return result
		end

	end

	def delete_project(projectName)
	
		results = build_query("project","Name,Description,State","(Name = \"#{projectName}\")")
		if(results.length==0)
			puts "The project with name #{projectName} could not be found\n\nPlease check the name and try again"
			return
		end

		fields={}
		fields["Name"] = projectName
		fields["State"]="Closed"
		results.each { |result|

			delete_result = @rally.update("project","#{result["_ref"]}",fields)
			puts " #{result["_ref"]}, #{result["Name"]} Closed"
		}
	end 

	def if_project(projectName)
		result = build_query("project","Name,Description","(Name = \"#{[projectName]}\")")

		if(result.length==0)
			return false
		else
			return true
		end
	end

	def update_project(projectName,fields)
		

		results = build_query("project","Name,Description,State","(Name = \"#{projectName}\")")
		if(results.length==0)
			puts "The project with name #{projectName} could not be found\n\nPlease check the name and try again"
			return
		end
		
		results.each{ |result|

			updated_project = @rally.update("project","#{result["_ref"]}",fields)
			if(updated_project)
				puts "#{result["Name"]} project is updated"
			end
		}

		true

	end
end