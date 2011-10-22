module GitHelpers
  def set_up_git_repo
    ["git init", "touch .gitkeep", "git add .", "git commit -am First"].each do |git_command|
      run_simple(git_command)
    end
  end

  def commit_everything_in_repo
    ['git add .', 'git commit -am MY_MESSAGE'].each do |git_command|
      run_simple(git_command)
    end
  end
end

World(GitHelpers)
