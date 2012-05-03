3D-PCB<br>
======<br>
OpenSCAD printed circuit board library for solder-free 3D-printable electronics.<br><br>

This library is licensed under the LGPL See http://www.gnu.org/licenses/lgpl.html <br><br>

Feature set:<br>
 -- power components --<br>
battery_holder_AAA(count = 1) // by default, makes a holder for 1 battery<br>
battery_holder_AA(count = 1) // but takes a parameter 'count' for several in series<br>
battery_holder_button_cell(count = 1)<br><br>

 -- component holders -- <br>
component_capacitor(diameter = 5.5)<br>
component_LED(diameter = 5)   <br>
component_2_LEDs(diameter = 5)<br>
component_resistor()<br>
component_transistor()<br><br>

-- and tie it all together -- <br>
base_board(length, width, thickness)        - similar to a pcb, you can place on a board<br>
peg(peg_height = 5, slot_width = 0.8)       - start and end point for traces<br>
peg_cap()                                   - end cap, print separately<br>
SPST_slide_switch_base()                    - base structure of slide switch<br>
SPST_slide_switch_toggle()                  - sliding structure of switch, print separetly<br>
trace_hop()                                 - for when traces cross, give two separate channels at 90 degree angle<br><br>

-- functions for placing -- <br>
get_component_distance() = 13.5             - uniform size of components, for easy arranging in grids<br><br><br>


