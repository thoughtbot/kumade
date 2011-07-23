require 'fileutils'

module RequireKumade
  def prepend_require_kumade_to_rakefile!
    rakefile_path = File.join(current_dir, 'Rakefile')
    if File.exist?(rakefile_path)
      unless `head -n1 #{rakefile_path}`.include?("require 'kumade'")
        current_rakefile_content = File.read(rakefile_path)
        new_rakefile_content = "require 'kumade'\n" + current_rakefile_content
        When %{I write to "Rakefile" with:}, new_rakefile_content
      end
    else
      Given %{an empty file named "Rakefile"}
    end
  end
end

World(RequireKumade)
