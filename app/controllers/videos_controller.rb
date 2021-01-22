class VideosController < ApplicationController
  before_action :require_video, only: [:show]

  def index
    if params[:query]
      data = VideoWrapper.search(params[:query])
    else
      data = Video.all
    end

    render status: :ok, json: data
  end

  def show
    render(
      status: :ok,
      json: @video.as_json(
        only: [:title, :overview, :release_date, :inventory, :image_url],
        methods: [:available_inventory]
        )
      )
  end

  def create
    @video = Video.new(video_params)

    if Video.find_by(title: @video.title)
      render json: {ok: false, cause: "duplicate errors", errors: @video.errors}, status: :bad_request
      return 
    end

    unless @video.save
      render json: {ok: false, cause: "validation errors", errors: @video.errors}, status: :bad_request
      return 
    end
  end

  private

  def require_video
    @video = Video.find_by(title: params[:title])
    unless @video
      render status: :not_found, json: { errors: { title: ["No video with title #{params["title"]}"] } }
    end
  end

  def video_params
    return params.permit(:external_id, :title, :overview, :release_date, :image_url, :inventory)
  end
end
