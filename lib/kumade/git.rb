module Kumade
  class Git < Base
    def initialize(pretending, environment)
      super()
      @pretending = pretending
      @environment = environment
    end
    
    def heroku_remote?
      `git config --get remote.#{environment}.url`.strip =~ /^git@heroku\.com:(.+)\.git$/
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
      run_or_error([command], "Failed to push #{branch} -> #{remote}")
      success("Pushed #{branch} -> #{remote}")
    end
    
    def create(branch)
      unless branch_exist?(branch)
        run_or_error("git branch #{branch}", "Failed to create #{branch}")
      end
    end
    
    def delete(branch_to_delete, branch_to_checkout)
      run_or_error(["git checkout #{branch_to_checkout}", "git branch -D #{branch_to_delete}"],
                   "Failed to clean up #{branch_to_delete} branch")
    end
    
    def add_and_commit_all_in(dir, branch, commit_message, success_output, error_output)
      run_or_error ["git checkout -b #{branch}", "git add -f #{dir}", "git commit -m '#{commit_message}'"],
                   "Cannot deploy: #{error_output}"
      success success_output
    end
    
    def current_branch
      `git symbolic-ref HEAD`.sub("refs/heads/", "").strip
    end
    
    def remote_exists?(remote_name)
      if pretending
        true
      else
        `git remote` =~ /^#{remote_name}$/
      end
    end
    
    def git_dirty?
      `git diff --exit-code`
      !$?.success?
    end
    
    def ensure_clean_git
      if ! pretending && git_dirty?
        error("Cannot deploy: repo is not clean.")
      else
        success("Git repo is clean")
      end
    end

    def branch_exist?(branch)
        branches = `git branch`
        regex = Regexp.new('[\\n\\s\\*]+' + Regexp.escape(branch.to_s) + '\\n')
        result = ((branches =~ regex) ? true : false)
        return result
    end
  end
end