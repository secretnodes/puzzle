class Common::PetitionsController < Common::BaseController
  before_action :ensure_chain
  load_and_authorize_resource only: [:new, :create]

  def index
   redirect_to namespaced_path( 'governance_root' )
  end

  def new
    @petition = @chain.namespace::Petition.new
  end

  def create
    end_date = petition_params[:voting_end_time].to_i.days.from_now
    @petition = @chain.petitions.new(
      petition_params.merge(
        voting_start_time: Time.now,
        voting_end_time: end_date,
        status: :voting_period,
        user_id: current_user.id
      )
    )

    if @petition.save!
      FinalizePetitionWorker.perform_at(end_date, @petition.id, @chain.class.to_s, @chain.id)
      flash[:success] = "You successfully created a petition entitled #{@petition.title}!"
      redirect_to namespaced_path('governance_root', type: params[:petition_type] )
    else
      flash[:error] = "There was an error creating your petition. Please try again."
      return
    end
  end

  def show
    @petition = @chain.namespace::Petition.find params[:id]
    @tally_result = @chain.namespace::PetitionTallyDecorator.new(@petition)
    
    sort_direction = params[:comment_sort].present? ? params[:comment_sort].downcase.to_sym : :asc
    @comments = @petition.comments.unscope(:order).order(created_at: sort_direction)
    @statuses = [['Consideration Phase', :voting_period], ['In Progress', :in_progress], ['Rejected', :rejected], ['Finished', :passed]] if current_user.foundation? || current_user.sudo?
  end

  def edit
    @petition = @chain.namespace::Petition.find params[:id]
    flash[:error] = 'That petition is not a foundation spend proposal, please select a different one.' and redirect_back(fallback_location: root_path) unless @petition.foundation?
   
  end

  def update
    @petition = @chain.namespace::Petition.find params[:id]

    flash[:error] = 'That petition is not a foundation spend proposal, please select a different one.' and redirect_back(fallback_location: root_path) unless @petition.foundation?

    if @petition.update(status: params[:status])
      flash[:success] = 'You saved the Foundation Spend Proposal successfully!'
      redirect_back(fallback_location: root_path)
    else
      flash[:error] = 'There was an error while saving your selection. Please try again.'
      redirect_back(fallback_location: root_path)
    end
  end

  private
  
  def petition_params
    params.require("#{@chain.namespace.to_s.downcase}_petition".to_sym).permit(
      :title,
      :voting_end_time,
      :description,
      :petition_type,
      :amount,
      :contact_info
    )
  end
end