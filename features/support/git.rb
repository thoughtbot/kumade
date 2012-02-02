module GitHelpers
  def set_up_git_repo
    ["git init --template=/dev/null", "touch .gitkeep", "git add .", "git commit -am First"].each do |git_command|
      run_simple(git_command)
    end
  end

  def commit_everything_in_repo(message = "MY_MESSAGE")
    ['git add .', "git commit -am '#{message}'"].each do |git_command|
      run_simple(git_command)
    end
  end

  def modify_tracked_file
    write_file('tracked-file', 'clean')
    commit_everything_in_repo('modify tracked file')
    append_to_file('tracked-file', 'dirty it up')
  end
end

World(GitHelpers)
