# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pg'

connection = PG.connect(dbname: 'memo_app')

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def parse_data
  json_file = "memos/#{params[:id]}.json"
  JSON.parse(File.read(json_file), symbolize_names: true) if File.exist?(json_file)
end

not_found do
  erb :error_not_found
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  files = Dir.glob('memos/*')
  memos = files.map do |file|
    JSON.parse(File.read(file), symbolize_names: true)
  end
  @memos = memos.sort_by { |file| file[:time] }
  erb :index
end

post '/memos' do
  memo = {
    'id' => SecureRandom.uuid,
    'title' => params[:title].empty? ? 'タイトルなし' : params[:title],
    'content' => params[:content],
    'time' => Time.now
  }
  File.open("memos/#{memo['id']}.json", 'w') do |file|
    JSON.dump(memo, file)
  end
  redirect to("/memos/#{memo['id']}")
end

get '/memos/new' do
  erb :new
end

get '/memos/:id' do
  if parse_data
    @memo = parse_data
    erb :show
  else
    erb :error_not_found
  end
end

get '/memos/:id/edit' do
  if parse_data
    @memo = parse_data
    erb :edit
  else
    erb :error_not_found
  end
end

patch '/memos/:id' do
  if parse_data
    File.open("memos/#{params[:id]}.json", 'w') do |file|
      memo = {
        'id' => params[:id],
        'title' => params[:title].empty? ? 'タイトルなし' : params[:title],
        'content' => params[:content],
        'time' => Time.now
      }
      JSON.dump(memo, file)
    end
    redirect to("/memos/#{params[:id]}")
  else
    erb :error_not_found
  end
end

delete '/memos/:id' do
  if parse_data
    File.delete("memos/#{params[:id]}.json")
    redirect to('/memos')
  else
    erb :error_not_found
  end
end
