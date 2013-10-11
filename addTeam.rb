require 'rally_api_emc_sso'
require '../CLI/connect.rb'


def get_Project_OID(projectName)
  #this will return project OID
  puts "Inside getProjectOID"
  result = build_query("Project","Name,Description,State,Parent,TeamMembers,ObjectID","(Name = \"#{projectName}\")")
  if(result.length==1)
    project =result.first
      team = {} #make this array of Team Member Objects and not of Team Member Names.
      
      team = get_Team_Members(result)
      puts team
      #@rally.update("project",project["ObjectID"],@object_array)
      #puts "Project ID is #{project["_ref"]} and team is #{project["TeamMembers"]}"
  else
      puts "Result length is #{result.length} and is in else"
  end
end

def build_query(type,fetch,string)
  query = RallyAPI::RallyQuery.new()
  query.type=type
  query.fetch=fetch
  query.query_string=string
 # query.project ={"_ref" => "https://rally1.rallydev.com/slm/webservice/v2.0/project/14357184706.js"}
  result = @rally.find(query)
  return result
end

def start
    
    puts "HI"
    @names = "Junyi Shi,Rohan Dalvi"
    names_array = @names.split(',')
    convert_to_objects(names_array)
    get_Project_OID(@project)
  
end

def get_Team_Members(result)
  
      project = result.first
      puts result.inspect
      return project["TeamMembers"].results
end

def parse_csv
  
  file_name = "rallyimport.csv"
  input = CSV.read(file_name)

  header = input.first
  rows = []
  (1...input.size).each { |i| rows << CSV::Row.new(header, input[i]) }
  
  
end

def convert_to_objects(array)
  object_array = Array.new
  
  array.each { |arr|
    puts arr
    object_array = get_user_objects(arr)
    
    
  }
  puts "Object Array"
    puts object_array.count
    puts "--------------------------"
end

def get_user_objects(userid)
    puts "Parameter is #{userid}"
    query = RallyAPI::RallyQuery.new()
    query.type = "user"
    query.fetch = "DisplayName, EmailAddress, FirstName, LastName, MiddleName"
    query.query_string="(DisplayName = \"#{userid}\")"    
  
    result = @rally.find(query)
    if(result.length==1)
        puts "Record found!"
        user_object = result.first
        return result.first
    else  
      
        puts "No Record could be found based on the query!"
        
    end
  
end

start

