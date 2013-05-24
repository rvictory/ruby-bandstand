class PianoBar

  @@pianobar = {}
  @@stations = []
  @@output = ""

  @@current_station = ""

  @@has_selected_station = false

  @@initialized = false

  @@stdin_thread = nil

  def self.initialized?
    @@initialized
  end

  def self.logout
    if !@@pianobar[:stdin].nil?
      @@pianobar[:stdin].close unless @@pianobar[:stdin].closed?
      @@stdin_thread.exit unless @@stdin_thread.nil?
      @@pianobar[:stdout].close unless @@pianobar[:stdout].closed?
      Process.kill("KILL", @@pianobar[:waitthr].pid) unless @@pianobar[:waitthr].nil? rescue ""
      @@initialized = false
    end
  end

  def self.init (username, password)
    if !@@pianobar[:stdin].nil?
      #We most likely already had a running copy of pianobar. Kill it by logging out
      self.logout
    end

    @@pianobar = {}
    @@stations = []
    @@output = ""

    @@current_station = ""

    @@has_selected_station = false

    if File.exists?('/opt/local/bin/pianobar')
      pianobar_path = '/opt/local/bin/pianobar'
    else
      pianobar_path = 'pianobar'
    end

    @@pianobar[:stdin], @@pianobar[:stdout], @@pianobar[:waitthr] = Open3.popen2(pianobar_path)
    puts @@pianobar[:stdout].readline
    @@pianobar[:stdin].puts username
    puts @@pianobar[:stdout].readline
    @@pianobar[:stdin].puts password
    puts @@pianobar[:stdout].readline
    login_results = @@pianobar[:stdout].readline
    if login_results !~ /ok/i
      puts "Incorrect login"
      return
    end
    @@initialized = true
    @@pianobar[:stdout].readline #Get stations ok
    #At this point we will spawn up the thread to get the station list and all subsequent output from pianobar
    @@stdin_thread = Thread.new {
      @@pianobar[:stdout].each_char do |c|
        @@output = @@output + c.to_s
        print c
        #Now we will slice the output string if it's too long, this is to hopefully save memory
        lines = @@output.lines.to_a
        if lines.length > 100
          @@output = lines.slice(lines.length - 100, 100).join("\n")
        end
      end
    }
    #Sleep for one second to let the station list populate
    sleep 1
    #Now populate the station list
    @@output.each_line do |line|
      if line =~ /\d+\)/
        @@stations.push line.gsub(/\[[^)]*\)\sq/i, "")
      end
    end

  end

  def self.stations
    @@stations
  end

  def self.output
    @@output
  end

  def self.current_song
    @@pianobar[:stdin].puts "i"
    sleep 0.5
    current = ""
    @@output.each_line do |line|
      if line =~ /\|\>/
        current = line
      end
    end
    current.split("|>").last
  end

  def self.current_station
    @@current_station
  end

  def self.current_time
    @@output.lines.to_a.last.split("[2K# ").last
  end

  def self.select_station station
    if @@has_selected_station
      @@pianobar[:stdin].puts "s#{station}"
    else
      @@has_selected_station = true
      @@pianobar[:stdin].puts station
    end
    @@current_station = stations[station.to_i]
  end

  def self.thumbs_up
    @@pianobar[:stdin].puts "+"
  end

  def self.thumbs_down
    @@pianobar[:stdin].puts "-"
  end

  def self.next_song
    @@pianobar[:stdin].puts "n"
  end

  def self.vol_up
    @@pianobar[:stdin].puts ")"
  end

  def self.vol_down
    @@pianobar[:stdin].puts "("
  end

  def self.play_pause
    @@pianobar[:stdin].puts "p"
  end

  def self.song_information
    @@pianobar[:stdin].puts "e"
    sleep 2
    explanation = ""
    @@output.each_line do |line|
      if line =~ /\(i\)/
        explanation = line
      end
    end
    explanation
  end

  def self.upcoming_songs
    puts "In upcoming songs"
    @@pianobar[:stdin].puts "u"
    sleep 1
    songs = []
    @@output.lines.to_a.reverse.each do |line|
      if line =~ /.*\d+\) (.*)/
        songs.push($1)
      end
      break if line =~ /.*0\).*/
    end
    songs
  end

end

=begin
+    love song
	-    ban song
	a    add music to station
	c    create new station
	d    delete station
	e    explain why this song is played
	g    add genre station
	h    song history
	i    print information about song/station
	j    add shared station
	m    move song to different station
	n    next song
	p    pause/continue
	q    quit
	r    rename station
	s    change station
	t    tired (ban song for 1 month)
	u    upcoming songs
	x    select quickmix stations
	b    bookmark song/artist
	(    decrease volume
	)    increase volume
	=    delete seeds/feedback
=end
