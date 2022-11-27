PSQL='psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c'
if [[ $1 ]]
then
# check whether argument is integer to check for atomic number in the db
  if [[ "$1" =~ ^[0-9]+$ ]]
  then
    DATA=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE atomic_number=$1")
    if [[ -z $DATA ]]
    then
      echo "No such element plz"
    else 
    #get data from second table, properties
      echo $DATA | while read atm_no BAR SYMBOL BAR NAME
      do
        #echo properties into variables
        PROPERTIES=$($PSQL "SELECT typ, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties WHERE atomic_number=$1")
        echo $PROPERTIES | while read TYPE BAR ATOMIC_MASS BAR MPT BAR BPT
        do
          echo "The element with atomic number $atm_no is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MPT celsius and a boiling point of $BPT celsius."
        done
      done
    fi
  # incase input isnt atomic_number, its either name or symbol... lets check
  else
    DATA=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE symbol='$1'")
    if [[ -z $DATA ]] #if its not the symbol provided, check the name parameter
    then
      DATA=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE name='$1'")
      if [[ -z $DATA ]] # if no name found
      then
        echo "I could not find that element in the database."
      else #there is a name found
        #get data from second table, properties
        echo $DATA | while read atm_no BAR SYMBOL BAR NAME
        do
          PROPERTIES=$($PSQL "SELECT typ, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties WHERE atomic_number=$atm_no")
          if [[ -z $PROPERTIES ]]
          then
            echo "I could not find that element in the database."
          else
            #now get from first table
            echo $PROPERTIES | while read TYPE BAR ATOMIC_MASS BAR MPT BAR BPT
            do
              echo "The element with atomic number $atm_no is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MPT celsius and a boiling point of $BPT celsius."
            done
          fi
        done
      fi
    else #here we have and use symbol
      #get data from table properties
      echo $DATA | while read atm_no BAR SYMBOL BAR NAME
      do
        PROPERTIES=$($PSQL "SELECT typ, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties WHERE atomic_number=$atm_no")
        if [[ -z $PROPERTIES ]]
        then
          echo "I could not find that element in the database."
        else #finds properties of the found data variable
          #now get from elements table
          echo $PROPERTIES | while read TYPE BAR ATOMIC_MASS BAR MPT BAR BPT
          do
            echo "The element with atomic number $atm_no is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MPT celsius and a boiling point of $BPT celsius."
          done
        fi
      done
    fi
  fi
else
  echo "Please provide an element as an argument."
fi
