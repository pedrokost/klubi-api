require 'rails_helper'

RSpec.describe CommentRequestMailer, type: :mailer do
  describe 'new_recommendation_posted' do
    let!(:klub) { create(:complete_klub, name: 'My klub' * 3) }
    let!(:comment) do
      create(:comment,
             commentable: klub,
             body: 'To je moje priporocilo',
             commenter_name: 'Pisatelj Joze',
             commenter_email: 'pisatelj.joze@test.com')
    end
    let!(:comment_request) do
      create(:comment_request,
             commentable: klub,
             comment: comment,
             commenter_email: 'pisatelj.joze@test.com',
             commenter_name: 'Pisatelj Joze',
             requester_name: 'Requester is my name',
             requester_email: 'requester@test.com')
    end

    let(:mail) { CommentRequestMailer.new_recommendation_posted(comment_request.id) }

    it 'renders the subject' do
      expect(mail.subject).to include('Pisatelj Joze je priporočil My klubMy klubMy klub')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql(['requester@test.com'])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql(['peter@klubi.si'])
    end

    it "is bbc's to bcc@klubi.si" do
      expect(mail.bcc).to eql(['bcc@klubi.si'])
    end

    it 'sends commenter name' do
      expect(mail.html_part.body.decoded).to match('Pisatelj Joze')
    end

    it 'sends requester name' do
      expect(mail.html_part.body.decoded).to match('Requester is my name')
    end

    it 'send comment body' do
      expect(mail.html_part.body.decoded).to match('To je moje priporocilo')
    end

    it 'should include the klub name' do
      expect(mail.html_part.body.decoded).to match('My klub' * 3)
    end

    it "should contain direct link to klub page" do
      expect(mail.html_part.body.decoded).to match(klub.spa_url)
    end
  end

  describe 'send_request' do
    let!(:klub) { create(:complete_klub, name: 'My klub') }
    let!(:comment_request) do
      create(:comment_request,
             commentable: klub,
             commenter_email: 'pisatelj.joze@test.com',
             commenter_name: 'Pisatelj Joze',
             requester_name: 'The Requester',
             requester_email: 'requester@test.com',
             )
    end

    let(:mail) { CommentRequestMailer.send_request(comment_request.id) }

    it 'renders the subject' do
      expect(mail.subject).to include('Priporoči My klub')
    end

    it 'sends the email to the commenter' do
      expect(mail.to).to eql(['pisatelj.joze@test.com'])
    end

    it 'sends the email from default email' do
      expect(mail.from).to eql(['peter@klubi.si'])
    end

    it "is bbc's to bcc@klubi.si" do
      expect(mail.bcc).to eql(['bcc@klubi.si'])
    end

    it 'sends commenter name' do
      expect(mail.html_part.body.decoded).to match('Pisatelj Joze')
    end

    it 'sends requester name' do
      expect(mail.html_part.body.decoded).to match('The Requester')
    end

    it 'send comment body' do
      expect(mail.html_part.body.decoded).to match('prosi za kratko priporočilo')
    end

    it 'should include the klub name' do
      expect(mail.html_part.body.decoded).to match('My klub')
    end

    it "should contain direct link to comment create page" do
      expect(mail.html_part.body.decoded).to match(comment_request.spa_url)
    end
  end
end
