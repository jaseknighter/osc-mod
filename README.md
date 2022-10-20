# osc mod

an osc ([open sound control](https://monome.org/docs/norns/reference/osc)) mod script for monome norns.

## requirements

* norns (required)
* osc sender/receiver (e.g. max/msp, lemur, etc.)

## installation

1. `;install https://github.com/jaseknighter/osc-mod`
2. restart norns
  
## about the script
the idea for the script came from a project i am working on to send capacitive touch events from an adafruit [mpr121](https://learn.adafruit.com/adafruit-mpr121-12-key-capacitive-touch-sensor-breakout-tutorial) 12-Key capacitive touch sensor breakout board connected to a raspberry pi to norns via osc.

## credits

* @eigen for spiffy params inspection code

## documentation
after installing the mod and restarting, turn on the mod (instructions [here](https://monome.org/docs/norns/community-scripts/#installing-a-mod)), restart norns, and load a script.

once the mod has been enabled and a norns script has been loaded, configure your osc client to send messages to norns (use your norns' ip address and port 10111).

navigate to the mod in the system menu (SYSTEM>MODS>OSC-MOD) to review the available params for the currently loaded script. 

E2 to cycle through the params. make note of the `osc addr` values of the params you want to control via osc (e.g. `/engine_level`). 

K1+E2 to jump to the next params group for faster navigation.

K1+K3 to save the params for the currently loaded script to the norns filesystem at: /we/dust/data/osc-mod.

create the controls in your osc client using the `osc addr` values you found in the osc-mod menu. 

the controls in your osc client for `number`, `control`, and `taper` params should send values between 1 and 127. 

controls in your osc client for `option` params should send numbers from 1 to the `max` value of the param displayed in the mod menu.

controls to change text params are not yet supported.

note: the github repository includes a maxpat ('osc_test.maxpat') that can be used for testing.

## feature roadmap
* fix bugs (e.g. not sure if code to set trigger params via osc is working)
* allow changing text params via osc
* receive sending ip and port
* other features tbd

