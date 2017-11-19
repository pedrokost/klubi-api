require 'rails_helper'

RSpec.describe Api::V2::CommentsController, type: :controller do

  describe "POST #comments" do

    context "without a comment request hash" do
      let(:comment_attrs) {
        {
          data: {
            type: 'comments',
            attributes: {
              request_hash: nil,
              body: 'This is my comment',
              commenter_email: 'user@test.com',
              commenter_name: 'User'
            }
          }
        }
      }

      it "return a error status code" do
        expect { post :create, params: comment_attrs }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context "with an already used comments hash" do
      let(:comment_attrs) {
        {
          data: {
            type: 'comments',
            attributes: {
              request_hash: '1234',
              body: 'This is my comment',
              commenter_email: 'user@test.com',
              commenter_name: 'User'
            }
          }
        }
      }

      let(:comment) { FactoryGirl.create(:comment) }
      let!(:comment_request) { FactoryGirl.create(:comment_request, { request_hash: '1234', comment: comment }) }

      it "returns an error status code" do
        post :create, params: comment_attrs
        expect(response.status).to eq 422
      end

      it "does not create a comment" do
        expect {
          post :create, params: comment_attrs
        }.not_to change(Comment, :count)
      end

      it "does not update the comment reference" do
        expect(comment_request.reload.comment).to eq comment
      end
    end

    context "with a comments request hash" do

      let!(:comment_request) { FactoryGirl.create(:comment_request, { request_hash: '1234'} ) }

      let(:comment_attrs) {
        {
          data: {
            type: 'comments',
            attributes: {
              request_hash: '1234',
              body: 'This is my comment',
              commenter_email: 'user@test.com',
              commenter_name: 'User'
            }
          }
        }
      }

      it "returns success" do
        post :create, params: comment_attrs
        expect(response).to be_success
      end

      it "returns the id of the created comment" do
        post :create, params: comment_attrs
        expect(json_response[:data][:id]).not_to be_nil
      end

      it "creates a comment" do
        expect { post :create, params: comment_attrs }.to change(Comment, :count).by(1)
      end

      it "appends the comment to the request" do
        post :create, params: comment_attrs
        expect(comment_request.reload.comment).not_to be_nil
      end

      it "sends a thank your email to commenter" do
        expect_any_instance_of(Comment).to receive(:send_comment_published_email_to_commenter)
        post :create, params: comment_attrs
      end

      it "sends an email to comment requester informing of new comment" do
        expect_any_instance_of(CommentRequest).to receive(:send_comment_received_email_to_requestor)
        post :create, params: comment_attrs
      end

      describe "without a body" do

        it "return an error status code" do
          comment_attrs[:data][:attributes][:body] = " "
          expect { post :create, params: comment_attrs }.to raise_error(ActionController::ParameterMissing)
        end
      end

      describe "without a commenter name" do

        it "return an error status code" do
          comment_attrs[:data][:attributes][:commenter_name] = ""
          expect { post :create, params: comment_attrs }.to raise_error(ActionController::ParameterMissing)
        end
      end
    end
  end
end
