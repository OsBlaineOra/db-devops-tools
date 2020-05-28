# Jenkins
### Open Jenkins
Get the Jenkins admin password
```
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

In your browser, open another tab and go to ```<yourComputeIP>:8080```
Use the admin password to log in

1. Install suggested
1. admin/Tester
1. Save
1. Start using Jenkins
1. New Item
1. Freestyle Project
1. [OK]
1. Source Code Management
    1. Select Git
    1. In Repository URL enter the https URL you copied from your fork of the repo
    1. Under Build Triggers check "GitHub hook trigger for GITScm polling"
1. Under Build Environment 
    1. Check "Delete workspace before build starts"
    1. Check "Use secret text(s) or file(s)"
1. Bindings Section
    1. Click Add button
    1. Select "Username and password (separated)"
    1. In "Username Variable" enter "username"
    1. In "Password Variable" enter "password"
    1. Select "Specific Credentials"
    1. Click the Add button.
    1. Select Jenkins.
    1. Set Kind to "Username with password"
    1. Set Username to "hol_prod"
    1. Set Password to "HandsOnLabUser1" (if you changed the password when you created the schema, use that password)
    1. Click Add
1. Build section
    1. Click Add build step
    1. Select Execute shell
    1. Enter the following in the Command field
    ```
    cd liquibase

    /opt/liquibase/liquibase --changeLogFile=master.json \
    --url=jdbc:oracle:thin:@demos_tp?TNS_ADMIN=/opt/oracle/wallet \
    --username=${username} \
    --password=${password} \
    --classpath=/opt/oracle/ojdbc8.jar \
    --contexts="!test" \
    update
    ```
1. Scroll to the bottom and click the Save button

## Configure utplsql
1. Click 'Jenkins' logo
1. Click 'Manage Jenkins'
1. Click 'Manage Plugins'
1. Click 'Available' tab
1. In the search box, enter 'utplsql'
1. Check the Install checkbox.
1. Click Install without restart.
1. Click 'Go back to the top page'
1. OR check 'Restart Jenkins when installation is complete and no jobs are running'
1. Open your project
1. Scroll down to the Build section and click 'Add build step'

