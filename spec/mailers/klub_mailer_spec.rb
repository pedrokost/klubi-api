require "rails_helper"

RSpec.describe KlubMailer, :type => :mailer do

  describe "new_klub_mail" do
    let(:klub) { build(:klub, name: 'My klub' * 10, editor_emails: ['submitter@email.com'], categories: ['fitnes', 'zumba']) }
    let(:mail) { KlubMailer.new_klub_mail(klub.to_json) }

    it 'renders the subject' do
      expect(mail.subject).to eql('A new klub has been added for review')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql(['pedro@zatresi.si'])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql(['pedro@zatresi.si'])
    end

    it 'sends submitter email' do
      expect(mail.body.encoded).to match('submitter@email.com')
    end

    it 'send klubs data' do
      expect(mail.body.encoded).to match('My klub')
    end

    it 'send klub\'s categories' do
      expect(mail.body.encoded).to match('fitnes.*zumba')
    end

    it 'should send long parameters in full length' do
      expect(mail.body.encoded).to match('My klub' * 10)
    end
  end

  describe "new_updates_mail" do
    let(:klub) { build(:klub, name: 'My klub' * 10, editor_emails: ['submitter@email.com'], categories: ['fitnes', 'zumba']) }
    let(:update) { build(:update, editor_email: 'joe@doe.com', field: 'my_field', oldvalue: 'old_val', newvalue: 'new_val') }
    let(:mail) { KlubMailer.new_updates_mail(klub.name, [update]) }

    it 'renders the subject' do
      expect(mail.subject).to eql("Updates submitted for 'My klubMy klubMy klubMy klubMy klubMy klubMy klubMy klubMy klubMy klub'")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql(['pedro@zatresi.si'])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql(['pedro@zatresi.si'])
    end

    it 'sends submitter email' do
      expect(mail.body.encoded).to match('joe@doe.com')
    end

    it 'send update data' do
      expect(mail.body.encoded).to match('my_field').and match('old_val').and match('new_val')
    end
  end
end
