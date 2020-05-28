create or replace package test_generate_customers_func as

  -- %suite(Between string function)

  -- %test(Generates all requested)
  procedure gen_all;

  -- %test(Generates up to the limit)
  procedure gen_to_limit;

  -- %test(Already at the limit, Generates 0)
  procedure over_limit;

  -- %test(Returns null for null input)
  procedure null_ammount;
end;
/
