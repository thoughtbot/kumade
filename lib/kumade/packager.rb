module Kumade
  class Packager < Base
    attr_reader :git
    
    def initialize(pretending, environment, git)
      super()
      @pretending = pretending
      @environment = environment
      @git = git
    end
    
    def run
      invoke_custom_task  if custom_task?
      package_with_jammit if jammit_installed?
      package_with_more   if more_installed?
    end
    
    def invoke_custom_task
      success "Running kumade:before_asset_compilation task"
      Rake::Task["kumade:before_asset_compilation"].invoke unless pretending
    end
    
    def custom_task?
      load("Rakefile") if File.exist?("Rakefile")
      Rake::Task.task_defined?("kumade:before_asset_compilation")
    end
    
    def package_with_jammit
      begin
        success_message = "Packaged assets with Jammit"

        if pretending
          success(success_message)
        else
          Jammit.package!

          success(success_message)
          git_add_and_commit_all_assets_in(jammit_assets_path)
        end
      rescue => jammit_error
        error("Error: #{jammit_error.class}: #{jammit_error.message}")
      end
    end
    
    def package_with_more
      success_message = "Packaged assets with More"
      if pretending
        success(success_message)
      else
        begin
          run "bundle exec rake more:generate"
          if git.git_dirty?
            success(success_message)
            git_add_and_commit_all_assets_in(more_assets_path)
          end
        rescue => more_error
          error("Error: #{more_error.class}: #{more_error.message}")
        end
      end
    end
    
    def git_add_and_commit_all_assets_in(dir)
      git.add_and_commit_all_in(dir, DEPLOY_BRANCH, 'Compiled assets', "Added and committed all assets", "couldn't commit assets")
    end
    
    def jammit_assets_path
      File.join(Jammit::PUBLIC_ROOT, Jammit.package_path)
    end
    
    def more_assets_path
      File.join('public', ::Less::More.destination_path)
    end
    
    def jammit_installed?
      @jammit_installed ||=
        (defined?(Jammit) ||
          begin
            require 'jammit'
            true
          rescue LoadError
            false
          end)
    end
    
    def more_installed?
      @more_installed ||=
        (defined?(Less::More) ||
          begin
            require 'less/more'
            true
          rescue LoadError
            false
          end)
    end
  end
end