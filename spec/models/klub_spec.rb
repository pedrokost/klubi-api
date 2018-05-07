require 'rails_helper'
require 'pry'

RSpec.describe Klub, type: :model do
  let(:klub) do
    build(:klub,
          name: 'Karate klub Skocjan -- ',
          email: 'owner@test.com',
          latitude: '46.421684',
          longitude: '14.089593',
          categories: ['football'])
  end

  subject { klub }

  it { should have_db_index(:slug) }
  it { should be_valid } # missing name

  it 'requires the name' do
    klub.name = nil
    expect(klub).not_to be_valid
  end

  it 'should require categories' do
    klub.categories = []
    expect(klub.valid?).to be_falsy
  end

  it 'should support multiple editors' do
    emails = ['a@google.com', 'b@google.com']
    klub.editor_emails = emails
    expect(klub).to be_valid
    klub.save
    expect(klub.reload.editor_emails).to eq(emails)
  end

  describe 'closed_at' do
    it 'should not be in future' do
      klub.closed_at = 1.day.from_now
      expect(klub).not_to be_valid
    end

    it 'can be today' do
      klub.closed_at = Date.today
      expect(klub).to be_valid
    end
  end

  describe 'url slug' do
    it 'should also contain slug and ID' do
      klub.save
      expect(klub.url_slug).to eq("karate-klub-skocjan-#{klub.id}")
    end
  end

  describe 'spa_url' do
    it 'should try not to include unsupported categories' do
      allow(ENV).to receive(:[]).with('SUPPORTED_CATEGORIES').and_return('football')
      allow(ENV).to receive(:[]).with('WEBSITE_FULL_HOST').and_return('https://www.example.com')
      klub.categories = %w[unsupported football]
      expect(klub.spa_url).not_to include 'unsupported'
    end
  end

  describe 'spa_edit_url' do
    it 'should try not to include unsupported categories' do
      allow(ENV).to receive(:[]).with('SUPPORTED_CATEGORIES').and_return('football')
      allow(ENV).to receive(:[]).with('WEBSITE_FULL_HOST').and_return('https://www.example.com')
      klub.categories = %w[unsupported football]
      expect(klub.spa_edit_url).not_to include 'unsupported'
    end
  end

  describe 'spa_data_confirmation_url' do
    it 'should contain the confirmation hash' do
      klub.data_confirmation_request_hash = '1234xxxx'
      allow(ENV).to receive(:[]).with('SUPPORTED_CATEGORIES').and_return('football')
      allow(ENV).to receive(:[]).with('WEBSITE_FULL_HOST').and_return('https://www.example.com')
      klub.categories = %w[football]
      expect(klub.spa_data_confirmation_url).to include 'potrdi'
      expect(klub.spa_data_confirmation_url).to include '1234xxxx'
    end
  end

  describe 'generate_data_confirmation_request_hash' do
    it 'generate a new random uuid for the klub' do
      klub.send(:generate_data_confirmation_request_hash!)

      expect(klub.data_confirmation_request_hash).not_to be_nil
      expect(klub.data_confirmation_request_hash.length).to eq 36
    end
  end

  describe 'facebook_page_id' do
    it 'is nil when not valid fb page' do
      klub.facebook_url = 'http://ni-ta-prav.si'

      expect(klub.send(:facebook_page_id)).to eq nil
    end

    it 'is nil when no facebook_url' do
      klub.facebook_url = nil

      expect(klub.send(:facebook_page_id)).to eq nil
    end

    it 'returns valid id from url' do
      klub.facebook_url = 'https://www.facebook.com/karateklub.olimpija'

      expect(klub.send(:facebook_page_id)).to eq 'karateklub.olimpija'
    end

    it 'extract id only' do
      klub.facebook_url = 'https://www.facebook.com/pg/Tokuhisa-Takashi-Karate-Dojo-141094595912874/'

      expect(klub.send(:facebook_page_id)).to eq '141094595912874'
    end

    it 'discards query params' do
      klub.facebook_url = 'http://www.facebook.com/fitnes.metulj?ref=ts&fref=ts'

      expect(klub.send(:facebook_page_id)).to eq 'fitnes.metulj'
    end

    it 'discards query params' do
      klub.facebook_url = 'https://www.facebook.com/pages/Slovenska-Zveza-Tradicionalnega-Karateja-SZTK/150573685047026?ref=digest_email#!/karate.goryu'

      expect(klub.send(:facebook_page_id)).to eq '150573685047026'
    end

    it "discards 'info' subpage" do
      klub.facebook_url = 'https://www.facebook.com/WksaSlovenija/info?tab=overview'

      expect(klub.send(:facebook_page_id)).to eq 'WksaSlovenija'
    end
  end

  describe 'create_updates' do
    it 'should not create update for tiny latitude change' do
      expect do
        klub.create_updates(latitude: 46.4216837)
      end.not_to change(Update, :count)
    end
    it 'should not create update for tiny longitude change' do
      expect do
        klub.create_updates(longitude: 14.0895932)
      end.not_to change(Update, :count)
    end

    it 'really should not create update fro nil to blank conversions' do
      klub.phone = nil
      klub.save

      expect do
        klub.create_updates(phone: '')
      end.not_to change(Update, :count)
    end

    it 'does not create updates which already exists from a previous submission' do
      expect do
        klub.create_updates(name: 'Novo ime',
                            editor: 'ninja@test.com')
      end.to change(Update, :count).by(1)

      expect do
        klub.create_updates(name: 'Novo ime',
                            editor: 'ninja@test.com')
      end.not_to change(Update, :count)
    end

    it 'creates updates which already exists from a previous submission if update was rejected' do
      expect do
        klub.create_updates(name: 'Novo ime',
                            editor: 'ninja@test.com')
      end.to change(Update, :count).by(1)

      Update.last.reject!

      expect do
        klub.create_updates(name: 'Novo ime',
                            editor: 'ninja@test.com')
      end.to change(Update, :count).by(1)
    end

    it 'creates updates which already exists from a previous submission if different user' do
      expect do
        klub.create_updates(name: 'Novo ime',
                            editor: 'ninja@test.com')
      end.to change(Update, :count).by(1)

      expect do
        klub.create_updates(name: 'Novo ime',
                            editor: 'another@test.com')
      end.to change(Update, :count).by(1)
    end

    it 'appends the note with the date' do
      klub.create_updates(notes: 'This is my note')

      expect(klub.updates.last.oldvalue).to eq ''
      expect(klub.updates.last.newvalue).to eq "#{Date.today}: This is my note"
    end

    it 'appends notes with dates' do
      klub.notes = 'This is the old notes'

      klub.create_updates(notes: 'This is another note')

      expect(klub.updates.last.oldvalue).to eq 'This is the old notes'
      expect(klub.updates.last.newvalue).to eq "#{Date.today}: This is another note\nThis is the old notes"
    end
  end

  describe 'slug creation' do
    it 'should generate slug on create' do
      klub.save
      expect(klub.slug).to eq('karate-klub-skocjan')
    end

    it 'should eliminate special characters when creating the slug' do
      klub.name = 'Škocjanski kareški Karate Črni klub'
      klub.save
      expect(klub.reload.slug).to eq 'skocjanski-kareski-karate-crni-klub'
    end

    it 'should eliminate special characters from the slug' do
      klub.save
      expect(klub.slug).to eq('karate-klub-skocjan')
      klub.name = 'Škocjansk!!i kareš~ki   '
      klub.save
      expect(klub.reload.slug).to eq 'skocjansk-i-kares-ki'
    end

    it 'should update slug on update' do
      klub.name = 'Šarate Klub Grosuplje'
      klub.save
      klub.reload
      expect(klub.slug).to eq('sarate-klub-grosuplje')
    end

    it 'should keep slug if not changed' do
      klub.name = 'Karate Klub Skocjan'
      klub.save
      klub.reload
      expect(klub.slug).to eq('karate-klub-skocjan')
    end

    it 'should allow two different klubs to have same slug' do
      # Differentiation is then in the IDs
      klub.save!
      another_klub = build(:klub, name: 'Karate klub Skocjan', email: 'owner@test.com', categories: ['football'])
      another_klub.save!
      expect(klub.reload.slug).to eq(another_klub.reload.slug)
    end
  end

  it 'may have branches' do
    branch1 = create(:complete_klub_branch, parent: klub)
    branch2 = create(:complete_klub_branch, parent: klub)

    expect(klub.branches).to match_array [branch1, branch2]
  end

  it 'may have a parent' do
    branch1 = create(:complete_klub_branch, parent: klub)

    expect(branch1.parent).to eq klub
  end

  describe 'branches' do
    it 'touches the parent when branch is edited' do
      expect do
        create(:klub_branch, parent: klub, categories: ['karate'])
      end.to change(klub, :updated_at).from(klub.updated_at)
    end
  end

  describe 'deleting a klub with updates' do
    let!(:update1) { create(:update, updatable: subject) }
    let!(:update2) { create(:update, updatable: subject) }

    it { expect(subject).to have_many(:updates).dependent(:destroy) }

    it 'should delete its updates when deleted' do
      expect { subject.destroy }.to change { Update.count }.by(-2)
    end
  end

  describe 'complete scope' do
    let!(:klub2) { create(:complete_klub) }

    it 'Klub.completed.all should return only completed models' do
      klub.save
      expect(Klub.completed.all).to eq([klub2])
      expect(Klub.completed.unscoped).to eq([klub2, klub])
    end
  end

  it 'should be complete if name, latitude and longitude are given and verified' do
    expect(klub.complete?).to be false
    klub.latitude = 12
    klub.longitude = 45
    klub.save
    expect(klub.complete?).to be false
    klub.verified = true
    klub.save
    expect(klub.complete?).to be true
  end

  it 'should update complete attribute when saving' do
    klub.latitude = 12
    klub.longitude = 45
    klub.verified = true
    klub.save

    expect(klub.complete?).to be true
  end

  it 'sends an email upon creation' do
    klub.save

    expect { subject.send(:send_review_notification) }.to change { enqueued_jobs.count }.by(1)
  end

  it 'sends a thank you email upon creation' do
    klub.save
    expect { subject.send(:send_thanks_notification, 'test@test.com') }.to change { enqueued_jobs.count }.by(1)
  end

  it 'sends an email upon updated' do
    klub.save
    expect { subject.send(:send_updates_notification, 'joe@doe.com') }.to change { enqueued_jobs.count }.by(1)
  end

  it 'send_confirm_notification' do
    klub.save
    expect { subject.send(:send_confirm_notification, 'test@email.com', [], []) }.to change {
      enqueued_jobs.count
    }.by 1
  end

  it 'send_updates_accepted_notification' do
    klub.save
    expect { subject.send_updates_accepted_notification('test@email.com', []) }.to change {
      ActionMailer::Base.deliveries.count
    }.by 1
  end

  it 'send_on_update_notifications' do
    klub.save

    expect(subject).to receive(:send_updates_notification).with('test@email.com')

    expect { subject.send_on_update_notifications('test@email.com', [], []) }.to change {
      enqueued_jobs.count
    }.by 1
  end

  it 'should be able to send a data verification email' do
    klub.save # klub must exist
    expect { subject.send_request_verify_klub_data_mail }.to change {
      ActionMailer::Base.deliveries.count
    }.by 1
  end

  it 'should send data verification email to correct addresee' do
    klub.save # klub must exist
    expect(KlubMailer).to receive(:request_verify_klub_mail).with(klub.id, 'owner@test.com').and_call_original
    subject.send_request_verify_klub_data_mail
  end

  it 'should not attempt to send data verification email to klubs without email' do
    klub.email = nil
    klub.save

    expect(KlubMailer).not_to receive(:request_verify_klub_mail)

    subject.send_request_verify_klub_data_mail
  end

  it 'remembers when it last sent a data verification email' do
    klub.save # klub must exist
    expect { subject.send_request_verify_klub_data_mail }.to change {
      klub.last_verification_reminder_at
    }
  end

  it 'creates a data_confirmation_request_hash before sending email' do
    klub.save # klub must exist
    expect(subject).to receive(:generate_data_confirmation_request_hash!).and_call_original
    subject.send_request_verify_klub_data_mail
  end

  describe 'geocoding' do
    Geocoder::Lookup::Test.add_stub(
      'Trzaska 25, 1000 Ljubljana', [
        {
          'latitude'          => 46.0448994,
          'longitude'         => 14.4892307,
          'address'           => 'Univerza v Ljubljani, Tržaška cesta 25, 1000 Ljubljana, Slovenija',
          'city'              => 'Ljubljana',
          'formatted_address' => 'Univerza v Ljubljani, Tržaška cesta 25, 1000 Ljubljana, Slovenija'
        }
      ]
    )

    context 'on create' do
      describe 'address provided' do
        let(:klub) { build(:klub, address: 'Trzaska 25, 1000 Ljubljana', categories: ['karate']) }

        it 'should compute latlong' do
          klub.save
          expect(klub.reload.latitude).not_to be_nil
          expect(klub.reload.longitude).not_to be_nil
          expect(klub.reload.town).not_to be_nil

          expect(klub.reload.latitude).to eq 46.044899
          expect(klub.reload.longitude).to eq 14.489231
          expect(klub.reload.town).to eq 'Ljubljana'
        end

        it 'should prettify the address' do
          klub.save
          expect(klub.reload.address).to eq 'Univerza v Ljubljani, Tržaška cesta 25, 1000 Ljubljana, Slovenija'
        end

        it 'should fillin the town' do
          klub.save
          expect(klub.reload.town).to eq 'Ljubljana'
        end

        it 'should not run if lat, long, address and town provided as well' do
          klub.latitude = 20
          klub.longitude = 35
          klub.town = 'Lj'
          klub.save

          expect(klub.reload.latitude).to eq 20
          expect(klub.reload.longitude).to eq 35
          expect(klub.reload.town).to eq 'Lj'
        end
      end

      describe 'address not provided' do
        let(:klub) { create(:klub, address: '', categories: ['karate']) }
        before do
          expect(Geocoder).not_to receive(:address)
        end
        it 'shoud not run if no address' do
          expect(klub.latitude).to be_nil
          expect(klub.longitude).to be_nil
          expect(klub.town).to be_nil
        end
      end
    end

    context 'on save' do
      let(:klub) { create(:klub, address: 'Trzaska 25, 1000 Ljubljana', categories: ['karate']) }
      it 'should not run' do
        expect(klub.latitude).to eq 46.044899
        expect(klub.longitude).to eq 14.489231

        klub.address = 'Vrazov trg 2, 1104 Ljubljana, Slovenija'
        klub.save

        expect(klub.latitude).to eq 46.044899
        expect(klub.longitude).to eq 14.489231
      end
    end
  end

  describe 'update_visits_count_if_outdated' do
    it 'updates visit count if nil' do
      subject.save!
      expect(subject).to receive(:update_visits_count!)

      subject.update_visits_count_if_outdated!
    end

    it 'updates the count if out of date' do
      subject.visits_count = 7
      subject.visits_count_updated_at = 1.month.ago
      subject.save!
      expect(subject).to receive(:update_visits_count!)

      subject.update_visits_count_if_outdated!
    end

    it 'returns current count if recent' do
      subject.visits_count = 7
      subject.visits_count_updated_at = 7.hours.ago
      subject.save!
      expect(subject).not_to receive(:update_visits_count!)

      subject.update_visits_count_if_outdated!
    end
  end

  describe 'update_visits_count' do
    it 'returns 0 for non persisted klubs' do
      expect(subject.persisted?).to be_falsy
      subject.update_visits_count!
      expect(subject.visits_count).to eq 0
    end

    it 'updates the count and date' do
      subject.save!
      expect_any_instance_of(GoogleAnalyticsFetcher).to receive(:total_visitors).and_return(5)

      subject.update_visits_count!

      expect(subject.reload.visits_count).to eq 5
      expect(subject.reload.visits_count_updated_at).to be > 5.minutes.ago
    end

    it "does nothing if can't reach GA" do
      time_ago = 45.minutes.ago
      subject.visits_count = 7
      subject.visits_count_updated_at = time_ago
      subject.save!
      expect_any_instance_of(GoogleAnalyticsFetcher).to receive(:total_visitors).and_return(nil)

      subject.update_visits_count!

      expect(subject.visits_count).to eq 7
      expect(subject.visits_count_updated_at).to eq time_ago
    end
  end
end
