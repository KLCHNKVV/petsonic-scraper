require 'open-uri'
require 'nokogiri'
require 'csv'
require 'xpath'

unless ARGV[0]
  print "\nSimple Ruby Scraper.\nUsage (for Unix terminal): 'ruby %script_name.rb% <web page URL> <name of csv file>.'"
end

url = ARGV[0]
csv_path = ARGV[1]
product_info = []

if File.zero?('petsonic.html')
  File.open('petsonic.html', 'w+').truncate(0)
end

html = open(url)
markup = Nokogiri::HTML(html)

html_file = File.new('petsonic.html', "w+")
html_file.puts(markup)

product_info << markup.at('title').text
price = markup.xpath('//span[@class="attribute_price"]').text.to_s.strip.scan /[^*!@%\^\s\€]+/
peso = markup.xpath('//span[@class="attribute_name"]').text.to_s.strip.scan /[^*!@%\^\s\.Gr,gr]+/
price.map! {|x| x + "€"}
peso.map! {|x| x + "Gr"}

product_info.push(price,peso)
product_info<<markup.at('.image_url').text

data_ary = Array.new(3) {Array.new}
for i in 0...3
  data_ary[i]<<product_info[0] + " - #{peso[i]}"
  data_ary[i]<<price[i]
  data_ary[i]<<product_info.last
end

File.open(csv_path, 'w+'){|csv_element| csv_element<<data_ary.map(&:to_csv).join}

html_file.close