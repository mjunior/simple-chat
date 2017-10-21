require 'spec_helper'

RSpec.describe TeamsController, type: :controller do
  include Devise::Test::ControllerHelpers

  before(:each) do
    @request.env["devise.mapping"] = Devise.mapping[:user]
    @current_user = FactoryGirl.create(:user)
    sign_in @current_user
  end

  describe 'GET #index' do
    it 'return http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    context 'Team exist' do
      context 'User is owner of the team' do
        it 'Return success' do
          team = FactoryGirl.create(:team, user: @current_user)
          get :show, params: { slug: team.slug }
          expect(response).to have_http_status(:success)
        end
      end

      context 'User is a member of the team' do
        it 'Return success' do
          team = FactoryGirl.create(:team)
          team.users << @current_user
          get :show, params: { slug: team.slug }
          
          expect(response).to have_http_status(:success)
        end
      end

      context 'User is not a member of the team' do
        it 'Redirect to root path' do
          team = FactoryGirl.create(:team)
          get :show, params: { slug: team.slug }
          expect(response).to redirect_to('/')
        end
      end
    end

    context 'Team dosent exist' do
      it 'Redirect to root path' do
        get :show, params: { slug: 'issonaoexiste' }
        expect(response).to redirect_to('/')
      end
    end
  end
  
  describe 'POST #create' do
    before(:each) do
      @team_attributes = FactoryGirl.attributes_for(:team, user: @current_user)
      post :create, params: {team: @team_attributes}
    end

    it 'Redirect to the new team' do
      expect(response).to have_http_status(302)
      expect(response).to redirect_to("/#{@team_attributes[:slug]}")      
    end

    it 'Check if the team was created with right attributes' do
      expect(Team.last.slug).to eq(@team_attributes[:slug])
      expect(Team.last.user).to eq(@current_user)
    end
  end

  describe 'DELETE #destroy' do
    
    before(:each) do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    context 'User is the owner of team' do
      it 'Return http success' do
        team = FactoryGirl.create(:team, user: @current_user)
        delete :destroy, params: {id: team.id}
        expect(response).to have_http_status(:success)        
      end
    end

    context 'User is not the owner of team' do
      it 'Return http forbidden' do
        team = FactoryGirl.create(:team)
        delete :destroy, params: {id: team.id}
        expect(response).to have_http_status(:forbidden)        
      end
    end
  end
end