# == Schema Information
#
# Table name: keys
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  key         :text
#  title       :string(255)
#  type        :string(255)
#  fingerprint :string(255)
#

require 'spec_helper'

describe DeployKey do
  let(:project) { create(:project) }
  let(:deploy_key) { create(:deploy_key, projects: [project]) }

  describe "Associations" do
    it { should have_many(:deploy_keys_projects) }
    it { should have_many(:projects) }
  end
end
