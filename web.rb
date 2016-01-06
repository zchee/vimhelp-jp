# -*- encoding: UTF-8 -*-
require "bundler"
require "sinatra"
require "json"
require "set"
require "digest/sha1"
require "erb"
require "open-uri"
require "cgi"
require "haml"
require "sinatra/reloader" if development?
require "rdiscount"
require "addressable/uri"

configure do
  # logging is enabled by default in classic style applications,
  # so `enable :logging` is not needed
  file = File.new("#{settings.root}/log/#{settings.environment}.log", "a+")
  file.sync = true
  use Rack::CommonLogger, file
end

# set :markdown, :layout_engine => :haml, :layout => :pos

load "vimhelp.rb"

$stdout.sync = true
# Disable only serving localhost in development mode
set :bind, "0.0.0.0"

root = "/usr/src/doc"
tagfiles = ["tags-ja", "tags"]

vimhelp = VimHelp.new(root, tagfiles)

# -------------------- get --------------------

get "/" do
  haml :index
end

get "/dev" do
  haml :index
end

get "/about" do
  haml :about
end

# ?query={}
get "/api/search/json/" do
  content_type :json
  query = params[:query]
  return "" unless query
  vimhelp.search(query, "").to_json
end

# ?query={}
get "/api/redirect_vimdoc_ja/" do
  url = "http://vim-jp.org/vimdoc-ja/"
  query = params[:query]
  if query && !query.empty?
    result = vimhelp.search(query, "")
    url = result[:vimdoc_url] unless result[:vimdoc_url].empty?
  end
  # 	puts url
  redirect url
end

# ?query={}
get "/vimdoc/" do
  query = params[:query]
  redirect "./api/redirect_vimdoc_ja/?query=" + query
end

get "/api/redirect_vimdoc/" do
  query = params[:query]
  redirect "./api/redirect_vimdoc_ja/?query=" + query
end

# ?query={}
get "/search/" do
  query = params[:query]
  redirect "./?query=" + query
end

get "/api/tags/json" do
  content_type :json
  response.headers["Access-Control-Allow-Origin"] = "*"
  if params.key? "term"
    vimhelp.tags.select { |item| item =~ /#{params[:term]}/i }.to_json
  else
    vimhelp.tags.to_json
  end
end

# -------------------- post --------------------

post "/search" do
  content_type :json
  response.headers["Access-Control-Allow-Origin"] = "*"
  query = params[:in]
  return "Not found." if !query || query == ""
  result = vimhelp.search(query, "Not found.")
  text = result[:text]
  text = CGI.escapeHTML(text)

  # option link
  text = text.gsub(/\|(.+?)\||(&#39;[[:alpha:]]+?&#39;)|(&lt;[[:alpha:]]+?&gt;)|(\w+\(\))/) do |_text|
    query = CGI.unescapeHTML(Regexp.last_match(1) ? Regexp.last_match(1) : Regexp.last_match(2) ? Regexp.last_match(2) : Regexp.last_match(3) ? Regexp.last_match(3) : Regexp.last_match(4))
    title = vimhelp.search(query)[:text].sub(/^.*\n/, "").gsub(/　+|\s+|\t+\n/, " ").slice(0, 200)
    # title = result[:text].gsub(/　+|\s+|\t+\n/, " ").slice(0, 200)
    if title.empty?
      query
    else
      escape_query = CGI.escapeHTML query
      "<a class=\"tag_keyword\" data-keyword=\"#{escape_query}\" title=\"#{CGI.escapeHTML title}\">#{escape_query}</a>"
    end
  end
  text = text.gsub(/\n/, "<br>")
  { vimdoc_url: result[:vimdoc_url], text: text }.to_json
end

post "/lingr/vimhelpjp" do
  logger.info "loading data"
  content_type :text
  json = JSON.parse(request.body.string)
  json["events"].select { |e| e["message"] }.map do|e|
    text = e["message"]["text"]
    room = e["message"]["room"]

    if /^:h[\s　]+(.+)/ =~ text
      query = text[/^:h[\s　]+(.+)/, 1]
      post_lingr_help(room, query, vimhelp)
    end

    if /^:he[\s　]+(.+)/ =~ text
      query = text[/^:he[\s　]+(.+)/, 1]
      post_lingr_help(room, query, vimhelp)
    end

    if /^:help[\s　]+(.+)/ =~ text
      query = text[/^:help[\s　]+(.+)/, 1]
      post_lingr_help(room, query, vimhelp)
    end
  end
  return ""
end

post "/slack/vimhelpjp" do
  content_type :text
  uri = Addressable::URI.parse("#{request.url}?#{request.body.string}")

  text = uri.query_values["text"]
  if /^:h[\s　]+(.+)/ =~ text
    query = text[/^:h[\s　]+(.+)/, 1]
  elsif /^:he[\s　]+(.+)/ =~ text
    query = text[/^:he[\s　]+(.+)/, 1]
  elsif /^:help[\s　]+(.+)/ =~ text
    query = text[/^:help[\s　]+(.+)/, 1]
  end

  channel = uri.query_values["channel_id"]

  post_slack_help(channel, query, vimhelp)
end

# -------------------- lingr-bot --------------------
def post_lingr_help(room, query, vimhelp)
  Thread.start do
    url = "#{ENV['VIMHELP_URL']}##{ERB::Util.url_encode query}"
    help = vimhelp.search(query, "Not found.")
    result_raw = (url + "\n" + help[:text].gsub(/^$/, "　")).chomp("　\n").chomp
    # logger.info result_raw

    results = []
    if result_raw.length >= 1000
      result_count = result_raw.length / 1000 + 1
      for i in 1..result_count do
        results.push result_raw.slice(((i - 1) * 1000)...(i * 1000))
      end
    else
      results.push result_raw
    end

    for result in results.each do
      param = {
        room: room,
        bot: ENV["LINGR_BOT_ID"],
        text: result,
        bot_verifier: ENV["LINGR_BOT_KEY"],
      }.tap { |p| p[:bot_verifier] = Digest::SHA1.hexdigest(p[:bot] + p[:bot_verifier]) }

      query_string = param.map do|e|
        e.map { |s| ERB::Util.url_encode s.to_s }.join "="
      end.join "&"

      open "http://lingr.com/api/room/say?#{query_string}"
    end
  end
end

def post_slack_help(channel, query, vimhelp)
  Thread.start do
    url = "#{ENV['VIMHELP_URL']}##{ERB::Util.url_encode query}"
    help = vimhelp.search(query, "Not found.")
    result_raw = (url + "\n" + help[:text].gsub(/^$/, "　")).chomp("　\n").chomp
    # logger.info result_raw

    results = []
    if result_raw.length >= 1400
      result_count = result_raw.length / 1400 + 1
      for i in 1..result_count do
        results.push result_raw.slice(((i - 1) * 1400)...(i * 1400))
      end
    else
      results.push result_raw
    end

    for result in results.each do
      param = {
        token: ENV["SLACK_API_TOKEN"],
        channel: channel,
        text: result,
        username: "vimhelp-jp",
        icon_url: ENV["SLACK_BOT_ICON_URL"],
      }

      query_string = param.map do|e|
        e.map { |s| ERB::Util.url_encode s.to_s }.join "="
      end.join "&"

      open "https://slack.com/api/chat.postMessage?#{query_string}&pretty=1"
    end
  end
end
