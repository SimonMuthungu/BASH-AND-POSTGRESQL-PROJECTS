#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
$($PSQL "TRUNCATE games, teams")
echo Truncated!
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WG OG
do
if [[ $WINNER != "winner" ]]
then
  W_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  if [[ -z $W_ID ]]
  then
    INSERT_INTO=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    if [[ $INSERT_INTO == "INSERT 0 1" ]]
    then
      echo inserted: $WINNER
    fi
  fi
fi
done

echo done with first, going to second
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WG OG
do
if [[ $OPPONENT != "opponent" ]]
then
  O_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  if [[ -z $O_ID ]] 
  then 
    INSERT_O=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    if INSERT_O="INSERT 0 1"
    then
      echo "Inserted also '$OPPONENT'"
    fi
  fi
fi
done

echo Beggining the games table...

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WG OG
do
if [[ $YEAR != "year" ]]
then
WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
O_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  INSERT_ALL=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', '$WINNER_ID', '$O_ID', '$WG', '$OG')")
  if [[ $INSERT_ALL == "INSERT 0 1" ]]
  then 
    echo "Inserted game into db"
  fi
fi
done
