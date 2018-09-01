require 'rails_helper'

require 'json'

RSpec.describe Api::V2::KlubsController, type: :controller do
  include ActiveSupport::Testing::TimeHelpers

  describe 'GET #klubs' do
    let!(:klub1) { FactoryBot.create(:klub, verified: true, latitude: 20.1, longitude: 10.1, categories: ['fitnes', 'gimnastika']) }
    let!(:klub2) { FactoryBot.create(:klub, verified: true, latitude: 20.1, longitude: 10.1, categories: ['fitnes']) }
    let!(:closed_klub) { FactoryBot.create(:klub, verified: true, latitude: 20.1, longitude: 10.1, categories: ['fitnes'], closed_at: Date.yesterday ) }
    let!(:klub_branch) { FactoryBot.create(:klub_branch, verified: true, latitude: 20.1, longitude: 10.1, parent: klub1, categories: ['gimnastika']) }

    before do
      get :index, params: { category: 'fitnes' }
    end

    subject { response }

    it { should be_successful }

    it "should return all open klubs" do
      klubs = json_response[:data]
      expect(klubs.length).to eq 2
    end

    it "should not return closed klubs" do
      klub_ids = json_response[:data].map{ |klub| klub[:id] }
      expect(klub_ids).not_to include closed_klub.url_slug
    end

    it "should return a list of klubs" do
      expect(response.status).to eq 200
      expect(response).to match_response_schema("v2/klubs")
    end

    describe "very incomplete data" do
      before do
        klub1.latitude = nil;
        klub1.longitude = nil;
        klub1.save

        get :index, params: { category: 'fitnes' }
      end

      it "does not return klubs that are incomplete" do
        # incomplete: no lat, long and name
        klubs = JSON.parse(response.body)['data']
        expect(klubs.length).to eq 1
      end
    end

    describe '?category' do

      context "=fitnes" do

        before do
          get :index, params: { category: 'fitnes' }
        end

        it "should return only fitnes klubs" do
          expect(response.status).to eq 200
          klubs = json_response[:data]
          expect(response).to match_response_schema("v2/klubs")
          expect(klubs.length).to eq 2
          expect(klubs.map{|h| h[:id]}).to match_array([klub1, klub2].map(&:url_slug))
        end
      end

      context "=gimnastika" do
        before do
          get :index, params: { category: 'gimnastika' }
        end

        it "should return only gimnastika klubs" do
          expect(response.status).to eq 200
          klubs = json_response
          expect(response).to match_response_schema("v2/klubs")
          expect(klubs[:data].length).to eq 2
          expect(klubs[:data].map{|h| h[:id]}).to match_array([klub1, klub_branch].map(&:url_slug))
        end

        it "should return correct type for parent relationship" do
          klubs = json_response
          first_klub = klubs[:data].first
          expect(first_klub[:relationships][:parent][:data][:type]).to eq "klubs"
        end
      end

      context "Missing category filter" do
        it "should raise an exception" do
          expect{
            get :index, params: { category: nil }
          }.to raise_error(ActionController::ParameterMissing)
        end
      end

      context "unsupporte cattegory" do
        before do
          expect(klub2.categories).to include 'fitnes' # expect at least one match
          allow(ENV).to receive(:[]).and_call_original
          expect(ENV).to receive(:[]).with("SUPPORTED_CATEGORIES").and_return('whatever,notit')
          get :index, params: { category: 'fitnes' }
        end

        it "should return 200" do
          expect(response).to be_successful
        end

        it "should return an empty result set" do
          klubs = json_response
          expect(response).to match_response_schema("v2/klubs")
          expect(klubs[:data].length).to eq 0
        end
      end
    end
  end

  describe 'GET #klubs/:id' do
    let!(:klub1) { FactoryBot.create(:klub, verified: true, latitude: 20.1, longitude: 10.1, categories: ['fitnes', 'gimnastika']) }
    let!(:klub_branch) { FactoryBot.create(:klub_branch, verified: true, latitude: 20.1, longitude: 10.1, parent: klub1, categories: ['gimnastika']) }
    let!(:closed_klub) { FactoryBot.create(:klub, verified: true, latitude: 20.1, longitude: 10.1, categories: ['fitnes'], closed_at: Date.yesterday ) }
    let!(:comment) { FactoryBot.create(:comment, commentable: klub1) }

    before do
      get :show, params: { id: klub1.url_slug }
    end

    subject { response }

    it { should be_successful }

    it "should return only klub1" do
      expect(json_response[:data].class).to eq Hash
      expect(json_response[:data][:id]).to eq klub1.url_slug
    end

    it "should return the matched klub" do
      expect(response.status).to eq 200
      expect(response).to match_response_schema("v2/klub")
    end

    it "should return the parent's slug" do
      get :show, params: { id: klub_branch.url_slug }
      expect(response).to match_response_schema('v2/klub')
      klub = json_response[:data]
      expect(klub[:relationships][:parent][:data][:id]).to eq klub1.url_slug
    end

    it "should return correct type for parent relationship" do
      get :show, params: { id: klub_branch.url_slug }
      klubs = json_response
      branch_klub = klubs[:data]
      expect(branch_klub[:relationships][:parent][:data][:type]).to eq "klubs"
    end

    it "should return correct type for branches relationship" do
      klubs = json_response
      parent_klub = klubs[:data]
      expect(parent_klub[:relationships][:branches][:data][0][:type]).to eq "klubs"
    end

    it "should include the parent" do
      get :show, params: { id: klub_branch.url_slug }
      expect(response).to match_response_schema('v2/klub')
      parent = json_response[:included].select { |inc| inc[:type] === 'klubs' }
      expect(parent.length).to eq 1
      parent = parent[0]
      expect(parent[:id]).to eq klub1.url_slug
    end

    it "should return the branches's slug" do
      get :show, params: { id: klub1.url_slug }
      expect(response).to match_response_schema('v2/klub')
      klub = json_response[:data]
      expect(klub[:relationships][:branches][:data].count).to eq 1
      expect(klub[:relationships][:branches][:data][0][:id]).to eq klub_branch.url_slug
    end

    it "should include the branches" do
      get :show, params: { id: klub1.url_slug }
      expect(response).to match_response_schema('v2/klub')
      branches = json_response[:included].select { |inc| inc[:type] === 'klubs' }
      expect(branches.length).to eq 1
      branch = branches[0]
      expect(branch[:id]).to eq klub_branch.url_slug
    end

    it "should include all branches for unverified klubs" do
      klub1.verified = false
      klub_branch.verified = false
      klub1.save
      klub_branch.save

      get :show, params: { id: klub1.url_slug }
      expect(response).to match_response_schema('v2/klub')
      branches = json_response[:data][:relationships][:branches][:data]
      expect(branches.length).to eq 1
      branch = branches[0]
      expect(branch[:id]).to eq klub_branch.url_slug
    end

    it "should not include unverified branches for verified klubs" do
      expect(klub1.verified).to eq true
      klub_branch.verified = false
      klub_branch.save

      get :show, params: { id: klub1.url_slug }
      expect(response).to match_response_schema('v2/klub')

      branches = json_response[:data][:relationships][:branches][:data]
      expect(branches.length).to eq 0
    end

    it "includes a link to images" do
      get :show, params: { id: klub1.url_slug }
      expect(response).to match_response_schema('v2/klub')

      images = json_response[:data][:relationships][:images][:links][:related]
      expect(images).to eq(images_klub_url(klub1.url_slug))
    end

    it "includes a comments" do
      get :show, params: { id: klub1.url_slug }
      expect(response).to match_response_schema('v2/klub')
      comments = json_response[:data][:relationships][:comments]
      expect(comments[:data].length).to eq 1

      comment_content = json_response[:included].select { |inc| inc[:id] == comment.id && inc[:type] == 'comments' }
      expect(comment_content).not_to be_nil
    end

    it "should return closed klubs together with closed_at" do
      get :show, params: { id: closed_klub.url_slug }
      expect(response).to match_response_schema('v2/klub')
      klub = json_response[:data]
      expect(klub[:attributes][:'closed-at']).to eq Date.yesterday.to_s
    end

    context "unsupported cattegory" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("SUPPORTED_CATEGORIES").and_return('whatever,notit')
        get :show, params: { id: klub1.url_slug }
      end

      it "should return 200" do
        expect(response).to be_successful
      end

      it "should return return the klub" do
        klubs = json_response
        expect(response).to match_response_schema("v2/klub")
        klub = json_response[:data]
        expect(klub[:id]).to eq klub1.url_slug
      end
    end
  end

  describe "GET #klubs/:id/images" do
    let!(:klub) { FactoryBot.create(:complete_klub) }

    context "when no valid facebook url" do
      before do
        klub.facebook_url = 'https://google.com'
        klub.save
        get :images, params: { id: klub.url_slug }
      end

      subject { response }

      it { should be_successful }

      it "should conform to the schema" do
        expect(response).to match_response_schema("v2/images")
      end

      it "should return an empty array" do
        expect(json_response[:data].length).to eq 0
      end
    end

    context "when no facebook url" do
      before do
        klub.facebook_url = nil
        klub.save
        get :images, params: { id: klub.url_slug }
      end

      subject { response }

      it { should be_successful }

      it "should conform to the schema" do
        expect(response).to match_response_schema("v2/images")
      end

      it "should return an empty array" do
        expect(json_response[:data].length).to eq 0
      end
    end

    context "when valid facebook url" do
      before do
        allow(Koala::Facebook::OAuth).to receive(:new).and_return(double(get_app_access_token: 'fake_token'))
        allow_any_instance_of(Koala::Facebook::API).to receive(:get_object).and_return([{ 'images' =>
          [{ 'height' => 710,
             'source' =>
             'https://scontent.xx.fbcdn.net/v/t31.0-8/10443276_348531425325870_4781202915849569619_o.jpg?oh=f2df7dd6fc54f416dbea0594b7f14481&oe=5A48F262',
             'width' => 1220 },
           { 'height' => 600,
             'source' =>
             'https://scontent.xx.fbcdn.net/v/t31.0-0/q87/p600x600/10443276_348531425325870_4781202915849569619_o.jpg?oh=10f2e8172f5153642b1e63d357462e43&oe=5A160301',
             'width' => 1030 },
           { 'height' => 480,
             'source' =>
             'https://scontent.xx.fbcdn.net/v/t31.0-0/q87/p480x480/10443276_348531425325870_4781202915849569619_o.jpg?oh=9f97568a6640f1bb9b116053d0a3e432&oe=5A43EEE1',
             'width' => 824 },
           { 'height' => 320,
             'source' =>
             'https://scontent.xx.fbcdn.net/v/t1.0-0/q85/p320x320/10470190_348531425325870_4781202915849569619_n.jpg?oh=a070e9dfe920fede9642c8a15d6dba5c&oe=5A469DC6',
             'width' => 550 },
           { 'height' => 540,
             'source' =>
             'https://scontent.xx.fbcdn.net/v/t31.0-0/q85/p180x540/10443276_348531425325870_4781202915849569619_o.jpg?oh=82e159fd8bb7f2bcd2a20eae30063ddd&oe=5A590C78',
             'width' => 927 },
           { 'height' => 130,
             'source' =>
             'https://scontent.xx.fbcdn.net/v/t1.0-0/q85/p130x130/10470190_348531425325870_4781202915849569619_n.jpg?oh=a239299e45bcd5c0de67db9a442b7b26&oe=5A5BAFA9',
             'width' => 223 },
           { 'height' => 225,
             'source' =>
             'https://scontent.xx.fbcdn.net/v/t1.0-0/q85/p75x225/10470190_348531425325870_4781202915849569619_n.jpg?oh=27a7ab68cad79c3b7c118051418a0fb5&oe=5A408153',
             'width' => 387 }],
          'id' => '348531425325870' }])

        klub.facebook_url = "https://www.facebook.com/klubi.slovenije/"
        klub.save
        get :images, params: { id: klub.url_slug }
      end

      subject { response }

      it { should be_successful }

      it "should conform to the schema" do
        expect(response).to match_response_schema("v2/images")
      end

      it "should include an array of images" do
        expect(json_response[:data].length).to be >= 1
      end
    end

    context "when invalid facebook page id" do
      before do
        allow(Koala::Facebook::OAuth).to receive(:new).and_return(double(get_app_access_token: 'fake_token'))
        allow_any_instance_of(Koala::Facebook::API).to receive(:get_object).and_raise('error')

        klub.facebook_url = "https://www.facebook.com/klubi.slovenije.does.not.exist/"
        klub.save
      end

      it "should return empty array when no results" do
        expect { get :images, params: { id: klub.url_slug } }.not_to raise_error
      end
    end
  end

  describe 'POST #klubs' do

    it "should send an email to admin" do
      expect_any_instance_of(Klub).to receive(:send_review_notification)

      post :create, params: {
        data: {
          type: 'klubs',
          attributes: {
            name: "Fitnes Maribor",
            editor: 'joe@doe.com',
            categories: ['football']
          }
        }
      }
    end

    it "should send an email to the submitter" do
      expect_any_instance_of(Klub).to receive(:send_thanks_notification)

      post :create, params: {
        data: {
          type: 'klubs',
          attributes: {
            name: "Qien eres?",
            editor: 'joe@doe.com',
            categories: ['football']
          }
        }
      }
    end

    it "should not allow missing submitter email" do
      expect {
        post :create, params: {
          data: {
            type: 'klubs',
            attributes: {
              name: 'Quien eres?',
              categories: ['football']
            }
          }
        }
      }.not_to change(Klub.unscoped, :count)

      expect(response.status).to eq 422
    end

    it "should not allow blank submitter email" do
      expect {
        post :create, params: {
          data: {
            type: 'klubs',
            attributes: {
              editor: '',
              name: 'Quien eres?',
              categories: ['football']
            }
          }
        }
      }.not_to change(Klub.unscoped, :count)

      expect(response.status).to eq 422
    end

    it "should not send thanks email if no submitter" do
      expect_any_instance_of(Klub).not_to receive(:send_thanks_notification)

      post :create, params: {
        data: {
          type: 'klubs',
          attributes: {
            name: 'Quien eres?',
            categories: ['football']
          }
        }
      }
    end

    it "should accept categories and other parameters" do

      valid_attrs = {name: "Fitnes Maribor", address: "Mariborska cesta 5", latitude: "46.5534849", longitude: "15.503709399999934", website: "http://www.fitnes-zumba.si",categories: ["fitnes","zumba"], editor: "jaz@ti.com", notes: "Ta klub ne obstaja", description: "This is the klub description"}

      expect(Klub).to receive(:new).
        with(valid_attrs.except(:editor))
        .and_return Klub.new(valid_attrs.except(:editor))

      post :create, params: {
        data: {
          type: 'klubs',
          attributes: valid_attrs
        }
      }
    end

    it "should downcase and dasherize new categories" do
      valid_attrs = {name: "Fitnes Maribor", address: "Mariborska cesta 5", latitude: "46.5534849", longitude: "15.503709399999934", website: "http://www.fitnes-zumba.si",categories: ["Fitnes","zu M  ba"], editor: "jaz@ti.com", notes: "Ta klub ne obstaja", description: "Thisis desc"}

      post :create, params: {
        data: {
          type: 'klubs',
          attributes: valid_attrs
        }
      }

      expect(Klub.last.categories).to match(['fitnes', 'zu-m-ba'])
    end

    it "should create a new unverified klub" do
      expect {
        post :create, params: {
          data: {
            type: 'klubs',
            attributes: {
              name: 'Fitnes Mariborcan 22',
              categories: ['football'],
              editor: 'joe@doe.com'
            }
          }
        }
      }.to change(Klub.unscoped, :count).by 1

      klub = Klub.unscoped.last
      expect(klub.verified?).to be_falsy
    end

    it "should set the klub verification date if submitter = owner" do
      post :create, params: {
        data: {
          type: 'klubs',
          attributes: {
            name: 'Fitnes Mariborcan 22',
            email: 'joe@doe.com',
            categories: ['football'],
            editor: 'joe@doe.com'
          }
        }
      }

      klub = Klub.unscoped.last
      expect(klub.last_verification_reminder_at).not_to be_nil
    end

    it "should not set the klub verification date if submitter = owner" do
      post :create, params: {
        data: {
          type: 'klubs',
          attributes: {
            name: 'Fitnes Mariborcan 22',
            email: 'ben@doe.com',
            categories: ['football'],
            editor: 'joe@doe.com'
          }
        }
      }

      klub = Klub.unscoped.last
      expect(klub.last_verification_reminder_at).to be_nil
    end

    it "should return 202 Accepted" do
      post :create, params: {
        data: {
          type: 'klubs',
          attributes: {
            name: 'Fitnes',
            editor: 'joe@doe.com',
            categories: ['football']
          }
        }
      }

      expect(response.status).to eq 202
    end

    it 'should not create klubs without category' do
      expect {
        post :create, params: {
          data: {
            type: 'klubs',
            attributes: {
              editor: 'joe@doe.com',
              name: 'Fitnes',
              categories: nil
            }
          }
        }
      }.not_to change(Klub.unscoped, :count)

      expect(response.status).to eq 422
    end

    it "should respond with created klub" do
      post :create, params: {
        data: {
          type: 'klubs',
          attributes: {
            editor: 'joe@doe.com',
            name: 'Fitnes',
            categories: ['football']
          }
        }
      }

      expect(json_response[:data][:id]).to be_truthy
      expect(json_response[:data][:attributes][:categories]).to match(['football'])
      expect(response).to match_response_schema('v2/klub')
    end

    context "a klub with branches" do

      it "should require latitude, longitude, address and town on branches" do
        expect {
          post :create, params: {
            data: {
              type: 'klub',
              attributes: {
                editor: 'joe@doe.com',
                name: 'Fitnes Mariborcan 22',
                address: 'Address 1',
                categories: ['football']
              },
              relationships: {
                branches: {
                  data: [{
                    type: 'klub',
                    attributes: {
                      name: 'Fitnes Mariborcan 22',
                      address: 'Address 2',
                      categories: ['football']
                    }
                  }]
                }
              }
            }
          }
        }.not_to change(Klub.unscoped, :count)

        expect(response.status).to eq 422
      end

      it "should create parent and the branch" do
        expect {
          post :create, params: {
            data: {
              type: 'klub',
              attributes: {
                name: 'Fitnes Mariborcan 22',
                editor: 'joe@doe.com',
                address: 'Address 1',
                categories: ['football']
              },
              relationships: {
                branches: {
                  data: [{
                    type: 'klub',
                    attributes: {
                      name: 'Fitnes Mariborcan 22',
                      address: 'Address 2',
                      town: 'None',
                      latitude: 123,
                      longitude: 231
                    }
                  }]
                }
              }
            }
          }
        }.to change(Klub.unscoped, :count).by(2)

        expect(response.status).to eq 202
      end
      it "should mark both parent and branches as unverified" do
        post :create, params: {
          data: {
            type: 'klub',
            attributes: {
              editor: 'joe@doe.com',
              name: 'Fitnes Mariborcan 22',
              address: 'Cesta XV. brigade 2, Metlika',
              categories: ['mycategor987y']
            },
            relationships: {
              branches: {
                data: [{
                  type: 'klub',
                  attributes: {
                    name: 'Fitnes Mariborcan 22',
                    address: 'Videm pri Ptuju 49, 2284 Videm pri Ptuju, Slovenija',
                    town: 'None',
                    latitude: 123,
                    longitude: 231
                  }
                }]
              }
            }
          }
        }
        klub = Klub.unscoped.where("'mycategor987y' = ANY(categories)").first

        expect(klub.verified).to eq false
        expect(klub.branches.count).to eq 1
        expect(klub.branches.first.verified).to eq false
      end

      it "should send an email for the parent to admin" do
        expect_any_instance_of(Klub).to receive(:send_review_notification)

        post :create, params: {
          data: {
            type: 'klub',
            attributes: {
              editor: 'joe@doe.com',
              name: 'Fitnes Mariborcan 22',
              address: 'Address 1',
              categories: ['football']
            },
            relationships: {
              branches: {
                data: [{
                  type: 'klub',
                  attributes: {
                    name: 'Fitnes Mariborcan 22',
                    address: 'Address 2',
                    town: 'Hehe',
                    latitude: 123,
                    longitude: 231
                  }
                }]
              }
            }
          }
        }
      end

      it "should send an email for the parent to editor" do
        expect_any_instance_of(Klub).to receive(:send_thanks_notification)

        post :create, params: {
          data: {
            type: 'klub',
            attributes: {
              name: 'Fitnes Mariborcan 22',
              address: 'Address 1',
              editor: 'bla@bla',
              categories: ['football']
            },
            relationships: {
              branches: {
                data: [{
                  type: 'klub',
                  attributes: {
                    name: 'Fitnes Mariborcan 22',
                    address: 'Address 2',
                    town: 'Town',
                    latitude: 123,
                    longitude: 231
                  }
                }]
              }
            }
          }
        }
      end

      it "should respond with created klub and the branches" do
        post :create, params: {
          data: {
            type: 'klub',
            attributes: {
              name: 'Fitnes Mariborcan 22',
              address: 'Address 1',
              editor: 'bla@bla',
              categories: ['football']
            },
            relationships: {
              branches: {
                data: [{
                  type: 'klub',
                  attributes: {
                    name: 'Fitnes Mariborcan 22',
                    address: 'Address 2',
                    town: 'Metlika',
                    latitude: 45.647485,
                    longitude: 15.3155356
                  }
                }]
              }
            }
          }
        }

        expect(json_response[:data][:id]).to be_truthy
        expect(json_response[:data][:attributes][:categories]).to match(['football'])
        expect(json_response[:data][:relationships][:branches][:data][0][:id]).to be_truthy
        expect(json_response[:included][0][:attributes][:address]).to eq 'Address 2'
        expect(json_response[:included][0][:attributes][:latitude]).to eq "45.647485"
        expect(json_response[:included][0][:attributes][:longitude]).to eq "15.315536"
        expect(response).to match_response_schema('v2/klub')
      end
    end
  end

  describe 'PATCH #klubs/:id' do

    let(:old_attrs) do
      {
        name: 'Old club',
        address: 'Univerza v Ljubljani, Tržaška cesta 25, 1000 Ljubljana, Slovenija',
        website: 'http://oldclub.com',
        phone: '040 040 040',
        email: 'old@club.com',
        categories: ['fitnes'],
        facebook_url: 'http://facebook.com/oldclub',
        editor_emails: []
      }
    end
    let(:new_attrs) do
      {
        name: 'New club',
        address: 'Trzaska 26, Ljubljana',
        website: 'http://newclub.com',
        phone: '404 404 404',
        email: 'new@club.com',
        categories: ['fitnes', 'rugby'],
        description: 'My new description',
        notes: "Kera stvar",
        'facebook-url': 'http://facebook.com/newclub'
      }
    end
    let!(:klub) { FactoryBot.create(:klub, old_attrs.merge(verified: true)) }

    it "should be accepted" do
      patch :update, params: {
        id: klub.url_slug,
        data: {
          type: 'klubs',
          attributes: new_attrs.merge(editor: 'joe@doe.com')
        }
      }
      expect(response.status).to eq 202  # Accepted -- no need to reply with changes
    end

    it "should create Update objects for each changed attributes" do
      expect {
        patch :update, params: {
          id: klub.url_slug,
          data: {
            type: 'klubs',
            attributes: new_attrs.merge(editor: 'joe@doe.com')
          }
        }
      }.to change(Update, :count).by(9)

      new_attrs.except(:notes).each do |key, val|
        expect(
          Update.find_by(
            updatable: klub,
            field: key.to_s.underscore,
            oldvalue: old_attrs[key.to_s.underscore.to_sym].to_s,
            newvalue: val.to_s,
            status: :unverified,
            editor_email: 'joe@doe.com'
        )).to be_truthy
      end

      expect(
        Update.find_by(
          updatable: klub,
          field: 'notes',
          oldvalue: "",
          newvalue: "#{Date.today}: Kera stvar",
          status: :unverified,
          editor_email: 'joe@doe.com'
      )).to be_truthy
    end

    it "should not create Update objects for unchanged attributes" do
      new_attrs = old_attrs.merge(name: 'Some club')

      expect {
        patch :update, params: {
          id: klub.url_slug,
          data: {
            type: 'klubs',
            attributes: new_attrs.merge(editor: 'joe@doe.com')
          }
        }
      }.to change(Update, :count).by(1)
    end

    it "should not change the Klub model" do
      patch :update, params: {
        id: klub.url_slug,
        data: {
          type: 'klubs',
          attributes: new_attrs.merge(editor: 'joe@doe.com')
        }
      }

      expect(klub.reload).to have_attributes(old_attrs)
    end

    it "should downcase and dasherize categories" do
      patch :update, params: {
        id: klub.url_slug,
        data: {
          type: 'klubs',
          attributes: {
            categories: ['Zumba', ' JoG   a']
          }.merge(editor: 'joe@doe.com')
        }
      }

      expect(Update.find_by(updatable: klub, field: 'categories', newvalue: "[\"zumba\", \"jog-a\"]")).to be_present
    end

    it "should send an email notification to admin" do
      expect_any_instance_of(Klub).to receive(:send_updates_notification)

      patch :update, params: {
        id: klub.url_slug,
        data: {
          type: 'klubs',
          attributes: new_attrs.merge(editor: 'joe@doe.com')
        }
      }
    end

    it "should not allow missing editor email" do
      expect {
        patch :update, params: {
          id: klub.url_slug,
          data: {
            type: 'klubs',
            attributes: new_attrs.merge(editor: nil)
          }
        }
      }.not_to change(Update, :count)

      expect(response.status).to eq 422
    end

    it "should not allow blank editor" do
      expect {
        patch :update, params: {
          id: klub.url_slug,
          data: {
            type: 'klubs',
            attributes: new_attrs.merge(editor: "")
          }
        }
      }.not_to change(Update, :count)

      expect(response.status).to eq 422
    end

    it "should send an email to the editor" do
      expect_any_instance_of(Klub).to receive(:send_confirm_notification).with('joe@doe.com', instance_of(Array), instance_of(Array))

      patch :update, params: {
        id: klub.url_slug,
        data: {
          type: 'klubs',
          attributes: new_attrs.merge(editor: 'joe@doe.com')
        }
      }
    end

    it "should not send confirm email if no editor" do
      expect_any_instance_of(Klub).not_to receive(:send_confirm_notification)

      patch :update, params: {
        id: klub.url_slug,
        data: {
          type: 'klubs',
          attributes: new_attrs.merge(editor: nil)
        }
      }
    end

    context "a klub with branches [expectations]" do

      let!(:klub_branch) { FactoryBot.create(:klub, old_attrs.merge(verified: true, parent: klub)) }
      let!(:second_branch) { FactoryBot.create(:klub, old_attrs.merge(verified: true, parent: klub)) }

      def send_request
        patch :update, params: {
          id: klub.url_slug,
          data: {
            type: 'klub',
            id: klub.url_slug,
            attributes: new_attrs.merge(editor: 'joe@doe.com'),
            relationships: {
              branches: {
                data: [{
                  type: 'klubs',
                  id: klub_branch.url_slug,
                  attributes: {
                    address: 'Cesta XV. brigade 2, Metlika',
                    latitude: 45.6474851,
                    longitude:  15.3155356,
                    town: 'Logatec'
                  }
                }, {
                  type: 'klubs',
                  attributes: {
                    address: 'Videm pri Ptuju 49, 2284 Videm pri Ptuju, Slovenija',
                    latitude: 46.369447,
                    longitude:  15.902942,
                    town: 'Logatec'
                  }
                }]
              }
            }
          }
        }
      end

      it "should persist new branches" do
        expect { send_request() }.to change(Klub, :count).by(1)
      end


      it "should send an email notification for the parent only to admin" do
        expect_any_instance_of(Klub).to receive(:send_updates_notification).once
        send_request()
      end

      it "should send an email for the parent only  to the editor" do
        expect_any_instance_of(Klub).to receive(:send_confirm_notification).once.with(anything, anything, anything)
        send_request()
      end
    end

    context "a klub with branches" do

      let!(:klub_branch) { FactoryBot.create(:klub, old_attrs.merge(verified: true, parent: klub)) }
      let!(:second_branch) { FactoryBot.create(:klub, old_attrs.merge(verified: true, parent: klub)) }

      before do

        allow_any_instance_of(Klub).to receive(:send_updates_notification)
        allow_any_instance_of(Klub).to receive(:send_confirm_notification)

        travel_to Time.new(2024, 11, 24, 01, 04, 44) do

          patch :update, params: {
            id: klub.url_slug,
            data: {
              type: 'klub',
              id: klub.url_slug,
              attributes: new_attrs.merge(editor: 'joe@doe.com'),
              relationships: {
                branches: {
                  data: [{
                    type: 'klubs',
                    id: klub_branch.url_slug,
                    attributes: {
                      address: 'Cesta XV. brigade 2, Metlika',
                      latitude: 45.6474851,
                      longitude:  15.3155356,
                      town: 'Logatec'
                    }
                  }, {
                    type: 'klubs',
                    attributes: {
                      address: 'Videm pri Ptuju 49, 2284 Videm pri Ptuju, Slovenija',
                      latitude: 46.369447,
                      longitude:  15.902942,
                      town: 'Ptuj'
                    }
                  }]
                }
              }
            }
          }
        end
      end

      it "should be accepted" do
        expect(response.status).to eq 202  # Accepted -- no need to reply with changes
      end

      it "should create update objects for each changed attributes of the branch" do
        address_update = Update.find_by(
          updatable: klub_branch,
          field: 'address',
          oldvalue: 'Univerza v Ljubljani, Tržaška cesta 25, 1000 Ljubljana, Slovenija',
          newvalue: 'Cesta XV. brigade 2, Metlika',
          status: :unverified,
          editor_email: 'joe@doe.com'
        )
        town_update = Update.find_by(
          updatable: klub_branch,
          field: 'town',
          oldvalue: 'Ljubljana',
          newvalue: 'Logatec',
          status: :unverified,
          editor_email: 'joe@doe.com'
        )
        latitude_update = Update.find_by(
          updatable: klub_branch,
          field: 'latitude',
          oldvalue: '46.044899',
          newvalue: '45.6474851',
          status: :unverified,
          editor_email: 'joe@doe.com'
        )
        longitude_update = Update.find_by(
          updatable: klub_branch,
          field: 'longitude',
          oldvalue: '14.489231',
          newvalue: '15.3155356',
          status: :unverified,
          editor_email: 'joe@doe.com'
        )

        expect(address_update).to be_present
        expect(town_update).to be_present
        expect(latitude_update).to be_present
        expect(longitude_update).to be_present

        # Make sure no other updates where created
        expect(Update.where(updatable: klub_branch).count).to eq 4
      end

      it "should not copy over the :created_at attribute" do
        expect(klub.branches.order('id ASC').last.created_at).to eq Time.new(2024, 11, 24, 01, 04, 44)
        expect(klub.branches.order('id ASC').last.updated_at).to eq Time.new(2024, 11, 24, 01, 04, 44)
      end

      it "should not change the Klub model" do
        expect(klub_branch.reload).to have_attributes(old_attrs)
      end

      it "should create new branches as unverified klub" do
        klub_branches = klub.reload.branches

        expect(klub_branches.count).to eq 3
        expect(klub_branches.map(&:verified)).to match_array [false, true, true]
      end

      it "should marked deleted branches for deletion" do
        expect(
          Update.where(
            updatable: second_branch,
            field: :marked_for_deletion,
            oldvalue: false,
            newvalue: true,
            status: :unverified,
            editor_email: 'joe@doe.com'
          )
        ).to exist
      end

      it "should not change the parent model" do
        expect(klub.reload).to have_attributes(old_attrs)
      end

      it "should not change the branch model" do
        expect(klub_branch.reload).to have_attributes(old_attrs)

      end
    end
  end

  describe "POST #klubs/:id/confirm" do
    let!(:klub) { FactoryBot.create(:complete_klub, data_confirmation_request_hash: 'myhash') }

    it "requires a valid data_confirmation_request_hash" do
      post :confirm, params: {
        id: klub.url_slug,
        request_hash: 'not real'
      }
      expect(response.status).to eq 404
    end

    it "returns 204" do
      post :confirm, params: {
        id: klub.url_slug,
        request_hash: 'myhash'
      }
      expect(response.status).to eq 204
    end

    it "updates the data_confirmed_at" do
      post :confirm, params: {
        id: klub.url_slug,
        request_hash: 'myhash'
      }

      expect(klub.reload.data_confirmed_at).not_to be_nil
    end

    it "nullifies the data_confirmation_request_hash when done" do
      post :confirm, params: {
        id: klub.url_slug,
        request_hash: 'myhash'
      }
      expect(klub.reload.data_confirmation_request_hash).to be_nil
    end
  end
end
