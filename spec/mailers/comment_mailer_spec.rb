require "rails_helper"

RSpec.describe CommentMailer, type: :mailer do

  describe "new_klub_mail" do
    let!(:klub) { create(:complete_klub, name: 'My klub' * 3) }
    let!(:comment) do
      create(:comment,
             commentable: klub,
             body: 'To je moje priporocilo',
             commenter_name: 'Pisatelj Joze',
             commenter_email: 'pisatelj.joze@test.com')
    end
    let(:mail) { CommentMailer.thank_your_for_recommendation(comment.id) }

    it 'renders the subject' do
      expect(mail.subject).to include('My klubMy klubMy klub se ti zahvaljuje za priporočilo')
    end

    it "is bbc's to bcc@klubi.si" do
      expect(mail.bcc).to eql(['bcc@klubi.si'])
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql(['pisatelj.joze@test.com'])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql(['peter@klubi.si'])
    end

    it 'send klubs data' do
      expect(mail.html_part.body.decoded).to match('My klubMy klubMy klub')
    end

    it "should contain direct link to klub page" do
      expect(mail.html_part.body.decoded).to match(klub.spa_url)
    end
  end
end
