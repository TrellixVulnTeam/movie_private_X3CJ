class MoviesController < ApplicationController
  before_action :set_movie, only:[:show, :edit, :update, :destroy]
  before_action :correct_user, only:[:edit, :update]
  before_action :authenticate_user!, only:[:create]

  def index
    if params[:keyword].present?
      @searches = ITunesSearchAPI.search(
        :term => params[:keyword],
        :country => 'jp',
        :media => 'movie',
        :lang => 'ja_jp',
        :limit => '50')
    end
    if current_user.present?
      if Movie.where(user_id: current_user.id).present?
        @xxx = Movie.where(user_id: current_user.id)
        @recommend = @xxx.order("RANDOM()").first
          @recommend1 = ITunesSearchAPI.search(
            :term => @recommend.director,
            :country => 'jp',
            :media => 'movie',
            :lang => 'ja_jp',
            :limit => '3')
      end
    end
    @review1 = Review.first
    @review2 = Review.second
    @review3 = Review.third
    @review4 = Review.fourth
    @review5 = Review.fifth
  end

  def new
    @search = ITunesSearchAPI.search(
        :term => params[:keyword],
        :country => 'jp',
        :media => 'movie',
        :lang => 'ja_jp',
        :limit => '10')
    @movie = Movie.new

    client = Twitter::REST::Client.new do |config|
      config.consumer_key         = ""
      config.consumer_secret      = ""
    end
    if params[:keyword2].present?
      @result_tweets = client.search(params[:keyword2], count: 30, result_type: "recent", exclude: "retweets" )
    end
  end

  def show
    @movie = Movie.joins(:reviews).where(track_id: params[:keyword]).group("track_id")
    @review = Review.where(track_id: params[:keyword])
  end

  def edit
  end

  def create
    @movie = Movie.new(movie_params)
    @movie.user_id = current_user.id
    if @movie.save
      redirect_to user_path(@movie.user_id)
    else
      redirect_back(fallback_location: new_movie_path,notice:'★ 既にmemoに登録されています。他の映画を検索しましょう。')
    end
  end

  def update
    @movie.update(movie_params)
    redirect_to movies_path
  end

  def destroy
    @movie.destroy
    redirect_to user_path(@movie.user_id)
  end

  private
  def set_movie
    @movie = Movie.find(params[:id])
  end

  def movie_params
    params.require(:movie).permit(:image, :title, :director, :staff, :information, :time, :category_id, :user_id, :when, :track_id )
  end

  def correct_user
    movie = Movie.find(params[:id])
    if current_user.id != movie.user.id
      redirect_to root/path
    end
  end

end
