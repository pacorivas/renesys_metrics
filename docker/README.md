# DOCKER MySQL

## Run MySQL container with local DB
```console
docker run --name my-mysql -e MYSQL_ROOT_PASSWORD=your_password -v /Users/paco/mysql/db:/var/lib/mysql -p 33060:3306 -d mysql:8.0
```