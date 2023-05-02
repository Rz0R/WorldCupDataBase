#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Script to insert data from games.csv into worldcup database

echo $($PSQL "TRUNCATE games, teams RESTART IDENTITY")

function GET_TEAM_ID () {
    TEAM=$1

    # get team id
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$TEAM'")

    # if not found
    if [[ -z $TEAM_ID ]]
    then
      # insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$TEAM')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $TEAM > /dev/tty

        # get new team id
        TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$TEAM'")
      fi
    fi

    echo $TEAM_ID
}
 
cat games.csv | while IFS="," read YEAR ROUND  WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
    # get winner id
    WINNER_ID=$(GET_TEAM_ID "$WINNER")

    # get opponent id
    OPPONENT_ID=$(GET_TEAM_ID "$OPPONENT")

    # insert game
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into games, $YEAR $ROUND $WINNER-$OPPONENT" 
    fi
  fi
done