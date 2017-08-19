require 'rails_helper'

RSpec.describe Api::V2::EmailStatsController, type: :controller do
  describe 'POST #weebhook' do

    describe "valid authenticity" do
      let(:valid_request_params) {
        {
          domain: 'mg.klubi.si',
          recipient: 'alice@example.com',
          event: 'delivered',
          timestamp: '1484415909',
          token: '9bac57f58b8d2f108c4d258aa244d5207d87e178a162f2d918',
          signature: '654919c15c9f26bb5ee3fe088f75bf58e8162df6eb4c35983a8c3f5641b6266f'
        }
      }

      before do
        expect(ENV).to receive(:[]).with("MAILGUN_API_KEY").and_return('key-9ff9ed2f6a3e8cb5acd18fa124773c7a')
        post :webhook, params: valid_request_params
      end

      it "should return 200" do
        expect(response.status).to eq 200
      end
    end

    describe "invalid authenticity" do
      let(:invalid_request_params) {
        {
          domain: 'mg.klubi.si',
          recipient: 'alice@example.com',
          event: 'delivered',
          timestamp: '1484415909',
          token: '9bac57f58b8d2f108c4d258aa244d5207d87e178a162f2d918',
          signature: '654919c15c9f26qq5ee3fe088f75bf58e8162df6eb4c35983a8c3f5641b6266f'
        }
      }

      before do
        expect(ENV).to receive(:[]).with("MAILGUN_API_KEY").and_return('key-9ff9ed2f6a3e8cb5acd18fa124773c7a')
        post :webhook, params: invalid_request_params
      end

      it "should return 406" do
        expect(response.status).to eq 406
      end
    end

    describe "email delivered" do
      let(:delivery_params) {
        {
          recipient: 'alice@example.com',
          event: 'delivered',
          timestamp: '1484415909',
          token: '9bac57f58b8d2f108c4d258aa244d5207d87e178a162f2d918',
          signature: '654919c15c9f26bb5ee3fe088f75bf58e8162df6eb4c35983a8c3f5641b6266f'
        }
      }

      before do
        allow(subject).to receive(:verify_authenticity).and_return(true)
        expect(ENV).to receive(:[]).with("MAILGUN_API_KEY").and_return('key-9ff9ed2f6a3e8cb5acd18fa124773c7a')
      end

      it "should return 200" do
        post :webhook, params: delivery_params
        expect(response.status).to eq 200
      end

      it "should add an entry to the db" do
        expect { post :webhook, params: delivery_params }.to change(EmailStat, :count).by(1)
      end

      it "should set the delivered timestamp in the db" do
        post :webhook, params: delivery_params
        expect(EmailStat.find_by(email: 'alice@example.com').last_delivered_at).to eq DateTime.new(2017,1,14,17,45,9)
      end

      describe "subsequent delivery" do
        let(:subsequent_delivery_params) {
          {
            recipient: 'alice@example.com',
            event: 'delivered',
            timestamp: '1484420098',
            token: 'deedefe3f5a3c9a4411fbd0bc1933ecd99a0ca142702e37797',
            signature: '923025b7a8116de59576936795c1ba3dfaa81f42f152a3fc3d5be8e14361960a'
          }
        }

        before do
          expect(ENV).to receive(:[]).with("MAILGUN_API_KEY").and_return('key-9ff9ed2f6a3e8cb5acd18fa124773c7a')
          post :webhook, params: delivery_params
        end

        it "should not create a new record" do
          expect { post :webhook, params: subsequent_delivery_params }.not_to change(EmailStat, :count)
        end

        it "should update the last_delivered_at" do
          post :webhook, params: subsequent_delivery_params
          expect(EmailStat.find_by(email: 'alice@example.com').last_delivered_at).to eq DateTime.new(2017,1,14,18,54,58)
        end
      end
    end

    describe "email opened" do
      let(:opened_params) {
        {
          recipient: 'alice@example.com',
          event: 'opened',
          timestamp: '1484415909',
          token: '9bac57f58b8d2f108c4d258aa244d5207d87e178a162f2d918',
          signature: '654919c15c9f26bb5ee3fe088f75bf58e8162df6eb4c35983a8c3f5641b6266f'
        }
      }

      before do
        allow(subject).to receive(:verify_authenticity).and_return(true)
        expect(ENV).to receive(:[]).with("MAILGUN_API_KEY").and_return('key-9ff9ed2f6a3e8cb5acd18fa124773c7a')
      end

      it "should return 200" do
        post :webhook, params: opened_params
        expect(response.status).to eq 200
      end

      it "should add an entry to the db" do
        expect { post :webhook, params: opened_params }.to change(EmailStat, :count).by(1)
      end

      it "should set the delivered timestamp in the db" do
        post :webhook, params: opened_params
        expect(EmailStat.find_by(email: 'alice@example.com').last_opened_at).to eq DateTime.new(2017,1,14,17,45,9)
      end
    end

    describe "email clicked" do
      let(:clicked_params) {
        {
          recipient: 'alice@example.com',
          event: 'clicked',
          timestamp: '1484415909',
          token: '9bac57f58b8d2f108c4d258aa244d5207d87e178a162f2d918',
          signature: '654919c15c9f26bb5ee3fe088f75bf58e8162df6eb4c35983a8c3f5641b6266f'
        }
      }

      before do
        allow(subject).to receive(:verify_authenticity).and_return(true)
        expect(ENV).to receive(:[]).with("MAILGUN_API_KEY").and_return('key-9ff9ed2f6a3e8cb5acd18fa124773c7a')
      end

      it "should return 200" do
        post :webhook, params: clicked_params
        expect(response.status).to eq 200
      end

      it "should add an entry to the db" do
        expect { post :webhook, params: clicked_params }.to change(EmailStat, :count).by(1)
      end

      it "should set the delivered timestamp in the db" do
        post :webhook, params: clicked_params
        expect(EmailStat.find_by(email: 'alice@example.com').last_clicked_at).to eq DateTime.new(2017,1,14,17,45,9)
      end
    end

    describe "email bounced" do
      let(:bounced_params) {
        {
          recipient: 'alice@example.com',
          event: 'bounced',
          timestamp: '1484415909',
          token: '9bac57f58b8d2f108c4d258aa244d5207d87e178a162f2d918',
          signature: '654919c15c9f26bb5ee3fe088f75bf58e8162df6eb4c35983a8c3f5641b6266f'
        }
      }

      before do
        allow(subject).to receive(:verify_authenticity).and_return(true)
        expect(ENV).to receive(:[]).with("MAILGUN_API_KEY").and_return('key-9ff9ed2f6a3e8cb5acd18fa124773c7a')
      end

      it "should return 200" do
        post :webhook, params: bounced_params
        expect(response.status).to eq 200
      end

      it "should add an entry to the db" do
        expect { post :webhook, params: bounced_params }.to change(EmailStat, :count).by(1)
      end

      it "should set the delivered timestamp in the db" do
        post :webhook, params: bounced_params
        expect(EmailStat.find_by(email: 'alice@example.com').last_bounced_at).to eq DateTime.new(2017,1,14,17,45,9)
      end
    end

    describe "email dropped" do
      let(:dropped_params) {
        {
          recipient: 'alice@example.com',
          event: 'dropped',
          timestamp: '1484415909',
          token: '9bac57f58b8d2f108c4d258aa244d5207d87e178a162f2d918',
          signature: '654919c15c9f26bb5ee3fe088f75bf58e8162df6eb4c35983a8c3f5641b6266f'
        }
      }

      before do
        allow(subject).to receive(:verify_authenticity).and_return(true)
        expect(ENV).to receive(:[]).with("MAILGUN_API_KEY").and_return('key-9ff9ed2f6a3e8cb5acd18fa124773c7a')
      end

      it "should return 200" do
        post :webhook, params: dropped_params
        expect(response.status).to eq 200
      end

      it "should add an entry to the db" do
        expect { post :webhook, params: dropped_params }.to change(EmailStat, :count).by(1)
      end

      it "should set the delivered timestamp in the db" do
        post :webhook, params: dropped_params
        expect(EmailStat.find_by(email: 'alice@example.com').last_dropped_at).to eq DateTime.new(2017,1,14,17,45,9)
      end
    end

   describe "invalid event type" do
     let(:invalid_params) {
       {
         recipient: 'alice@example.com',
         event: 'not-valid-event',
         timestamp: '1484415909',
         token: '9bac57f58b8d2f108c4d258aa244d5207d87e178a162f2d918',
         signature: '654919c15c9f26bb5ee3fe088f75bf58e8162df6eb4c35983a8c3f5641b6266f'
       }
     }

     before do
       allow(subject).to receive(:verify_authenticity).and_return(true)
       expect(ENV).to receive(:[]).with("MAILGUN_API_KEY").and_return('key-9ff9ed2f6a3e8cb5acd18fa124773c7a')
     end

     it "should return 406" do
      # Mailgun does not retry on 406.
      post :webhook, params: invalid_params
      expect(response.status).to eq 406
     end

     it "does not save the field in the db" do
      expect {post :webhook, params: invalid_params }.not_to change(EmailStat, :count)
     end

     it "should silently handle the error" do
       expect { post :webhook, params: invalid_params }.not_to raise_error
     end
   end

  end

end
