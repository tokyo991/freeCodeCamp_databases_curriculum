#!/bin/bash

PSQL="psql --username=postgres --dbname=number_guess -t --no-align -c"

# Generate random number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

# Check if user exists
USER_INFO=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  # New user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  USER_ID=$USER_INFO

  # Get stats
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Start game
echo "Guess the secret number between 1 and 1000:"
read GUESS

NUMBER_OF_GUESSES=0

while true
do
  ((NUMBER_OF_GUESSES++))

  # Check if input is integer
  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
    continue
  fi

  if (( GUESS > SECRET_NUMBER ))
  then
    echo "It's lower than that, guess again:"
    read GUESS
  elif (( GUESS < SECRET_NUMBER ))
  then
    echo "It's higher than that, guess again:"
    read GUESS
  else
    # Correct guess
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

    # Save game
    INSERT_GAME=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
    break
  fi
done
