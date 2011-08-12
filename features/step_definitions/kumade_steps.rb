When /^I run kumade with "([^"]+)"$/ do |args|
  When %{I run `bundle exec kumade #{args}`}
end
