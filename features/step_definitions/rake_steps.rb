When /^I require the kumade railtie in the Rakefile$/ do
  rakefile_content = prep_for_fs_check { IO.readlines("Rakefile") }
  new_rakefile_content = rakefile_content.map do |line|
    if line.include?('load_tasks')
      ["require 'kumade/railtie'", line].join("\n")
    else
      line
    end
  end.join

  overwrite_file("Rakefile", new_rakefile_content)
end
