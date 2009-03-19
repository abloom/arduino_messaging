require 'socket'
sock = TCPSocket.new("10.0.0.20", 23)
sock.write("1000")
sock.write("1127")
sock.write("1255")
sock.close

