3D-PCB
======
OpenSCAD printed circuit board library for solder-free 3D-printable electronics.

Feature set:
 -- power components --
battery_holder_AAA(count = 1) // by default, makes a holder for 1 battery
battery_holder_AA(count = 1) // but takes a parameter 'count' for several in series
battery_holder_button_cell(count = 1)

 -- component holders -- 
component_capacitor(diameter = 5.5)
component_LED(diameter = 5)   
component_2_LEDs(diameter = 5)
component_resistor()
component_transistor()

-- and tie it all together -- 
base_board(length, width, thickness)        - similar to a pcb, you can place on a board
peg(peg_height = 5, slot_width = 0.8)       - start and end point for traces
peg_cap()                                   - end cap, print separately
SPST_slide_switch_base()                    - base structure of slide switch
SPST_slide_switch_toggle()                  - sliding structure of switch, print separetly
trace_hop()                                 - for when traces cross, give two separate channels at 90 degree angle

-- functions for placing -- 
get_component_distance() = 13.5             - uniform size of components, for easy arranging in grids


