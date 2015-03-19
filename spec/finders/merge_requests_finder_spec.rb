require 'spec_helper'

describe MergeRequestsFinder do
  let(:user) { create :user }
  let(:user2) { create :user }
  let(:project1) { create(:project) }
  let(:project2) { create(:project) }
  let(:merge_request1) { create(:merge_request, author: user, source_project: project1, target_project: project2) }
  let(:merge_request2) { create(:merge_request, author: user, source_project: project2, target_project: project1) }
  let(:merge_request3) { create(:merge_request, author: user, source_project: project2, target_project: project2) }

  before do
    project1.team << [user, :master]
    project2.team << [user, :developer]
    project2.team << [user2, :developer]
  end

  describe :execute do
    before :each do
      merge_request1
      merge_request2
      merge_request3
    end

    it 'should filter by scope' do
      params = { scope: 'authored', state: 'opened' }
      merge_requests = MergeRequestsFinder.new.execute(user, params)
      merge_requests.size.should == 3
    end

    it 'should filter by project' do
      params = { project_id: project1.id, scope: 'authored', state: 'opened' }
      merge_requests = MergeRequestsFinder.new.execute(user, params)
      merge_requests.size.should == 1
    end
  end
end
