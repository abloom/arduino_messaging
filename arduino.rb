require 'rubygems'
require 'serialport'
require 'active_support'

class Arduino
  cattr_accessor :logger
  
  def initialize(tty_path)
    @tty_path = tty_path
    logger.info "Arduino Init: #{@tty_path}"
    connect!
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
    min, max = case graph
    when '1' then [1, 170]
    else [0, 254]
    end
      
    value = (((msg.to_f / 100.0) * max) + min).to_i
    value = value.to_s.rjust(3, '0');
    write(3, "#{graph}#{value}")
  end
  
  def clear_graph(graph)
    write(4, graph)
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
    m_type = m_type.to_s.rjust(2, '0')
    
    msg = "[#{m_type}#{m_body}]"
    logger.info "Sending: #{msg}"
    @sp.write(msg)
  end
end