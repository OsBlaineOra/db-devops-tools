# utPLSQL
# ? SETUP ?
## Test package
For this exersice you will be creating a package of tests to test the generate_customers function.

Review the function
```
cat source/gen_cust.fnc
```

Review the test package specification
```
cat test/test_generate_customers_func.pks
```

utPLSQL uses annotaions to define the unit tests.
```-- %suite(Generate Customers function)``` declares that this is a test suite named "Generate Customers function"  

```-- %suitepath(generate_customers)``` is used to define the path to the unit being tested.  In this case it is a single stored function "generate_customers".  If you were testing a function inside of a package you could declare the path all the way from the schema to the function ```-- %suitepath(my_schema.the_package.a_function)```.  Use a path definition that makes sense for your project.  

The function that you will be testing inserts data and executes a commit.  You will need to manually rollback the test data and use ```-- %rollback(manual)``` so that utPLSQL will not attempt to control the rollbacks.  

A fake test that always passes has been included.
```
  -- %test(Fake Test)
  procedure always_pass;
```
The ```-- %test(<Test Name>)``` annotation declares that the following procedure is a test.

Review the test package body
```
cat test/test_generate_customers_func.pkb
```

A helper procedure is included "delete_added_customers" that you will call to clean up the generated customers.
```
procedure delete_added_customers is
  begin
    delete from customers
    where name like 'custxxx%';

    commit;
  end;
```

The fake test procedure creates a boolean variable set to true and tests to see if it's true.  This will always pass.
```
 procedure always_pass is
    l_is_true boolean := true;
  begin
    ut.expect( l_is_true ).to_be_true();
  end;
```

## Test Coverage
http://utplsql.org/utPLSQL/v3.0.4/userguide/coverage.html

In your Jenkins project page, look under "Last Successful Artifacts" and click on "coverage.html".  (It may not be pretty since it's being served from the Jenkins page.)  
Currently is should say "All files (0% lines covered at 0 hits/line)" since there is a function defined in the schema and none of the tests cover it.

This HTML report is genereated when Jenkins runs the "Execute shell" step with the following command.
```
DB_URL="demos_tp"

utPLSQL-cli/bin/utplsql run ${username}/${password}@${DB_URL}?TNS_ADMIN=/opt/oracle/wallet \
-f=ut_coverage_html_reporter  -o=coverage.html \
-f=ut_xunit_reporter -o=xunit_test_results.xml
```

There are other coverage reporters available such as a "Sonar Reporter" for example.
```
-f=ut_coverage_sonar_reporter -o=coverage.xml \
```
If you're using Sonar, you would need to include and setup the Sonar plugin for Jenkins.  That is beyond the scope of this lab.

## Create a real test
Edit the package spec
```
nano test/test_generate_customers_func.pks
```
Replace the lines
```
  -- %test(Fake Test)
  procedure always_pass;
```
With the following
```
  -- %test(Generates all requested)
  procedure gen_all;
```

Edit the package body
```
nano test/test_generate_customers_func.pkb
```
Replace the lines
```
 procedure always_pass is
    l_is_true boolean := true;
  begin
    ut.expect( l_is_true ).to_be_true();
  end;
```
With the following
```
  procedure gen_all is
  begin
    ut.expect( generate_customers( 20 ) ).to_( equal(20) );
  end;
```
In this test you are telling utPLSQL (ut) to expect that when you call the generate_customers function passing in 20 that it will return 20.

1. Run manually
1. Git push
1. Check results
1. Check coverage
1. Query customers
    ```
    select * from hol_prod.customers;
    ```
1. Run again in Jenkins. Test Fails because the previous test data is still there.

### Before All

Edit the package spec
```
nano test/test_generate_customers_func.pks
```
Add the following between the ```-- %rollback(manual)``` and ```-- %test(Generates all requested)``` lines
```
  -- %beforeall
  procedure before_all;
```
Edit the package body
```
nano test/test_generate_customers_func.pkb
```
Add the following before the line ```procedure gen_all is```
```
  procedure before_all
    is
  begin
    delete_added_customers;
  end;
```

1. Git push
1. Check results
   This time it passed because the before_all setup procedure sets up the environment so that it only contains the two "test" records created by the liquibase insert step.
1. Check coverage
    The coverage should now be at 80%.

### Add a test for requesting more than the limit.
Edit the package spec
```
nano test/test_generate_customers_func.pks
```
Add the following after the line  ```  procedure gen_all;```
```
  -- %test(Generates up to the limit)
  procedure gen_to_limit;
```
Edit the package body
```
nano test/test_generate_customers_func.pkb
```
Add the following before the end of the package
```
  procedure gen_to_limit is
  begin
    ut.expect( generate_customers( 30 ) ).to_( equal(23) );
  end;
```

1. Git add/commit/push
1. Check results
   The new test fails.  3 new customers were created but it was expecting 23.  This is because the data was not cleaned up after the previous test.  
   The before_all setup procedure is only run once before all tests run.

### After each
1. Add the following after the ```procedure before_all;``` line
  ```
     --%aftereach
     procedure delete_added_customers;
  ```
  This will call the cleanup procedure after each test is run.  
  Alternativly, you could make it a ```--%beforeeach``` and have it reset the environment before each test runs.  But then you would need to have an ```--$afterall``` to do a final cleanup.
1. Git add/commit/push
1. Check results, both tests should now pass.
1. Check coverage
    The coverage should now be at 86.67%.

### Already over the limit
Edit the package spec
```
nano test/test_generate_customers_func.pks
```
Add the following before the end of the package
```
  -- %test(Already at the limit, Generates 0)
  procedure over_limit;
```
Edit the package body
```
nano test/test_generate_customers_func.pkb
```
Add the following before the end of the package
```
  procedure over_limit is
    new_name varchar2(200);
  begin
    ut.expect( generate_customers( 30 ) ).to_( equal(0) );
  end;
```

1. Git add/commit/push
1. Check results
   The new test fails.  

### Add setup to test (insert 30 then run test)

### After All
check count
add clean up


### null in 0 out
### test for null out
change ```equal(0)``` to ```be_null``

### exceptions
