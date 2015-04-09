require "rails_helper"

RSpec.describe KlubMailer, :type => :mailer do

  let(:klub) { build(:klub, name: 'My klub', editor_emails: ['submitter@email.com']) }
  let(:mail) { KlubMailer.new_klub_mail(klub.inspect) }

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
end
