#!/bin/bash
# Build the binary diagrams using blockdiag's packetdiag command.
# To obtain this command, use
# pip install packetdiag

function run {
  packetdiag -f /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf -T png "$1" "$2"
}

run numeric-types.packetdiag numeric-types.png
run fixed-length-strings.packetdiag fixed-length-strings.png
run fixed-length-blobs.packetdiag fixed-length-blobs.png
run binary-alignment.packetdiag binary-alignment.png
run graphics.packetdiag graphics.png