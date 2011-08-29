module Kumade
  class Git < Thor::Shell::Color
    def initialize(pretending, environment)
      super()
      @pretending = pretending
      @environment = environment
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
      if @pretending
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
      if ! @pretending && git_dirty?
        error("Cannot deploy: repo is not clean.")
      else
        success("Git repo is clean")
      end
    end

    def run_or_error(commands, error_message)
      all_commands = [commands].flatten.join(' && ')
      if @pretending
        say_status(:run, all_commands)
      else
        error(error_message) unless run(all_commands)
      end
    end
    
    def run(command, config = {})
      say_status :run, command
      config[:capture] ? `#{command}` : system("#{command}")
    end
    
    def error(message)
      say("==> ! #{message}", :red)
      exit 1
    end
    
    def success(message)
      say("==> #{message}", :green)
    end
    
    def branch_exist?(branch)
        branches = `git branch`
        regex = Regexp.new('[\\n\\s\\*]+' + Regexp.escape(branch.to_s) + '\\n')
        result = ((branches =~ regex) ? true : false)
        return result
    end
  end
end