create or replace package body test_generate_customers_func as

  procedure delete_added_customers is
  begin
    delete from customers
    where name like 'custxxx%';

    commit;
  end;

  procedure before_all
    is
  begin
    delete_added_customers;
  end;

  procedure gen_all is
  begin
    ut.expect( generate_customers( 20 ) ).to_( equal(20) );
  end;

  procedure gen_to_limit is
  begin
    ut.expect( generate_customers( 30 ) ).to_( equal(23) );
  end;

  procedure over_limit is
    new_name varchar2(200);
  begin
    FOR counter IN 1 .. 30 LOOP
        new_name := 'custxxxTestOL' || counter || ' ' || CURRENT_TIMESTAMP;
        INSERT INTO customers (
        name,
        email
        ) VALUES (
        new_name,
        translate(new_name, ' ', '.') ||'@example.com'
        );
    END LOOP;

    ut.expect( generate_customers( 30 ) ).to_( equal(0) );
  end;

  procedure null_ammount is
  begin
    ut.expect( generate_customers( null ) ).to_( be_null );
  end;
end;
/
