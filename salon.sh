#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
trim() {
  echo "$1" | xargs
}


echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "\nWelcome to My Salon, how can I help you?"


MAIN_MENU(){
  if [[ $1 ]]
  then 
   echo -e "\n$1"
  fi

  SERVICE_SELECTION=$($PSQL "SELECT * FROM services;")
  
  echo "$SERVICE_SELECTION" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME service"
  done
  read SERVICE_ID_SELECTED

  SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
  if [[ -z $SERVICE_AVAILABILITY ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
    return
  fi

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$(trim "$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")")
  if [[ -z $CUSTOMER_NAME ]]
  then 
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')" > /dev/null 
  fi

  SELECTED_SERVICE_NAME=$(trim "$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")")
  echo -e "\nWhat time would you like your $SELECTED_SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  CUSTOMER_ID=$(trim "$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")")

  $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')"

  echo -e "\nI have put you down for a $SELECTED_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}
MAIN_MENU










 
