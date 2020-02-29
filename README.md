# Lord Vetinari clock

This project is implementing a simple Lord Vetinari clock.

The clock's seconds hand is otherwise random moving but minutes and hours are exact.

## Usage

Find a clock mechanism and rewire its coil. See next section for details.

Find any NodeMCU chip.

Flash the NodemCU sw to ESP. Required modules are "tmr" and "gpio" which presumably any type of build would contain. Both integer and float builds are ok.

Install lua/* file to the NodeMCU.

Wire clock's coil pins to GND, D5 and D6 NodeMCU pins.

Power on the NodeMCU.

Enjoy the clock.

*Note: Start timeout is 5sec in order to allow one to run some command before actual clocking starts. This obviously is aimed at developers.*

## Rewiring existing analog clock

Idea basically is to gain access to both ends of the magnet coil and expose them to NodeMCU pins.

Wiring diagram is basically explained in [this project](https://www.cibomahto.com/2008/03/controlling-a-clock-with-an-arduino/).

This sw is configuring NodeMCU pins 5 and 6 to connect with the coil.

## License

GPLv3, see LICENSE file
