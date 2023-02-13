#!/bin/bash

echo -e "\n~~Number Guessing Game~~\n"

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN_MENU(){
  echo -e "\nEnter your username:"
  read USERNAME 

  NUMBER_OF_GUESSES=0

  if [ "${#USERNAME}" -lt 23 ] && ! [ -z $USERNAME ]
  then 
    RANDOM_NUMBER=$(($RANDOM%1000))
    
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")

    if ! [[ -z $USER_ID ]]
    then
    EXISTING_USER 
    else
    NEW_USER 
    fi
  else
    echo "Value is too long"
  fi

}
EXISTING_USER(){
GAMES_PLAYED=$($PSQL "SELECT games_played FROM game_story WHERE user_id='$USER_ID';")
BEST_GAME=$($PSQL "SELECT best_score FROM game_story WHERE user_id='$USER_ID';")

echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
THE_GAME "Guess the secret number between 1 and 1000:"
}
NEW_USER(){
  GAMES_PLAYED=0
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
  THE_GAME "Guess the secret number between 1 and 1000:"
}
THE_GAME(){
  if ! [[ -z $1 ]]
  then
  echo -e "\n$1\n"
  fi
  read GUESSED_NUMBER
   ((NUMBER_OF_GUESSES++))

  if [[ $GUESSED_NUMBER =~ ^-?[0-9]+$ ]]
  then

    if [[ $GUESSED_NUMBER -lt $RANDOM_NUMBER ]]
    then
      echo -e "\nIt's higher than that, guess again:\n"
      THE_GAME
    elif [[ $GUESSED_NUMBER -gt $RANDOM_NUMBER ]]
    then
      echo -e "\nIt's lower than that, guess again:\n"
      THE_GAME
    else
      END_GAME
    fi
  else
  echo -e "\nThat is not an integer, guess again:\n"
  THE_GAME
  fi
}

END_GAME(){
  if ! [[ -z $USER_ID ]]
  then
    if [[ $BEST_GAME -gt $NUMBER_OF_GUESSES ]]
    then 
      UPDATE_BEST_SCORE=$($PSQL "UPDATE game_story SET best_score = $NUMBER_OF_GUESSES WHERE user_id = $USER_ID;")
    fi
    ((GAMES_PLAYED++))
    UPDATE_GAMES_PLAYED=$($PSQL "UPDATE game_story SET games_played=$GAMES_PLAYED WHERE user_id='$USER_ID';")
  else
    INSERT_NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
    ISERT_USERID_GAMES_PLAYED=$($PSQL "INSERT INTO game_story(user_id, games_played) VALUES($USER_ID, 1);")
    UPDATE_BEST_SCORE=$($PSQL "UPDATE game_story SET best_score='$NUMBER_OF_GUESSES' WHERE user_id='$USER_ID';")
  fi

  echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!\n"
}

MAIN_MENU