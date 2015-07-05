class StoresController < ApplicationController

  before_action :require_login, only: [:show, :token_reset]

  respond_to :html, :json

  #
  # GET /signup
  #
  def new
    @store = Store.new
  end

  #
  # GET /account (open Angular SPA)
  #
  def show
    @store = current_store
    respond_with @store, include: [:api_token, :simple_receipts]
  end

  #
  # POST /stores
  #
  def create
    @store = Store.new store_params
    if @store.save
      assign_api_token @store
      login @store
      redirect_to account_path @store
    else
      render :new
    end
  end

  #
  # PUT /account/token_reset
  #
  def token_reset
    reset_api_token current_store
    respond_with current_store.api_token
  end

  def passwd_reset
    # can only get here through login form
    # can't go here if logged in
  end

  private

  def store_params
    params.require(:store).permit(:name, :email, :email_confirmation, :password, :password_confirmation)
  end

  def assign_api_token store
    # TODO: handle uniqueness validation failure
    ApiToken.create(store_id:store.id, hex_value:SecureRandom.hex)
  end

  def reset_api_token store
    token = ApiToken.find_by(store_id:store.id)
    token.update(hex_value:SecureRandom.hex)
  end

end
