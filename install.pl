#!/usr/bin/perl
#
# installation program for rotfl 0.6.5
# last modified on April 3, 2000 by Chris Lumens

   # "autoconf" time...locate programs we need for installation
print "looking for needed programs...\n";

foreach my $dir ('/opt/bin', '/usr/local/bin', '/usr/bin', '/bin')
{
   if (-x "$dir/install")
   {
      print "found install in $dir\n";
      $INSTALL = "$dir/install"  
   }

   if (-x "$dir/gzip")
   {
      print "found gzip in $dir\n";
      $GZIP = "$dir/gzip";
   }

   if (-x "$dir/cat")
   {
      print "found cat in $dir\n";
      $CAT = "$dir/cat";
   }
   
   if (-x "$dir/pod2man")
   {
      print "found pod2man in $dir\n";
      $POD2MAN = "$dir/pod2man";
   }
}   

if (! defined($INSTALL)) { print "cannot find program: $INSTALL\n" ; exit; }
if (! defined($GZIP))    { print "cannot find program: $GZIP\n"    ; exit; }
if (! defined($CAT))     { print "cannot find program: $CAT\n"     ; exit; }
if (! defined($POD2MAN)) { print "cannot find program: $POD2MAN\n" ; exit; }

system ("clear");
print <<Welcome;

----------------------------------
    rotfl Installation Program
----------------------------------

Welcome to the rotfl installation program!  This program will copy
everything to the appropriate directories and get everything set up
for you to use rotfl!  Just follow the directions and you will be 
using rotfl in no time!

*** You must be root to install rotfl!  If you are not root, quit ***
*** now by hitting control+c.  This installation will fail badly  ***
***                     if you are not root!                      ***

Press enter to continue...
Welcome
<STDIN>;

system ("clear");

print <<Prefix;
===========================
==> Installation Prefix <==
===========================

The default installation prefix is /usr/local.  You may want rotfl
to use another base directory for installation.  You may specify
that directory now, or press enter to use the default.

Prefix

print 'Which installation prefix? [/usr/local] ';
chomp ($user_prefix = <STDIN>);

if ($user_prefix eq '') { $PREFIX = '/usr/local'; }
else                    { $PREFIX = $user_prefix; }

   # set install variables depending on the user's input prefix
$BIN = "$PREFIX/bin";
$MAN = "$PREFIX/man/man1";
$LIB = "$PREFIX/lib/rotfl";
$DOC = "$PREFIX/doc/rotfl";

   # we want the uninstall program to be able to uninstall everything from
   # the directories that is was installed to.  so, write the prefix into the
   # uninstall script.
open (UNINST, 'uninstall.in') || die ('cannot open template uninstall script');
open (OUT, '>uninstall.pl')   || die ('cannot open output uninstall script');
while (<UNINST>)
{
   print OUT $_;
   print OUT "\$PREFIX = '$PREFIX';\n" if (/insert\ prefix/);
}
close (UNINST);
close (OUT);

system ("clear");

print <<ReadKey_install;

===================================
==>    Required Perl Modules    <==
===================================

Unfortunately, rotfl requires that you have the Term::ReadKey module
installed from CPAN.  We need to determine if you have this module.
If you do not, it will be compiled and installed for you.

ReadKey_install

print 'Do you have Term::ReadKey installed? [y/n]: ';
chomp ($got_module = <STDIN>);

if ($got_module =~ /n/i)
{
   print <<Build_module;
   
=======================   
==> Building Module <==
=======================

Okay.  I am going to build the Term::ReadKey module for you.  This
consists of the following steps:

- Decompressing the module archive.
- Making the makefile.
- Building the module.
- Testing to see if the module was built properly.
- Installing it.

Press enter to continue.
Build_module
<STDIN>;

   $current_dir = $ENV{$PWD};
   system "cp TermReadKey-2.14.tar.gz /tmp; cd /tmp; tar -xvzf TermReadKey-2.14.tar.gz";
   system "cd /tmp/TermReadKey-2.14; perl Makefile.PL; make; make test; make install";
   system "cd $current_dir";
}
   
print <<"Ready";
   
========================
==> Ready to install <==
========================

Now it is time to move on to the actual rotfl installation.  We are
going to use $PREFIX as the location to install everything under.

Press enter to continue.
Ready
<STDIN>;

print <<Copying;

=====================
==> Copying files <==
=====================

We are now copying the various rotfl files to their locations under
the prefix.  This will only take a second (unless you have a very 
slow computer.)
Copying

system ("rm -r $LIB/examples") if (-d "$LIB/examples");

print  ("$INSTALL -g bin -m 755 -o root ./rotfl $BIN/rotfl\n");
system ("$INSTALL -g bin -m 755 -o root ./rotfl $BIN/rotfl");

print  ("$POD2MAN --center=\"text formatting system\" --lax rotfl >rotfl.1\n");
system ("$POD2MAN --center=\"text formatting system\" --lax rotfl >rotfl.1");
print  ("$CAT rotfl.1 | $GZIP -9c > rotfl.1.gz\n");
system ("$CAT rotfl.1 | $GZIP -9c > rotfl.1.gz");
print  ("$INSTALL -g root -m 644 -o root ./rotfl.1.gz $MAN/rotfl.1.gz\n");
system ("$INSTALL -g root -m 644 -o root ./rotfl.1.gz $MAN/rotfl.1.gz");
system ("rm -rf ./{rotfl.1.gz,rotfl.1}");

print  ("$INSTALL -g root -m 755 -o root -d $LIB\n");
system ("$INSTALL -g root -m 755 -o root -d $LIB");
print  ("$INSTALL -g root -m 644 -o root ./examples/* $LIB\n");
system ("$INSTALL -g root -m 644 -o root ./examples/* $LIB");
print  ("$INSTALL -g root -m 755 -o bin ./uninstall.pl $LIB/uninstall.pl\n");
system ("$INSTALL -g root -m 755 -o root ./uninstall.pl $LIB/uninstall.pl");

print  ("$INSTALL -g root -m 755 -o root -d $DOC\n");
system ("$INSTALL -g root -m 755 -o root -d $DOC");

foreach (HOWTO, README, TODO, NEWS, COPYING, CHANGES)
{
   print  ("$INSTALL -g root -m 644 -o root ./$_ $DOC/$_\n");
   system ("$INSTALL -g root -m 644 -o root ./$_ $DOC/$_");
}

print <<"All_done";

=================
==> All done! <==
=================

Well, my work here is done.  Everything has been installed properly.
Check out the documentation that has been placed in $DOC.  
There are example rotfl files in $LIB.

And just in case you want to remove rotfl at some later time, I put
the uninstall program in $LIB.  It is called uninstall.pl.

Enjoy using rotfl!
   - Chris Lumens <chris\@bangmoney.org>
   
All_done
