# Mobius
A Mutlipurpose tool to install and manage several programs like: 
* **PostgreSql**
* **MySql** 
* **UWSGI**
* **Python**
* **Node**

## Usage:
**NOTE: This script will only run using root**

Step 1: Download the main script:
```
wget https://raw.githubusercontent.com/bhardwajkonark/mobius/main/mobius.sh  -O mobius.sh
# or
curl https://raw.githubusercontent.com/bhardwajkonark/mobius/main/mobius.sh  -o mobius.sh
```
Step 2: Run the file with the following format:
```
sh mobius.sh 
```

Options :
```
  1. Install Postgres
  2. Install Mysql
  3. Create postgres database 
  4. Create mysql database
  5. Import Postgresql database 
  6. Import Mysql database
  7. Create Virtualenv
  8. Install Virtualenv
  9. Change Owner of all tables in Postgres
  10. Create Swap File 
  11. Install Python Deadsnake PPA (Ubuntu only)
  12. Install Python (Ubuntu only)
  13. Install UWSGI  (Ubuntu only)
  14. Install NVM
```

#### Additional Notes

The script automatically runs in interactive mode and waits for the user to input. 