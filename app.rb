require "bundler/setup"
Bundler.require(:default)
require "sinatra/reloader"

Dir["models/*.rb"].each do |model|
  require_relative model
end

Dir["repositories/*.rb"].each do |repository|
  require_relative repository
end

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  configure do
    set :views, settings.root + "/views"
  end

  enable :method_override

  def self.database_config
    YAML.load_file("config/database.yml")[ENV['RACK_ENV'] || 'development']
  end

  def self.database
    @database ||= Mysql2::Client.new(:host => "us-cdbr-iron-east-04.cleardb.net", :username => "bcde534746bbcc", :password => ENV['DATABASE_PASSWORD'], :database => "heroku_f11dc660cd4fd47", :reconnect => true)
    # ベタ書きだと動く　config/database.yml 読み込みだとaccess denied
  end

  helpers do
    def protected!
      unless authorized?
        response["WWW-Authenticate"] = %(Basic realm="Restriced Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials &&
      @auth.credentials == [ENV["SAKKI_USERNAME"], ENV["SAKKI_PASSWORD"]]
    end

    def entry_repository
      # @ が2個
      @@entry_repository ||= EntryRepository.new(App.database)
    end

    def title
      str = ""
      if @entry
        str = @entry.title + " - "
      end
      str + "blogじゃん？"
    end
  end

  get "/" do
    slim :index
  end

  get "/entries/new" do
    protected!
    slim :writing
  end

  get "/entries/edit/:id" do
    protected!
    @entry = entry_repository.fetch(params[:id].to_i)

    slim :writing
  end

  post "/entries" do
    protected!
    entry = Entry.new
    entry.title = params[:title]
    entry.body = params[:body]
    id = entry_repository.save(entry)

    redirect to("/entries/#{id}")
  end

  put "/entries" do
    protected!
    entry = Entry.new
    entry.id = params[:id]
    entry.title = params[:title]
    entry.body = params[:body]
    id = entry_repository.update(entry)

    redirect to("/entries/#{id}")
  end

  delete "/entries" do
    protected!
    entry_repository.delete(params[:delId])

    redirect to("/")
  end

  get "/entries/:id" do
    @entry = entry_repository.fetch(params[:id].to_i)

    slim :entry
  end
end
