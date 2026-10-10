#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only"

echo "~~~~~ MY SALON ~~~~~"
echo
echo "Welcome to My Salon, how can I help you?"
echo

show_services() {
  $PSQL -c "SELECT service_id || ') ' || name FROM services ORDER BY service_id;"
}

show_services
read SERVICE_ID_SELECTED

while ! [[ "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]] || [[ -z $($PSQL -c "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;") ]]; do
  echo
  echo "I could not find that service. What would you like today?"
  show_services
  read SERVICE_ID_SELECTED
done

SERVICE_NAME=$($PSQL -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

echo
echo "What's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL -v phone="$CUSTOMER_PHONE" <<'SQL'
SELECT name FROM customers WHERE phone = :'phone';
SQL
)

if [[ -z "$CUSTOMER_NAME" ]]; then
  echo
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  $PSQL -v name="$CUSTOMER_NAME" -v phone="$CUSTOMER_PHONE" <<'SQL'
INSERT INTO customers(name, phone) VALUES (:'name', :'phone');
SQL
fi

CUSTOMER_ID=$($PSQL -v phone="$CUSTOMER_PHONE" <<'SQL'
SELECT customer_id FROM customers WHERE phone = :'phone';
SQL
)

echo
echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

$PSQL -v customer_id="$CUSTOMER_ID" -v service_id="$SERVICE_ID_SELECTED" -v time="$SERVICE_TIME" -v time_value="$SERVICE_TIME" <<'SQL'
INSERT INTO appointments(customer_id, service_id, time) VALUES (:'customer_id', :'service_id', :'time_value');
SQL

echo
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."