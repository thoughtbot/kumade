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
end
