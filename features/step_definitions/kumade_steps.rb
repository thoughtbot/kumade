When /^I run kumade with "([^"]+)"$/ do |args|
  When %{I run `bundle exec kumade #{args}`}
end

Given /^I have loaded "([^"]+)"$/ do |file|
  in_current_dir do
    load(file)
  end
end
