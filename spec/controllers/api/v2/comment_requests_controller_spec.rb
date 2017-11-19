require 'rails_helper'

RSpec.describe Api::V2::CommentRequestsController, type: :controller do

  describe "POST #comment-requests" do
    let(:klub) { FactoryGirl.create(:complete_klub) }

    it "should require requester email address" do
      expect {
        post :create, params: {
          id: klub.url_slug,
          data: {
            type: 'comment-requests',
            attributes: {
              requester_email: nil,
              requester_name: 'Joe Doe',
              commenter_email: 'mon@her.com',
              commenter_name: 'Mon Her'
            },
            relationships: {
              klub: {
                data: {
                  id: klub.id,
                  type: 'klubs'
                }
              }
            }
          }
        }
      }.to raise_error(ActionController::ParameterMissing)
    end

    it "should require requester name" do
      expect {
        post :create, params: {
          id: klub.url_slug,
          data: {
            type: 'comment-requests',
            attributes: {
              requester_email: 'joe@doe.com',
              requester_name: ' ',
              commenter_email: 'mon@her.com',
              commenter_name: 'Mon Her'
            },
            relationships: {
              klub: {
                data: {
                  id: klub.id,
                  type: 'klubs'
                }
              }
            }
          }
        }
      }.to raise_error(ActionController::ParameterMissing)
    end

    it "should require commenter email address" do
      expect {
        post :create, params: {
          id: klub.url_slug,
          data: {
            type: 'comment-requests',
            attributes: {
              requester_email: 'joe@doe.com',
              requester_name: 'Joe Doe',
              commenter_email: '',
              commenter_name: 'Mon Her'
            },
            relationships: {
              klub: {
                data: {
                  id: klub.id,
                  type: 'klubs'
                }
              }
            }
          }
        }
      }.to raise_error(ActionController::ParameterMissing)
    end

    it "should require commenter name" do
      expect {
        post :create, params: {
          id: klub.url_slug,
          data: {
            type: 'comment-requests',
            attributes: {
              requester_email: 'joe@doe.com',
              requester_name: 'Joe Doe',
              commenter_email: 'mon@her.com',
              commenter_name: nil
            }
          }
        }
      }.to raise_error(ActionController::ParameterMissing)
    end

    it "should require valid commenter email" do
      expect {
        post :create, params: {
          id: klub.url_slug,
          data: {
            type: 'comment-requests',
            attributes: {
              requester_email: 'joe@doe.com',
              requester_name: 'Joe Doe',
              commenter_email: '@her.com',
              commenter_name: 'Mon Her'
            },
            relationships: {
              klub: {
                data: {
                  id: klub.id,
                  type: 'klubs'
                }
              }
            }
          }
        }
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should require valid requester email" do
      expect {
        post :create, params: {
          id: klub.url_slug,
          data: {
            type: 'comment-requests',
            attributes: {
              requester_email: 'joedoe.com',
              requester_name: 'Joe Doe',
              commenter_email: 'mon@her.com',
              commenter_name: 'Mon Her'
            },
            relationships: {
              klub: {
                data: {
                  id: klub.id,
                  type: 'klubs'
                }
              }
            }
          }
        }
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should return 202 on success" do
      post :create, params: {
        id: klub.url_slug,
        data: {
          type: 'comment-requests',
          attributes: {
            requester_email: 'joe@doe.com',
            requester_name: 'Joe Doe',
            commenter_email: 'mon@her.com',
            commenter_name: 'Mon Her'
          },
          relationships: {
            klub: {
              data: {
                id: klub.id,
                type: 'klubs'
              }
            }
          }
        }
      }

      expect(response.status).to eq 202
    end

    it "should create a comment request" do
      expect {
        post :create, params: {
          id: klub.url_slug,
          data: {
            type: 'comment-requests',
            attributes: {
              requester_email: 'joe@doe.com',
                requester_name: 'Joe Doe',
              commenter_email: 'mon@her.com',
              commenter_name: 'Mon Her'
            },
            relationships: {
              klub: {
                data: {
                  id: klub.id,
                  type: 'klubs'
                }
              }
            }
          }
        }
      }.to change(CommentRequest, :count).by(1)

      request = CommentRequest.last
      expect(request.requester_email).to eq  'joe@doe.com'
      expect(request.requester_name).to eq 'Joe Doe'
      expect(request.commenter_email).to eq 'mon@her.com'
      expect(request.commenter_name).to eq 'Mon Her'
    end

    it "shoud not create new comment request if already existing" do
      FactoryGirl.create(:comment_request, commenter_email: 'mon@her.com', commentable: klub)

      expect {
        post :create, params: {
          id: klub.url_slug,
          data: {
            type: 'comment-requests',
            attributes: {
              requester_email: 'joe@doe.com',
              requester_name: 'Joe Doe',
              commenter_email: 'mon@her.com',
              commenter_name: 'Mon Her'
            },
            relationships: {
              klub: {
                data: {
                  id: klub.id,
                  type: 'klubs'
                }
              }
            }
          }
        }
      }.not_to change(CommentRequest, :count)
    end

    it "should send emails to commenter" do
      expect_any_instance_of(CommentRequest).to receive(:send_comment_request_email)

      post :create, params: {
        id: klub.url_slug,
        data: {
          type: 'comment-requests',
          attributes: {
            requester_email: 'joe@doe.com',
            requester_name: 'Joe Doe',
            commenter_email: 'mon@her.com',
            commenter_name: 'Mon Her'
          },
          relationships: {
            klub: {
              data: {
                id: klub.id,
                type: 'klubs'
              }
            }
          }
        }
      }
    end

    it "returns existing hash if request duplicated" do
      FactoryGirl.create(:comment_request, commenter_email: 'mon@her.com', commentable: klub, request_hash: '1233')

      post :create, params: {
        id: klub.url_slug,
        data: {
          type: 'comment-requests',
          attributes: {
            requester_email: 'joe@doe.com',
            requester_name: 'Joe Doe',
            commenter_email: 'mon@her.com',
            commenter_name: 'Mon Her'
          },
          relationships: {
            klub: {
              data: {
                id: klub.id,
                type: 'klubs'
              }
            }
          }
        }
      }
      expect(json_response[:data][:id]).to eq '1233'
      expect(json_response[:data][:type]).to eq 'comment-requests'
    end

    it "does not resent request email if already exists" do
      expect_any_instance_of(CommentRequest).not_to receive(:send_comment_request_email)

      FactoryGirl.create(:comment_request, commenter_email: 'mon@her.com', commentable: klub, request_hash: '1233')

      post :create, params: {
        id: klub.url_slug,
        data: {
          type: 'comment-requests',
          attributes: {
            requester_email: 'joe@doe.com',
            requester_name: 'Joe Doe',
            commenter_email: 'mon@her.com',
            commenter_name: 'Mon Her'
          },
          relationships: {
            klub: {
              data: {
                id: klub.id,
                type: 'klubs'
              }
            }
          }
        }
      }
    end

    it "returns valid JSONAPI format" do
      post :create, params: {
        id: klub.url_slug,
        data: {
          type: 'comment-requests',
          attributes: {
            requester_email: 'joe@doe.com',
            requester_name: 'Joe Doe',
            commenter_email: 'mon@her.com',
            commenter_name: 'Mon Her'
          },
          relationships: {
            klub: {
              data: {
                id: klub.id,
                type: 'klubs'
              }
            }
          }
        }
      }

      expect(response).to match_response_schema("v2/comment-request")
    end
  end
end
