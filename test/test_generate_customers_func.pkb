create or replace package body test_generate_customers_func as

  procedure delete_added_customers is
  begin
    delete from customers
    where name like 'custxxx%';
  end;

 procedure always_pass is
    l_is_true boolean := true;
  begin
    ut.expect( l_is_true ).to_be_true();
  end;


end;
/