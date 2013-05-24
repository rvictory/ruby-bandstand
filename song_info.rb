# song_info.rb - interface to the scrobbler2 Song information
require 'active_support/all'
require 'scrobbler2'
require 'json'
require 'open-uri'

# Put your api_secret in a file called "api_secret"
# Put your api_key in a file called "api_key"

Scrobbler2::Base.api_secret = File.open('api_secret', 'rb') { |file| file.read }.chomp
Scrobbler2::Base.api_key = File.open('api_key', 'rb') { |file| file.read }.chomp

class SongInfo

  def self.get_song_info(artist, track)
    Scrobbler2::Track.new(artist, track)
  end

  def self.get_album_image_url(artist, album)
    results = JSON.parse(Scrobbler2::Base.get('album.getInfo', {'artist' => artist, 'album' => album}).body)
    if results
      if results['album']
        if results['album']['image']
          url = ''
          results['album']['image'].each do |image|
            if url == ''
              url = image['#text']
            end
            if image['size'] = 'medium'
              url = image['#text']
            end
          end
          return url
        end
      end
    end
    return ''
  end

  def self.get_album_image_url2(artist, album)
    track = self.get_album_info(artist, album)
    puts track.inspect
    puts track.info.inspect
    puts track.info.to_hash.keys
    puts track.info['name']
    return "" if track.nil?
    if track.info['album']
      puts track.info['album']
      return track.info['album']['image'].values.first
    else
      return ""
    end
  end

  def self.get_lyrics(artist, song)
    api_key = '61f688602decddd9992649616f891c'
    results = open(URI::encode("http://api.lyricsnmusic.com/songs?api_key=#{api_key}&q=#{artist} #{song}")) { |file| file.read }
    if results
      results = JSON.parse(results)
      if results.is_a?(Array) && results.length > 0
        return {'full_url' => results.first['url'], 'lyrics' => results.first['snippet']}
      end
    end
    return {'full_url' => '', 'lyrics' => ''}
  end

end

# Testing Code
if __FILE__ == $0
  #puts SongInfo.get_song_info("Fun.", "Some Nights").info
  #puts SongInfo.get_album_image_url("Bruno Mars", "Locked Out Of Heaven")
  #puts JSON.parse(Scrobbler2::Base.get('album.getInfo', {'artist' => 'Sh', 'album' => 'Locked Out of Heaven'}).body)['album']['image']
  puts SongInfo.get_lyrics('Eminem', 'Love the way you lie').inspect
end