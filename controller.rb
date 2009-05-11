require 'rubygems'
# require 'serialport'

class SerialPort
  def initialize(port, opts)
    @port, @opts = port, opts
  end
  
  def write(msg)
    puts "Sent: #{msg}"
  end
end

class Message
  attr_accessor :key, :name
  
  def self.build(name, key, &block)
    obj = new(name, key, &block)
    return obj
  end
  
  def initialize(name, key, &block)
    @name, @key, @process = name, key.to_s, block
  end
  
  def run
    @process.call
  end
end

Messages = [
  Message.build("Alive?", 1) do
    raise "Unimplemented"
  end,
  
  Message.build("Demo Mode", 2) do
    send_message(1)
  end,
  
  Message.build("Nixie Digits: Message", 3) do
    send_message 3, read_input("Display: ")
  end,
  
  Message.build("Nixie Digits: Zero Message", 4) do
    send_message 4, read_input("Display: ")
  end,
  
  Message.build("Nixie Digits: Clear", 5) do
    send_message 2
  end,
  
  Message.build("Bar Graph: Message", 6) do
    send_message 5, read_input("Graph: "), read_input("Value: ")
  end,
  
  Message.build("Bar Graph: Clear", 7) do
    send_message 5, read_input("Graph: "), 0
  end,
  
  Message.build("Quit", "Q") do
    exit(0)
  end
  ]
  
def Messages.print_collection
  each { |msg| puts "#{msg.key}.) #{msg.name}" }
end

def read_input(msg)
  printf msg
  STDIN.readline.chomp
end

def send_message(msg, *args)
  message = msg.to_s
  message << " #{args.join(" ")}" if args
  message << "\r\n"
  
  @sp.write(message)
end

if ARGV.size < 1
  STDERR.print "Usage: #{$0} port-path\n"
  exit(1)
end

begin
  puts "Opening Serial Port: #{ARGV[0]}"
  @sp = SerialPort.new(ARGV[0], :baud => 9600)
  
  loop do
    Messages.print_collection
    
    input = read_input("Choice: ")
    msg = Messages.find{ |m| m.key == input || m.key.downcase == input }
    msg.run if msg
    
    puts "\n"
  end
ensure
  puts "\nClosing Serial Port: #{ARGV[0]}"
end