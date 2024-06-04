#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

DISPLAY_SERVICES() {
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "Please select a service:"
  while read -r SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done <<< "$AVAILABLE_SERVICES"
}

GET_SERVICE_SELECTION() {
  while true; do
    DISPLAY_SERVICES
    read SERVICE_ID_SELECTED

    # Check if input is a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
      echo -e "\nInvalid input. Please enter a number.\n"
      continue
    fi

    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    # If the service ID is invalid
    if [[ -z $SERVICE_NAME_SELECTED ]]; then
      echo -e "\nInvalid service ID. Please try again.\n"
    # if the service ID is valid
    else
      echo -e "\nYou selected $SERVICE_NAME_SELECTED."
      
      # ask phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_ID_RESULT=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_ID_RESULT ]]
        then # ask for name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        # put name + phone in customer table
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')") 
        CUSTOMER_ID_RESULT=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        fi
      # ask for time appointment  
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID_RESULT")
      echo -e "What time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
      read SERVICE_TIME
     
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID_RESULT, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
   
      SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME_SELECTED | sed -E 's/^ *| *$//g')
      CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')
      echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
      break
    fi
  done
}

MAIN_MENU() {
  GET_SERVICE_SELECTION
}

MAIN_MENU

