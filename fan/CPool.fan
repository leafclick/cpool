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

using sql

native const class CPool : Service
{
  **
  ** Standard log for web service
  **
  internal static const Log log := Log.get("cpool")

  **
  ** CPool configuration
  **
  const CPoolConfig config := CPoolConfig()

  **
  ** Constructor with configuration
  **
  new make(CPoolConfig config)

  **
  ** Get new Connection from connection pool
  **
  SqlConn getConnection()

}
