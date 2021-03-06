require 'rails_helper'
require 'capybara/rspec'

RSpec.describe Like, type: :model do
  context 'Like associations tests' do
    it { should belong_to(:user) }
    it { should belong_to(:post) }
  end
end
