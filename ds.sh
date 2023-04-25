# Author           : HUbert Leszczynski ( 193552 )
# Created On       : 25.04.2023
# Last Modified By : Hubert Leszczynski
# Last Modified On : 25.04.2023
# Version          : prealpha 0.0.1
#
# Description      :Gra w sapera na dwie osoby
# Opis
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

#!/bin/bash
ONGOING=1
PLAYER1_POINTS=0
PLAYER2_POINTS=0
CURRENT_PLAYER=1
SIZE=20
BOMBS=30
FIELD=()
FIELD_WITH_FOG=()
INDEX=0
min=0
function field_creator {
	rozmiar=SIZE*SIZE
	for (( i=0; i<rozmiar; i++ ))
	do
		FIELD[$i]=". "
		FIELD_WITH_FOG[$i]=". "
	done

	for (( i=0; i<BOMBS; i++ ))
	do
		bomb_location=$(shuf -i 0-400 -n 1)
		FIELD[$bomb_location]="* "
	done
}
function print_field {
	for (( i=0; i<SIZE; i++ ))
	do
		for (( j=0; j<SIZE; j++ ))
		do
			printf "${FIELD[$INDEX]}"
			INDEX=$INDEX+1
		done
		echo ""
	done
}

field_creator
print_field
while [ $ONGOING -ne 0 ]; do
	if [ $CURRENT_PLAYER -ne 1 ]; then
		CURRENT_PLAYER=1
	elif [ $CURRENT_PLAYER -ne 0 ]; then
		CURRENT_PLAYER=0
	fi



	ONGOING=0



done

