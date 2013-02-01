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

using concurrent

class TestCPool  : Test
{

    Void testLifecycle()
    {
        config := CPoolConfig() { url = "jdbc:h2:~/test"; username="sa" }
        s := CPool(config)

        // initial state
        verifyEq(s.isInstalled, false)
        verifyEq(s.isRunning, false)
        verifyService(CPool#, null)

        // install
        verifySame(s.install, s)
        verifyEq(s.isInstalled, true)
        verifyEq(s.isRunning, false)
        verifyService(CPool#, s)

        // start
        verifySame(s.start, s)
        verifySame(s.start, s)
        verifyEq(s.isInstalled, true)
        verifyEq(s.isRunning, true)
        verifyService(CPool#, s)

        // stop
        verifySame(s.stop, s)
        verifySame(s.stop, s)
        verifyEq(s.isInstalled, true)
        verifyEq(s.isRunning, false)
        verifyService(CPool#, s)

        // uninstall
        verifySame(s.uninstall, s)
        verifySame(s.uninstall, s)
        verifyEq(s.isInstalled, false)
        verifyEq(s.isRunning, false)
        verifyService(CPool#, null)

        // start implies
        verifySame(s.start, s)
        verifyEq(s.isInstalled, true)
        verifyEq(s.isRunning, true)
        verifyService(CPool#, s)

        // uninstall implies stop
        verifySame(s.uninstall, s)
        verifyEq(s.isInstalled, false)
        verifyEq(s.isRunning, false)
        verifyService(CPool#, null)

    }

    Void testConnection()
    {
        config := CPoolConfig() { url = "jdbc:h2:~/test"; username="sa" }
        s := CPool(config)

        // clean starting state
        verifyService(CPool#,  null)

        // start service
        verifySame(s.start, s)

        db := s.getConnection()
        try {
            stmt := db.sql("""select 'hello' as hello from dual""").prepare
            rows := stmt.query
            verifyEq(rows.size, 1)
            verifyEq(rows[0]->hello, "hello")
            stmt.close
        } finally {
            db.close
        }

        // stop and uninstall
        verifySame(s.uninstall, s)
        // verify clean state
        verifyEq(s.isInstalled, false)
    }

    Void testPool()
    {
        // clean starting state
        verifyService(CPool#,  null)

        // start service
        service := CPool(CPoolConfig() { url = "jdbc:h2:~/test"; username="sa" })
        verifySame(service.start, service)

        connectingClosure := |Obj? msg->Str?| {
            Str s := (Str) msg;
            CPool fbcp := Service.find(CPool#)
            db := fbcp.getConnection
            try {
               stmt := db.sql("""select '$s' as hello from dual""").prepare
               rows := stmt.query
               if (rows.size != 1)
                 throw Err("Unexpected resultset size!")
               col0 := rows[0].cols[0]
               if (s != rows[0].get(col0))
                    throw Err("Unexpected query result from DB!")
               return s;
            } finally {
               db.close
            }

            return "bs";
        }

        actors := Actor[,]
        500.times {
            actors.add(Actor(ActorPool(), connectingClosure))
        }

        n := 10000
        futures := Future[,]
        n.times {
            a := actors[Int.random(0..<actors.size)]
            f := a.send("a" + it)
            futures.add(f)
        }

        n.times {
            verifyEq(futures[it].get(5sec), "a${it.toStr}")
        }

        // stop and uninstall
        verifySame(service.uninstall, service)
        // verify clean state
        verifyEq(service.isInstalled, false)
    }

    Void verifyService(Type t, Service? s)
    {
        uri := "/sys/service/$t.qname".toUri
        if (s == null)
        {
            verifyEq(Service.find(t, false), null)
            verifyErr(UnknownServiceErr#) { Service.find(t) }
            verifyErr(UnknownServiceErr#) { Service.find(t, true) }
        }
        else
        {
            verify(Service.list.contains(s))
            verify(Service.findAll(t).contains(s))
            verifySame(Service.find(t), s)
            verifySame(Service.find(t, false), s)
            verifySame(Service.find(t, true), s)
        }
    }

}


const class ConnectingActor : Actor
{
    new make(ActorPool p) : super(p) {}

    override Obj? receive(Obj? msg) {
        Str s := (Str) msg;
        db := CPool(CPoolConfig() { url = "jdbc:h2:~/test"; username="sa" }).getConnection
        try {
            stmt := db.sql("select '$s' as hello from dual").prepare
            rows := stmt.query()

            if (rows.size != 1 || s != rows[0].trap(s.toStr))
                throw Err("Unexpected result retrieved from db!")

            return s;
        } finally {
            db.close
        }
        return null;
  }
}
