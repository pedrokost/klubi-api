require 'rails_helper'

RSpec.describe CommentRequest, type: :model do

  let(:klub) { create(:complete_klub, categories: ['football']) }

  let(:comment) { build(:comment, {
      commentable: klub,
      body: 'This is the comment',
      commenter_name: 'MyName',
      commenter_email: 'email@test.com'
    })
  }

  let(:comment_request) { build(:comment_request,
    commentable: klub,
    comment: comment,
    requester_email: 'requester@test.com',
    requester_name: 'arst',
    commenter_email: 'email@test.com',
    )
  }
  subject { comment_request }
  it { should be_valid }

  it "send_comment_received_email_to_requestor" do
    comment.save!
    subject.save!
    expect { subject.send(:send_comment_received_email_to_requestor) }.to change {
      enqueued_jobs.count
    }.by 1
  end

  it "generates request_hash on create" do
    expect(comment_request.request_hash).to be nil
    comment_request.save!
    expect(comment_request.request_hash).not_to be nil
  end

  describe "send_comment_request_email" do

    it "does nothing if request not persisted" do
      expect { subject.send_comment_request_email }.not_to change { enqueued_jobs.count }
    end

    it "sends email if persistend" do
      subject.save!
      expect { subject.send_comment_request_email }.to change { enqueued_jobs.count }.by(1)
    end
  end

  describe "spa_url" do
    it "should point to correct link" do
      allow(ENV).to receive(:[]).with("SUPPORTED_CATEGORIES").and_return('football')
      allow(ENV).to receive(:[]).with("WEBSITE_FULL_HOST").and_return('https://www.example.com')
      klub.categories = ['football']
      subject.save
      expect(subject.spa_url).to eq "https://www.example.com/football/#{klub.url_slug}/oddaj-mnenje/#{subject.request_hash}"
    end
  end
end
