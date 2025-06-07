class Api::V1::JobsController < ApplicationController
  # Override the default (lenient) auth from Authenticatable
  skip_before_action :authenticate_request_by_default

  # Explicit auth controls
  before_action :authenticate_request_strict, only: [:create, :update, :destroy]
  before_action :authenticate_request_lenient, only: [:index, :show]

  before_action :set_job, only: [:show, :update, :destroy]
  before_action :authorize_owner!, only: [:update, :destroy]

  # GET /api/v1/jobs
  def index
    render json: Job.all
  end

  # GET /api/v1/jobs/:id
  def show
    render json: @job
  end

  # POST /api/v1/jobs
  def create
    job = Job.new(job_params.merge(user_id: current_user_id))
    if job.save
      render json: job, status: :created
    else
      render json: job.errors, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/jobs/:id
  def update
    if @job.update(job_params)
      render json: @job
    else
      render json: @job.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/jobs/:id
  def destroy
    @job.destroy
    head :no_content
  end

  private

  def authenticate_request_strict
    authenticate_request(strict: true)
  end

  def authenticate_request_lenient
    authenticate_request(strict: false)
  end

  def set_job
    @job = Job.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Job not found' }, status: :not_found
  end

  def authorize_owner!
    if @job.user_id != current_user_id
      render json: { error: 'Forbidden' }, status: :forbidden
    end
  end

  def job_params
    params.permit(:title, :description, :company, :location)
  end
end
