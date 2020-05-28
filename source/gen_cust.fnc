CREATE OR REPLACE FUNCTION generate_customers (amount IN NUMBER)
     RETURN NUMBER
  IS
    c_max_customers   CONSTANT INTEGER := 25;
    customer_count number;
    adjusted_amount   NUMBER := amount;
    new_name varchar2(200);

  begin
  
     IF c_max_customers > 0 THEN
        SELECT COUNT (*) INTO customer_count FROM customers;
  
        IF (customer_count + amount > c_max_customers) THEN
           adjusted_amount := c_max_customers - customer_count;
        ELSE
           adjusted_amount := amount;
        END IF;
     END IF;
  
     IF adjusted_amount > 0 THEN
  
        FOR counter IN 1 .. adjusted_amount LOOP
        new_name := 'custxxx' || counter || ' ' || CURRENT_TIMESTAMP;
          INSERT INTO customers (
              name,
              email
          ) VALUES (
              new_name,
              translate(new_name, ' ', '.') ||'@example.com'
          );
  
        COMMIT;
        END LOOP;
     ELSE
        adjusted_amount := 0;
     END IF;
  
     RETURN adjusted_amount;
  END generate_customers;
/