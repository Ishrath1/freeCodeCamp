#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"



MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  echo -e "\n1) cut
2) color
3) perm
4) style
5) trim"

  read SERVICE_ID_SELECTED

  # if service not available
  if [[ ! $SERVICE_ID_SELECTED =~ [1-5] ]]
  then
    # going back to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE=$($PSQL"SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
    # get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL"SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    
    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      # ask for name
      read CUSTOMER_NAME
      # add customer
      INSERT_CUSTOMER_RESULT=$($PSQL"INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME');")
    fi
    # get customer_id
    CUSTOMER_ID=$($PSQL"SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # ask time
    echo -e "\nWhat time would you like your $(echo $SERVICE | sed -r 's/^ *//g'), $CUSTOMER_NAME?"
    read SERVICE_TIME

    # add appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL"INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

    # display success message
    if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
    then
      echo -e "\nI have put you down for a $(echo $SERVICE | sed -r 's/^ *//g') at $SERVICE_TIME, $CUSTOMER_NAME."

    fi
  fi

}


MAIN_MENU "Welcome to My Salon, how can I help you?"