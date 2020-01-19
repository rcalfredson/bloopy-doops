# frozen_string_literal: true

require 'cgi'
require 'net/http'
require 'nokogiri'

# returns query results from AllMusic
class AllMusic
  def album(album_query)
    data = album_page(album_query)
    { songs: song_titles(data),
      title: title(data),
      albumArtist: artist(data) }
  end

  def album_page(album_query)
    allmusic_search_path = 'https://www.allmusic.com/search/all/'
    search_results = Nokogiri::HTML(Net::HTTP.get(URI("#{allmusic_search_path}#{
      CGI.escape(album_query)}")))
    song_link = search_results.xpath('//div[@class="title"]/a/@href')[0].content
    Nokogiri::HTML(Net::HTTP.get(URI(song_link)))
  end

  def song_titles(page_content)
    page_content.xpath('//div[@class="title"]').map do |link|
      link.content.strip
    end
  end

  def artist(page_content)
    top_content(page_content.xpath('//h2[@class="album-artist"]'))
  end

  def top_content(nodes)
    nodes.first.content.strip
  end

  def title(page_content)
    top_content(page_content.xpath('//h1[@class="album-title"]'))
  end
end
