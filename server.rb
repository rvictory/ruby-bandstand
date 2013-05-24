# PianoBarWeb - A Web interface for pianobar
# By Ryan Victory
#
#TODO: Implement more complex things from pianobar (station creation, mixing, etc.)

require 'sinatra'
require 'open3'
require './piano_bar'
require './song_info'

configure do
end

get '/' do
  #First check if piano bar is initialized, if not, redirect them to the "login to pandora" screen
  redirect "/pandora_login" unless PianoBar.initialized?
  erb :index
end

get '/pandora_login' do
  erb :pandora_login
end

post '/pandora_login' do
  PianoBar.init(params[:username], params[:password])
  if PianoBar.initialized?
    redirect '/'
  else
    @show_error = true
    erb :pandora_login
  end
end

get '/pandora_logout' do
  PianoBar.logout
  redirect '/pandora_login'
end

get '/commands/choose_station' do
  PianoBar.select_station params[:station]
end

get '/commands/thumbs_up' do
  PianoBar.thumbs_up
end

get '/commands/thumbs_down' do
  PianoBar.thumbs_down
end

get '/commands/volume_up' do
  PianoBar.vol_up
end

get '/commands/volume_down' do
  PianoBar.vol_down
end

get '/commands/next_song' do
  PianoBar.next_song
end

get '/commands/play_pause' do
  PianoBar.play_pause
end

get '/info/current_song' do
  PianoBar.current_song
end

get '/info/upcoming_songs' do
  PianoBar.upcoming_songs.to_json
end

get '/info/current_album_art' do
  song_info = PianoBar.current_song
  return "" if song_info.nil?
  song_name, temp = song_info.split(" by ")
  artist, album = temp.split(" on ") unless temp.nil?
  if artist && album
    artist.gsub!('"', '')
    album.gsub!('"', '').gsub!(' (Single)', '')
    return SongInfo.get_album_image_url(artist, album)
  else
    return ""
  end
end

get '/info/lyrics' do
  song_info = PianoBar.current_song
  return "" if song_info.nil?
  song_name, temp = song_info.split(" by ")
  artist, album = temp.split(" on ") unless temp.nil?
  if artist && song_name
    artist.gsub!('"', '')
    song_name.gsub!('"', '')
    return SongInfo.get_lyrics(artist, song_name).to_json
  end
  return {}.to_json
end

get '/info/current_time' do
  PianoBar.current_time
end

get '/info/explain_current_song' do
  PianoBar.song_information
end

get '/debug' do
  PianoBar.output.gsub("\n", "<br>")
end

get '/commands/re_init' do
  PianoBar.logout
  redirect '/'
end

get '/info/login_status' do
  if PianoBar.initialized?
    "connected"
  else
    "disconnected"
  end
end