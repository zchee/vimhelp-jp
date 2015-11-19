# -*- encoding: UTF-8 -*-
require "bundler"
require 'sinatra'
require 'json'
require 'set'
require 'digest/sha1'
require 'erb'
require 'open-uri'
require "cgi"
require "haml"
require 'sinatra/reloader' if development?
require 'rdiscount'
require 'addressable/uri'

configure do
  # logging is enabled by default in classic style applications,
  # so `enable :logging` is not needed
  file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
  file.sync = true
  use Rack::CommonLogger, file
end

# set :markdown, :layout_engine => :haml, :layout => :pos


load "vimhelp.rb"

$stdout.sync = true
# Disable only serving localhosh in development mode
set :bind, '0.0.0.0'



root = "plugins"
tagfiles = ["tags-ja", "tags"]

vimhelp = VimHelp.new(root, tagfiles)


get '/' do
  haml :index
end

get '/dev' do
  haml :index
end

get '/about' do
  haml :about
end


post '/search' do
  content_type :json
  response.headers['Access-Control-Allow-Origin'] = '*'
  query = params[:in]
  if !query || query == ""
    return "Not found."
  end
  result = vimhelp.search(query, "Not found.")
  text = result[:text]
  text = CGI.escapeHTML(text)

  # option link
  text = text.gsub(/\|(.+?)\||(&#39;[[:alpha:]]+?&#39;)|(&lt;[[:alpha:]]+?&gt;)|(\w+\(\))/){ |text|
    query = CGI.unescapeHTML($1 ? $1 : $2 ? $2 : $3 ? $3 : $4)
    title = vimhelp.search(query)[:text].sub(/^.*\n/, "").gsub(/　+|\s+|\t+\n/, " ").slice(0, 200)
    # 		title = result[:text].gsub(/　+|\s+|\t+\n/, " ").slice(0, 200)
    if title.empty?
      query
    else
      escape_query = CGI.escapeHTML query 
      "<a class=\"tag_keyword\" data-keyword=\"#{ escape_query }\" title=\"#{ CGI.escapeHTML title }\">#{ escape_query }</a>"
    end
  }
  text = text.gsub(/\n/, "<br>")
  { :vimdoc_url => result[:vimdoc_url], :text => text }.to_json
end


# ?query={}
get '/api/search/json/' do
  content_type :json
  query  = params[:query]
  if !query
    return ""
  end
  vimhelp.search(query, "").to_json
end


# ?query={}
get '/api/redirect_vimdoc_ja/' do
  url = "http://vim-jp.org/vimdoc-ja/"
  query  = params[:query]
  if query && !query.empty?
    result = vimhelp.search(query, "")
    url = result[:vimdoc_url] unless result[:vimdoc_url].empty?
  end
  # 	puts url
  redirect url
end


get '/api/tags/json' do
  content_type :json
  response.headers['Access-Control-Allow-Origin'] = '*'
  if params.has_key? "term"
    vimhelp.tags.select{ |item| item =~ /#{params[:term]}/i }.to_json
  else
    vimhelp.tags.to_json
  end
end



# -------------------- lingr-bot --------------------
def post_lingr_help(room, query, vimhelp)
  Thread.start do
    # url = "http://vim-help-jp.herokuapp.com/##{ERB::Util.url_encode query}"
    url = "#{ENV['VIMHELP_URL']}##{ERB::Util.url_encode query}"
    help = vimhelp.search(query, "Not found.")
    # result = (url + "\n" + help[:vimdoc_url] + "\n" + help[:text].gsub(/^$/, "　")).slice(0, 1000)
    # result = (help[:vimdoc_url] + "\n" + help[:text].gsub(/^$/, "　")).slice(0, 1000)
    result = (url + "\n" + help[:text].gsub(/^$/, "　")).chomp("　\n").chomp.slice(0, 1000)
    param = {
      room: room,
      text: result,
      bot_id: ENV['LINGR_BOT_ID'],
      bot_secret: ENV['LINGR_BOT_SECRET']
    }.tap {|p| p[:bot_verifier] = Digest::SHA1.hexdigest(p[:bot_id] + p[:bot_secret]) }

    query_string = param.map {|e|
      e.map {|s| ERB::Util.url_encode s.to_s }.join '='
    }.join '&'

    open "http://lingr.com/api/room/say?#{query_string}"
  end
end

def post_slack_help(channel, query, vimhelp)
  Thread.start do
    url = "#{ENV['VIMHELP_URL']}##{ERB::Util.url_encode query}"
    help = vimhelp.search(query, "Not found.")
    result_raw = (url + "\n" + help[:text].gsub(/^$/, "　")).chomp("　\n").chomp

    results = []
    if result_raw.length >= 1400
      result_count = result_raw.length / 1400 + 1
      for i in 1..result_count do
        results.push result_raw.slice((i - 1) * 1400, i * 1400)
      end
    else
      results.push result_raw
    end

    for result in results.each do
      param = {
        token: ENV['SLACK_API_TOKEN'],
        channel: channel,
        text: result,
        username: 'vimhelp-jp',
        icon_url: ENV['SLACK_BOT_ICON_URL']
      }

      query_string = param.map {|e|
        e.map {|s| ERB::Util.url_encode s.to_s }.join '='
      }.join '&'

      open "https://slack.com/api/chat.postMessage?#{query_string}&pretty=1"
    end
  end
end

post '/lingr/vimhelpjp' do
  content_type :text
  json = JSON.parse(request.body.string)
  json["events"].select {|e| e['message'] }.map {|e|
    text = e["message"]["text"]
    room = e["message"]["room"]

    if /^:h[\s　]+(.+)/ =~ text
      query = text[/^:h[\s　]+(.+)/, 1]
      # open "http://lingr.com/api/room/say?room=#{room}&bot=vimhelpjp_test&text=#{json}&bot_verifier=260189b9b8ec77ca29bfde5caf72ced9f30d0817"
      post_lingr_help(room, query, vimhelp)
    end

    if /^:help[\s　]+(.+)/ =~ text
      query = text[/^:help[\s　]+(.+)/, 1]
      # post_lingr_help(room, query, vimhelp)
    end
  }
  # post_lingr_help(room, query, vimhelp)
  return ""
end

post '/slack/vimhelpjp' do
  content_type :text
  uri = Addressable::URI.parse("#{request.url}?#{request.body.string}")

    text = uri.query_values['text']
  if /^:h[\s　]+(.+)/ =~ text
    query = text[/^:h[\s　]+(.+)/, 1]
  elsif /^:he[\s　]+(.+)/ =~ text
    query = text[/^:he[\s　]+(.+)/, 1]
  elsif /^:help[\s　]+(.+)/ =~ text
    query = text[/^:help[\s　]+(.+)/, 1]
  end

  channel = uri.query_values['channel_id']

  post_slack_help(channel, query, vimhelp)
end

# ?query={}
get '/vimdoc/' do
  query  = params[:query]
  redirect "./api/redirect_vimdoc_ja/?query=" + query
end

get '/api/redirect_vimdoc/' do
  query  = params[:query]
  redirect "./api/redirect_vimdoc_ja/?query=" + query
end


# ?query={}
get '/search/' do
  query  = params[:query]
  redirect "./?query=" + query
end
