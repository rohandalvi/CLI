#just a helper script for getting results from UserPermission abstract type

require 'rally_api_emc_sso'
require '../CLI/connect.rb'
require 'timeout'

def build_query(type,fetch,project,string)
  
  query = RallyAPI::RallyQuery.new()
  query.type = type
  query.fetch = fetch
  query.query_string = string
  
  result = @rally.find(query)
  
  if(result.length!=0)
    return result
  else
    puts "There was some problem accessing your query #{string}"
  end
  
end

def start
  
rescue
  status = Timeout::timeout(180) do
    
    @response_plain = http.post(uri.path,@data).body
  end
rescue Timeout::Error => e
  raise "Timer expired -- Waited for too long for response from carrier"

  
=begin  
  result = build_query("User","DisplayName,Role,TeamMemberships,UserPermissions","","(TeamMemberships.Name = \"Rohan-test\")" && "(DisplayName = \"Nigel Watkins\")")
  
  story = result.first
  puts story["UserPermissions"].results.first.inspect
=end  
  get_role_permission()

  
end

def get_role_permission()
  
    query = RallyAPI::RallyQuery.new()
    query.type = :projectpermission
    query.fetch = "Role"
    query.workspace = {"_ref" => "#{get_workspace}"}
    query.project = {"_ref" => "#{get_project}"}
    query.query_string="(Role = \"Editor\")"
    
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