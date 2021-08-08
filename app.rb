# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

class Memo
  def self.list
    conn = PG.connect(dbname: 'memo_app')
    conn.exec("SELECT * FROM memos")
  end

  def self.create(title, content)
    conn = PG.connect(dbname: 'memo_app')
    conn.exec("INSERT INTO memos(title, content, created_at, updated_at)
    VALUES ('#{title}', '#{content}', current_timestamp, current_timestamp)")
  end

  def self.find(id)
    conn = PG.connect(dbname: 'memo_app')
    conn.exec("SELECT * FROM memos WHERE id='#{id}'")
  end

  def self.delete
  end

end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

not_found do
  erb :error_not_found
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = Memo.list
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
  @memo = Memo.find(params[:id])
  erb :show
end

get '/memos/:id/edit' do
  @memo = Memo.find(params[:id])
  erb :edit
  # erb :error_not_found
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
