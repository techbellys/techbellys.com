class Api::V1::ProxyController < ApplicationController
  def forward_auth
    forward_request_to(:auth)
  end

  def forward_jobs
    forward_request_to(:job)
  end

  private

  def forward_request_to(service)
    service_url = service_base_url(service)
    path = params[:path]
    full_url = "#{service_url}/api/v1/#{path}"

    response = Faraday.send(request.method.downcase.to_sym, full_url) do |req|
      req.headers = forwarded_headers
      req.headers['Content-Type'] = 'application/json'
      req.body = request_body_json
    end

    render status: response.status, json: parse_response_body(response)
  rescue JSON::ParserError
    render status: response.status, plain: response.body
  rescue => e
    Rails.logger.error("Proxy request to #{full_url} failed: #{e.message}")
    render status: :bad_gateway, json: { error: "Proxy error: #{e.message}" }
  end

  def service_base_url(service)
    case service
    when :auth
      ENV.fetch('AUTH_SERVICE_URL', 'http://localhost:3000')
    when :job
      ENV.fetch('JOB_SERVICE_URL', 'http://localhost:3001')
    else
      raise ArgumentError, "Unknown service: #{service}"
    end
  end

  def request_body_json
    body = request.body.read
    body.present? ? body : nil
  end

  def forwarded_headers
    request.headers.env.select { |k, _| k.start_with?('HTTP_') }
                      .transform_keys { |key| key.sub(/^HTTP_/, '').titleize.split.join('-') }
                      .tap { |h| h['Authorization'] = request.headers['Authorization'] }
  end

  def parse_response_body(response)
    JSON.parse(response.body)
  rescue JSON::ParserError
    { raw_body: response.body }
  end
end
