require 'rubygems'
require 'serialport'
require 'active_support'

class Arduino
  cattr_accessor :logger
  
  def initialize(tty_path)
    @tty_path = tty_path
    logger.info "Arduino Init: #{@tty_path}"
  end
  
  def send_message(message_type, *args)
    connect!
    send(message_type, *args)
  rescue => e
    logger.error e.message
  ensure
    disconnect!
  end
  
  def display_digits(msg)
    logger.info "Sending: 3#{msg}"
    write("3#{msg}")
  end
  
  def demo_mode
    logger.info "Sending: 1"
    write("1")
  end
  
  def clear_digits
    logger.info "Sending: 2"
    write("0")
  end
  
  def display_graph(graph, msg)
    logger.info "Sending: 5#{graph}#{msg}"
    write("5#{graph}#{msg}")
  end
  
  def clear_graph(graph)
    logger.info "Sending: 5#{graph}00"
    write("5#{graph}00")
  end
  
  def connect!
    @sp = SerialPort.new(@tty_path, 9600, 8, 1, SerialPort::NONE)
    logger.info "Connected."
  end
  
  def disconnect!
    @sp.close
    logger.info "Disconnected"
  end
  
  def write(msg)
    @sp.write(msg)
  end
end