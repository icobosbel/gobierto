# frozen_string_literal: true

module User::ApiAuthenticationHelper
  extend ActiveSupport::Concern

  private

  def current_user
    @current_user ||= find_current_user
  end

  def user_authenticated?
    current_user.present?
  end

  def authenticate_user!
    raise_unauthorized unless user_authenticated?
  end

  def find_current_user
    return unless token.present?

    current_site.users.confirmed.joins(:api_tokens).find_by(user_api_tokens: { token: token })
  end

  def raise_unauthorized
    render(json: { message: "Unauthorized" }, status: :unauthorized, adapter: :json_api) && return
  end

  def token
    @token = request.headers["Authorization"] || params["token"]
  end
end
