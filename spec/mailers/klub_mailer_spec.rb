require "rails_helper"

RSpec.describe KlubMailer, :type => :mailer do

  describe "new_klub_mail" do
    let!(:klub) { create(:klub, name: 'My klub' * 10, editor_emails: ['submitter@email.com'], categories: ['fitnes', 'zumba']) }
    let(:mail) { KlubMailer.new_klub_mail(klub.id) }

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

    it "should contain direct link to admin's klub page" do
      expect(mail.body.encoded).to match("/klubs/#{klub.id}")
    end
  end

  describe "new_klub_thanks_mail" do
    let!(:klub) { create(:klub, name: 'My klub' * 10, editor_emails: ['submitter@email.com'], categories: ['fitnes', 'zumba']) }
    let(:mail) { KlubMailer.new_klub_thanks_mail(klub.id, 'submitter@email.com') }

    it 'renders the subject' do
      expect(mail.subject).to match('Hvala za dodani klub')
    end

    it 'is sent to the editor' do
      expect(mail.to).to eql(['submitter@email.com'])
    end

    it 'is sent by the zatresi bot' do
      expect(mail.from).to eql(['peter@zatresi.si'])
    end

    it 'send klubs data' do
      expect(mail.body.encoded).to match('My klub')
    end

    it 'send klub\'s categories' do
      expect(mail.body.encoded).to match('fitnes.*zumba')
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

  describe "confirmation_for_pending_updates_mail" do
    let(:klub) {
      create(:complete_klub, name: 'MyKlub', categories: ['fitnes'])
    }
    let(:update) {
      create( :update, field: 'phone', oldvalue: 'staro', newvalue: 'novo', updatable: klub )
    }
    let(:mail) {
      KlubMailer.confirmation_for_pending_updates_mail(
        klub.id,
        'joe@email.com',
        [update.id]
      )
    }

    it "is sent to the editor" do
      expect(mail.to).to eql(['joe@email.com'])
    end

    it "is sent from peter bot" do
      expect(mail.from).to eql(['peter@zatresi.si'])
    end

    it "renders the subject" do
      expect(mail.subject).to match('Vaši popravki za MyKlub')
    end

    it "contains link to the klub" do
      expect(mail.body.encoded).to match("http://www.zatresi.si/fitnes/#{klub.slug}/")
    end

    it "contains link to edit the klub" do
      expect(mail.body.encoded).to match("http://www.zatresi.si/fitnes/#{klub.slug}/uredi")
    end

    it "contains the list of updates" do
      expect(mail.body.encoded.downcase).to match('telefon')
      expect(mail.body.encoded.downcase).to match('novo')
    end
  end

  describe "confirmation for accepted updates mail" do
    let(:klub) {
      create(:complete_klub, name: 'MyKlub', categories: ['fitnes'])
    }
    let(:update) {
      create( :update, field: 'address', oldvalue: 'staro', newvalue: 'novo', updatable: klub )
    }
    let(:update2) {
      create( :update, field: 'phone', oldvalue: '043224', newvalue: '012312', updatable: klub )
    }
    let(:mail) {
      KlubMailer.confirmation_for_acceped_updates_mail(
        klub.id,
        'joe@email.com',
        [update.id, update2.id]
      )
    }

    before do
      update.accept!
      update2.accept!
    end

    it "is sent to the editor" do
      expect(mail.to).to eql(['joe@email.com'])
    end

    it "is sent from peter bot" do
      expect(mail.from).to eql(['peter@zatresi.si'])
    end

    it "renders the subject" do
      expect(mail.subject).to match('Vaši popravki za MyKlub so bili sprejeti')
    end

    it "contains link to the klub" do
      expect(mail.body.encoded).to match("http://www.zatresi.si/fitnes/#{klub.slug}/")
    end

    it "contains link to edit the klub" do
      expect(mail.body.encoded).to match("http://www.zatresi.si/fitnes/#{klub.slug}/uredi")
    end

    it "contains the list of updates" do
      expect(mail.body.encoded.downcase).to match('naslov')
      expect(mail.body.encoded.downcase).to match('novo')

      expect(mail.body.encoded.downcase).to match('telefon')
      expect(mail.body.encoded.downcase).to match('012312')
    end
  end

  describe "emails to request verification of klub data" do
    let(:klub) {
      create(:complete_klub,
        name: 'MyKlub',
        categories: ['fitnes'],
        email: 'owner@test.com',
        facebook_url: 'http://facebook.com',
        website: 'http://website.com',
        address: "Cesta XV. brigade 2, Metlika",
        phone: "041 444 222")
    }
    let(:mail) {
      KlubMailer.request_verify_klub_mail(
        klub.id,
        klub.email,
      )
    }

    it "is sent to the klub owner" do
      expect(mail.to).to eql(['owner@test.com'])
    end

    it "is sent from peter bot" do
      expect(mail.from).to eql(['peter@zatresi.si'])
    end

    it "is bbc's to bcc@zatresi.si" do
      expect(mail.bcc).to eql(['bcc@zatresi.si'])
    end

    it "renders the correct subject" do
      expect(mail.subject).to match('Preverite podatke vašega kluba')
    end

    it "contains link to the klub's edit page" do
      expect(mail.body.encoded).to match("http://www.zatresi.si/fitnes/#{klub.slug}/")
    end

    it "contains the the klub data" do
      expect(mail.body.encoded.downcase).to match('ime')
      expect(mail.body.encoded.downcase).to match('kraj treningov')
      expect(mail.body.encoded.downcase).to match('e-pošta')
      expect(mail.body.encoded.downcase).to match('spletna stran')
      expect(mail.body.encoded.downcase).to match('facebook stran')
      expect(mail.body.encoded.downcase).to match('telefon')

      expect(mail.body.encoded.downcase).to match('myklub')
      expect(mail.body.encoded.downcase).to match('cesta xv. brigade 2, 8330 metlika')
      expect(mail.body.encoded.downcase).to match('owner@test.com')
      expect(mail.body.encoded.downcase).to match('http://facebook.com')
      expect(mail.body.encoded.downcase).to match('http://website.com')
      expect(mail.body.encoded.downcase).to match('041 444 222')
    end
  end
end
