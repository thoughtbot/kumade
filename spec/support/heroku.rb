shared_context "when on Cedar" do
  let(:command_line) { mock("Cocaine::CommandLine") }

  before do
    Cocaine::CommandLine.expects(:new).
      with("bundle exec heroku stack --remote staging").
      returns(command_line)

    command_line.expects(:run).returns(%{
  aspen-mri-1.8.6
  bamboo-mri-1.9.2
  bamboo-ree-1.8.7
* cedar (beta)
})
  end
end

shared_context "when not on Cedar" do
  let(:command_line) { mock("Cocaine::CommandLine") }

  before do
    Cocaine::CommandLine.expects(:new).
      with("bundle exec heroku stack --remote staging").
      returns(command_line)

    command_line.expects(:run).returns(%{
  aspen-mri-1.8.6
* bamboo-mri-1.9.2
  bamboo-ree-1.8.7
  cedar (beta)
})
  end
end
