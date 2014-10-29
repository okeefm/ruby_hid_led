Ruby HID LED
============

This project is designed to control a HID LED beacon (http://www.delcomproducts.com/downloads/USBVIHID.pdf) from Ruby. 

Installation
------------

* To install the project, begin by installing Signal 11's HID library on your chosen system: https://github.com/signal11/hidapi
* Once the HID API has been installed, the Ruby code should work via the FFI bindings to the library.
* `vendor_id`, `product_id`, and `serial_number` should be changed to reference your specific product. They can be found through Signal 11's demo GUI, among other methods.

Usage
-----

To use the code, call `ruby ruby_ffi_test.rb` with one of the following options:

    red
    green
    yellow
    off

Example: `ruby ruby_ffi_test.rb yellow` will turn on the yellow LED.

Copyright
---------

Original code developed by Shawn Anderson at http://spin.atomicobject.com/2014/01/31/ruby-prototyping-ffi/

Current author: Michael O'Keefe

Copyright (c) 2014 Michael O'Keefe
