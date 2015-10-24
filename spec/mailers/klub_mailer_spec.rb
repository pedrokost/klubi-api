require "rails_helper"

RSpec.describe KlubMailer, :type => :mailer do

  let(:klub) { build(:klub, name: 'My klub' * 10, editor_emails: ['submitter@email.com'], categories: ['fitnes', 'zumba']) }
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

  it 'send klub\'s categories' do
    expect(mail.body.encoded).to match('fitnes.*zumba')
  end

  it 'should send long parameters in full length' do
    expect(mail.body.encoded).to match('My klub' * 10)
  end
end
