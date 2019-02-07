require 'combine_pdf'
require 'yomu'

def normalize(text)
  text.downcase.gsub(/[\s[:punct:]]/, '')
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

def page_id(page)
  if page <= 14
    %w( i ii iii iv v vi vii viii ix x xi xii xiii xiv )[page - 1]
  else
    (page - 14).to_s
  end
end

def print_range(range)
  if range.min == range.max
    page_id(range.min)
  else
    "#{page_id(range.min)}-#{page_id(range.max)}"
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

terms.each do |term|
  puts [term, *get_ranges(term_pages.fetch(term,[])).map(&method(:print_range))].join(",")
end
