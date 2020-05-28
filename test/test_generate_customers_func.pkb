create or replace package body test_generate_customers_func as

  procedure delete_added_customers is
  begin
    delete from customers
    where name like 'custxxx%';
  end;


end;
/