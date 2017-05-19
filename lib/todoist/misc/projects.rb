module Todoist
  module Misc
    class Projects
        include Todoist::Util  
        
        # Get archived projects.  Returns projects as documented here.
        def get_archived_projects()
          result = NetworkHelper.getResponse(Config::TODOIST_PROJECTS_GET_ARCHIVED_COMMAND)
          return ParseHelper.make_objects_as_array(result)
        end
        
        # Gets project information including all notes.
        
        def get_project_info(project, all_data = true)
          result = NetworkHelper.getResponse(Config::TODOIST_PROJECTS_GET_COMMAND, {project_id: project.id, all_data: true})
          
          project = result["project"] ? ParseHelper.make_object(result["project"]) : nil
          notes = result["notes"] ? ParseHelper.make_objects_as_array(result["notes"]) : nil
          return {"project" => project, "notes" => notes}
        end
        
        # Gets a project's uncompleted items
        def get_project_data(project)
          result = NetworkHelper.getResponse(Config::TODOIST_PROJECTS_GET_DATA_COMMAND, {project_id: project.id})
          project = result["project"] ? ParseHelper.make_object(result["project"]) : nil
          items = result["items"] ? ParseHelper.make_objects_as_array(result["items"]) : nil
          return {"project" => project, "items" => items}
        end
    end
  end
end