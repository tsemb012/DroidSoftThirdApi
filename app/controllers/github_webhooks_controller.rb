class GithubWebhooksController < ActionController::API

  include GithubWebhook::Processor

  # Handle push event
  def github_push(payload)
    repo_url = payload['repository']['html_url']

    if repo_url == 'https://github.com/tsemb012/LocationCsv'
      load_csv
    else
      Rails.logger.info("Unhandled repository: #{repo_url}")
    end
    head :ok
  end

  # Handle create event
  def github_create(payload)
    # handle create webhook
  end

  private

  def webhook_secret(payload)
    ENV['GITHUB_WEBHOOK_SECRET']
  end

  private

  def load_csv
    import_prefecture_csv_data
    import_city_csv_data
  end
end
