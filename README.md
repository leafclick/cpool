Introduction
============
The `cpool` is a Fantom pod that provides simple SQL connection pooling. Under the hood it uses BoneCP for connection pooling.

Installation:
=============

Required software
-----------------
- Sun Jdk 1.6+
- [Fantom 1.0.65+](http://fantom.org)
- [Google Guava (14.0-rc1)](http://code.google.com/p/guava-libraries/)
- [BoneCP](http://jolbox.com/download.html)

Pod pre-install
-----------------------------------
- copy `guava-14.0-rc1.jar` into `$FAN_HOME/lib/java/ext/`

Pod pre-test
-----------------------------------
- Download [H2 database](http://www.h2database.com/html/download.html)
- copy `h2-1.3.167.jar` into `$FAN_HOME/lib/java/ext/`
- ensure that `$FAN_HOME/etc/sql/config.props` contains this line:
  `java.drivers=com.mysql.jdbc.Driver,org.h2.Driver`

Setup and build
---------------
    $ fan build.fan && fan build.fan test

  

Usage
=====

Apart from setting up a connection pool and obtaining a connection the `cpool` pod is used just like the standard Fantom `sql` pod.

        // Connect to the database as "sa" user
	config := CPoolConfig() { url = "jdbc:h2:~/test"; username="sa" }
        poolService := CPool(config)

        // start the service
        poolService.start

        // Get a connection from the pool
        db := poolService.getConnection()
        try {
            // prepare and run the query
            stmt := db.sql("""select 'hello' as hello from dual""").prepare
            rows := stmt.query

            // do stuff
            echo("First row: " + rows[0]->hello)

            // close the statement 
            stmt.close
        } finally {
            // return the connection to the pool
            db.close
        }

