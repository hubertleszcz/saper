# Author           : HUbert Leszczynski ( 193552 )
# Created On       : 25.04.2023
# Last Modified By : Hubert Leszczynski
# Last Modified On : 29.05.2023
# Version          : 1.0.0
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

#tablica niewidoczna dla gracza. Są na niej pokazane bomby
FIELD=()
#tablica widoczna podczas rozgrywki
FIELD_WITH_FOG=()

CURRENT_BOMBS=0

function field_creator {
	rozmiar=SIZE*SIZE
	for (( i=0; i<rozmiar; i++ ))
	do
		FIELD[$i]=1
		FIELD_WITH_FOG[$i]=". "
	done

	for (( i=0; i<BOMBS; i++ ))
	do
		bomb_location=$(shuf -i 0-$((SIZE*SIZE)) -n 1)
		if [ "${FIELD[$bomb_location]}" -eq 1 ]; then
			FIELD[$bomb_location]=2
			((CURRENT_BOMBS++))
		fi
	done
}

#wprowadzanie koordynatow docelowych ruchu gracza
move_input(){
    while true; do
    	POS_Y=$(zenity --entry --title "Saper" --text "Podaj wiersz(od 0 do $((SIZE-1))): ")
	#sprawdzenie poprawności danych
    	if [[ $POS_Y =~ ^[0-9]+$ && $POS_Y -le $SIZE ]]; then
    		break
    	else
    		zenity --info --title "Saper" --text "Złe dane. Podaj jeszcze raz."
    	fi
    done
    while true; do
    	POS_X=$(zenity --entry --title "Saper" --text "Podaj kolumne(od 0 do $((SIZE-1))): ")
	#sprawdzenie poprawności danych
    	if [[ $POS_X =~ ^[0-9]+$ && $POS_X -le $SIZE ]]; then
    		break
    	else
    		zenity --info --title "Saper" --text "Złe dane. Podaj jeszcze raz."
    	fi
    done
}

find_adjacent_bombs(){
	COUNT_BOMBS=0
	HELPER=$((SIZE-1))
	#sprawdzenie z lewej strony
	if [ $POS_X -ne 0 ]; then
		TMPX=$((POS_X-1))
		if [ "${FIELD[$POS_Y*$SIZE+$TMPX]}" -eq 2 ]; then
			((COUNT_BOMBS+=1))
		fi
		
		if [ $POS_Y -ne 0 ]; then
			TMPY=$((POS_Y-1))
			
			if [ "${FIELD[$TMPY*$SIZE+$TMPX]}" -eq 2 ]; then
				((COUNT_BOMBS+=1))
			fi
		fi
		
		if [ $POS_Y -ne $HELPER ]; then
			TMPY=$((POS_Y+1))
			
			if [ "${FIELD[$TMPY*$SIZE+$TMPX]}" -eq 2 ]; then
				((COUNT_BOMBS+=1))
			fi
		fi
	fi
	#sprawdzenie z prawej strony
	if [ $POS_X -ne $HELPER ]; then
		TMPX=$((POS_X+1))
		
		if [ "${FIELD[$POS_Y*$SIZE+$TMPX]}" -eq 2 ]; then
			((COUNT_BOMBS+=1))
		fi
		
		if [ $POS_Y -ne 0 ]; then
			TMPY=$((POS_Y-1))
			if [ "${FIELD[$TMPY*$SIZE+$TMPX]}" -eq 2 ]; then
				((COUNT_BOMBS+=1))
			fi
		fi
		
		if [ $POS_Y -ne $HELPER ]; then
			TMPY=$((POS_Y+1))
			if [ "${FIELD[$TMPY*$SIZE+$TMPX]}" -eq 2 ]; then
				((COUNT_BOMBS+=1))
			fi
		fi
	fi
		
	#sprawdzenie z góry	
	if [ $POS_Y -ne 0 ]; then
		TMPY=$((POS_Y-1))
		
		if [ "${FIELD[$TMPY*$SIZE+$POS_X]}" -eq 2 ]; then
			((COUNT_BOMBS+=1))
		fi
	fi
	
	#sprawdzenie z dołu
	if [ $POS_Y -ne $HELPER ]; then
		TMPY=$((POS_Y+1))
		
		if [ "${FIELD[$TMPY*$SIZE+$POS_X]}" -eq 2 ]; then
			((COUNT_BOMBS+=1))
		fi
	fi
	
	FIELD_WITH_FOG[$POS_Y*$SIZE+$POS_X]="$COUNT_BOMBS"
	FIELD[$POS_Y*$SIZE+$POS_X]=3
}

#wypisanie pola gry
function display(){
	zen_output=""
	for ((i=0; i<SIZE; i++))
	do
		for((j=0; j<SIZE; j++))
		do
			index=$((i*SIZE+j))
			zen_output+=" ${FIELD_WITH_FOG[index]} "
		done
		zen_output+="\n"
	done
	zenity --info --title "Saper" --text "$zen_output \n Player 1 : $PLAYER1_POINTS  Player 2 : $PLAYER2_POINTS"	
}

show_help(){
	echo "Gra w sapera na dwie osoby. Każdy gracz w swojej rundzie może wykonać ruch. Najpierw musi wybrać typ ruchu.1- sprawdzenie pojedynczego pola. Gdy nie ma na nim bomby otrzymuje punkt, a na planszy pojawia się ilosc bomb w okolicy. 2-rozbrojenie danego pola. Gdy na polu jest bomba, otrzymuje sie 2 punkty, a gdy nie ma bomby - traci 1 punkt. W drugim przypadku pokazuje rowniez ilosc bomb w okolicy. 3- wyjście."
}

show_info(){
	echo "Autor: Hubert Leszczyński Wersja: 1.0.0"
}

#sprawdzenie parametrów -h lub -v
while getopts "hv" option; do
	case $option in
		h) 
			show_help
			exit;;
		v)
			show_info
			exit;;
		*)
			echo "Błędny parametr"
			exit;;
	esac
done

#parametr oznaczajacy ilosc bomb
if [ -z "$1" ]; then
	BOMBS=10
elif  [[ $1 =~ ^[0-9]+$ ]]; then
	if [ $1 -gt 1 ]; then
		BOMBS=$1
	else
		zenity --info --title "Saper" --text "Nie mozna miec mniej niz 1 bomb. Ustawiono jedną"
		BOMBS=1
	fi
fi

#parametr oznaczający rozmiar planszy
if [ -z "$2" ]; then
	SIZE=10
elif  [[ $1 =~ ^[0-9]+$ ]]; then
	if [ $2 -gt 30 ]; then
		zenity --info --title "Saper" --text "Za duze pole. Ustawiono rozmiar na 10"
		SIZE=10
	elif [ $2 -lt 4 ]; then
		zenity --info --title "Saper" --text "Za male pole. Ustawiono rozmiar na 10"
		SIZE=10
	else
		SIZE=$2
	fi
fi

#wykluczenie nieprawidłowej ilości bomb na planszy
if [ $BOMBS -ge $((SIZE*SIZE)) ]; then
	zenity --info --title "Saper" --text "Za duzo bomb. Ustawiono bomby na 10"
	BOMBS=10
fi

field_creator

#główna pętla gry
while [ $ONGOING -ne 0 ]; do

	#zmiana gracza
	if [ $CURRENT_PLAYER -ne 1 ]; then
		CURRENT_PLAYER=1
	elif [ $CURRENT_PLAYER -ne 2 ]; then
		CURRENT_PLAYER=2
	fi
	
	while true; do
		display
		
		MOVE_TYPE=$(zenity --entry --title "Saper" --text "Podaj typ ruchu: 1 to sprawdzenie, 2 to rozbrojenie, a 3 to zakonczenie rozgrywki:  ")
		if [[ $MOVE_TYPE =~ ^[0-9]+$ && $MOVE_TYPE -le 3 && $MOVE_TYPE -ge 1 ]]; then
			break
		else
			zenity --info --title "Saper" --text "Bledne dane"
		fi 
	done
	
	if [ $MOVE_TYPE -eq 3 ]; then
		ONGOING=0
		
	elif [ $MOVE_TYPE -eq 1 ]; then
	        move_input
		
		if [ "${FIELD[$POS_Y*$SIZE+$POS_X]}" -eq 2 ]; then
			#znalezienie bomby
			zenity --info --title "Saper" --text "BOOOOOOM"
			if [ $CURRENT_PLAYER -eq 1 ]; then
				PLAYER1_POINTS=0
			elif [ $CURRENT_PLAYER -eq 2 ]; then
				PLAYER2_POINTS=0
			fi 
			ONGOING=0	
		
		elif [ "${FIELD[$POS_Y*$SIZE+$POS_X]}" -eq 3 ]; then
			zenity --info --title "Saper" --text "Pole wczesniej odkryte. Tracisz ruch" 
		
		else
			#pole bez bomby
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
		#rozbrojenie bomby
		zenity --info --title "Saper" --text "I po bombie! Dostajesz 2 punkty"
		
		if [ $CURRENT_PLAYER -eq 1 ]; then
			((PLAYER1_POINTS+=2))
		
		else
			((PLAYER2_POINTS+=2))
		fi
		
		((CURRENT_BOMBS--))
		FIELD_WITH_FOG[$POS_Y*$SIZE+$POS_X]="V"
		FIELD[$POS_Y*$SIZE+$POS_X]=3
	    
	    elif [ "${FIELD[$POS_Y*$SIZE+$POS_X]}" -eq 3 ]; then
			zenity --info --title "Saper" --text "Pole wczesniej odkryte. Tracisz ruch" 
			
	    else
	    	#rozbrojenie pustego pola
	    	zenity --info --title "Saper" --text "Puste pole! Tracisz 1 punkt"
		if [ $CURRENT_PLAYER -eq 1 ]; then
			((PLAYER1_POINTS-=1))
		else
			((PLAYER2_POINTS-=1))
		fi
		
	  	find_adjacent_bombs
		FIELD[$POS_Y*$SIZE+$POS_X]=3
		
	  fi
	  
	else
		zenity --info --title "Saper" --text "Błędny ruch!"
	fi
	#zakonczenie rozgrywki przy braku bomb na planszy
	if [ $CURRENT_BOMBS -eq 0 ]; then
		zenity --info --title "Saper" --text "Koniec bomb!"
		ONGOING=0
	fi
done

#wynik końcowy
if [ $PLAYER1_POINTS -gt $PLAYER2_POINTS ]; then
	zenity --info --title "Saper" --text "Gracz 1 wygrał!"	
	
elif [ $PLAYER2_POINTS -gt $PLAYER1_POINTS ]; then
	zenity --info --title "Saper" --text "Gracz 2 wygrał!"
	
else
	zenity --info --title "Saper" --text "Remis!"
fi
