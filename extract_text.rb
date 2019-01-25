require 'fileutils'
require 'combine_pdf'
require 'yomu'

FileUtils.rm_rf('pages')
FileUtils.mkdir('pages')
CombinePDF.load("source.pdf").pages.each_with_index do |page, i|
  $stdout.write "Page #{i + 1}\r"
  File.open("pages/page_#{'%03d' % (i+1)}", "w") do |f|
    p = CombinePDF.new
    p << page

    f.write(Yomu.read(:text, p.to_pdf))
  end
end
puts
