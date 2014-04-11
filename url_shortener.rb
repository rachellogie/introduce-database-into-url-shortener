require 'sinatra/base'
require 'sequel'

class UrlShortener < Sinatra::Application
  set :public_folder, './public'

  if UrlShortener.development?
    ENV['DATABASE_URL'] = 'postgres://gschool_user:password@localhost/urls_testing'
  end

  DB = Sequel.connect(ENV['DATABASE_URL'])

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
      id = DB[:urls].insert(original_url: url_to_shorten)

      redirect to("/#{id}?stats=true")
    end
  end

  get '/favicon.ico' do
    "None here"
  end


  get '/:id' do
    show_stats = params['stats'] == 'true'
    id = params['id'].to_i

    model = DB[:urls].where(id: id).first()
    original_url = model[:original_url]
    total_visits = model[:visits]

    if show_stats
      shortened_url = "#{request.base_url}/#{id}"

      erb :show_shortened_url, locals:{shortened_url: shortened_url, original_url: original_url, total_visits: total_visits}
    else
      DB[:urls].where(id: id).update(visits: total_visits + 1)
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