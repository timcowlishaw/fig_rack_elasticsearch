require 'sinatra'
require 'haml'
require 'securerandom'
require 'elasticsearch'

set :bind, '0.0.0.0'

helpers do
  def save_document(text)
    search.index(
      :index  => index_name,
      :type   => type_name,
      :id     => id,
      :body   => { :text => text }
    )
  end

  def find_documents(term)
    results = search.search(
      :index => index_name,
      :body => { :query => { :match => { :text => term }}}
    )
    results["hits"]["hits"].map { |result|
      result["_source"]["text"]
    }
  end

  private

  def search
    @search ||= Elasticsearch::Client.new(
     :log  => true,
     :host => search_host
    )
  end

  def id
    SecureRandom.hex
  end

  def search_host
    ENV.fetch("FIGRACKELASTICSEARCH_ELASTICSEARCH_1_PORT_9300_TCP_ADDR")
  end

  def index_name
    'articles_index'
  end

  def type_name
    'article'
  end
end

get '/' do
  haml :index
end

get "/articles/search" do
  term = params[:term]
  results = find_documents(term)
  haml :results, :locals => {:term => term, :results => results}
end

post "/articles" do
  text = params[:text]
  save_document(text)
  redirect "/"
end


