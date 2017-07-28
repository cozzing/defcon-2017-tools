#!/usr/bin/env ruby

require 'json'

def from9(s)
  s
    .unpack('B*')[0]
    .chars
    .each_slice(9)
    .select{|x| x.size == 9}
    .map(&:join)
    .map{|x| x.to_i(2)}
end

if ARGV.empty?
  puts "Usage: #{__FILE__} pcap_stream.json"
  exit 1
end

arr = JSON.parse(IO.binread ARGV[0])

BPL = 12

arr.each do |i|
  id = i['id']
  data = i['data']
  next if data.empty?
  if id == 0
    $stdout.puts "\e[1;33mSent 0x" + data.size.to_s(16) + ' bytes: '
  else
    $stdout.puts "\e[0;38mReceived 0x" + data.size.to_s(16) + ' bytes: '
  end
  xs = data.unpack('m')[0].unpack('B*')[0]
  xs = from9(data.unpack('m')[0])
  xs
    .each_slice(BPL)
    .each_with_index do |arr, i|
    $stdout.write('  %07x:' % (BPL * i))
    arr.each do |c|
      $stdout.write(' %03x' % c)
    end
    $stdout.write(' ' * (15 - arr.size) * 4)
    $stdout.write '|'
    arr.each { |c| $stdout.write(c.between?(32, 127) ? c.chr : ".") }
    $stdout.puts '|'
  end
  $stdout.puts "\e[0m"
end