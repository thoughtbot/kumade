require "spec_helper"

describe Kumade::NoopPackager do
  subject { Kumade::NoopPackager }

  it_should_behave_like "packager"

  its(:assets_path) { should == "" }

  it { should_not be_installed }
end
