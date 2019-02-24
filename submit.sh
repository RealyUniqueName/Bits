#!/bin/bash

rm bits.zip
zip -r bits.zip src README.md LICENSE haxelib.json > /dev/null
haxelib submit bits.zip