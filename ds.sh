# Author           : HUbert Leszczynski ( 193552 )
# Created On       : 25.04.2023
# Last Modified By : Hubert Leszczynski
# Last Modified On : 9.05.2023
# Version          : alpha 0.0.1
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
SIZE=10
BOMBS=30
FIELD=()
FIELD_WITH_FOG=()
INDEX=0
min=0

MOVE_TYPE=0
POS_X=0
POS_Y=0
function field_creator {
	rozmiar=SIZE*SIZE
	for (( i=0; i<rozmiar; i++ ))
	do
		FIELD[$i]=1
		FIELD_WITH_FOG[$i]=". "
	done

	for (( i=0; i<BOMBS; i++ ))
	do
		bomb_location=$(shuf -i 0-400 -n 1)
		FIELD[$bomb_location]=2
	done
}
print_field() {
	for (( i=0; i<SIZE; i++ ))
	do
		for (( j=0; j<SIZE; j++ ))
		do
			printf "${FIELD_WITH_FOG[$INDEX]}"
			INDEX=$INDEX+1
		done
		echo ""
	done
}

field_creator

while [ $ONGOING -ne 0 ]; do
	if [ $CURRENT_PLAYER -ne 1 ]; then
		CURRENT_PLAYER=1
	elif [ $CURRENT_PLAYER -ne 2 ]; then
		CURRENT_PLAYER=2
	fi

	print_field

	echo "Podaj typ ruchu: 1 to sprawdzenie, 2 to rozbrojenie, a 3 to zakonczenie rozgrywki:  "
	read MOVE_TYPE

	if [ $MOVE_TYPE -eq 3 ]; then
		ONGOING=0
	elif [ $MOVE_TYPE -eq 1 ]; then
	        echo "Podaj wiersz: "
		read POS_Y
               	echo "Podaj kolumne: "
	        read POS_X
		if [ "${FIELD[$POS_Y*$SIZE+$POS_X]}" -eq 2 ]; then
			echo "BOOM"
			ONGOING=0	 
		else
			if [ $CURRENT_PLAYER -eq 1 ]; then
				((PLAYER1_POINTS+=1))
			else	
				((PLAYER2_POINTS+=1))
			fi
		fi
	elif [ $MOVE_TYPE -eq 2 ]; then
		echo "aaaaa"
	else
		echo "Nieprawidlowy ruch!"
	fi
	echo "Player 1 : $PLAYER1_POINTS  Player 2 : $PLAYER2_POINTS"
done
if [ $PLAYER1_POINTS -gt $PLAYER2_POINTS ]; then
	echo "Gracz 1 zwyciezyl"
elif [ $PLAYER2_POINTS -gt $PLAYER1_POINTS ]; then
	echo "Gracz 2 zwyciezyl"
else
	echo "Remis"
fi
