#!/bin/bash
images=( Labyrinth.128x64.bmp Labyrinth.1600x1200.bmp Labyrinth.256x128.bmp Labyrinth.32x16.bmp Labyrinth.400x300.bmp Labyrinth.512x256.bmp Labyrinth.64x32.bmp Labyrinth.800x600.bmp )
for img in "${images[@]}"; do
	echo "Running experiment $3 on filter $1 of with implementation $2 and image $img"
	for i in $(bash -c "echo {1..60}"); do
	    echo -n "$3," >> "$1_experiment_$3.csv";
	    ./../src/build/tp2 Gamma -i "$2" "../src/tests/data/imagenes_a_testear/$img" -o ../src/output/ >> "$1_experiment_$3.csv"; 
	done;
done;