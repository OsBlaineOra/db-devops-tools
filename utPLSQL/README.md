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

```-- %suitepath(generate_customers)``` is used to define the path to the unit being tested.  In this case it is a single stored function "generate_customers".  If you were testing a function inside of a package you could declare the path all the way from the schema to the function  
```-- %suitepath(my_schema.the_package.a_function)```.  Use a path definition that makes sense for your project.  

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

The fake test procedure creates a boolean variable set to true and tests to see if it's true.  This will always pass.
```
 procedure always_pass is
    l_is_true boolean := true;
  begin
    ut.expect( l_is_true ).to_be_true();
  end;
```

## Test Coverage

In your Jenkins project page, you will see a "Code Coverage" graph on the right hand side.

The current code coverage is 0%.

Your build is already configured to generate a Cobertura style coverage report by including the following parameters to the utPLSQL-cli call.

```
-f=ut_coverage_cobertura_reporter -o=coverage.xml \
```

There are other coverage reporters available such as an "HTML Reporter" for example.  Including this reporter will generate a dynamic web page to display your code coverage.
```
-f=ut_coverage_html_reporter -o=coverage.html \
```
You can find more information and other coverage reporting options [here](http://utplsql.org/utPLSQL/latest/userguide/coverage.html "utPLSQL code coverage documentation").

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

1. Run the tests locally
    ```
    /opt/utPLSQL-cli/bin/utplsql run hol_dev/HandsOnLabUser1@demos_TP?TNS_ADMIN=/opt/oracle/wallet \
    -f=ut_coverage_html_reporter  -o=coverage.html \
    -f=ut_documentation_reporter -c
    ```
1. Reveiw the output to see that the test passed on Dev
1. Start Web Server
    ```
    pushd /home/opc/db-devops-tools; python -m SimpleHTTPServer; popd
    ```
1. **In your browser**
1. Check Dev code coverage \<yourPublicIp>:8000/coverage.html
1. **In Cloud Shell**
1. Ctrl-C to stop the web server
1. Git add/commit/push
1. Check Jenkins test results
1. Check Jenkins code coverage
1. **In Jenkins** click Build Now to run the build a second time  
   The test Fails because the previous test data is still there.
1. **In SQL Developer Web** Execute the following query in the worksheet to query the customers
    ```
    select * from hol_test.customers;
    ```

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
  procedure delete_added_customers is
  begin
    delete from customers
    where name like 'custxxx%';

    commit;
  end;
    
  procedure before_all is
  begin
    delete_added_customers;
  end;
```

A helper procedure, "delete_added_customers", is included that you will call to clean up the generated customers.  In this case you are calling it before any tests are run to make sure any old test customers have been removed.

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
Add the following before the end of the package
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
Edit the package spec
```
nano test/test_generate_customers_func.pks
```
Add the following after the ```procedure before_all;``` line
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
   The new test fails.  Since the 'after each' procedure is working there is still room to generate new customers before the limit.  You will need to add a little setup code to make sure there are more customers than the limit before running the test.  

### Add setup to test (insert 30 then run test)
Edit the package body
```
nano test/test_generate_customers_func.pkb
```
Add the following before the ```ut.expect(...``` line
```
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
```
This will create 30 new customers in the table before the test is run.
1. Git add/commit/push
1. Check results, all 3 tests should now pass.
1. Check coverage
   The coverage should now be at 93.33%.

## Test for null in 0 out
Edit the package spec
```
nano test/test_generate_customers_func.pks
```
Add the following before the end of the package
```
  -- %test(Returns 0 for null input)
  procedure null_ammount;
```
Edit the package body
```
nano test/test_generate_customers_func.pkb
```
Add the following before the end of the package
```
  procedure null_ammount is
  begin
    ut.expect( generate_customers( null ) ).to_( equal(0) );
  end;
```

1. Git add/commit/push
1. Check results, all 4 tests should pass.
1. Check coverage
   The coverage should now be at 100%.


### test for null out
A change request has come in.  The user would like the function to return null when a null is passed in.  
It is good practice to setup your tests so they test for what you want the code to do, before your change it.  

Edit the package spec
```
nano test/test_generate_customers_func.pks
```
Change the line
```
  -- %test(Returns 0 for null input)
```
To
```
  -- %test(Returns null for null input)
```
Edit the package body
```
nano test/test_generate_customers_func.pkb
```
Change the line
```
    ut.expect( generate_customers( null ) ).to_( equal(0) );
```
To
```
    ut.expect( generate_customers( null ) ).to_( be_null );
```

1. Git add/commit/push
1. Check results, this test should now fail.

### Change the code to pass the test
Edit the function
```
nano source/gen_cust.fnc
```
Change the code
```
      IF amount is null then 
         Return 0;
      END IF;
```
To
```
      IF amount is null then 
         Return null;
      END IF;
```

1. Git add/commit/push
1. Check results, all 4 tests should now pass.

## Test for Exceptions
Even though we have 100% code coverage, there is still at least one potential bug.  
If a user calls this function and passes in a non numeric value the function will throw an exception "numeric or value error".  Add a test to check for the expected exception.

Edit the package spec
```
nano test/test_generate_customers_func.pks
```
Add the following before the end of the package
```
  -- %test(Throws numeric or value error for non numeric input)  
  --%throws(-06502)
  procedure alpha_in;
```
You use the ```--%throws(<Exception number>)``` annotation to test for the exception number you expect to be thrown.  

Edit the package body
```
nano test/test_generate_customers_func.pkb
```
Add the following before the end of the package
```
  procedure alpha_in is
    created integer;
  begin
    created := generate_customers( 'x' );
  end;
```
In this test you're expecting an exception to be thrown so there will not be a value to test for.

1. Git add/commit/push
1. Check results, all 5 tests should pass.

