require 'combine_pdf'
require 'yomu'

def normalize(text)
  text
    .strip
    .downcase
    .gsub(/\s+/, ' ')
end

def term_whitespace_combos(term)
  tokens = term.split(/\b/)
  output = tokens.take(1)
  tokens.drop(1).each do |t|
    if t == " "
      output = output + output.map { |o| o + t }
    else
      output.each { |o| o << t }
    end
  end
  output
end

terms = File.foreach("terms.txt").map(&method(:normalize))
term_pages = Hash.new { |h, k| h[k] = [] }

pdf = CombinePDF.load("source.pdf")
pdf.pages.each_with_index do |page, i|
  $stdout.write "Page #{i}\r"

  p = CombinePDF.new
  p << page

  text = normalize(Yomu.read(:text, p.to_pdf))

  terms.each do |term|
    if term_whitespace_combos(term).any? { |c| text.include?(c) }
      term_pages[term] << i + 1
    end
  end
end
puts

term_pages.each do |term, pages|
  puts [term, *pages].join(",")
end
