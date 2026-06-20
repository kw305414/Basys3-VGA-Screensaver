# Basys3-VGA-Screensaver
VGA screensaver project implemented in Verilog on an Artix-7 FPGA (Basys 3 board).

A hardware VGA controller project that displays an animated screensaver. The design was implemented in Verilog on an Artix-7 FPGA.

## Project Description
The system generates a video signal in a standard **640x480 @ 60Hz** resolution. The 100 MHz signal from the onboard oscillator is divided to the 25 MHz frequency (Pixel Clock) required by the VGA standard. 

A multi-colored graphic is displayed on the monitor, moving smoothly across the screen and bouncing off its edges. The main logic includes:
* Hardware clock frequency divider.
* Generation of horizontal (HS) and vertical (VS) synchronization signals.
* Logic calculating motion vectors and object position.
* Reading graphics from the internal ROM with hardware image scaling (x4).
* A 3-bit color palette decoder converting pixel codes into a 12-bit RGB signal (displaying different colors for the background, face, eyes, and mouth).

## Hardware Used
* Evaluation board: **Digilent Basys 3** (Xilinx Artix-7 XC7A35T)
* Interface: VGA connector (driven by resistor ladders)

## File Structure
* `main.v` - Main Verilog module containing the entire system logic and ROM.
* `constraints.xdc` - Physical pin assignments file for the Basys 3 board.

## About
Project created by Krzysztof Witosz as part of the Programmable Logic Devices laboratory for the Electronics and Telecommunications major at the Silesian University of Technology.
