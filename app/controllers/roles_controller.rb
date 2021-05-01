class RolesController < ApplicationController

  def index
    render json: Role.all.to_json(secure)
  end  

  private

    def secure
      Role.to_secure
    end

end
