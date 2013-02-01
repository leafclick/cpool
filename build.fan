#!/usr/bin/env fan

using build

**
** Build: cpool
**
class Build : BuildPod
{
  new make()
  {
    podName = "cpool"
    version = Version("1.0")
    summary = "fantom sql connection pool"
    meta    = ["proj.name":    "cpool",
               "license.name": "Apache License, Version 2.0" ]
    depends = ["sys 1.0+", "sql 1.0+", "util 1.0+", "concurrent 1.0+", "build 1.0+"]
    srcDirs = [`fan/`, `test/`]
    javaDirs = [`native/src/cpool/`, `native/src/org/slf4j/impl/`]
    resDirs = Uri[,]
  }

  @Target { help = "Compile to pod file and associated natives, then mix it with requied jars" }
  override Void compile(){
    File[] files := jarFiles
    File homeDir := Env.cur.homeDir
    extDir := homeDir + `lib/java/ext/`
    files.each{
      targetFile := extDir + it.name.toUri
      if(!targetFile.exists) {
        File res := it.copyInto(extDir)
        res.deleteOnExit
      }
    }
    super.compile
    jarJar()
  }

  once File jarsFolder(){
    File sourceFile := File(((Str) typeof->sourceFile).toUri)
    jarsFolder := sourceFile.parent + `jars/`
    return jarsFolder
  }
  
  File[] jarFiles(){
    File homeDir := Env.cur.homeDir
    forCompileDir := jarsFolder
    
    return [forCompileDir + `bonecp-0.7.1.RELEASE.jar`,
                    forCompileDir + `guava-14.0-rc1.jar`,
                    forCompileDir + `slf4j-api-1.6.6.jar`]
  }

  Void jarJar(){
    jdk      := JdkTask(this)
    jarExe   := jdk.jarExe
    curPod   := outPodDir.toFile + `${podName}.pod`
    jtemp    := scriptDir + `temp-java/`
    if(jtemp.exists){
      jtemp.delete
    }
    jtemp.create
    
    addJar(jarExe, jtemp, jarFiles)

    log.info("curPod.osPath=$curPod.osPath")
    Exec(this, [jarExe, "-xf", curPod.osPath], jtemp).run
    Exec(this, [jarExe, "-fu", curPod.osPath, "-C", jtemp.osPath, "."], jtemp).run

    Delete(this, jtemp).run
  }
  
  Void addJar(Str jarExe, File jtemp, File[] files){
    files.each|File f|{
      Exec(this, [jarExe, "-xf", f.osPath], jtemp).run
    }
  }

  Void addSubFolders(Uri[] arr, Uri folder) {
    Str sourceFile := typeof->sourceFile
    File curFile := File(sourceFile.toUri)
    theDirFile := curFile.parent + folder

    if(! theDirFile.exists){
        throw Err("Folder $theDirFile does not exist ")
    }

    theDirFile.walk |File f|{
	    if(f.isDir){
		arr.add(f.pathStr[(theDirFile.pathStr.size - (folder.toStr.size))..(f.pathStr.size - 1)].toUri)
	    }
    }
  }
}
