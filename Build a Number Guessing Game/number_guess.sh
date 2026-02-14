#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
BAR=\|

# Asking for username
echo "Enter your username:"
read USERNAME

USERNAME_INFO=$($PSQL"SELECT username, games_played, best_game FROM users WHERE username='$USERNAME';")

if [[ -z $USERNAME_INFO ]]
then
  INSERT_USERNAME_RESULT=$($PSQL"INSERT INTO users(username,games_played,best_game) VALUES('$USERNAME',0,0);")
  if [[ $INSERT_USERNAME_RESULT == "INSERT 0 1" ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  fi
else
  echo "$USERNAME_INFO" | while IFS=$BAR read USERNAME GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# Game loop
NUMBER=$(($RANDOM%(1000)+1))
echo "Guess the secret number between 1 and 1000:"
read GUESS
COUNT=1
echo $NUMBER

if [[ $GUESS =~ ^[0-9]*$ ]]
then
  while [ $GUESS -ne $NUMBER ]
  do
    if [[ $GUESS > $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
    read GUESS
    ((COUNT++))
  done
else
  echo "That is not an integer, guess again:"
  read GUESS
fi

echo "You guessed it in $COUNT tries. The secret number was $NUMBER. Nice job!"

# update db

BEST_GAME=$($PSQL"SELECT best_game FROM users WHERE username='$USERNAME';")

if [[ $BEST_GAME == 0 || $BEST_GAME > $COUNT ]]
then
  UPDATE_BEST_GAME=$($PSQL"UPDATE users SET best_game = $COUNT WHERE username = '$USERNAME';")
fi

UPDATE_GAMES_PLAYED=$($PSQL"UPDATE users SET games_played=games_played + 1 WHERE username = '$USERNAME';")

