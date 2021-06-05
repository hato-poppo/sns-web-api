class ApplicationController < ActionController::API

  def response_success(json)
    render status: 200, json: json
  end

  def response_bad_request(message = 'Bad Request')
    render status: 400, json: { status: 400, message: message }
  end

  def response_unauthorized(message = 'Unauthorized')
    render status: 401, json: { status: 401, message: message }
  end

  def response_not_found(message = 'Not Found')
    render status: 404, json: { status: 404, message: message }
  end

  def response_conflict(message = 'Conflict')
    render status: 409, json: { status: 409, message: message }
  end

  def response_unprocessable_entity(message = 'Unprocessable Entity')
    render status: 422, json: { status: 422, message: message }
  end

  def response_internal_server_error(message = 'Internal Server Error')
    render status: 500, json: { status: 500, message: message }
  end

end
