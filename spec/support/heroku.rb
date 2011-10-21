shared_context "when on Cedar" do
  let(:command_line)  { mock("Kumade::CommandLine") }
  let(:stack_command) { "bundle exec heroku stack --remote staging" }
  let(:heroku_output) { ["aspen-mri-1.8.6", "bamboo-mri-1.9.2", "bamboo-ree-1.8.7", "* cedar (beta)"].map { |s| "  #{s}"}.join("\n") }

  before do
    Kumade::CommandLine.expects(:new).with(stack_command).returns(command_line)

    command_line.expects(:run_or_error).returns(heroku_output)
  end
end

shared_context "when not on Cedar" do
  let(:command_line)  { mock("Kumade::CommandLine") }
  let(:stack_command) { "bundle exec heroku stack --remote staging" }
  let(:heroku_output) { ["aspen-mri-1.8.6", "* bamboo-mri-1.9.2", "bamboo-ree-1.8.7", "cedar (beta)"].map {|s| "  #{s}" }.join("\n") }

  before do
    Kumade::CommandLine.expects(:new).with(stack_command).returns(command_line)

    command_line.expects(:run_or_error).returns(heroku_output)
  end
end
