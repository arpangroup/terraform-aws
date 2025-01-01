# Shell Scripting


## 1. Creating a Shell Script
````bash
#!/bin/bash
````
This tells the system to use Bash to execute the script.

`#!/bin/bash` is called a **shebang** (or **hashbang**) line. It tells the system which interpreter to use to execute the script.
- `#` and `!`: These characters start the shebang.
- show all shells: `cat /etc/shells`

## 2. Running a Shell Script
````bash
chmod +x script.sh
````


## 3. Variables
````bash
VAR1="World"
echo "Hello, $VAR1" # Single quote will not work
````


## 4 Command line Arguments:
````bash
echo "Total Arguments: " $#  # is used to print total arguments
echo "All Arguments: " $@    # is used to print values of all arguments

echo "First -> " $1
echo "Second -> " $2
````
Run the above script as `./arguments.sh Hello World`

## 5. Input:
````bash
# Approach-1
echo "Enter your Company Name: "
read COMPANY

# Approach-2
read -p "Enter your username: " USERNAME   # -p for prompt message with read command

# Approach-3
read -sp "Enter your password: " PASSWORD  # -s input without displaying on screen

echo "Hello, $USERNAME" 
````

## 6. Arithmetic Operators:
````bash
read -p "Enter Number one: " n1
read -p "Enter Number two: " n2

echo "$n1 + $n2 is = " $((n1 + n2))
echo "$n1 + $n2 is = " $((n1 - n2))
echo "$n1 + $n2 is = " $((n1 * n2))
echo "$n1 + $n2 is = " $((n1 / n2))
````


## 7. Conditions:
````bash
# Check if NAME is Admin
if [ $NAME == "Admin" ]; then
    echo "Welcome, Admin!"
else
    echo "Access denied."
fi
````

````bash
# Check if input is greater than 10 or not
if [[ $VAR -gt 10 ]] && [[ $VAR -lt 50 ]]; then
    echo "The number is greater than 10"
elif [[ $VAR -eq 10 ]]; then
    echo "The number is 10"
else
    echo "Access denied."
fi
````

````bash
# Check if single file exists
if [ -f "file.txt" ]; then
  echo "File exists."

# Check if multiple files exists
if [ -f /etc/demo.conf -a -f /etc/hosts ]; then
    echo "Both files exists"
else
    echo "Both files doesn't exists"
fi

# For Directory
if [ -d /temp ]; then
  echo "temp directory exists"
````
- `-f`: file; `-d`: directory
- `-a`: and

````bash
# Check if variable is empty
read -p "Enter username: " USERNAME

if [ -z "$USERNAME" ]; then
  echo "$USERNAME is empty"
fi
````
- `-z`: Tests if the string is empty.

### String Operators

| Operator | Description                   | Example                 |
|----------|-------------------------------|-------------------------|
| `-z`     | True if the string is empty   | `[ -z "$VAR" ]`         |
| `-n`     | True if the string is not empty | `[ -n "$VAR" ]`       |
| `=`      | True if two strings are equal | `[ "$VAR1" = "$VAR2" ]` |
| `!=`     | True if two strings are not equal | `[ "$VAR1" != "$VAR2" ]` |



### File Operators

| Operator | Description                                   | Example               |
|----------|-----------------------------------------------|-----------------------|
| `-e`     | True if the file exists                      | `[ -e "file.txt" ]`   |
| `-f`     | True if the file exists and is a regular file | `[ -f "file.txt" ]`   |
| `-d`     | True if the file exists and is a directory    | `[ -d "directory" ]`  |
| `-r`     | True if the file is readable                 | `[ -r "file.txt" ]`   |
| `-w`     | True if the file is writable                 | `[ -w "file.txt" ]`   |
| `-x`     | True if the file is executable               | `[ -x "script.sh" ]`  |

---

### Integer Operators

| Operator | Description                                                | Example                  |
|----------|------------------------------------------------------------|--------------------------|
| `-eq`    | True if integers are equal                                 | `[ "$NUM1" -eq "$NUM2" ]` |
| `-ne`    | True if integers are not equal                             | `[ "$NUM1" -ne "$NUM2" ]` |
| `-lt`    | True if the first integer is less than the second          | `[ "$NUM1" -lt "$NUM2" ]` |
| `-le`    | True if the first integer is less than or equal to the second | `[ "$NUM1" -le "$NUM2" ]` |
| `-gt`    | True if the first integer is greater than the second       | `[ "$NUM1" -gt "$NUM2" ]` |
| `-ge`    | True if the first integer is greater than or equal to the second | `[ "$NUM1" -ge "$NUM2" ]` |

---

### Logical Operators

| Operator | Description                            | Example                            |
|----------|----------------------------------------|------------------------------------|
| `!`      | Logical NOT (negates a condition)      | `[ ! -z "$VAR" ]`                 |
| `-a`     | Logical AND                            | `[ -n "$VAR1" -a -n "$VAR2" ]`    |
| `-o`     | Logical OR                             | `[ -z "$VAR1" -o -z "$VAR2" ]`    |



### Advanced Examples
**Check if a variable is set and non-empty:**
````bash
if [ -n "$USERNAME" ]; then
  echo "USERNAME is set: $USERNAME"
else
  echo "USERNAME is empty or unset"
fi

````

**Delete the username if it exists:**
````bash
read -p "Enter the username you want to delete: " USERNAME
USERVAR="$(cat /etc/passwd | grep $USERNAME | cut -d ":" -f 1)"
if [ -n "$USERVAR" ]; then
  echo "$USERNAME exists and I am deleting it"
  userdel -r $USERVAR
else
  echo "USERNAME is empty or unset"
fi
````

**Check if file is executable**
````bash
if [ -X "$FILE" ]; then
  echo "File $FILE is executable"
fi
````

## 8. Loops:
````bash
for i in {1..5}; do
    echo "Number $i"
done
````

````bash
for i in 1 2 3 4 5; do
    echo "Welcome $i times"
done
````

````bash
for i in 1 2 3 4 5; do
    echo "Welcome $i times"
done
````

````bash
read -sp "Enter the password that you want to set to the users: " PASS
#for USER in user1 user2 user3 user4 user5; do
for USER in $(cat users.txt); do
  useradd $USER
  echo "$PASS" | passwd --stdin $USER
done
````

````bash
read -p "Enter the username: " USERNAME

for HOSTS in $(cat hosts.txt); do
    # &>: Redirects both stdout (standard output) and stderr (standard error) to the specified location.
    # /dev/null: A special file that discards all data written to it. Redirecting output to /dev/null effectively silences the command, so you don't see any output in the terminal.
    ping -c3 $HOSTS &> /dev/null # c3: count-3==> ping 3 times; /dev/null: Redirects both stdout  and stderr to the specified location.
    if [ $? -eq 0 ]; then
        echo "$HOSTS is UP"
        ssh root@$HOSTS useradd $username
    else
      echo "$HOSTS is DOWN"
    fi
done
````


## 9. Functions:
````bash
greet() {
    echo "Hello, $1"
}
greet "World"
````


## 10. HERE DOC
````bash
cat <<EOF
  This is a multiline message.
  It can contain multiple line of text
EOF
````

**Output (">") the HereDoc content to file.txt**:
````bash
cat <<EOF> file.txt
  The current working directory is: $PWD
  You are logged in as: $(whoami)
EOF
````