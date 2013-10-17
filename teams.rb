=begin

  This updates team member for a given project. It can be tweaked to get input via different sources.
  
  Author: Rohan Dalvi
  Organization: EMC Corporation.
  Date Modified: 10/14/2013
    
=end  
  
  require 'rally_api_emc_sso'
  require '../CLI/connect.rb'
  require 'CSV'
  
  #function to build and execute queries.
    
  def build_query(type,fetch,project_ref,string)
    query = RallyAPI::RallyQuery.new()
    
    query.type = type
    query.fetch=fetch
    query.query_string=string  
    result = @rally.find(query)
      
    return result
    
  end
  
  def manageTeams(row)
    
        @names_array = row["Name"].split(",") 
        $count = 0
        
        while $count < @names_array.length
        
          currentTeamMembership = get_current_team_membership(@names_array[$count].strip)   
          
          current = currentTeamMembership.first
          h_array = Array.new
          h_array = current["TeamMemberships"]
          h_array<<get_project_ref(row["Project"])
   
          final = {}
          
          final["TeamMemberships"] = h_array #adding array elements to hash for querying.
          puts "#{final["TeamMemberships"].inspect}"
          
          #update query for rally.
          @rally.update("user",@story["_ref"],final)   
          
          $count+=1
        end 
    
  end

  #init function

  def start
    
    filename = "demo.csv" #input CSV file's name.
    puts "Getting input CSV.."
    CSV.foreach("demo.csv", encoding: "bom|utf-8")
    input = CSV.read(filename)
    header = input.first
    
    rows = []
    (1...input.size).each { |i| rows << CSV::Row.new(header, input[i]) }
    
    puts "Preprocessing..."
    
    @iCount = 0
    @names_array = []
    
    rows.each { |row|
      
      if(row["Name"]!=nil && row["Project"]!=nil)
        
        manageTeams(row)
      end
      
      }
    
    puts "End of Program"   
 end
  
  #get list of member teams for a given user.
  
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
  
  #get the project object which needs to be added to the list of memberships for the given user.
  
  def get_project_ref(projectName)
    
      result = build_query("Project","Name,Description,ObjectID","","(Name = \"#{projectName}\")")
      puts result.inspect
     
      if(result.length==1)
        project = result.first
        return project
        
      else
     
        puts "There was some problem getting the project"
        exit
      end 
  end
  
 start