ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
  config.order = 'random'
end

def id_of_created_url(current_path)
  current_path.gsub('/','')
end
