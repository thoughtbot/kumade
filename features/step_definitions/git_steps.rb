When /^I initialize a git repo$/ do
  When "I successfully run `git init`"
end

When /^I commit everything in the current directory to git$/ do
  steps %{
    When I successfully run `git add .`
    And I successfully run `git commit -m blerg`
  }
end
