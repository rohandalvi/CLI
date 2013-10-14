=begin

  This updates team member for a given project. It can be tweaked to get input via different sources.
  
  Author: Rohan Dalvi
  Organization: EMC Corporation.
  Date Modified: 10/14/2013
    
=end  
  
  require '../CLI/connect.rb'
    
  def build_query(type,fetch,project_ref,string)
    query = RallyAPI::RallyQuery.new()
    
    query.type = type
    query.fetch=fetch
    query.query_string=string  
    result = @rally.find(query)
      
    return result
    
  end

  def start

    @projectName = "" #Add Name of Project
    username = "" #Add user to be updated
        
    currentTeamMembership = get_current_team_membership(username)
    
   # puts "Current Team Membership: #{currentTeamMembership.inspect}"
    current = currentTeamMembership.first
    h_array = Array.new
    h_array = current["TeamMemberships"]
    h_array<<get_project_ref
   
   
    puts "h array = #{h_array.inspect}"
    
    #declaring hash which will be passed on to the update function   
    final = {}
    final["TeamMemberships"] = h_array #adding array elements to hash for querying.
    #update query for rally.
    @rally.update("user",@story["_ref"],final)
    
    
    puts "End of Program"   
 end
  
  def get_current_team_membership(displayname)
    #get current team membership for a user    
    result = build_query("User","DisplayName,TeamMemberships","","(DisplayName = \"#{displayname}\")")   
    
    if(result.length!=0)
      @story = result.first
      return result
      
     else
       
       puts "There was some problem getting team membership for this user"
     
     end
  end
  
  def get_project_ref
    
    
      result = build_query("Project","Name,Description,ObjectID","","(Name = \"#{@projectName}\")")
      puts result.inspect
     
      if(result.length==1)
        project = result.first
        puts "What is project? #{project.class}"
        return project
        
      else
     
        puts "There was some problem getting the project"
        
      end
    
  end
  
  def get_project
    result = build_query("Project","Name,Description,ObjectID","","(Name = \"#{@projectName}\")")
     
    puts result.inspect
    
    if(result.length==1)
        project = result.first
        return project["_ref"]
    else
        puts "There was some problem getting the project"
    end
 end
   
 start