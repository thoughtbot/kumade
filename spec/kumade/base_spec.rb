require 'spec_helper'

describe Kumade::Base, "#success" do
  it "exists" do
    subject.should respond_to(:success)
  end
end

describe Kumade::Base, "#error" do
  it "exists" do
    subject.should respond_to(:error)
  end

  it "prints its message and raises its message" do
    subject.should_receive(:say).with("==> ! I'm an error!", :red)
    lambda{ subject.error("I'm an error!") }.should raise_error(Kumade::DeploymentError)
  end
end
