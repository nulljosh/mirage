# Mirage Technical Whitepaper

**v1.0** | October 2026

Mirage is a five-room desert platformer written as a native app for Joshua Tree, a from-scratch operating system for PCs and the Raspberry Pi. The world, the rules and the story are one C header with no system calls, so the same code runs at ring 3 on the PC build, at EL0 on the Pi, on a Mac for testing, and in the browser as WebAssembly. An autopilot, Duke, plays it to the end, and every Joshua Tree build replays that run.

## The world

`mirage_core.h` holds five rooms of 40 by 20 tiles, 16 pixels a tile. Positions are fixed point at a sixteenth of a pixel and the world moves one step per kernel tick, 100 a second. Gravity, a fixed jump about 59 pixels high and a walk of 1.5 pixels a step are tuned so a ledge three tiles up and a gap three tiles wide are always in reach.

Joshua Tree's keyboard sends presses, not releases. So a walk key starts a short walk timer and each key repeat tops it up. The opposite key turns Wren around and `s` stops her. It feels like holding a key and needs nothing new from the kernel.

Scorpions walk their floor and turn at walls and edges. Bats sweep three tiles each way. The Dust King walks at Wren, hops every 140 steps and takes eight hits. A prickly pear gives back a heart. A fall into a pit costs a heart and puts Wren back where she entered the room.

## The picture

`mirage.c` draws into the app's window. A tile is as big as fits about eleven rows, and a camera follows Wren through the rest. Each room has a flat sky, a far layer of scenery that slides at half speed for depth, a near layer that stands on the ground, the tiles, then the figures. Every sprite is a 16 by 16 letter map (the Dust King is 32 by 32) drawn with a dark outline. There are no images and no gradients: about 46 KB of code holds the whole game.

## Playing it by machine

On every step the game prints one line of state (room, position, hearts, staff, key, gate, the Dust King's health) and one line listing what is alive in the room. Duke reads only those lines and plays only by pressing keys. Step mode (`.`, then `n` for five steps) stops the clock so a busy machine can't make Duke miss a jump. It pauses the game and does nothing else.

Duke's winning run becomes Joshua Tree's `mirage-route.txt`. The host check plays it against the header compiled for the Mac. The ring-3 check boots the OS headless, types the same keys and requires the final state line to match the host's exactly. So a change that makes the two builds differ by a single pixel of position fails.

## The web build

`build.sh` compiles the same two files and Joshua Tree's text renderer with clang for wasm32. Joshua Tree's syscall header gained a third branch, so the game's one call out (writing its state line) becomes a page import. The game exports start, key and tick functions. The page owns the loop at 100 ticks a second and copies the 960 by 540 picture to a canvas. The module is 61 KB.

MIT License. Copyright 2026 Joshua Trommel.
