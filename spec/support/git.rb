module GitHelpers
  def dirty_the_repo
    `echo dirty_it_up > .gitkeep`
  end
end
