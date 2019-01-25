require 'combine_pdf'
require 'yomu'

def normalize(text)
  text.downcase.gsub(/\s/, '')
end

def get_ranges(pages)
  pages
    .reduce([]) do |acc, i|
    l = acc.pop
    if l && (l.max == i - 1)
      acc + [(l.min..i)]
    elsif l
      acc + [l, (i..i)]
    else
      [(i..i)]
    end
  end
end

def print_range(range)
  if range.min == range.max
    range.min.to_s
  else
    "#{range.min}-#{range.max}"
  end
end

terms = File.foreach("terms.txt").map(&:chomp).map(&:strip)
term_pages = Hash.new { |h, k| h[k] = [] }

Dir["pages/*"].sort.each_with_index do |pagefile, i|
  text = File.read(pagefile)

  terms.each do |term|
    if normalize(text).include?(normalize(term))
      term_pages[term] << i + 1
    end
  end
end

term_pages.each do |term, pages|
  puts [term, *get_ranges(pages).map(&method(:print_range))].join(",")
end
