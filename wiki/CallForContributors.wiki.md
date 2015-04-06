Lua Alchemy (http://code.google.com/p/lua-alchemy) is the system that
brings Lua (http://lua.org) to Adobe Flash -- and it needs your help!

We have started our development in December 2008. We are now at
version 0.2.2.

Lua Alchemy currently allows running Lua code from AS3 and allows that
Lua code to use AS3 objects transparently. (See our live demo:
http://lua-alchemy.googlecode.com/svn/trunk/demo/index.html)

Lua Alchemy is impressive as it is now, but it can be even better!

We have large number of features to implement, from easiest coding
tasks to the hard but interesting intellectual challenges. As Lua
Alchemy is still in early stage of development, it has a couple of
non-fatal issues, that nevertheless do annoy its users.

See our issue tracker: http://code.google.com/p/lua-alchemy/issues/list

Some of most juicy features planned:

  * Fast AS3 — Lua communication interface
  * Lua replacement for MXML.
  * Full support for advanced Lua types (tables, coroutines) from AS3.
  * A library to wrap asynchronous AS3 operations (like file access) into Lua coroutines for more straightforward end-user's code. (Also would serve as a workaround for the notorious flyield() bug of Adobe Alchemy, allowing remote dofile() etc.)

# Can You Help Lua Alchemy?

  * Have a question on how Lua Alchemy works or how is best to use it?
  * Want to share how you use Lua Alchemy in your project?
  * Have an idea on how to make Lua Alchemy better?
  * Have some time to write documentation?
  * Perhaps even have some time to contribute code?

Please post to lua-alchemy-dev@googlegroups.com!

(You may also add an issue to our bug-tracker: http://code.google.com/p/lua-alchemy/issues/list)

# On Code Contributions

We accept:

  1. GitHub pull requests from your forks (preferable).
  1. Git patches based on the master branch (send them to the mailing list).
  1. If you're not familiar with Git, but do want to help, you may simply get current master, change it and send to mailing list a regular patch (or even modified master itself in an archive).

When writing code for Lua Alchemy, please try to follow these non-mandatory
simple rules:

  1. Try to follow code style. (Some things are described here: http://code.google.com/p/lua-alchemy/wiki/CodingGuidelines.)
  1. Try to write tests for the code you wrote.
  1. If to implement a feature you need to write some complex code, please ask in the mailing list first -- perhaps one of us have something relevant around.

What do you need to know:

To contribute code to Lua Alchemy, you need to know ActionScript
and/or plain C and/or Lua. We have some tasks for any of these
languages alone, however, due to the nature of Lua Alchemy, most of
our tasks require a mix of them in various proportions. If you do not
know any of these technologies, but still want to help, do not
hesitate asking any questions on mailing list.

# How to Setup Development Environment

If you're on OS X or Linux, things are easy. Just install Adobe Flex
SDK (http://opensource.adobe.com/wiki/display/flexsdk/Setup) and Adobe
Alchemy (http://labs.adobe.com/wiki/index.php/Alchemy:Documentation:Getting_Started)
and you're good to go.

If you're on Windows, things are bit harder. This guide describes how
to install required toolchain on Windows:
http://code.google.com/p/lua-alchemy/wiki/SetupFlexSdkAlchemyOnWindows.
As you may see it is a rather complicated process.

To help our contributors who work on Windows, we plan to create free
VMWare Appliance image (runnable in a free VMWare player), containing
full Lua Alchemy toolchain installed on Ubuntu JeOS system. This would
allow users to compile Lua Alchemy code without installation hassle,
while still allowing to edit it in a favorite Windows IDE. If you'd
like to use such appliance, please drop a note to the mailing list, we
would provide it ASAP.

# One Final Note

Please remember: we're always glad to help you! If you have any
questions, please post them to the mailing list
(lua-alchemy-dev@googlegroups.com or
http://groups.google.com/group/lua-alchemy-dev)

