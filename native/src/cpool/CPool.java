//
// Copyright 2012 leafclick s.r.o. <info@leafclick.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

package fan.cpool;

import fan.sys.*;
import fan.sql.*;
import java.sql.*;
import java.util.Enumeration;

import com.jolbox.bonecp.BoneCP;
import com.jolbox.bonecp.BoneCPConfig;

public class CPool extends Service$ implements Service {
    public final Log log()
    {
        if (log == null) log = Log.get("cpool");
        return log;
    }

    // constructor factory called by Foo.make
    public static CPool make(CPoolConfig config) {
        CPool self = new CPool();
        make$(self, config);
        return self;
    }

    // constructor implementation called by subclasses
    public static void make$(CPool self, CPoolConfig config) {
        self.config = config;
        org.slf4j.impl.StaticLoggerBinder binder = org.slf4j.impl.StaticLoggerBinder.getSingleton();
    }

    // boiler plate for reflection
    public Type typeof() {
        if (type == null) type = Type.find("cpool::CPool");
        return type;
    }

    private static Type type;

    @Override
    public boolean isInstalled() {
        return Service$.isInstalled(this);
    }

    @Override
    public boolean isRunning() {
        return Service$.isRunning(this);
    }

    @Override
    public Service install() {
        return Service$.install(this);
    }

    @Override
    public Service uninstall() {
        return Service$.uninstall(this);
    }

    @Override
    public Service start() {
        return Service$.start(this);
    }

    @Override
    public Service stop() {
        return Service$.stop(this);
    }


    public void onStart() {

        listRegisteredDrivers();

        Connection connection = null;
        try {
            // setup the connection pool
            BoneCPConfig boneCPConfig = new BoneCPConfig();
            boneCPConfig.setJdbcUrl(config.url);
            boneCPConfig.setUsername(config.username);
            boneCPConfig.setPassword(config.password);
            boneCPConfig.setMinConnectionsPerPartition((int) config.minConnectionsPerPartition);
            boneCPConfig.setMaxConnectionsPerPartition((int) config.maxConnectionsPerPartition);
            boneCPConfig.setPartitionCount((int) config.partitionCount);
            boneCPConfig.setAcquireIncrement((int) config.acquireIncrement);
            boneCPConfig.setReleaseHelperThreads((int) config.releaseHelperThreads);
            boneCPConfig.setLogStatementsEnabled(config.logStatementsEnabled);

            synchronized (poolLock) {
                if (connectionPool == null)
                    connectionPool = new BoneCP(boneCPConfig); // setup the connection pool
                else {
                    throw Err.make("Connection pool already started! Please shutdown the service first.");
                }
            }

            // test connectivity
            connection = connectionPool.getConnection(); // fetch a connection
            if (connection != null) {
                log().info("Connection pool has been started.");
            } else {
                connectionPool.shutdown(); // shutdown connection pool.
                throw Err.make("Can't start sql connection pool!");
            }
        } catch (SQLException e) {
            log().err("Connection pool setup error", e);
        } finally {
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    log().err("Connection cleanup error", e);
                }
            }
        }

    }

    public void onStop() {
            synchronized (poolLock) {
                if (connectionPool != null)
                    connectionPool.shutdown(); // shutdown connection pool.
                connectionPool = null;
            }
    }


    private void listRegisteredDrivers() {
        try {
            Enumeration enumeration = DriverManager.getDrivers();
            while (enumeration.hasMoreElements()) {
                Driver d = (Driver) enumeration.nextElement();
                log().debug("Registered JDBC driver: " + d.getClass().getName());
            }
        } catch (Exception e) {
            throw Err.make("Error listing registered JDBC drivers", e);
        }
    }


    public SqlConn getConnection()
    {
        try {
            java.sql.Connection jconn = null;
            synchronized (poolLock) {
                if (connectionPool != null) {
                    jconn = connectionPool.getConnection();
                } else {
                    throw new SQLException("Connection pool is not initialized!");  
                }
            }
            return SqlConnImplPeer.wrapConnection(jconn);
        } catch (SQLException e) {
            throw SqlErr.make(e.getMessage(), Err.make(e));
        }
    }

    static { loadDrivers(); }
        
    private static void loadDrivers()
    {
        try
        {
            String val = Pod.find("sql").config("java.drivers");
            if (val == null) { return; }
            String[] classNames = val.split(",");
            for (int i=0; i<classNames.length; ++i)
            {
                String className = classNames[i].trim();
                try
                {
                    Class.forName(className);
                }
                catch (Exception e)
                {
                    System.out.println("WARNING: Cannot preload JDBC driver: " + className);
                }
            }
        }
        catch (Throwable e)
        {
            System.out.println(e);
        }
    }

    private static Object poolLock = new Object();
    private BoneCP connectionPool = null;
    private Log log;

    public CPoolConfig config;
}
