create or replace package body test_generate_customers_func as

  procedure normal_case is
  begin
    ut.expect( generate_customers( 20 ) ).to_( equal(20) );
  end;

  procedure zero_start_position is
  begin
    ut.expect( generate_customers( 20 ) ).to_( equal(5) );
  end;

  procedure big_end_position is
  begin
    ut.expect( generate_customers( 20 ) ).to_( equal(0) );
  end;

  procedure null_string is
  begin
    ut.expect( generate_customers( null, 2, 5 ) ).to_( be_null );
  end;

end;
/