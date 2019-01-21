require 'combine_pdf'
require 'yomu'

terms = File.foreach("terms.txt").map(&:chomp).map(&:downcase).map { |t| t.squeeze(' ') }
term_pages = Hash.new { |h, k| h[k] = [] }

pdf = CombinePDF.load("source.pdf")
pdf.pages.take(20).each_with_index do |page, i|
  $stdout.write "Page #{i}\r"
  p = CombinePDF.new
  p << page
  text = Yomu.read(:text, p.to_pdf).downcase.gsub(/\s/, ' ').squeeze(' ')
  terms.each do |term|
    if text.include?(term)
      term_pages[term] << i + 1
    end
  end
end
puts

term_pages.each do |term, pages|
  puts [term, *pages].join(",")
end
