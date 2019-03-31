# C=64 Flames

This small program is for Commodore 64. It displays a full-screen flame demo, with inspiration from 
[How Doom Fire Was Done](http://fabiensanglard.net/doom_fire_psx/index.html) by Fabien Sanglard.

## Compilation and running

I used the [CBM Prg Studio](http://www.ajordison.co.uk/index.html) for the system. There are still some spurious files, like the Basic
source code file which were supposed to auto-start the program. This has only been tested on the [VICE](http://vice-emu.sourceforge.net/)
emulator, not on real hardware. 

The assembly code is put into $1000, and started with 'SYS4096'. It runs in a loop forever.

## Technical stuff

The program first initializes important stuff. First it sets the screen background and border to black. It then fills the screen memory with
the character '160' which is a solid block in the default C=64 chararcter set. The screen color memory is filled with black characters.

The screen stays filled with block characters for the whole effect. The effect is done by changing the color of the characters in the 
screen color memory according to the fire effect logic. However, because the C=64 colors are set by the hardware and they are not in 
the correct order, the program uses a separate array for saving and modifying the effect data. The data is 1000 (25 \* 40) bytes
and it is initialized mostly to zero, but the bottom line, that is, last 40 bytes, are initialized to $FF. 

The frame loop loops over 24 lines using the X register. The last line is skipped, because it is always the origin of the fire and
stays at $FF. The line is still in the data because the algorithm reads the line below the current position for its next value. 
For each line, the Y register is used to loop over the characters. 

For each character in the row, the value of the row below from the last round is read from the value array. A constant value is
subtracted, and then the SID voice 3 is used as a random element to see if we want to add values to it. It is possible to get
a higher value than the row below. 

The value calculated for current position from the character below and the random elements is divided by 16 to get an index
to the color list. The color is then saved to the screen color memory and the real value is saved to the array of flame values.

## Limitations and future ideas

The C=64 has only sixteen different colors, so the choice of the flame colors is difficult. Currently it has two grays to represent
smoke.

The speed of the effect is not huge. It's still multiple frames per second, but the C=64 struggles to do updates for all 1000 character
positions fast enough. A smaller effect on a partial screen or with bigger pixels would be faster but more complicated to code.

The resolution is not great. Using other characters than just the block might make the effect more pleasing, but that would probably
mean also changing the background color with some pattern instead of using just black. 

The effect now uses only the pixel just below the current one. The fire effect could be modified to use randomly one pixel to the left
or right as described on Sanglard's page. 

The C=64 assembly code is not very optimized. It can probably be improved, but as my first C=64 assembly program, I am now happy with it.