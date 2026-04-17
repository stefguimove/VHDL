#!/bin/bash

# 1. Nettoyage et création de la bibliothèque de travail
if [ -d "work" ]; then vdel -all -lib work; fi
vlib work

# 2. Compilation de la bibliothèque technologique (CORE8LPGVT)
# Note : Vérifie le chemin exact vers ce fichier sur les machines de l'école
vcom -93 /softslin/ams_4.11/vhdl/core8lpgvt/core8lpgvt.vhd

# 3. Compilation de ta NETLIST (le résultat de Design Vision)
# On compile output_fsm.vhd au lieu de tous les petits composants
vcom -93 output_fsm.vhd

# 4. Compilation de ton TESTBENCH
# Assure-toi que le testbench est dans le même dossier ou ajuste le chemin
vcom -93 bench/bench.vhd

# 5. Lancement de la simulation avec le fichier SDF
# -sdftyp /UUT=... : On injecte les délais dans l'instance de ton filtre
# /UUT est le nom de l'instance dans ton bench.vhd (vérifie si c'est UUT ou I_DUT)
vsim -t ps \
     -sdftyp /UUT=output_fsm.sdf \
     +sdf_errors_to_warnings \
     work.bench