@echo off

clear

odin build demo -out:demo_debug.exe -debug
odin build test -out:test_debug.exe -debug
