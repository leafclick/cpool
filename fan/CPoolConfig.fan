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

**
** Connection pool configuration class.
**
const class CPoolConfig
{
  **
  ** DB connection string.
  **
  const Str url

  **
  ** User name to use.
  **
  const Str username

  **
  ** Password to use.
  **
  const Str password := ""

  **
  ** Min number of connections per partition.
  **
  const Int minConnectionsPerPartition := 5

  **
  ** Max number of connections per partition.
  **
  const Int maxConnectionsPerPartition := 10

  **
  ** Number of partitions.
  **
  const Int partitionCount := 1

  **
  ** Number of new connections to create in 1 batch.
  **
  const Int acquireIncrement := 2

  **
  ** Number of release-connection helper threads to create per partition.
  **
  const Int releaseHelperThreads := 3

  **
  ** If set to true, log SQL statements being executed.
  **
  const Bool logStatementsEnabled := false

  **
  ** Default constructor
  **
  new make(|This|? f := null)
  {
    if (f != null) f(this)
  }

}
