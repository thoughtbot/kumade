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

  def modify_tracked_file
    write_file('tracked-file', 'clean')
    commit_everything_in_repo
    append_to_file('tracked-file', 'dirty it up')
  end
end

World(GitHelpers)
