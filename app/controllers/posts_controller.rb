class PostsController < ApplicationController
  before_action :require_login, only: %i[new create]
  before_action :set_search

  def index
    @posts = if (tag_name = params[:tag])
               Post.with_tag(tag_name).order(created_at: :desc).page(params[:page]).per(10)
             else
               Post.order(created_at: :desc).page(params[:page]).per(10)
             end
  end

  def search
    @q = Post.ransack(search_params)
    @posts = @q.result(distinct: true).includes(:user).order(created_at: :desc).page(params[:page])
    render :index
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.new(post_params)
    if @post.save
      redirect_to post_path(@post), success: 'ポストを作成しました'
    else
      flash.now[:danger] = 'ポストを作成できませんでした'
      render :new
    end
  end

  def show
    @post = Post.find(params[:id])
    @comment = Comment.new
  end

  def edit
    @post = current_user.posts.find(params[:id])
    @tag_names = @post.tag_names # タグの名前を取得
  end

  def update
    @post = current_user.posts.find(params[:id])
    if @post.update(post_params)
      redirect_to post_path(@post), success: 'ポストを更新しました'
    else
      flash.now[:danger] = 'ポストを更新できませんでした'
      render :edit
    end
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy!
    redirect_to posts_path, success: 'ポストを削除しました'
  end

  def set_search
    @q = Post.ransack(params[:q])
  end

  private

  def search_params
    params.require(:q).permit!
  end

  def post_params
    params.require(:post).permit(:title, :body, :tag_names)
  end
end
