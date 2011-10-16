require "spec_helper"

describe Kumade::NoopPackager, :with_mock_outputter do
  subject { Kumade::NoopPackager }

  it_should_behave_like "packager"

  its(:assets_path) { should == "" }
end
