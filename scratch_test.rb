require 'hexapdf'
doc = HexaPDF::Document.new
io = File.open('public/fonts/GoNotoKurrent-Regular.ttf', 'rb')
begin
  font = doc.fonts.add(io)
  puts "Successfully added font from IO! Name: #{font}"
rescue => e
  puts "Failed: #{e.message}"
end
