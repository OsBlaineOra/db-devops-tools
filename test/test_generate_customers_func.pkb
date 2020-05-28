create or replace package body test_generate_customers_func as

  procedure gen_all is
  begin
    ut.expect( generate_customers( 20 ) ).to_( equal(20) );
  end;

  procedure gen_to_limit is
  begin
    ut.expect( generate_customers( 20 ) ).to_( equal(5) );
  end;

  procedure over_limit is
  begin
    ut.expect( generate_customers( 20 ) ).to_( equal(0) );
  end;

  procedure null_ammount is
  begin
    ut.expect( generate_customers( null ) ).to_( be_null );
  end;

end;
/