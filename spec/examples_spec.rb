RSpec.describe 'examples from /examples dir' do

  it 'finish with exit code 0' do
    examples_dir = "#{File.dirname(__FILE__)}/../examples/"
    expect(system "ruby #{examples_dir}basic.rb").to eql true
  end

end
