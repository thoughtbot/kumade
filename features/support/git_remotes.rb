module GitRemoteHelpers
  def remove_all_git_remotes
    remotes = `git remote -v show | grep fetch | cut -f1`.strip.split
    remotes.each { |remote| `git remote rm #{remote} 2> /dev/null` }
  end
end

World(GitRemoteHelpers)
