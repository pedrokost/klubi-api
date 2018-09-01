require 'rails_helper'

RSpec.describe Comment, type: :model do

  let(:klub) { FactoryBot.create(:complete_klub)  }
  let(:comment) { build(:comment, {
      commentable: klub,
      body: 'This is the comment',
      commenter_name: 'MyName',
      commenter_email: 'email@test.com'
    })
  }

  subject { comment }
  it { should be_valid }

  it "send_comment_published_email_to_commenter" do
    subject.save!
    expect { subject.send(:send_comment_published_email_to_commenter) }.to change {
      enqueued_jobs.count
    }.by 1
  end
end
