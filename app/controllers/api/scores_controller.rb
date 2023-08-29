module Api
  # Controller that handles CRUD operations for scores
  class ScoresController < ApplicationController
    before_action :logged_in!
    before_action :validate_score_user_id, only: :destroy

    def user_feed
      scores = Score.all.order(played_at: :desc, id: :desc).includes(:user).limit(25)
      serialized_scores = scores.map(&:serialize)

      response = {
        scores: serialized_scores,
      }

      render json: response.to_json
    end

    def create
      score = current_user.scores.build(score_params)

      if score.save
        render json: {
          score: score.serialize
        }
      else
        render json: {
          errors: score.errors.messages
        }, status: :bad_request
      end
    end

    def destroy
      @score.destroy!

      render json: {
        score: @score.serialize
      }
    end

    def user_scores
      score = Score.where(user_id: params[:user_id]).order(played_at: :desc).includes(:user)

      response = {
        scores: score.map(&:serialize),
      }

      render json: response.to_json
    end

    private

    def score_params
      params.require(:score).permit(:total_score, :played_at)
    end

    def validate_score_user_id
      @score = Score.find(params[:id])

      return if @score.user_id == current_user.id

      render json: {
        errors: [
          'Score does not belong to user'
        ]
      }, status: :unauthorized
    end
  end
end
