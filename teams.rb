=begin

  This updates team member for a given project. It can be tweaked to get input via different sources.
  
  Author: Rohan Dalvi
  Organization: EMC Corporation.
  Date Modified: 10/14/2013
    
=end  
  
  require 'rally_api_emc_sso'
  require '../CLI/connect.rb'
  
  
  #function to build and execute queries.
    
  def build_query(type,fetch,project_ref,string)
    query = RallyAPI::RallyQuery.new()
    
    query.type = type
    query.fetch=fetch
    query.query_string=string  
    result = @rally.find(query)
      
    return result
    
  end

  #init function

  def start
    #change name of project in connect.rb file
    @username = "Name of user" #Add user to be updated
        
    currentTeamMembership = get_current_team_membership(@username)
    
   # puts "Current Team Membership: #{currentTeamMembership.inspect}"
   
    current = currentTeamMembership.first
    h_array = Array.new
    h_array = current["TeamMemberships"]
    h_array<<get_project_ref
   
    puts "h array = #{h_array.inspect}"
 
    #declaring hash which will be passed on to the update function   
    final = {}
    final["TeamMemberships"] = h_array #adding array elements to hash for querying.
    puts "#{final["TeamMemberships"].inspect}"
    #update query for rally.
    @rally.update("user",@story["_ref"],final)
    
    puts "End of Program"   
 end
  
  #get list of member teams for a given user.
  
  def get_current_team_membership(displayname)
    #get current team membership for a user    
    result = build_query("User","DisplayName,TeamMemberships","","(DisplayName = \"#{displayname}\")")   
    
    if(result.length!=0)
      @story = result.first
      puts "Current Team Memberships: #{result.inspect}"
      return result
      
     else
       
       puts "There was some problem getting team membership for this user"
     
     end
  end
  
  #get the project object which needs to be added to the list of memberships for the given user.
  
  def get_project_ref
    
      result = build_query("Project","Name,Description,ObjectID","","(Name = \"#{@project}\")")
      puts result.inspect
     
      if(result.length==1)
        project = result.first
        puts "What is project? #{project.class}"
        return project
        
      else
     
        puts "There was some problem getting the project"
        exit
      end 
  end
  
 start