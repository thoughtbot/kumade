require 'cocaine'
module Kumade
  class Git < Base
    def initialize
      super()
    end

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
      success("Pushed #{branch} -> #{remote}")
    end

    def create(branch)
      unless has_branch?(branch)
        CommandLine.new("git branch #{branch}").run_or_error("Failed to create #{branch}")
      end
    end

    def delete(branch_to_delete, branch_to_checkout)
      command_line = CommandLine.new("git checkout #{branch_to_checkout} && git branch -D #{branch_to_delete}")
      command_line.run_or_error("Failed to clean up #{branch_to_delete} branch")
    end

    def add_and_commit_all_in(dir, branch, commit_message, success_output, error_output)
      command_line = CommandLine.new("git checkout -b #{branch} && git add -f #{dir} && git commit -m '#{commit_message}'")
      command_line.run_or_error("Cannot deploy: #{error_output}")
      success(success_output)
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
        error("Cannot deploy: repo is not clean.")
      else
        success("Git repo is clean")
      end
    end

    private

    def has_branch?(branch)
      CommandLine.new("git show-ref #{branch}").run
    end
  end
end
