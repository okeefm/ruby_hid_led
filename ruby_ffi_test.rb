# Author: Michael O'Keefe
# Original code from: Shawn Anderson
# Original code URL: http://spin.atomicobject.com/2014/01/31/ruby-prototyping-ffi/
# To run: install the proper HID API for your OS: https://github.com/signal11/hidapi

require 'ffi'
require 'pry'

LED_GREEN = 0x01
LED_RED = 0x02
LED_YELLOW = 0x04
LED_OFF = 0x00

LED_ON = 0x0C
LED_FLASH = 0x14
 
# This is very minimal, as all we need to be able to do is write to the light
module HidApi
  extend FFI::Library
  ffi_lib 'hidapi'
 
  attach_function :hid_open, [:int, :int, :int], :pointer
  attach_function :hid_write, [:pointer, :pointer, :int], :int
  attach_function :hid_close, [:pointer], :void
 
  REPORT_SIZE = 9 # 8 bytes + 1 byte for report type
  def self.pad_to_report_size(bytes)
    (bytes+[0]*(REPORT_SIZE-bytes.size)).pack("C*")
  end

  def self.send_command(led_color, device)
    # SEND
    command_to_send = self.pad_to_report_size([0x65,0x0C,led_color,0xFF])
    res = hid_write device, command_to_send, REPORT_SIZE
    raise "command write failed" if res <= 0
  end
end
 
 color = ARGV[0].chomp.downcase
case color
when "green"
  led_color = LED_GREEN
when "red"
  led_color = LED_RED
when "yellow"
  led_color = LED_YELLOW
when "off"
  led_color = LED_OFF
else
  raise ArgumentError, "No LED color #{color}"
end
 
# CONNECT
vendor_id = 0x0fc5.to_i
product_id = 0xb080.to_i
serial_number = 0
device = HidApi.hid_open(vendor_id, product_id, serial_number)

blinks = ARGV[1] ? ARGV[1].to_i : 0

HidApi.send_command(led_color, device)

blinks.times do |t|
  HidApi.send_command(LED_OFF, device)

  sleep(0.5)

  HidApi.send_command(led_color, device)

  sleep(0.5)
end
HidApi.hid_close(device)

