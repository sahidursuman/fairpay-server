class PayController < ApplicationController
  include ApplicationHelper


  def widget
    uuid = params[:uuid]
    @embed = Embed.resolve(uuid)
    # render layout: false
  end

  def iframe
    uuid = params[:uuid]
    @embed = Embed.resolve(uuid)
  end


  def step1
    embed_uuid = params[:uuid]
    puts "current user: #{current_user}"

    session_data = {
        email: session[:email],
        authenticated_user: current_user
    }
    embed_params = params.permit(:amount, :description, :return_url, :correlation_id, :assigned_offer, :uuid)
    embed_params[:session_data] = session_data

    embed = Embed.resolve(embed_uuid)
    @data = hashify( embed.embed_data(embed_params) )
    puts "embed data: #{@data}"

    if params[:json]
      render json: @data
    else
      @data
    end

    #
    #
    # @amount = amount_param(:amount) || @embed.get_data_field(:amount)
    # @description = params[:description] || @embed.get_data_field(:description)
    # @return_url = params[:return_url] || @embed.get_data_field(:return_url)
    # @correlation_id = params[:correlation_id]
    #
    # offer_uuid = params[:offer]
    # if offer_uuid
    #   puts "passed in offer uuid: #{offer_uuid}"
    #   @assigned_offer = Offer.resolve(offer_uuid, required:false)
    # end
  end

  # def step1_post
  #   embed_uuid = params[:uuid]
  #   embed = Embed.by_uuid(embed_uuid)
  #
  #   assigned_amount = amount_param(:assigned_amount)
  #   entered_amount = amount_param(:entered_amount)
  #   chosen_amount = amount_param(:chosen_amount)
  #   amount = assigned_amount || entered_amount || chosen_amount
  #
  #   data = params.slice(:name, :email, :recurrence, :mailing_list, :description, :memo)
  #   data[:amount] = amount
  #
  #   transaction = embed.step1(data)
  #
  #   #todo: remove this
  #   step2_uri = "/pay/#{embed.uuid}/step2/#{transaction.uuid}"
  #   # session[:step2_uri] = step2_uri
  #
  #   session[:current_url] = transaction.step2_url
  #
  #   redirect_to step2_uri
  # end


  def step2
    @embed = Embed.by_uuid(params[:uuid])
    @transaction = Transaction.by_uuid(params[:transaction_uuid])

    raise "invalid transaction id: #{params[:transaction_uuid]}" unless @transaction #todo confirm provisional status
    raise "missing transaction amount"  unless @transaction.base_amount && @transaction.base_amount > 0

    @dwolla_authenticated = session[:dwolla_authenticated]  # make sure to allow just authenticated session
    if current_user && current_user.email == @transaction.payor.email
      puts "authenticated user session - stored payments available"
      @profile_authenticated = true   # rename this to something dwolla specific
    end
    # used to resume after login
    session[:current_url] = @transaction.step2_url
  end

  def step2_post
    embed = Embed.by_uuid(params[:uuid])
    transaction = embed.step2(params)
    redirect_to "/pay/#{embed.uuid}/thanks/#{transaction.uuid}"
  end

  # def step2_dwolla_post
  #   embed = Embed.by_uuid(params[:uuid])
  #   transaction = embed.step2(params)
  #   redirect_to "/pay/#{embed.uuid}/thanks/#{transaction.uuid}"
  # end

  # probably only needed in api controller
  # def update_fee_allocation
  #   embed = Embed.by_uuid(params[:uuid])
  #   result = embed.update_fee_allocation(params)
  #   render json: result
  # end
  #
  # def send_dwolla_info
  #   embed = Embed.by_uuid(params[:uuid])
  #   result = embed.send_dwolla_info(params)
  #   render json: result
  # end


  # def pay_via_dwolla
  #   # transaction_uuid = params[:transaction_uuid]
  #   # p "t uuid: #{transaction_uuid}"
  #   # transaction = Transaction.find_by(uuid: transaction_uuid)
  #   # raise "transaction not found for uuid: #{transaction_uuid}"  unless transaction
  #   # # transaction.payor.dwolla_token.make_payment(transaction.payee.dwolla_token, transaction.amount)
  #   # transaction.pay_via_dwolla
  #
  #   embed = Embed.by_uuid(params[:uuid])
  #   transaction = embed.pay_via_dwolla(params)
  #
  #   redirect_to "/pay/#{embed.uuid}/thanks/#{transaction.uuid}"
  # end


  def thanks
    @embed = Embed.by_uuid(params[:uuid])
    @transaction = Transaction.by_uuid(params[:transaction_uuid])
    # used to redisplay after signup
    session[:current_url] = @transaction.finished_url
  end


  # def estimate_fee
  #   bin = params[:bin]
  #   amount = params[:amount]
  #   embed = Embed.by_uuid(params[:uuid])
  #   result = embed.card_payment_service.estimate_fee(amount, bin)
  #   render json: result
  #
  #   transaction = Transaction.by_uuid(params[:transaction_uuid])
  #   transaction.calculate
  # end


  def merchant_receipt
    @embed = Embed.by_uuid(params[:uuid])
    @transaction = Transaction.by_uuid(params[:transaction_uuid])
  end

  # note, this won't work in a single proc dev environment
  # private
  # def fetch_widget_data(embed_uuid, params)
  #   url = "#{base_url}/api/v1/embeds/#{embed_uuid}/widget_data"
  #   response = RestClient.get url, params: params
  #   puts "response: #{response}"
  #   JSON.parse(response)
  # end



end
