# Liquibase
In the Cloud Shell ssh session.
```
cd project/liquibase
```

## Create Files

Create a file liquibase.properties 
```
nano liquibase.properties
```
Add the following values.  Correct the password if you have changed it.
```
changeLogFile: master.json
url: jdbc:oracle:thin:@demos_tp?TNS_ADMIN=/opt/oracle_wallet
username: hol_dev
password: HandsOnLabUser1
classpath: ojdbc8.jar
```

Create a file runOnce/changelog-create-customers.json
```
nano runOnce/changelog-create-customers.json
```
Add the following to the file
```
{
  "databaseChangeLog": [
    {
      "preConditions": [
        {
          "runningAs": {
            "username": "HOL_DEV"
          }
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
```
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
```
select * from databasechangelog order by id;
```

## Tags from the changelog
You can add a tag to a changelog with the following section
```
      "tagDatabase": {
        "tag": "<YourTagGoesHer>"
      },
```

Create a file runOnce/changelog-create-orders.json  
```
nano runOnce/changelog-create-orders.json
```
Add the following to the file.  
```
{
  "databaseChangeLog": [
    {
      "preConditions": [
        {
          "runningAs": {
            "username": "HOL_DEV"
          }
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

```
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
```
select * from databasechangelog order by id;
```

## Add column

Create a file runOnce/changelog-add-col-customers-name.json
```
nano runOnce/changelog-add-col-customers-name.json
```
Add the following to the file
```
{
  "databaseChangeLog": [
    {
      "preConditions": [
        {
          "runningAs": {
            "username": "HOL_DEV"
          }
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

```
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
```
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

## Multiple changes in a set
Create a file runOnce/changelog-order-statuses.json
```
nano runOnce/changelog-create-order-statuses.json
```
Add the following to the file
```
{
  "databaseChangeLog": [
    {
      "preConditions": [
        {
          "runningAs": {
            "username": "HOL_DEV"
          }
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

```
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
```
{
  "databaseChangeLog": [
    {
      "preConditions": [
        {
          "runningAs": {
            "username": "HOL_DEV"
          }
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

```
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

```
select * from order_statuses;
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

```
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
```
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
```
select * from order_statuses;
```

## Load Test data - Context
Modify liquibase.properties

```
nano liquibase.properties
```
Add the following at the bottom
```
contexts: !test
```
Create a file runOnce/changelog-load-test-data.json

```
nano runOnce/changelog-load-test-data.json
```

```
{
  "databaseChangeLog": [
    {
      "preConditions": [
        {
          "runningAs": {
            "username": "HOL_DEV"
          }
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

```
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
Nothing runs

```
select * from customers;
select * from orders;
```

### Run with context
```
liquibase --contexts="test" update
```

To rollback this changeset you need to use --contexts="test"
```
liquibase --contexts="test" rollback Five
```
## Run Diff
```
liquibase --referenceUrl="jdbc:oracle:thin:hol_dev_good/HandsOnLabUser1@demos_tp?TNS_ADMIN=/home/opc/wallet" diff
```
Edit properties
```
nano liquibase.properties
```
Add reference db connection information
```
referenceUrl: jdbc:oracle:thin:@demos_tp?TNS_ADMIN=/home/opc/wallet
referenceUsername: hol_dev_good
referencePassword: HandsOnLabUser1
```
```
liquibase --diffTypes=tables,columns diff
```
## Generate diffChangeLog
```
liquibase --changeLogFile=diff-changelog.json diffChangeLog
cat diff-changelog.json
```
## GenerateChanglogFile - Rev eng
```
liquibase --changeLogFile=generated.json generateChangeLog
cat generated.json
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
pushd /home/opc/project/liquibase/docs; python -m SimpleHTTPServer; popd
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





## integrate with Jenkins
### Run pipeline
git pull
liquibase update
