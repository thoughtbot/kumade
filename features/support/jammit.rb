module JammitHelpers
  def set_up_jammit
    assets_yaml = <<-YAML.strip
      javascripts:
        default:
          - public/javascripts/application.js
    YAML
    write_file('public/javascripts/application.js', 'var foo = 3;')
    write_file('config/assets.yml', assets_yaml)
    commit_everything_in_repo('add Jammit files')
  end
end

World(JammitHelpers)
