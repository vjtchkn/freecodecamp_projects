#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Remove all data from the database
echo $($PSQL "TRUNCATE teams, games")

# Inserting into teams and games tables
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Condition on not being the first line with names
  if [[ $YEAR != 'year' ]]
  then
    # Try to get winner and opponent team_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Add winner to teams if not already in table, get new team_id
    if [[ -z $WINNER_ID ]]
    then
      IRW=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      echo Insert into teams, $WINNER
    fi

    # Add opponent to teams if not already in table, get new team_id
    if [[ -z $OPPONENT_ID ]]
    then
      IRO=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      echo Insert into teams, $OPPONENT
    fi

    # Add all game info to game table
    IRG=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
    VALUES ('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')")
    echo Insert into games, $YEAR $ROUND
  fi
done
