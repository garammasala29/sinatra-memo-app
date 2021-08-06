# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pg'

class Memo
  def self.all
    connection = PG.connect(dbname: 'memo_app')
    connection.exec('SELECT * FROM memos') do |result|
      result.each do |row|
        row['title']
      end
    end
  end

  def self.create(title, content)
    conn = PG.connect(dbname: 'memo_app')
    conn.exec("INSERT INTO memos(title, content, created_at, updated_at)
    VALUES ('#{title}', '#{content}', current_timestamp, current_timestamp)")
  end

  def self.delete
  end

end

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
  Memo.create(params[:title], params[:content])
  redirect to("/memos")
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
