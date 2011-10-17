shared_context "when on Cedar" do
  let(:command_line) { mock("Kumade::CommandLine instance") }

  before do
    Kumade::CommandLine.expects(:new).
      with("bundle exec heroku stack --remote staging").
      returns(command_line)

    command_line.expects(:run_or_error).returns(true)
    command_line.expects(:last_command_output).returns(%{
  aspen-mri-1.8.6
  bamboo-mri-1.9.2
  bamboo-ree-1.8.7
* cedar (beta)
})
  end
end

shared_context "when not on Cedar" do
  let(:command_line) { mock("Kumade::CommandLine") }

  before do
    Kumade::CommandLine.expects(:new).
      with("bundle exec heroku stack --remote staging").
      returns(command_line)

    command_line.expects(:run_or_error).returns(true)
    command_line.expects(:last_command_output).returns(%{
  aspen-mri-1.8.6
* bamboo-mri-1.9.2
  bamboo-ree-1.8.7
  cedar (beta)
})
  end
end
