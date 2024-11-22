# MattBat-Vk8a8 Language
This is a C-like language written in Bison and Lex, designed specially for MattBatWings' "BatPU" Minecraft CPU.

This is still in WIP,as it currently does not support:
* Function declarations
* Function calls
* Automatically placed variables

# How to use:
## On linux:

First, CD into the project directory using the terminal.
Next, run `make` to compile the project.
To run the program, type `./mbvl [input file] > [output file]`

## On Windows:

Compile the program manually OR download one of the binaries from the "Releases" tab on the right.
Run the program with `./mbvl.exe [input file] > [output file]`

### Warning: I've only tested the EXE with wine. If it doesn't work, please file an issue.

# Example program:
```
:testlabel
if ($1 + $2 == $3) {
  $1 + $1;
  %ldi r2 1
  %str r2 r1
  goto lab;
}
```
This compiles to:
```
.testlabel

ldi r1 1
ldi r2 2
lod r1 r1
lod r2 r2
add r2 r1 r2

ldi r2 3
cmp r1 r2
brh ne .l0

ldi r1 1
ldi r2 1
lod r1 r1
lod r2 r2
add r2 r1 r2

ldi r2 1 ; inline 
str r2 r1 ; inline 
jmp .lab

.l0 ; IF 
```
