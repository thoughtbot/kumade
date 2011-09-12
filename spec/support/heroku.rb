shared_context "when on Cedar" do
  let(:cocaine_mock) { mock("Cocaine::CommandLine") }

  before do
    Cocaine::CommandLine.should_receive(:new).
      with("bundle exec heroku stack --remote staging").
      and_return(cocaine_mock)

    cocaine_mock.should_receive(:run).and_return(%{
  aspen-mri-1.8.6
  bamboo-mri-1.9.2
  bamboo-ree-1.8.7
* cedar (beta)
})
  end
end

shared_context "when not on Cedar" do
  let(:cocaine_mock) { mock("Cocaine::CommandLine") }

  before do
    Cocaine::CommandLine.should_receive(:new).
      with("bundle exec heroku stack --remote staging").
      and_return(cocaine_mock)
    cocaine_mock.should_receive(:run).and_return(%{
  aspen-mri-1.8.6
* bamboo-mri-1.9.2
  bamboo-ree-1.8.7
  cedar (beta)
})
  end
end
