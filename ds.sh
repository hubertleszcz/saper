# Author           : HUbert Leszczynski ( 193552 )
# Created On       : 25.04.2023
# Last Modified By : Hubert Leszczynski
# Last Modified On : 16.05.2023
# Version          : alpha 0.0.2
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
BOMBS=10
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
		bomb_location=$(shuf -i 0-100 -n 1)
		FIELD[$bomb_location]=2
	done
}
print_field() {
	INDEX=0
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

move_input(){
    echo "Podaj wiersz: "
    read POS_Y
    echo "Podaj kolumne: "
    read POS_X
}

find_adjacent_bombs(){
	COUNT_BOMBS=0
	HELPER=$SIZE-1
	if [ $POS_X -ne 0 ]; then
		TMPX=$POS_X-1
		if [ "${FIELD[$POS_Y*$SIZE+$TMPX]}" -eq 2 ]; then
			((COUNT_BOMBS+=1))
		fi
		if [ $POS_Y -ne 0 ]; then
			TMPY=$POS_Y-1
			if [ "${FIELD[$TMPY*$SIZE+$TMPX]}" -eq 2 ]; then
				((COUNT_BOMBS+=1))
			fi
		fi
		if [ $POS_Y -ne $HELPER ]; then
			TMPY=$POS_Y+1
			if [ "${FIELD[$TMPY*$SIZE+$TMPX]}" -eq 2 ]; then
				((COUNT_BOMBS+=1))
			fi
		fi
	fi
	if [ $POS_X -ne $HELPER ]; then
		TMPX=$POS_X+1
		if [ "${FIELD[$POS_Y*$SIZE+$TMPX]}" -eq 2 ]; then
			((COUNT_BOMBS+=1))
		fi
		if [ $POS_Y -ne 0 ]; then
			TMPY=$POS_Y-1
			if [ "${FIELD[$TMPY*$SIZE+$TMPX]}" -eq 2 ]; then
				((COUNT_BOMBS+=1))
			fi
		fi
		if [ $POS_Y -ne $HELPER ]; then
			TMPY=$POS_Y+1
			if [ "${FIELD[$TMPY*$SIZE+$TMPX]}" -eq 2 ]; then
				((COUNT_BOMBS+=1))
			fi
		fi
	fi
	if [ $POS_Y -ne 0 ]; then
		TMPY=$POS_Y-1
		if [ "${FIELD[$TMPY*$SIZE+$POS_X]}" -eq 2 ]; then
			((COUNT_BOMBS+=1))
		fi
	fi
	if [ $POS_Y -ne $HELPER ]; then
		TMPY=$POS_Y+1
		if [ "${FIELD[$TMPY*$SIZE+$POS_X]}" -eq 2 ]; then
			((COUNT_BOMBS+=1))
		fi
	fi
	FIELD_WITH_FOG[$POS_Y*$SIZE+$POS_X]="$COUNT_BOMBS "
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
	        move_input
		if [ "${FIELD[$POS_Y*$SIZE+$POS_X]}" -eq 2 ]; then
			echo "BOOM"
			ONGOING=0	 
		else
			if [ $CURRENT_PLAYER -eq 1 ]; then
				((PLAYER1_POINTS+=1))
			else	
				((PLAYER2_POINTS+=1))
			fi
			find_adjacent_bombs
		fi
	elif [ $MOVE_TYPE -eq 2 ]; then
	    move_input
	    if [ "${FIELD[$POS_Y*$SIZE+$POS_X]}" -eq 2 ]; then
		echo "Bomba rozbrojona!. 2 punkty!"
		if [ $CURRENT_PLAYER -eq 1]; then
			((PLAYER1_POINTS+=2))
		else
			((PLAYER2_POINTS+=2))
		fi
	    else
		echo "Puste pole! Tracisz 1 punkt"
		if [ $CURRENT_PLAYER -eq 1 ]; then
			((PLAYER1_POINTS-=1))
		else
			((PLAYER2_POINTS-=1))
		fi
	  FIELD[$POS_Y*$SIZE+$POS_X]=3
	  fi
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
