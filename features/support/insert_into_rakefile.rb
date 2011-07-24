module InsertIntoRakefileHelpers
  def insert_after_tasks_are_loaded(new_content)
    rakefile_path = File.join(current_dir, 'Rakefile')
    current_rakefile_content = File.readlines(rakefile_path)
    load_tasks_index = current_rakefile_content.index("Kumade.load_tasks")

    new_rakefile_content = current_rakefile_content[0..load_tasks_index].join +
                           "\n" + new_content +
                           current_rakefile_content[load_tasks_index..-1].join
    When %{I write to "Rakefile" with:}, new_rakefile_content
    When %{I commit everything in the current directory to git}
  end
end

World(InsertIntoRakefileHelpers)
