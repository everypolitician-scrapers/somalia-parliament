#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('#lblcontent strong').each do |party|
    next if party.text.tidy.empty?
    members = party.xpath('following-sibling::text() | following-sibling::strong').slice_before { |e| e.name == 'strong' }.first
    members.each do |person|
      next if person.text.tidy.empty?
      data = { 
        name: person.text.tidy.sub(/^\d+\.?\s+/,''),
        party: party.text.tidy,
        term: '2012',
        source: url.to_s,
      }
      ScraperWiki.save_sqlite([:name, :party, :term], data)
    end
  end
end

scrape_list('http://www.parliament.somaligov.net/The%20Members.html')
