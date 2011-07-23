When /^I initialize a git repo$/ do
  When "I successfully run `git init`"
end

When /^I commit everything in the current directory to git$/ do
  steps %{
    When I successfully run `git add .`
    And I successfully run `git commit -m blerg`
  }
end

When /^I load the tasks with a stub for git push$/ do
  steps %{
    When I write to "Rakefile" with:
    """
    require 'kumade'
    class Kumade::Deployer
      def git_push(remote)
        puts "[stub] Deployed to " + remote
      end
    end
    Kumade.load_tasks
    """
  }
end
