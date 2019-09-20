# Lord Vetinari clock

This project is implementing a simple Lord Vetinari clock.

The clock's seconds hand is otherwise random moving but minutes and hours are exact.

## Usage

Find any NodeMCU chip.

Flash the NodemCU sw to ESP. Required modules are "tmr" and "gpio" which presumably any type of build would contain. Internal algorithmics should be working with integer as well as float builds.

Install lua/* file to the NodeMCU.

Power on the NodeMCU using usb cable or connecting 5V to the pins directly.

Enjoy the clock.

*Note: Start timeout is 5sec in order to allow one to run some command before actual clocking starts. This obviously is aimed at developrs.*

## Rewiring exinsting analog clock

Idea basically is to gain access to both ends of the magnet coil and expose it to 2 nodemcu pins.

Wiring diagram is basically explained in [this project](https://www.cibomahto.com/2008/03/controlling-a-clock-with-an-arduino/).

This sw is configuring NodeMCU pins 5 and 6 to connect with the coil.

## Building

TODO

## License

GPLv3, see LICENSE file
