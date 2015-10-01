require 'spec_helper'

describe command('/usr/local/bin/vim --version') do
  it 'runs with error' do
    expect(subject.exit_status).to eq 0
  end
end
