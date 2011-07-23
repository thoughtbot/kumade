When /^I initialize a git repo$/ do
  When "I successfully run `git init`"
end

When /^I commit everything in the current directory to git$/ do
  steps %{
    When I successfully run `git add .`
    And I successfully run `git commit -m blerg`
  }
end

When /^I stub out git push$/ do
  prepend_require_kumade_to_rakefile!

  steps %{
    When I append to "Rakefile" with:
    """

    class Kumade::Deployer
      def git_push(remote)
        puts "[stub] Deployed to " + remote
      end
    end
    """
  }
end
