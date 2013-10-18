#just a helper script for getting results from UserPermission abstract type

require 'rally_api_emc_sso'
require '../CLI/connect.rb'
require 'timeout'

def build_query(type,fetch,project,string)
  
  query = RallyAPI::RallyQuery.new()
  query.type = type
  query.fetch = fetch
  query.query_string = string
  query.limit=10
  
  
  result = @rally.find(query)
  
  if(result.length!=0)
    return result
  else
    puts "There was some problem accessing your query #{string}"
  end
  
end

def start
  
  get_role_permission()

  
  puts "Done"
end

def get_role_permission()
  
    query = RallyAPI::RallyQuery.new()
    query.type = :projectpermission
    query.fetch = "Role"
    query.workspace = {"_ref" => "#{get_workspace}"}
    query.query_string="(Role != \"Viewer\")"
    query.limit=10
    
    
    result = @rally.find(query)

    if(result.length!=0)
      puts "Got some result"
      puts result.first.Role
    else
      puts "No result"
    end
  
end

def get_workspace
  
  result = build_query("workspace","Name,Projects,State","","(Name = \"#{@workspace}\")")
  
  if(result.length>0)
    story = result.first
    return story["_ref"]
  end
  
end
def get_project
  
  result = build_query("project","Name,TeamMembers","","(Name = \"#{@project}\")")
  
  if(result.length>0)
    story = result.first
    return story["_ref"]
  end
  
end

start