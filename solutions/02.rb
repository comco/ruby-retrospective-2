#                         ,-.        _.---._
#                        |  `\.__.-''       `.
#                         \  _        _  ,.   \
#   ,+++=.____mtv.rb_______)_||______|_|_||    |
#  (_.ooo.===================||======|=|=||    |
#     ~~'    by comco     |  ~'      `~' o o  /
#                          \   /~`\     o o  /
#                           `~'    `-.____.-'
class Song
  attr_reader :name, :artist, :album

  def initialize(name, artist, album)
    @name   = name
    @artist = artist
    @album  = album
  end

  def state
    [name, artist, album]
  end
end

class Collection
  include Enumerable

  attr_reader :songs, :names, :artists, :albums

  def initialize(songs)
    @songs = songs
    @names, @artists, @albums = *songs.map(&:state).transpose.map(&:uniq)
  end

  def self.parse(text)
    songs = text.lines.map(&:chomp).each_slice(4).map do |name, artist, album|
      Song.new(name, artist, album)
    end

    new songs
  end

  def each(&block)
    songs.each(&block)
  end

  def filter(criteria)
    Collection.new select { |song| criteria.matches?(song) }
  end

  def adjoin(other)
    Collection.new (songs | other.songs)
  end
end

# a criteria contains a member which is a predicate for checking the criteria
class Criteria
  def initialize(&matching_block)
    @matching_block = matching_block
  end

  def matches?(song)
    @matching_block.call(song)
  end

  # base criterias definition
  def self.name(song_name)
    new { |song| song.name == song_name }
  end

  def self.artist(artist_name)
    new { |song| song.artist == artist_name }
  end

  def self.album(album_name)
    new { |song| song.album == album_name }
  end

  # criteria composition support
  def !
    Criteria.new { |song| not matches?(song) }
  end

  def |(other)
    Criteria.new { |song| matches?(song) or other.matches?(song) }
  end

  def &(other)
    Criteria.new { |song| matches?(song) and other.matches?(song) }
  end
end
