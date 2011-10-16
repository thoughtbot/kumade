require 'spec_helper'

describe Kumade::Outputter, "#success" do
  before { STDOUT.stubs(:puts) }

  it "prints a message to STDOUT" do
    subject.success("woo hoo")
    STDOUT.should have_received(:puts).with(regexp_matches(/==> woo hoo/))
  end
end

describe Kumade::Outputter, "#error" do
  before { STDOUT.stubs(:puts) }

  it "raises a DeploymentError with the given message" do
    lambda { subject.error("uh oh") }.should raise_error(Kumade::DeploymentError, "uh oh")
  end

  it "prints a message to STDOUT" do
    subject.error("uh oh") rescue nil
    STDOUT.should have_received(:puts).with(regexp_matches(/==> ! uh oh/))
  end
end

describe Kumade::Outputter, "#info" do
  before { STDOUT.stubs(:puts) }

  it "prints a message to STDOUT" do
    subject.info("the more you know")
    STDOUT.should have_received(:puts).with(regexp_matches(/==> the more you know/))
  end
end

describe Kumade::Outputter, "#say_command" do
  before { STDOUT.stubs(:puts) }

  it "prints a formatted message to STDOUT" do
    subject.say_command("git checkout master")
    STDOUT.should have_received(:puts).with(" " * 8 + "git checkout master")
  end
end

describe Kumade::Outputter, "#info" do
  before { STDOUT.stubs(:puts) }

  it "prints a message to STDOUT" do
    subject.info("the more you know")
    STDOUT.should have_received(:puts).with(regexp_matches(/==> the more you know/))
  end
end
