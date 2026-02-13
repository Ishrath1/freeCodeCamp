#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL"TRUNCATE teams,games;")

# Reading year,round,winner,opponent,winner_goals,opponent_goals from file
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skipping first line
  if [[ $WINNER != winner ]]
  then
    # Get winner_id
    WINNER_ID=$($PSQL"SELECT team_id FROM teams WHERE name='$WINNER';")
    
    # If not found
    if [[ -z $WINNER_ID ]]
    then
      # Insert new team
      INSERT_WINNER_TEAM_RESULT=$($PSQL"INSERT INTO teams(name) VALUES('$WINNER');")

      # Checking if it worked
      if [[ $INSERT_WINNER_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted team $WINNER
      fi
      # Get new winner_id
      WINNER_ID=$($PSQL"SELECT team_id FROM teams WHERE name='$WINNER';")
    fi
  fi

  # Skipping first line
  if [[ $OPPONENT != opponent ]]
  then
    # Get opponent_id
    OPPONENT_ID=$($PSQL"SELECT team_id FROM teams WHERE name='$OPPONENT';")
    
    # If not found
    if [[ -z $OPPONENT_ID ]]
    then
      # Insert new team
      INSERT_OPPONENT_TEAM_RESULT=$($PSQL"INSERT INTO teams(name) VALUES('$OPPONENT');")
      
      # Checking if it worked
      if [[ $INSERT_OPPONENT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted team $OPPONENT
      fi
      # Get new opponent_id
      OPPONENT_ID=$($PSQL"SELECT team_id FROM teams WHERE name='$OPPONENT';")
    fi
  fi

  if [[ $YEAR != year && $ROUND != round && $WINNER_GOALS != winner_goals && $OPPONENT_GOALS != opponent_goals ]]
  then
    # Get game_id
    GAME_ID=$($PSQL"SELECT game_id FROM games WHERE year=$YEAR AND round='$ROUND' AND winner_id=$WINNER_ID AND opponent_id=$OPPONENT_ID;")
    # If not found 
    if [[ -z $GAME_ID ]]
    then
      # Insert new game
      INSERT_GAME_RESULT=$($PSQL"INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS);")

      # Checking ...
      if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted game $YEAR $ROUND $WINNER $OPPONENT $WINNER_GOALS $OPPONENT_GOALS
      fi
      # Get new game_id
      GAME_ID=$($PSQL"SELECT game_id FROM games WHERE year=$YEAR AND round='$ROUND' AND winner_id=$WINNER_ID AND opponent_id=$OPPONENT_ID;") 
    fi
  fi

done