# Setup flexSDK on Windows
Information from:
**http://opensource.adobe.com/wiki/display/flexsdk/Setup+on+Windows**

### Install the latest version of Cygwin

Download Cygwin's installer, `setup.exe`, here and run it (Vista/IE7 users may need to right-click on the link and save the file locally before running it, as it may not run directly from clicking in the browser). You can accept the default settings, except that you must set the Default Text File Type to "DOS / Text".

There is no official site from which to download Cygwin; the setup program offers a number of mirrors for you to choose. Some of them can be flaky, so if you have a problem, try a different mirror. We've had good luck with **[ftp://mirrors.kernel.org](ftp://mirrors.kernel.org) and**http://mirrors.kernel.org .

Double-clicking `C:\cygwin\Cygwin.bat` opens a window in which you can enter command lines. You'll probably want to keep a shortcut to this somewhere convenient.

### Install J2SE 5.0\_13

Sun has archived this particular release here. Click on the "Download JDK" link and accept the license agreement. Click the "Windows Offline Installation, Multi-language" link to download the installer, which is named `jdk-1_5_0_13-windows-i586-p.exe`.

Run this installer, which requires administrative permissions. You should accept all of the installer's defaults. The branch setup scripts assume that the JDK will be installed at `C:\Program Files\Java\jdk1.5.0_13`. Wait until the installer completes, then restart your machine.

### Install Ant 1.7.0

Download the Apache Ant Project's archived release of Ant 1.7.0 and unzip it (Vista/IE7 users may need to right-click on the link and save the file locally before opening it, as it may unzip directly from clicking in the browser). Put the apache-ant-1.7.0 in cygwin. Add Ant export in `.bashrc` file
```
export ANT_HOME="$(cygpath -w -i /path_to_ant)"
export PATH="${PATH}${PATH:+:}$(cygpath -u ${ANT_HOME}\\bin)"
```

### Configure Flash Player
```
mm.cfg
```

Download mm.cfg into your Windows home directory (`C:\Documents and Settings\username`). This file specifies
```
ErrorReportingEnable = 1
TraceOutputFileEnable = 1
```

If your system already has an mm.cfg file, paste these two lines into it.
FlashPlayerTrust

Open the directory `C:\WINDOWS\system32\Macromedia\Flash`. If it doesn't already contain a directory named FlashPlayerTrust, create one. Download FlexSDK.cfg into FlashPlayerTrust. Vista/IE7 users may need to save the file onto the desktop first and then copy it locally into this directory; saving into a folder in the `WINDOWS\system32` hierarchy directly from IE7 may quietly fail due to the browser's security model.

This file simply contains
```
C:\
```

so that SWFs anywhere on your `C:` drive are trusted to load local content. If you don't develop on `C:` drive, change the drive letter or add additional lines.

Note: If you are getting "Security Sandbox Violation" errors (e.g. when running ant checkintests), you may need to use more specific directories than `C:\`, e.g. `C:\dev\`. You may put one on each line.
Test your setup

To test your setup, launch Cygwin, change your working directory to the trunk of the Flex SDK, and run its setup.sh script:
```
cd flex/sdk/trunk
source setup.sh
```

Execute

```
java -version
```

and confirm that Java 1.5.0\_13 is being found.

Execute

```
ant -version
```

and confirm that Ant 1.7.0 is being found. If you see the warning "cygpath: can't convert empty path", you can ignore it.


# Setup Alchemy on Windows
Information from:
**http://labs.adobe.com/wiki/index.php/Alchemy:Documentation:Getting_Started#Windows**

This section will show how to setup and use Alchemy on Windows using Cygwin.
Requirements

  * Alchemy Toolkit Package for your operating system
  * Cygwin with the following packages installed
    * Perl
    * zip
    * gcc / g++
  * Java
  * Flex 3.2 SDK
  * Flex Builder or Flex SDK setup to target compilation for Flash Player 10

**Step 1** Download and install Cygwin. Make sure to install the following packages:

  * Perl
  * zip
  * gcc / g++

**Step 2** Download and install Java.

**Step 3** Make sure to restart the Cygwin terminal after installing Java.

**Step 4** Download and install the Flex SDK, and add the `$FLEX_HOME/bin` directory to your Cygwin environment's path (within `~/.bashrc`) (See below for an example).

**Step 5** Download the Alchemy Package for your system from the pre-release site. For this example, we will assume that Windows is being used.

**Step 6** Unzip the package and copy the alchemy folder to you system. We will refer to this path as `$ALCHEMY_HOME`

**Step 7** Open a Cygwin terminal and change to the `$ALCHEMY_HOME/` directory.

**Step 8** Run the `$ALCHEMY_HOME/config` script
```
./config
```
**Step 9** Open alchemy\_setup for editing and add the path to the ADL executable (included in the Flex SDK):
```
export ADL=/cygdrive/c/flex/bin/adl.exe
```
Make sure to uncomment this line, and that it contains the path to `ADL.exe` on your system.

**Step 10** Open your bash setup script to edit. This can usually be found in the `~/.bashrc` file.

**Step 11** Edit the the `.bashrc` script so that `alchemy-setup` is run when the script is run:
```
source /cygdrive/c/alchemy/alchemy-setup
```
This should be added before your PATH is modified.

**Step 12** Add $ALCHEMY\_HOME/achacks to your path.
```
PATH=$ALCHEMY_HOME/achacks:/cygdrive/c/flex/bin:$PATH
```
You `.bashrc` file should look similar to:

```
source /cygdrive/c/alchemy/alchemy-setup
PATH=$ALCHEMY_HOME/achacks:/cygdrive/c/flex/bin:$PATH
export PATH
```

The file may contain other commands specific to your system.

**Step 13** Save the file, and restart your cygwin terminal.

**Step 14** Change to the `$ALCHEMY_HOME/bin` directory, and run the following command:
```
ln -s llvm-stub llvm-stub.exe
```
Note that this step wont be necessary in future builds.

**Step 15** Change to the `$ALCHEMY_HOME/samples/stringecho` directory

**Step 16** Type the following command in the terminal
```
alc-on; which gcc
```
It should print out the path that points to the gcc contained with the `$ALCHEMY_HOME/achacks/` directory.

**Step 17** Enter the following command to compile the `c` program into a `SWC`:
```
gcc stringecho.c -O3 -Wall -swc -o stringecho.swc
```
You should see output similar to:
```
$ gcc stringecho.c -O3 -Wall -swc -o stringecho.swc
WARNING: While resolving call to function 'main' arguments were dropped!

2544.achacks.swf, 363806 bytes written
frame rate: 60
frame count: 1
69 : 4
72 : 363736
76 : 33
1 : 0
0 : 0
frame rate: 24
frame count: 1
69 : 4
77 : 506
64 : 31
63 : 16
65 : 4
9 : 3
41 : 26
82 : 471
1 : 0
0 : 0
  adding: catalog.xml (deflated 75%)
  adding: library.swf (deflated 61%)
```
**Step 18** Type `ls -l` You should see output similar to:
```
labuser@LABVM-VU32EN /cygdrive/c/alchemy/samples/stringecho
$ ls -l
total 1181
-rw-r--r--  1 labuser        None 344376 Oct 22 12:28 1664.achacks.exe.bc
-rw-r--r--  1 labuser        None    956 Oct 22 12:28 1664.achacks.o
-rw-r--r--  1 labuser        None 344376 Oct 22 14:38 2232.achacks.exe.bc
-rw-r--r--  1 labuser        None    956 Oct 22 14:38 2232.achacks.o
-rw-r--r--  1 labuser        None 344376 Oct 22 11:15 3688.achacks.exe.bc
-rw-r--r--  1 labuser        None    956 Oct 22 11:15 3688.achacks.o
drwx------+ 2 Administrators None      0 Oct 22 11:59 as3
-r-x------+ 1 Administrators None    435 Oct 20 20:41 readme.txt
-r-x------+ 1 Administrators None   1221 Oct 20 20:41 stringecho.c
-rwxr-xr-x  1 labuser        None 144099 Oct 22 14:38 stringecho.swc
```
Make sure `stringecho.swc` is present in the directory.

**Step 19** The `stringecho.swc` SWC can now be used in a Flash Player 10 ActionScript or Flex project. Just link it in when compiling like your would link in any other SWC.

**Step 20** Change to the `$ALCHEMY_HOME/samples/stringecho/as3` directory.

**Step 21** This directory contains a simple ActionScript file that contains the following code which uses the `SWC` we just created:
```
package
{
	import flash.display.Sprite;
	import cmodule.stringecho.CLibInit;
	
	public class EchoTest extends Sprite
	{
		public function EchoTest()
		{
			var loader:CLibInit = new CLibInit;
			var lib:Object = loader.init();
			trace(lib.echo("foo"));
		}
	}
}
```
**Step 22** Use the following command to compile the ActionScript code using MXMLC:
```
mxmlc.exe -library-path+=../stringecho.swc --target-player=10.0.0 EchoTest.as
```
This will generate a Flash Player 10 `SWC` that traces "foo" when run in the debug player.
Troubleshooting

  * Make sure that you are compiling with the Alchemy version of the gcc tools. You can confirm this by typing:
```
      which gcc
```
  * Make sure to run the
```
      alc-on
```
> > command prior to compiling a project.

Thats all.

# Troubleshooting
Make sure that your user name is written in latin letters.