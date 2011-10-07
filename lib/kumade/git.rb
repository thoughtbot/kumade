require 'cocaine'
module Kumade
  class Git
    def heroku_remote?
      remote_url = `git config --get remote.#{Kumade.configuration.environment}.url`.strip
      !! remote_url.strip.match(/^git@heroku\..+:(.+)\.git$/)
    end

    def self.environments
      url_remotes = `git remote`.strip.split("\n").map{|remote| [remote, `git config --get remote.#{remote}.url`.strip] }.select{|remote| remote.last =~ /^git@heroku\.com:(.+)\.git$/}.map{|remote| remote.first}
    end

    def push(branch, remote = 'origin', force = false)
      command = ["git push"]
      command << "-f" if force
      command << remote
      command << branch
      command = command.join(" ")

      command_line = CommandLine.new(command)
      command_line.run_or_error("Failed to push #{branch} -> #{remote}")
      Kumade.outputter.success("Pushed #{branch} -> #{remote}")
    end

    def create(branch)
      unless has_branch?(branch)
        CommandLine.new("git branch #{branch} >/dev/null").run_or_error("Failed to create #{branch}")
      end
    end

    def delete(branch_to_delete, branch_to_checkout)
      if has_branch?(branch_to_delete)
        command_line = CommandLine.new("git checkout #{branch_to_checkout} 2>/dev/null && git branch -D #{branch_to_delete}")
        command_line.run_or_error("Failed to clean up #{branch_to_delete} branch")
      end
    end

    def add_and_commit_all_assets_in(dir)
      command = ["git checkout -b #{Kumade::Heroku::DEPLOY_BRANCH} 2>/dev/null",
                 "git add -f #{dir}",
                 "git commit -m 'Compiled assets.'"].join(' && ')
      command_line = CommandLine.new(command)
      command_line.run_or_error("Cannot deploy: couldn't commit assets")
      Kumade.outputter.success("Added and committed all assets")
    end

    def current_branch
      `git symbolic-ref HEAD`.sub("refs/heads/", "").strip
    end

    def remote_exists?(remote_name)
      if Kumade.configuration.pretending?
        true
      else
        `git remote` =~ /^#{remote_name}$/
      end
    end

    def dirty?
      ! CommandLine.new("git diff --exit-code").run
    end

    def ensure_clean_git
      if ! Kumade.configuration.pretending? && dirty?
        Kumade.outputter.error("Cannot deploy: repo is not clean.")
      else
        Kumade.outputter.success("Git repo is clean")
      end
    end

    private

    def has_branch?(branch)
      CommandLine.new("git show-ref #{branch}").run
    end
  end
end
