

# Inspec test for recipe git_cookbook::default

# The Inspec reference, with examples and extensive documentation, can be found
describe package('git') do
	it { should be_installed }
end
