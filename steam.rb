#!/usr/bin/ruby

require 'rubygems'
require 'yaml'
require 'fileutils'
require 'logger'
require 'highline/import'
require 'arduino'

logger = Logger.new(STDOUT)
logger.level = Logger::INFO

Arduino.logger = logger

[:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white].each do |color|
  instance_eval <<-EOF
    def #{color}(msg)
      return msg unless ENV['TM_FILENAME'].nil?
      $terminal.color(msg, :#{color})
    end
  EOF
end

def config_path
  File.expand_path("~/.arduino_monitor/config.yml")
end

def load_setup_from_yaml  
  File.exists?(config_path) ? YAML.load_file(config_path) : false
end

def serial_port_menu
  choose do |menu|
    menu.header = "Serial Ports Available"
    menu.select_by = :index
    menu.prompt = "Port Selection: "
    
    Dir["/dev/tty.*"].each do |port|
      menu.choice(cyan(port)) { port }
    end
  end
end

def write_setup(setup, chosen_path)
  setup ||= {}
  setup['serial_path'] = chosen_path
  
  FileUtils.mkdir_p(File.dirname(config_path))
  File.open(config_path, "w") { |f| YAML.dump(setup, f) }
  say "Wrote config: #{config_path}"
  
  return setup
end

setup = load_setup_from_yaml
arduino = setup ? Arduino.new(setup['serial_path']) : false

loop do
  choose do |menu|
    menu.header = "Available Arduino Operations"
    menu.select_by = :index
    menu.prompt = "What would you like to do: "
    
    if arduino     
      menu.choice(green("Demo Mode"), "Runs a simple demo") { arduino.send_message(:demo_mode) }
      
      menu.choice(green("Display Digits")) do
        msg = ask "Message: "
        arduino.send_message(:display_digits, msg)
      end
      
      menu.choice(green("Clear Digits")) { arduino.send_message(:clear_digits) }
      
      menu.choice(green("Display Graph")) do
        graph = ask "Graph #: "
        value = ask "Value (0-100): "
        arduino.send_message(:display_graph, graph, value)
      end
      
      menu.choice(green("Clear Graph")) do
        graph = ask "Graph #: "
        arduino.send_message(:clear_graph, graph)
      end
    end
    
    menu.choice(magenta("Setup")) do
      say "\n\n"
      setup = write_setup(setup, serial_port_menu)
      arduino = Arduino.new(setup['serial_path'])
    end
    
    menu.choice(red("Quit")) { exit }
  end
  
  say "\n\n"
end
