class SwapReservationsController < ApplicationController
  before_action :log_in
  before_action :set_reservation_swap, except: [:index, :create]
  
  #ACTIVE USER IS THE ONE WHO SEND THE REQUEST
  #PASSIVE USER IS THE ONE WHO RECEIVE REQUEST
  def index
    @incoming = current_user.passive_requests
    @outgoing = current_user.active_requests
  end
  
  def create
    passive_reservation = Reservation.find(params[:reservation_id])
    room = passive_reservation.room
    active_user = current_user
    if Reservation.exists?(room_id: room.id, user_id: active_user.id)
      active_reservation = Reservation.find_by(room_id: room.id, user_id: active_user.id)

      @reservation_swap = SwapReservation.new(passive_user_id: params[:passive_user_id],
                                              active_user_id: current_user.id,
                                              passive_reservation_id: params[:reservation_id], 
                                              active_reservation_id: active_reservation)
      if  @reservation_swap.save!
        respond_to do |format|
          format.html
        end
      else
        flash[:danger] = 'Errore nella creazione'
      end
    end
  end
  
  def update
    @reservation_swap.accept
  end
  
  def destroy
    @reservation_swap.destroy!
    head :no_content
  end
  
  private
  def validationparams
    @reservation_swap.passive_user_id != @reservation_swap.active_user_id && @reservation_swap.passive_reservation_id != @reservation_swap.active_reservation_id
  end

  def set_reservation_swap
    @reservation_swap = SwapReservation.find(params[:id])
  end
  
  def log_in
    redirect_to login_path if current_user.nil?
  end
end
