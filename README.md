# code description:

  ### This SQL project creates a database schema for managing an airport. It includes various tables, triggers, procedures, functions, and views. The code also inserts rows into the tables to populate them with initial data.
  
  ## The project creates the following tables:
  ### AirLines_tbl:
  Stores information about airlines, including their unique codes and names.
  ### Planes_tbl:
  Stores information about planes, including their unique codes, associated airline codes, and the number of seats they have.
  ### Destinations_tbl:
  Stores information about destinations, including their unique codes and names.
  ### Flights_tbl:
  Stores information about flights, including their unique codes, associated plane codes, destination codes, ticket prices, flight dates, and continuation flight codes.
  ### Passengers_tbl:
  Stores information about passengers, including their unique codes, first names, last names, and phone numbers.
  ### OrderTicket_tbl:
  Stores information about order tickets, including their unique codes, associated flight codes, passenger codes, order dates, and seat numbers.
  
  - A **trigger** that enforces seat availability constraints.
  - A **trigger** that enforces that orders are placed before the flight date.
  - A **procedure** that inserts a new passanger into the passengers table.
  - A **procedure** that updates a flight's date to a new provided date.
  - A **function** that finds connecting flights and calculates their price with a 10% discount.
  - A **function** that returns the number of passengers for a given flight code.
  - A **function** that selects randomly a passenger from among all passengers whose phone number prefix belongs to a certain company and calculates the price of his flight ticket with a discount.
  - A **view** that combines data from multiple tables to provide detailed information about flights and passengers.
  - A **view** that calculates the size of each airline company based on the number of planes they have.

## Instructions for Running the Code
  To run the SQL code on your computer:
  1. Install a compatible Relational Database Management System (RDBMS) such as Microsoft SQL Server.
  2. Execute the SQL statements.
