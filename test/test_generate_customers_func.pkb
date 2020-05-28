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
end;
/