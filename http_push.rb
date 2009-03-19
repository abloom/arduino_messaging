#!/usr/bin/ruby

require 'socket'

puts "Opening Socket"
sock = TCPSocket.new("10.0.0.20", 23)

begin
  while
    $stdout.write "brightness: "
    msg = gets()
    sock.write(msg)
    puts "sent: #{msg}"
  end
ensure
  puts "\nClosing Socket"
  sock.close
end
