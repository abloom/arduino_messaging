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
    sleep(1)
  rescue => e
    logger.error e.message
  ensure
    disconnect!
  end
  
  def demo_mode
    write(0)
  end
  
  def display_digits(msg)
    write(1, msg)
  end
  
  def clear_digits
    write(2)
  end
  
  def display_graph(graph, msg)
    value = (msg.to_f / 100.0) * 254.0
    write(3, "#{graph}#{value.to_i}")
  end
  
  def clear_graph(graph)
    write(4, "#{graph}000")
  end
  
  def connect!
    @sp = SerialPort.new(@tty_path, 9600, 8, 1, SerialPort::NONE)
    logger.info "Connected."
  end
  
  def disconnect!
    @sp.close
    logger.info "Disconnected"
  end
  
  def write(m_type, m_body = "")
    m_type = (m_type < 10 ? "0#{m_type}" : m_type.to_s)
    
    msg = "[#{m_type}#{m_body}]"
    logger.info "Sending: #{msg}"
    @sp.write(msg)
  end
end