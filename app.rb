# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

# rubocop disable Style/Documentation
class Memo
  def initialize
    @conn = PG.connect(dbname: 'memo_app')
  end

  def list
    @conn.exec('SELECT * FROM memos')
  end

  def create(title, content)
    @conn.exec('INSERT INTO memos(title, content, created_at, updated_at)
    VALUES ($1, $2, current_timestamp, current_timestamp)', [title, content])
  end

  def find(id)
    @conn.exec('SELECT * FROM memos WHERE id = $1 LIMIT 1', [id]).first
  end

  def update(id, title, content)
    @conn.exec('UPDATE memos SET title = $1, content = $2, updated_at = current_timestamp WHERE id = $3',
               [title, content, id])
  end

  def delete(id)
    @conn.exec('DELETE FROM memos WHERE id = $1', [id])
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
  @memos = Memo.new.list
  erb :index
end

post '/memos' do
  Memo.new.create(params[:title], params[:content])
  redirect to('/memos')
end

get '/memos/new' do
  erb :new
end

get '/memos/:id' do
  @memo = Memo.new.find(params[:id])
  @memo ? (erb :show) : (redirect to('not_found'))
end

get '/memos/:id/edit' do
  @memo = Memo.new.find(params[:id])
  @memo ? (erb :edit) : (redirect to('not_found'))
end

patch '/memos/:id' do
  @memo = Memo.new.update(params[:id], params[:title], params[:content])
  @memo ? (redirect to("/memos/#{params[:id]}")) : (redirect to('not_found'))
end

delete '/memos/:id' do
  @memo = Memo.new.delete(params[:id])
  @memo ? (redirect to('/memos')) : (redirect to('not_found'))
end
