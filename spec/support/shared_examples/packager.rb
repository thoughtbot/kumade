share_examples_for "packager" do
  its(:assets_path) { should_not be_nil }

  it { should respond_to(:installed?) }
  it { should respond_to(:package) }
end
