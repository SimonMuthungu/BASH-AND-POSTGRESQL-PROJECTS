#!/bin/bash
#connecting to the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER_OF_GUESSES=0
SECRET_NUMBER=$((($RANDOM%1000)))
#asks fo username and checks db
echo  "Enter your username:"
read USERNAME
# checks whether username in db
USER_AVAILABLE=$($PSQL "SELECT username, games_played, best_game FROM number_game WHERE username='$USERNAME'")
# if username not in database, it adds them with initial values
if [[ -z $USER_AVAILABLE ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  ADD_USER=$($PSQL "INSERT INTO number_game(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
else #if user is available it prints the welcome message
  echo $USER_AVAILABLE | while IFS="|" read USER GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

echo "for testing, random number is: $SECRET_NUMBER"
echo "Guess the secret number between 1 and 1000:"
read USER_GUESS

if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
then
  echo "That is not an integer, guess again:"
    NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
    read USER_GUESS
fi

while [[ $USER_GUESS -ne $SECRET_NUMBER ]]
do
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
      NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
      read USER_GUESS
  elif [[ $USER_GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
    read USER_GUESS
  elif [[ $USER_GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
    read USER_GUESS
  fi
done

if [[ $USER_GUESS -eq $SECRET_NUMBER ]] 
then
NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  
  CHECK_USER=$($PSQL "SELECT username, games_played, best_game FROM number_game WHERE username='$USERNAME'")
  echo $CHECK_USER | while IFS="|" read USER GAMES_PLAYED BEST_GAME
  do
  GAMES_PLAYED=$(($GAMES_PLAYED+1))
  echo "Games played: $GAMES_PLAYED"
  if [[ $GAMES_PLAYED -eq 1 ]]
  then
    #update with NUMBER_OF_GUESSES
    INS_NUMBER_OF_GUESSES=$($PSQL "UPDATE number_game SET best_game=$NUMBER_OF_GUESSES WHERE username='$USER'")
    echo $INS_NUMBER_OF_GUESSES
  else
    if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
    then
      INS=$($PSQL "UPDATE number_game SET best_game=$NUMBER_OF_GUESSES WHERE username='$USER'")
      echo $INS
    fi
  fi
  INSERT=$($PSQL "UPDATE number_game SET games_played=$GAMES_PLAYED WHERE username='$USER'")
  echo $INSERT
  done
fi
