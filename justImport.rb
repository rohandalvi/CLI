=begin
	
Author: Rohan Dalvi
Version: 1.0
Organization: EMC Corporation
Date Created: 10/5/2013.

Description: This is a intro script to import only user stories (no features or iterations). Takes care 
of the 2 step process to import parent-child user stories. 
	
=end

require '../justImport/connect.rb'
require 'csv'


def manage_Stories(row)
	
	puts "Managing row #{@iCount}"

	if(!story_exists(row["Name"]))
		if(row["Parent"]!=nil)
			if(it_is_parent_ID(row["Parent"]))
				if(parent_id_exists(row["Parent"]))
					row["Parent"] = get_parent_from_id(row["Parent"])

					create_child_story(row) #everything is fine, insert the child with parent field in it.
				else
					puts "The ParentID you entered for user story with name #{row["Name"]} does not exist, if you are not sure about the ID, please enter the Parent story name next time."
				end
			else
				puts "In else"
				if(parent_name_exists(row["Parent"])) #check if parent name exists in Rally.
					# get Parent ID of this parent whose name exists in the project.
					puts "Parent with name #{row["Parent"]} exists"
					@PID = get_parent_id_from_name(row["Parent"])
					connect_parent_to_child(row,@PID)
				else #if no such parent with that name exists in Rally, create it .
					#create a parent by this name first, and make the create parent function return the newly created parent's id.
				
					@PID = create_parent_by_name(row["Parent"])
					connect_parent_to_child(row,@PID)
				end
			end
		else
			create_child_story(row)
			puts "!"
		end
	else
		puts "Story with name #{row["Name"]} exists "
		check_update_story(row)

	end

end

def connect_parent_to_child(result_row,object)

	if(object!=nil)
		puts "Found object #{object}"
		result_row["Parent"] = object
		create_child_story(result_row)

	else
		puts "Could not find Parent's PID, looking for Parent #{row["Parent"]}"
	end

end

def it_is_parent_ID(looksLikeID)
	looksLikeID = looksLikeID.to_s
	if( (! looksLikeID.nil?) && (looksLikeID[0..1].eql?("US") ) && (looksLikeID[2..5]=~ /^[-+]?[0-9]+$/) )
		return true
	else
		return false
	end

end

#add update query to make this function work.

def check_update_story(story)

	puts "Getting Story ID because #{story["Name"]} exists"
	storyID = get_story_id(story["Name"])
	puts "Story ID is #{storyID}"
	if(storyID==nil)
		puts "There was some problem getting the story id of this story #{story["Name"]}"
		exit
	end
	update_array = {}
	update_array["Name"] = story["Name"]
	update_array["Description"] = story["Description"]
	update_array["ScheduleState"] = story["Schedule State"]
	if(story["Parent"]!=nil)
		if(parent_name_exists(story["Parent"]))
			update_array["Parent"] = get_parent_id_from_name(story["Parent"])

		else
			update_array["Parent"] = create_parent_by_name(story["Parent"])
		end
	end
	@rally.update("hierarchicalrequirement","FormattedID|#{storyID}",update_array)
	#update_query  goes here
	#add up	

end

def get_story_id(storyName)

	result = build_query("hierarchicalrequirement","Name,Description,FormattedID,ScheduleState,Parent","(Name = \"#{storyName}\")")
	first_entry = result.first
	if(result.length == 1)
		return first_entry["FormattedID"]
	
	else
		puts "There was some problem getting the story ID from get_story_id"
		exit
	end
end

def build_query(type,fetch,string)
	query = RallyAPI::RallyQuery.new()
	query.type=type
	query.fetch=fetch
	query.query_string=string
	query.project ={"_ref" => "https://rally1.rallydev.com/slm/webservice/v2.0/project/14357184706.js"}
	result = @rally.find(query)
	return result
end

def create_child_story(info)

	puts "This may throw an error"
	puts "Info parent is #{info["Parent"]}"
	child_array = {}

	child_array["Name"] = info["Name"]
	child_array["Description"] = info["Description"]
	child_array["ScheduleState"] = info["Schedule State"]
	child_array["Parent"] = info["Parent"]
	puts "Child array parent #{child_array["Parent"].class}"

	create_story = @rally.create("hierarchicalrequirement",child_array)
end

def parent_id_exists(parentID)
	result = build_query("hierarchicalrequirement","Name,FormattedID","(FormattedID = \"#{parentID}\")")
	
	if(result.length > 0)
		return true
	else
		return false
	end

end

def story_exists(storyName)

	result = build_query("hierarchicalrequirement","Name,FormattedID","(Name = \"#{storyName}\")")
	query = RallyAPI::RallyQuery.new()

	if(result.length>0)
		return true
	else
		return false
	end

end

def create_parent_by_name(parentName)

	parentArray = {}
	parentArray["Name"] = parentName.strip
	
	result = @rally.create("hierarchicalrequirement",parentArray)
	parentID = nil
	if(result)
		parentID = get_parent_id_from_name(parentName)
	else
		puts "inside else result"
		puts "There was some problem creating that parent with name #{parentName}, please check the error"
		exit
	end
	parentID
end

def parent_name_exists(parentName)
	puts "Finding parent with name #{parentName}"
	result = build_query("hierarchicalrequirement","Name,FormattedID","(Name = \"#{parentName}\")")
	
	if(result.length > 0)
		puts "returning true"
		return true
	else
		puts "returning false"
		return false
	end

end

def get_parent_id_from_name(parentName)
	puts "Finding parent ID from name #{parentName}"
	result = build_query("hierarchicalrequirement","Name,FormattedID","(Name = \"#{parentName}\")")
	
	pid = nil
	if(result.length == 1)
		story = result.first
		pid = story
	else
		puts "Result's length is #{result.length}"
		puts "There was some problem finding your parent story, please check in Rally."
		exit
	end
	pid
end

def get_parent_from_id(parentID)
	result = build_query("hierarchicalrequirement","Name,FormattedID","(FormattedID = \"#{parentID}\")")
	parent = nil
	if(result.length==1)
		story = result.first
		parent = story
	else
		puts "Result's length is #{result.length}"
		puts "There was some problem finding your parent story, please check in Rally."
		exit
	end
	parent

end

=begin
	
1 -> Name, 2-> Description, 3 -> ScheduleState, 4-> Project, 5 -> Parent
	
=end
def start
	puts "Connected"
	file_name = "rallyimport.csv"
	input = CSV.read(file_name)

	header = input.first
	rows = []
	(1...input.size).each { |i| rows << CSV::Row.new(header, input[i]) }

	@iCount = 59 #@iCount = 0 or rows.length-1
	while @iCount>0 #@iCount<rows.length or @iCount> 0
		if(input[@iCount]!= nil)
		#puts rows[@iCount]
		manage_Stories(rows[@iCount])
		end
		@iCount -= 1 #@iCount += 1 or @iCount -= 1
		
	end
end
start