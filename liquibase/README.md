# Liquibase
In the Cloud Shell ssh session.
```
cd /home/opc/db-devops-tools/liquibase
```

## Create Files

Create a file liquibase.properties 
```
nano liquibase.properties
```
Add the following values.  Correct the password if you have changed it.
```yaml
changeLogFile: master.json
url: jdbc:oracle:thin:@demos_tp?TNS_ADMIN=/opt/oracle/wallet
username: hol_dev
password: HandsOnLabUser1
classpath: /opt/oracle/ojdbc8.jar
```

Create a file runOnce/changelog-create-customers.json
```
nano runOnce/changelog-create-customers.json
```
Add the following to the file
```json
{
  "databaseChangeLog": [
    {
      "preConditions": [
        {
          "or": [
            {
              "runningAs": {
                "username": "HOL_DEV"
              }
            },
            {
              "runningAs": {
                "username": "HOL_PROD"
              }
            }
          ]
        }
      ]
    },
    {
      "changeSet": {
        "id": "1",
        "author": "YourNameHere",
        "comment": "Add table customers",
        "changes": [
          {
            "createTable": {
              "tableName": "customers",
              "columns": [
                {
                  "column": {
                    "name": "id",
                    "type": "int",
                    "autoIncrement": true,
                    "constraints": {
                      "primaryKeyName": "customers_pk",
                      "primaryKey": true
                    }
                  }
                },
                {
                  "column": {
                    "name": "email",
                    "type": "varchar(200)",
                    "constraints": {
                      "uniqueConstraintName": "customers_email_uk",
                      "unique": true
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    }
  ]
}
```

Create a file master.json
```
nano master.json
```
Add the following to the file
```json
{
  "databaseChangeLog": [
    {
      "include": {
        "file": "runOnce/changelog-create-customers.json"
      }
    }
  ]
}
```

### Generate SQL
```
liquibase updateSQL
```
### Run the changes on your Database
```
liquibase update
```

## Tags from the command line
```
liquibase tag One
```
Look at the LB data
```sql
select * from hol_dev.databasechangelog order by id;
```

## Tags from the changelog
You can add a tag to a changelog with the following section
```json
      "tagDatabase": {
        "tag": "<YourTagGoesHer>"
      },
```

Create a file runOnce/changelog-create-orders.json  
```
nano runOnce/changelog-create-orders.json
```
Add the following to the file.  
```json
{
  "databaseChangeLog": [
    {
      "preConditions": [
        {
          "or": [
            {
              "runningAs": {
                "username": "HOL_DEV"
              }
            },
            {
              "runningAs": {
                "username": "HOL_PROD"
              }
            }
          ]
        }
      ]
    },
    {
      "changeSet": {
        "id": "2",
        "author": "YourNameHere",
        "comment": "Add table orders",
        "tagDatabase": {
          "tag": "Two"
        },
        "changes": [
          {
            "createTable": {
              "tableName": "orders",
              "columns": [
                {
                  "column": {
                    "name": "id",
                    "type": "int",
                    "autoIncrement": true,
                    "constraints": {
                      "primaryKey": true,
                      "primaryKeyName": "orders_pk"
                    }
                  }
                },
                {
                  "column": {
                    "name": "order_datetime",
                    "type": "timestamp",
                    "defaultValueComputed": "CURRENT_TIMESTAMP",
                    "constraints": {
                      "nullable": false
                    }
                  }
                },
                {
                  "column": {
                    "name": "customer_id",
                    "type": "int",
                    "constraints": {
                      "nullable": false,
                      "foreignKeyName": "orders_customer_id_fk",
                      "references": "HOL_DEV.CUSTOMERS(id)"
                    }
                  }
                },
                {
                  "column": {
                    "name": "order_status",
                    "type": "varchar2(10)",
                    "constraints": {
                      "nullable": false
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    }
  ]
}
```

Add this new changelog to the file master.json
```
nano master.json
```
Modify the file to include the new changelog.

```json
{
  "databaseChangeLog": [
    {
      "include": {
        "file": "runOnce/changelog-create-customers.json"
      }
    },
    {
      "include": {
        "file": "runOnce/changelog-create-orders.json"
      }
    }
  ]
}
```
### Run the changes on your Database
```
liquibase update
```

Look at changes in SDW

Look at LB tables
```sql
select * from hol_dev.databasechangelog order by id;
```
Note: The very last tag added in a set of changelogs will be overwritten by a tag added from the command line.

## Shema Diff
Your database has been setup with two schemas, hol_dev and hol_prod.  Running ```liquibase update``` in your shell session is configured to update hol_dev and you have configured Jenkins to update hol_prod whenever your code is pushed to GitHub.

Switch to SQL Developer Web and run the following query to show the existing tables in hol_dev and hol_prod.
```sql
select owner, table_name
  from all_tables
 where owner in ('HOL_DEV', 'HOL_PROD')
order by 1,2;
```
As you can see, tables have been created in hol_dev and not hol_prod.

You can also use the  ```liquibase diff``` to compare schemas by passing in a 'reference Url'.

```
liquibase --referenceUrl="jdbc:oracle:thin:hol_prod/HandsOnLabUser1@demos_tp?TNS_ADMIN=/opt/oracle/wallet" diff
```
If you plan to use the 'diff' comand a lot, you can add the reference values to the liquibase.properties file
```
nano liquibase.properties
```
Add reference db connection information
```yaml
referenceUrl: jdbc:oracle:thin:@demos_tp?TNS_ADMIN=/opt/oracle/wallet
referenceUsername: hol_prod
referencePassword: HandsOnLabUser1
```
You can also filter the diff report to specific diffTypes.
```
liquibase --diffTypes=tables,columns diff
```
Push your changes to GitHub to test the Jenkins integration.
```bash
cd /opc/db-devops-tools
git status
git add .
git commit -m"Added customers and orders tables."
git push
cd liquibase
```
Switch to your Jenkins tab and make sure the build does not error.  Once the build is complete, run the diff command again.
```
liquibase diff
```

### Generate diffChangeLog
You can use the ```diffChangeLog``` command to compae your current schema to a "known good" and auto-generate a changelog.  You could use this changelog to sync your current schema with the reference schema.  
**Do not run this changelog, it is only an example**
```
liquibase --changeLogFile=diff-changelog.json diffChangeLog
cat diff-changelog.json
rm diff-changelog.json
```

## Add column

Create a file runOnce/changelog-add-col-customers-name.json
```
nano runOnce/changelog-add-col-customers-name.json
```
Add the following to the file
```json
{
  "databaseChangeLog": [
    {
      "preConditions": [
        {
          "or": [
            {
              "runningAs": {
                "username": "HOL_DEV"
              }
            },
            {
              "runningAs": {
                "username": "HOL_PROD"
              }
            }
          ]
        }
      ]
    },
    {
      "changeSet": {
        "id": "3",
        "author": "YourNameHere",
        "comment": "Add name column to customers table",
        "tagDatabase": {
          "tag": "Three"
        },
        "changes": [
          {
            "addColumn": {
              "schemaName": "HOL_DEV",
              "tableName": "customers",
              "columns": [
                {
                  "column": {
                    "name": "name",
                    "type": "varchar(255)"
                  }
                }
              ]
            }
          }
        ]
      }
    }
  ]
}
```
Add the new change log to the bottom of the file master.json
```
nano master.json
```

```json
{
  "databaseChangeLog": [
...
    },
    {
      "include": {
        "file": "runOnce/changelog-add-col-customers-name.json"
      }
    }
  ]
}
```
### Run the changes on your Database
```
liquibase update
```
Look at the table in SQL Developer Web.

### The customer name column should be required.  
The customer name column is missing a not null constraint.  
You could create another changeset and run it, or if you're sure no one else is currently working on this table, you could do a quick rollback, fix it and re-run the change.

### Rollback 1
Rollback one changeset with the following command.
```
liquibase rollbackCount 1
```
Look at the table in SQL Developer Web.  
Edit the file runOnce/changelog-add-col-customers-name.json
```
nano runOnce/changelog-add-col-customers-name.json
```
Add a `"nullable": false` constraint to the column.
```json
...
                {
                  "column": {
                    "name": "name",
                    "type": "varchar(255)",
                    "constraints": {
                      "nullable": false
                    }
                  }
                }
...
```
Re-run the update.
```
liquibase update
```
Look at the table in SQL Developer Web.

### Rollback to a tag
```
liquibase rollback "Two"
```

Look at SDW changes
Look at LB tables

Re-run the changes
```
liquibase update
```
Push your changes to GitHub
```bash
cd /opc/db-devops-tools
git status
git add .
git commit -m"Added customers and orders tables."
git push
cd liquibase
```
Switch to your Jenkins tab in your browser and make sure the build does not error.  Once the build is complete, run the diff command again.
```
liquibase diff
```

## Multiple changes in a set
Create a file runOnce/changelog-order-statuses.json
```
nano runOnce/changelog-create-order-statuses.json
```
Add the following to the file
```json
{
  "databaseChangeLog": [
    {
      "preConditions": [
        {
          "or": [
            {
              "runningAs": {
                "username": "HOL_DEV"
              }
            },
            {
              "runningAs": {
                "username": "HOL_PROD"
              }
            }
          ]
        }
      ]
    },
    {
      "changeSet": {
        "id": "4",
        "author": "YourNameHere",
        "comment": "Create Order_Statuses table",
        "tagDatabase": {
          "tag": "Four"
        },
        "changes": [
          {
            "createTable": {
              "schemaName": "HOL_DEV",
              "tableName": "order_statuses",
              "columns": [
                {
                  "column": {
                    "name": "status",
                    "type": "varchar(10)",
                    "constraints": {
                      "primaryKeyName": "order_statuses_pk",
                      "primaryKey": true
                    }
                  }
                },
                {
                  "column": {
                    "name": "description",
                    "type": "varchar(255)"
                  }
                }
              ]
            }
          },
          {
            "addForeignKeyConstraint": {
              "baseColumnNames": "order_status",
              "baseTableName": "orders",
              "constraintName": "order_status_fk",
              "referencedColumnNames": "status",
              "referencedTableName": "order_statuses",
              "validate": true
            }
          }
        ]
      }
    }
  ]
}
```
Add the new change log to the bottom of the file master.json
```
nano master.json
```

```json
{
  "databaseChangeLog": [
...
    },
    {
      "include": {
        "file": "runOnce/changelog-create-order-statuses.json"
      }
    }
  ]
}
```
### Run the changes on your Database
```
liquibase update
```
Look at the table in SQL Developer Web.

## Load Master Data .csv file
Create a file runOnce/status-data.csv
```
nano runOnce/status-data.csv
```
Add the following
```
status,description
New,Still being created
Submitted,Awaiting payment
Shipped,as been sent
Complete,Has been delivered
```
Create a file runOnce/changelog-load-status-data.json
```
nano runOnce/changelog-load-status-data.json
```
Add the following
```json
{
  "databaseChangeLog": [
    {
      "preConditions": [
        {
          "or": [
            {
              "runningAs": {
                "username": "HOL_DEV"
              }
            },
            {
              "runningAs": {
                "username": "HOL_PROD"
              }
            }
          ]
        }
      ]
    },
    {
      "changeSet": {
        "id": "5",
        "author": "YourNameHere",
        "comment": "Load Order_Statuses data",
        "tagDatabase": {
          "tag": "Five"
        },
        "changes": [
          {
            "loadData": {
              "schemaName": "HOL_DEV",
              "tableName": "order_statuses",
              "file": "runOnce/status-data.csv"
            }
          }
        ]
      }
    }
  ]
}
```
Add the new change log to the bottom of the file master.json
```
nano master.json
```

```json
{
  "databaseChangeLog": [
...
    },
    {
      "include": {
        "file": "runOnce/changelog-load-status-data.json"
      }
    }
  ]
}
```

```
liqubase update

```

```sql
select * from hol_dev.order_statuses;
```


## Fix a typo.
There is a typo in the Shipped description "as been sent"  

Change the .csv file  
Try to roll back the change.
```
liquibase rollback Four
```
You will receive an error.
```
...
Unexpected error running Liquibase: No inverse to liquibase.change.core.LoadDataChange created
...
```

Certain changes can not be automatically rolled back.
Data changes, pl/sql
# Add link

### Add rollback section
```
nano runOnce/changelog-load-status-data.json
```

```json
,
          {
            "rollback": {
              "delete": {
                "tableName": "order_statuses"
              }
            }
          }
```
## Load data / rollback data / load again
Fix the data
```
nano runOnce/status-data.csv
```
```
...
Shipped,Has been sent
...
```
Rollback the change
```
liquibase rollback Four
```

Now you should get an error saying that the changelog has been modified.
```
Unexpected error running Liquibase: Validation Failed:
     1 change sets check sum
          runOnce/changelog-load-status-data.json::5::YourNameHere was: 8:808882540b8e59eb72c531c6f762ec8b but is now: 8:d0961735f2e626c20cb6df76860055ef
```
add ```"validCheckSum": "<but is now value>",``` to the changeset

```
nano runOnce/changelog-load-status-data.json
```
```json
      "changeSet": {
        "id": "5",
        "author": "YourNameHere",
        "comment": "Load Order_Statuses data",
        "validCheckSum": "8:d0961735f2e626c20cb6df76860055ef",
        "changes": [{
```
Rollback the change
```
liquibase rollback Four
```
remove "validCheckSum": "8:d0961735f2e626c20cb6df76860055ef",

```
nano runOnce/changelog-load-status-data.json
```

Run the corrected change
```
liquibase update
```
This time everything should run.

Check the data in SDW
```sql
select * from hol_dev.order_statuses;
```
Push your changes to GitHub
```bash
cd /opc/db-devops-tools
git status
git add .
git commit -m"Added customers and orders tables."
git push
cd liquibase
```
Switch to your Jenkins tab in your browser and make sure the build does not error.  Once the build is complete, check the hol_prod data in SDW.  
**Data differences are not shown in the diff results.**

```sql
select * from hol_prod.order_statuses;
```

## Load Test data - Context
Modify liquibase.properties

```
nano liquibase.properties
```
Add the following at the bottom
```yaml
contexts: !test
```
Create a file runOnce/changelog-load-test-data.json

```
nano runOnce/changelog-load-test-data.json
```

```json
{
  "databaseChangeLog": [
    {
      "preConditions": [
        {
          "or": [
            {
              "runningAs": {
                "username": "HOL_DEV"
              }
            },
            {
              "runningAs": {
                "username": "HOL_PROD"
              }
            }
          ]
        }
      ]
    },
    {
      "changeSet": {
        "id": "6",
        "author": "YourNameHere",
        "comment": "Load Test Data",
        "tagDatabase": {
          "tag": "Six"
        },
        "context": "test",
        "changes": [
          {
            "insert": {
              "schemaName": "HOL_DEV",
              "tableName": "customers",
              "columns": [
                {
                  "column": {
                    "name": "email",
                    "value": "Betty@example.com"
                  }
                },
                {
                  "column": {
                    "name": "name",
                    "value": "Betty"
                  }
                }
              ]
            }
          },
          {
            "insert": {
              "schemaName": "HOL_DEV",
              "tableName": "customers",
              "columns": [
                {
                  "column": {
                    "name": "email",
                    "value": "Bob@example.com"
                  }
                },
                {
                  "column": {
                    "name": "name",
                    "value": "Bob"
                  }
                }
              ]
            }
          },
          {
            "insert": {
              "schemaName": "HOL_DEV",
              "tableName": "orders",
              "columns": [
                {
                  "column": {
                    "name": "customer_id",
                    "valueComputed": "(SELECT id FROM customers where name = 'Betty')"
                  }
                },
                {
                  "column": {
                    "name": "order_status",
                    "value": "New"
                  }
                }
              ]
            }
          },
          {
            "insert": {
              "schemaName": "HOL_DEV",
              "tableName": "orders",
              "columns": [
                {
                  "column": {
                    "name": "customer_id",
                    "valueComputed": "(SELECT id FROM customers where name = 'Bob')"
                  }
                },
                {
                  "column": {
                    "name": "order_status",
                    "value": "Submitted"
                  }
                }
              ]
            }
          },
          {
            "rollback": {
              "delete": {
                "tableName": "orders"
              }
            }
          },
          {
            "rollback": {
              "delete": {
                "tableName": "customers"
              }
            }
          }
        ]
      }
    }
  ]
}
```
Add the new change log to the bottom of the file master.json
```
nano master.json
```

```json
{
  "databaseChangeLog": [
...
    },
    {
      "include": {
        "file": "runOnce/changelog-load-test-data.json"
      }
    }
  ]
}
```

```
liquibase update
```
Nothing runs.  
Adding ```contexts: !test``` to the liquibase.properties file will cause liquibase to not run any changes with a context of 'test'.  If you did not include the contexts entry, liquibase will not test any context.

```sql
select * from hol_dev.customers;
select * from hol_dev.orders;
```

### Run with context
```
liquibase --contexts="test" update
```
Remember, comand line options such as ```--contexts="test"``` will override the same setting in the liquibase.properties file.  In this case it instructs liquibase to include the 'test' changes.

To rollback this changeset you need to use --contexts="test".
```
liquibase --contexts="test" rollback Five
```

## Run on Change
Some database objects are created using the "Create or Replace" syntax such as Views and PL/SQL objects (Functions, Procedures, Packages and Triggers).  
It is a good practice to maintain the source for these objects directly in your VCS and have liquibase "re-compile" them whenever they change.

Tyically the source for these objects would reside in another directory but for simplicity sake in this lab, they are located in the runOnChange directory with the Liquibase changelogs.

Review the following files.
runOnce/status_view.sql
```
cat runOnce/status_view.sql
```
runOnce/admin_tools.pks
```
cat runOnce/admin_tools.pks
```
runOnce/admin_tools.pkg
```
cat runOnce/admin_tools.pkg
```

Create a file runOnChange/changelog-status-view.json

```
nano runOnChange/changelog-status-view.json
```
Add the following
```json
{
  "databaseChangeLog": [
    {
      "preConditions": [
        {
          "or": [
            {
              "runningAs": {
                "username": "HOL_DEV"
              }
            },
            {
              "runningAs": {
                "username": "HOL_PROD"
              }
            }
          ]
        }
      ]
    },
    {
      "changeSet": {
        "id": "7",
        "author": "YourNameHere",
        "comment": "Create or replace status view",
        "runOnChange": true,
        "changes": [
          {
            "createView": {
              "fullDefinition": true,
              "selectQuery": "create or replace view status as select status order_status from order_statuses",
              "viewName": "DD_DEQUEUE_ERRORS"
            }
          }
        ],
        "rollback": ""
      }
    }
  ]
}
```

Add this new changelog to the file master.json
```
nano master.json
```
Modify the file to include the new changelog.

```json
{
  "databaseChangeLog": [
...,
    {
      "include": {
        "file": "runOnChange/changelog-status-view.json"
      }
    }
  ]
}
```
### Run the changes on your Database
```
liquibase update
```

Look at changes in SDW

Look at LB tables
```sql
select * from hol_dev.databasechangelog order by dateexecuted;
```
Notice the dateexecuted timestamp.

Edit the view SQL in the changelog

```
nano runOnChange/changelog-status-view.json
```
Change the SQL in "selectQuery" to the following.

```
              "selectQuery": "create or replace view status as select status order_status, description from order_statuses",
```
### Run the changes on your Database
```
liquibase update
```
Look at changes in SDW

Look at LB tables
```sql
select * from hol_dev.databasechangelog order by dateexecuted;
```
Notice the dateexecuted timestamp has changed.

Create a file runOnChange/changelog-gen_cust-fnc.json

```
nano runOnChange/changelog-gen_cust-fnc.json
```
Add the following
```json
{
  "databaseChangeLog": [
    {
      "preConditions": [
        {
          "or": [
            {
              "runningAs": {
                "username": "HOL_DEV"
              }
            },
            {
              "runningAs": {
                "username": "HOL_PROD"
              }
            }
          ]
        }
      ]
    },
    {
      "changeSet": {
        "id": "8",
        "author": "YourNameHere",
        "comment": "Create or replace generate customers function",
        "runOnChange": true,
        "changes": [
          {
            "createProcedure": {
              "dbms": "oracle",
              "encoding": "utf8",
              "path": "gen_cust.fnc",
              "relativeToChangelogFile": true
            }
          }
        ],
        "rollback": ""
      }
    }
  ]
}
```

Notice this changelog references a file in the "path" value and that this file path is relative to the changelog file.
```
              "path": "gen_cust.fnc",
              "relativeToChangelogFile": true
```

Add this new changelog to the file master.json
```
nano master.json
```
Modify the file to include the new changelog.

```json
{
  "databaseChangeLog": [
...,
    {
      "include": {
        "file": "runOnce/changelog-gen_cust-fnc.json"
      }
    }
  ]
}
```
### Run the changes on your Database
```
liquibase update
```
Look at changes in SDW

Look at LB tables
```sql
select * from hol_dev.databasechangelog order by dateexecuted;
```
Notice the dateexecuted timestamp.

Edit the gen_cust.fnc file
```
nano runOnChange/gen_cust.fnc.json
```

Change the Max customer constant to 25.
```
c_max_customers   CONSTANT INTEGER := 25;
```

### Run the changes on your Database
```
liquibase update
```

Look at LB tables
```sql
select * from hol_dev.databasechangelog order by dateexecuted;
```
Notice the dateexecuted timestamp has changed.

A changelog flagged ```"runOnChange": true,``` will re-run whenever the changelog itself is changed or the file it's referencing has changed.  

Push your changes to GitHub
```bash
cd /opc/db-devops-tools
git status
git add .
git commit -m"Added customers and orders tables."
git push
cd liquibase
```
Switch to your Jenkins tab in your browser and make sure the build does not error.  Once the build is complete, check the hol_prod data in SDW.  

## GenerateChanglogFile - Reverse engineer your current schema
```
liquibase --changeLogFile=generated.json generateChangeLog
cat generated.json
rm generated.json
```
## Drop All
```
liquibase dropAll
```
## Generate Docs
```
liquibase DBDoc docs
ls -la docs
```
Use the following command to start a simple HTTP server with Python.
```
pushd /home/opc/db-devops-tools/liquibase/docs; python -m SimpleHTTPServer; popd
```
Go to ```<yourComputeIP>:8000``` to review the docs.
## Run all
```
liquibase update
```
## Generate Docs
```
liquibase DBDoc docs
```
## Drop All
```
liquibase dropAll
```
