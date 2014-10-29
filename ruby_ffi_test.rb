# Author: Michael O'Keefe
# Original code from: Shawn Anderson
# Original code URL: http://spin.atomicobject.com/2014/01/31/ruby-prototyping-ffi/
# To run: install the proper HID API for your OS: https://github.com/signal11/hidapi

require 'ffi'

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

if ARGV[1] == "flash"
  send(LED_FLASH,led_color)
end
 
send(LED_ON,led_color)

HidApi.hid_close(device)


def send(led_task, led_color)
  # SEND
  command_to_send = HidApi.pad_to_report_size([0x65,led_task,led_color,0xFF])
  res = HidApi.hid_write device, command_to_send, HidApi::REPORT_SIZE
  raise "command write failed" if res <= 0
end