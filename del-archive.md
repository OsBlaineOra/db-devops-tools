# Archive

## Download Credentials
1. Click the menu icon in the upper left corner.
2. Click "Autonomous Transaction Processing".
3. Change to your compartment.
4. Locate your new ATP instance and click the menu option. (Three dots on the right side of the row)
5. Click "Service Console"
6. Click "Administration"
7. Click "Download Client Credentials (Wallet)"
8. Set a password that will be used to access the zip file.
9. Click "Download" and save the .zip file to /wallet.
10. Extract the .zip file into the /wallet directory.
11. Edit /wallet/ojdbc.properties
12. Set password 2 places.
13. Comment line 2.
14. Un-Comment last 4 lines.
***Warning*** this is a credentials file that will be used when connecting to your database. ***Keep it Secure***.





# Archive


https://docs.cloud.oracle.com/iaas/Content/Compute/Tasks/accessinginstance.htm

### Connecting to Your Linux Instance from a Unix-style System

$ ssh –i <private_key> opc@<public-ip-address>
<private_key> is the full path and name of the file that contains the private key associated with the instance you want to access.

<public-ip-address> is your instance IP address that you retrieved from the Console.


### Connecting to Your Linux Instance from a Windows System
Open putty.exe.

In the Category pane, expand Window, and then select Translation.

In the Remote character set drop-down list, select UTF-8. The default locale setting on Linux-based instances is UTF-8, and this configures PuTTY to use the same locale.

In the Category pane, select Session and enter the following:

Host Name (or IP address):

opc@<public-ip-address>

<username> is the default name for the instance. For Oracle Linux and CentOS images, the default user name is opc. For the Ubuntu image, the default name is ubuntu.

<public-ip-address> is your instance public IP address that you retrieved from the Console

Port: 22

Connection type: SSH

In the Category pane, expand Connection, expand SSH, and then click Auth.

Click Browse, and then select your private key.

Click Open to start the session.

If this is your first time connecting to the instance, you might see a message that the server's host key is not cached in the registry. Click Yes to continue the connection.



### SQL Dev Online
1. Click the menu icon in the upper left corner.
2. Click "Autonomous Transaction Processing".
3. Change to your compartment.
4. Locate your new ATP instance and click the menu option. (Three dots on the right side of the row)
5. Click "Service Console"
6. Click "Development"
7. Click "SQL Developer Web"
8. Enter the Admin user and password and login.
9. Enter the below SQL comands.
10. Save the URL for the page.
https://adgeraj32gr-myDb.adb.us-ashburn-1.oraclecloudapps.com/ords/admin/_sdw/?nav=worksheet
When you want to log in as the new user, change the /admin/ part of that URL to the value you set in p_url_mapping_pattern then login as the new user.



Run the following command in the Cloud Shell.
```
oci db autonomous-database get --autonomous-database-id $DB_OCID --query 'data."connection-urls"."sql-dev-web-url"' --raw-output
```
1. Copy the Url
1. Open a new browser tab
1. Paste in the URL to open SQLDeveloper Web.
   ![](images/sqlDevWebLogon.png)  
1. Sign in using the admin user and password for your database.
   ![](images/sqlDevWeb.png)
# (Cloud Shell - 2 minutes not counting CS spin up time)