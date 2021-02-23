require 'net/http'
require 'nokogiri'
require 'json'

require 'optparse'


class PreProcesser
  # ==(入力)引数としてargvを追加
  def self.exec(argv)
    opt = OptionParser.new
    opt.on('--infile=VAL')
    opt.on('--outfile=VAL')
    opt.on('--category=VAL')

    params = {}
    opt.parse!(argv, into: params)

    raise 'Error: --infileと --categoryは同時に指定できません。' if params[:infile] && params[:category]

    return params
  end
end


class HtmlReader
  def initialize(options)
    @infile = options[:infile]
    @category = options[:category]
  end

  def get_from(url)
    return Net::HTTP.get(
      URI(url)
    )
  end

  def read_website
    url = 'https://masayuki14.github.io/pit-news/'
    url = url + '?category=' + @category if @category
    return Net::HTTP.get(
      URI(url)
    )
  end

  # ===(入力)引数はparams
  def read
    if @infile
      html = File.read(@infile)
    else
      html = read_website
    end

    return html
  end
end


class Scraper
  # ===クラスメソッドにするためにself.を追加して移植
  def self.scrape_news(news)
    {
      title: news.xpath('./p/strong/a').first.text,
      url: news.xpath('./p/strong/a').first['href']
    }
  end

  # ===クラスメソッドにするためにself.を追加して移植
  def self.scrape_section(section)
    {
      category: section.xpath('./h6').first.text,
      news:  section.xpath('./div/div').map { |node| scrape_news(node) }
    }
  end

  def self.scrape(html)
    doc = Nokogiri::HTML.parse(html, nil, 'utf-8')
    return doc.xpath('/html/body/main/section[position() > 1]').map { |section| scrape_section(section) }
  end
end


class JsonWriter
  def initialize(options)
    @outfile = options[:outfile]
  end

  # === クラスメソッドにするために self. を追加して移植
  def write_file(path, text)
    File.open(path, 'w') { |file| file.write(text) }
  end

  def write(pitnews)
    outfile = @param || 'pitnews.json'  # イディオムを使う
    write_file(outfile, {pitnews: pitnews}.to_json)
  end
end


class Command
  def self.main(argv)
    options = PreProcesser.exec(argv)
    reader = HtmlReader.new(options)
    writer = JsonWriter.new(options)          # === インスタンス化する

    pitnews = Scraper.scrape(reader.read)
    writer.write(pitnews)                     # === ファイルに書き込み
  end
end


Command.main(ARGV)
