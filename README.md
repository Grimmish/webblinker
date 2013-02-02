A small project for the Raspberry Pi (RPi) that uses a NodeJS webserver to control a panel of LEDs.

DEMO
	http://www.youtube.com/watch?v=LyUHh7UwAM8

REQUIREMENTS
* Must run on an RPi. I'm using Arch, but Raspbian might work.

* NodeJS (Known to work with v0.8.17, older might be fine)

* Node modules:
  * SocketIO
  * http

* Client-side JS libraries:
  * socket.js (comes with the SocketIO module)
  * raphael-min.js (http://raphaeljs.com)

* Perl modules:
  * Device::BCM2835

* An LED panel hooked to the appropriate pins
  * I used shift registers to control more pins, but browse the logic and you'll see how to adapt it to your purposes.

CONTENTS
* led_controller.pl
  * Manipulates the GPIO pins of the RPi; takes commands through a FIFO 

* webblinker.js
  * Node app that brokers LED on/off updates between clients and commands led_controller.pl through the FIFO

* socket.html
  * Client-side JS

* launch.sh
  * Convenient way to launch the two server-side components
