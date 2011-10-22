module RailsAppHelpers
  def create_rails_app_with_kumade
    run_simple("rails new rake-tasks -T")
    cd('rake-tasks')
    append_to_file('Gemfile', "gem 'kumade', :path => '#{PROJECT_PATH}'")
    run_bundler
    set_up_git_repo
  end

  def create_rails_app_with_kumade_and_jammit
    create_rails_app_with_kumade
    add_jammit_to_gemfile
    run_bundler
    commit_everything_in_repo
  end
end

World(RailsAppHelpers)
