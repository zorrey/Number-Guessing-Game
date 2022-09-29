#!/bin/bash
#PSQL="psql --username=freecodecamp dbname=number_guess --tuples-only -c";
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN(){
#first prompt 
echo  "Enter your username:"
read USERNAME  

if [[ $1 ]]
then
  echo -e "\n$1"
fi

#random number
SECRET_NUMBER=$[$RANDOM % 1000 + 1]
#echo $NUMBER
if [[ -z $USERNAME ]]
then
  MAIN "Please enter your username OR press key '1' followed by 'enter' to exit."
else
  if [[ $USERNAME == '1' ]]
  then
    EXIT  
  else
    CHECK
  fi
fi
}

CHECK(){
  #check if username in db
  USER_NAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
  #if not in db
  if [[ -z $USER_NAME ]]
  then
     INSERT_NAME_RESULT=$($PSQL "INSERT INTO users(username ) VALUES ('$USERNAME')");
     USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
     RESPOND
  else
    #if in db retrieve games_played, best_game
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    RESPOND "1"
  fi
}

RESPOND(){
  if [[ $1 -eq '1' ]]
  then 
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID ;");
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID ;");
  #prompt existing user:Welcome back, <username>! You have played <games_played> games, and your best game took <best_game> guesses.
  echo "Welcome back, $(echo $USERNAME | sed -r 's/^ *| *$//g')! You have played $(echo $GAMES_PLAYED | sed -r 's/^ *| *$//g') games, and your best game took $(echo $BEST_GAME | sed -r 's/^ *| *$//g') guesses."  
  else
  echo "Welcome, $USERNAME! It looks like this is your first time here." 
  fi
  #prompt: Guess the secret number between 1 and 1000:
  echo "Guess the secret number between 1 and 1000:"
  #GAME_DEL=$($PSQL "DELETE FROM games WHERE guesses=0;")
  NUMBER_OF_GUESSES=0;
  flag=0;
  GUESSES
}

GUESSES(){
  while [[ $flag == 0 ]]
  do 
    #read the guess
    read GUESS
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      #if not prompt - That is not an integer, guess again:
      echo "That is not an integer, guess again:"  
    else
      #check guess if equal, less than or greater than
      #promp acocrdingly and increase 
      if [ $GUESS -eq $SECRET_NUMBER ]
      then
        flag==1;
      elif [ $GUESS -gt $SECRET_NUMBER ]
      then
        echo "It's lower than that, guess again:"
      elif [ $GUESS -lt $SECRET_NUMBER ]
      then 
        echo "It's higher than that, guess again:"
      fi
      NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
    fi    
  done
  if [[ ! $NUMBER_OF_GUESSES == 0 ]]
  then 
    NEW_GAME=$($PSQL "INSERT INTO games (guesses, user_id) VALUES ($NUMBER_OF_GUESSES, $USER_ID)")
    echo "You guessed it in $(echo $NUMBER_OF_GUESSES | sed -r 's/^ *| *$//g' ) tries. The secret number was $(echo $SECRET_NUMBER | sed -r 's/^ *| *$//g' ). Nice job!"
  else
    EXIT
  fi
}

EXIT(){
  check for games with 0 number guessess and delete them
  GAME_DEL=$($PSQL "DELETE FROM games WHERE guesses=0;")
      EMPTY_USERS=$($PSQL "SELECT user_id FROM users FULL JOIN games USING(user_id) WHERE guesses IS NULL;");
      if [[ ! -z $EMPTY_USERS ]]
      then
        echo "$EMPTY_USERS" | while read USER_ID
      do
        DEL=$($PSQL "DELETE FROM users WHERE user_id=$USER_ID;")
      done
      fi  
  echo "Bye. See you soon :)"
}

MAIN










 
