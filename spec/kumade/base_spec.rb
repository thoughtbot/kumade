require 'spec_helper'

describe Kumade::Base, "#success" do
  it { should respond_to(:success) }
end

describe Kumade::Base, "#error" do
  before { STDOUT.stubs(:puts) }

  it { should respond_to(:error) }

  it "prints its message and raises its message" do
    lambda { subject.error("I'm an error!") }.should raise_error(Kumade::DeploymentError)

    STDOUT.should have_received(:puts).with(regexp_matches(/I'm an error!/))
  end
end
