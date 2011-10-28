module GitHelpers
  def dirty_the_repo
    `echo dirty_it_up > .gitkeep`
  end

  def create_untracked_file_in(directory)
    FileUtils.mkdir_p(directory)
    FileUtils.touch(File.join(directory, 'i-am-untracked'))
  end
end
