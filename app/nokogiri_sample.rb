require 'nokogiri'

html = File.open('pitnews.html', 'r') { |f| f.read }
doc = Nokogiri::HTML.parse(html, nil, 'utf-8')

nodes = doc.xpath('//h6')  # '//h6'は文章全体のh6が対象となる

nodes.each { |node| pp node }
