#!/bin/bash

PSQL="psql --username=postgres --dbname=periodic_table -t --no-align -c"

# ARGUMENT CHECK

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

ARG="$1"

# QUERY FOR ELEMENT

ELEMENT=$($PSQL "SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
FROM elements e
JOIN properties p USING(atomic_number)
JOIN types t ON p.type_id = t.type_id
WHERE e.atomic_number::text='$ARG' OR e.symbol='$ARG' OR e.name='$ARG'")

if [[ -z $ELEMENT ]]
then
  echo "I could not find that element in the database."
  exit 0
fi

IFS="|" read ATOMIC_NUMBER SYMBOL NAME TYPE MASS MELTING BOILING <<< "$ELEMENT"

# OUTPUT

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
