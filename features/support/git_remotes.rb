module GitRemoteHelpers
  @@created_remotes = []

  def remove_all_created_remotes
    in_current_dir do
      @@created_remotes.each do |remote|
        run_simple("git remote rm #{remote}")
      end
    end

    @@created_remotes = []
  end

  def add_heroku_remote_named(remote_name)
    run_simple("git remote add #{remote_name} git@heroku.com:#{remote_name}_app.git")
    @@created_remotes << remote_name
  end

  def add_non_heroku_remote_named(remote_name)
    run_simple("git remote add #{remote_name} git@github.com:gabebw/kumade.git")
    @@created_remotes << remote_name
  end
end

World(GitRemoteHelpers)
