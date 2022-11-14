#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~ MY SALON ~~~\n"
echo -e "Welcome... How can I be of help to you?\n"
MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  # if not empty
  ALL_SERVICES=$($PSQL "SELECT * FROM services")
  echo "$ALL_SERVICES" | while read S_ID BAR NAME
  do
    echo "$S_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  # check whether theres such a service from the db
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
  #run main menu again with the message
    MAIN_MENU "I could not find that service, please select again..."
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # Customer not in db so we take name
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nWhat is your name?"
      read CUSTOMER_NAME
      INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi  
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    if [[ ! -z $INSERT_APPOINTMENT ]]
    then
      echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}
MAIN_MENU
