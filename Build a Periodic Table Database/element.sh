PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"


DISPLAY_ELEMENT(){
  # Check if argument is entered
  if [[ -z $1 ]]
  then
    echo "Please provide an element as an argument."
  else
    # Check if argument is atomic_number
    if [[ $1 =~ ^[0-9]+$ ]]
    then
      # Getting info from db
      RES=$($PSQL"SELECT atomic_number,symbol,name,type,atomic_mass,melting_point_celsius,boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE atomic_number=$1;")
    # Check if argument is name or symbol
    elif [[ $1 =~ ^[a-zA-Z]+$ ]]
    then
      # Getting info from db
      RES=$($PSQL"SELECT atomic_number,symbol,name,type,atomic_mass,melting_point_celsius,boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE symbol='$1' OR name='$1';")
    fi

    # If info not found
    if [[ -z $RES ]]
    then
      echo "I could not find that element in the database."
    else
    # Display info
      BAR=\|
      echo "$RES" | while IFS=$BAR read ATOMIC_NUMBER SYMBOL NAME TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
      do
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
      done
    fi
  fi

}

DISPLAY_ELEMENT $1