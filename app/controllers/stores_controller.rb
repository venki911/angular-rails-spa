class StoresController < ApplicationController

  before_action :require_login, only: [:show, :token_reset]
  before_action :validate_api_token, only: [:update]

  respond_to :html, :json

  # GET /signup
  def new
    @store = Store.new
    @title = "New Account"
  end

  # GET /account.html (open Angular SPA)
  # GET /account.json (serve up account data)
  def show
    @store = current_store
    respond_with @store, include: [:api_token, :simple_receipts]
  end

  # POST /stores
  def create
    @store = Store.new store_params
    if @store.save
      assign_api_token @store
      login @store
      # NOTE account_path and NOT account_path(@store)
      # the latter doesn't work because there is no route
      # defined for account/:id
      redirect_to account_path
    else
      render :new
    end
  end

  # PUT /account.json
  def update
    if @valid_api_token
      @store = Store.find params[:id]
      @store.update params.require(:store).permit(:name, :email)
      # TODO: return the object
      # By default, Rails won't do this with PUT, body content is empty
      respond_with @store
    else
      # unauthorized
      render json: { status:"error",
                       mesg:"Invalid API token" }, status: 401
    end
  end

  # GET /account/token_reset.json
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

  def validate_api_token
    @valid_api_token = ApiToken.find_by hex_value:params[:api_token]
  end

end
