create or replace package test_generate_customers_func as

  -- %suite(Generate Customers function)
  -- %suitepath(generate_customers)

  -- %beforeall
  procedure before_all;
  
  --%aftereach
  procedure delete_added_customers;

  -- %test(Generates all requested)
  procedure gen_all;

  -- %test(Generates up to the limit)
  procedure gen_to_limit;

  -- %test(Already at the limit, Generates 0)
  procedure over_limit;

  -- %test(Returns null for null input)
  procedure null_ammount;

  -- %test(Throws numeric or value error for non numeric input)  
  --%throws(-06502)
  procedure alpha_in;
end;
/
