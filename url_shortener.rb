require 'sinatra/base'

class UrlShortener < Sinatra::Application
  set :public_folder, './public'

  set :urls, {}

  get '/' do
    erb :index, locals:{error: '', url_to_shorten: ''}
  end

  post '/shortened_url' do
    url_to_shorten = params['url_to_shorten']

    if url_to_shorten.empty?
      erb :index, locals:{error: 'URL can not be blank', url_to_shorten: url_to_shorten}
    elsif !is_url?(url_to_shorten)
      erb :index, locals:{error: 'The text you entered is not a valid URL', url_to_shorten: url_to_shorten}
    else
      max_id = settings.urls.keys.max.nil? ? 0 : settings.urls.keys.max
      new_id = max_id + 1
      settings.urls[new_id] = {original_url: url_to_shorten, visits: 0}

      redirect to("/#{new_id}?stats=true")
    end
  end

  get '/:id' do
    show_stats = params['stats'] == 'true'
    id = params['id'].to_i
    original_url = settings.urls[id][:original_url]
    total_visits = settings.urls[id][:visits]

    if show_stats
      shortened_url = "#{request.scheme}://#{request.host}:#{request.port}/#{id}"

      erb :show_shortened_url, locals:{shortened_url: shortened_url, original_url: original_url, total_visits: total_visits}
    else
      previous_visits = settings.urls[id][:visits]
      settings.urls[id] = {original_url: original_url, visits: previous_visits + 1}
      redirect to(original_url)
    end
  end

  private
  # this is a good thing to break out and unit test since you have
  # two acceptance tests to test this code.
  def is_url?(url)
    begin
      # make sure you return true or false, not truthy or falsy
      !!(url =~ URI.regexp(['http', 'https']))
    rescue URI::InvalidURIError
      false
    end
  end
end