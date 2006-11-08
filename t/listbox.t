#!/usr/bin/perl -w
# -*- perl -*-

# This file is the translation of a Tcl script to test out the "listbox"
# command of Tk.  It is organized in the standard fashion for Tcl tests.
#
# Copyright (c) 1993-1994 The Regents of the University of California.
# Copyright (c) 1994-1997 Sun Microsystems, Inc.
# Copyright (c) 1998-1999 by Scriptics Corporation.
# All rights reserved.
#
# RCS: @(#) $Id: listbox.t,v 1.2 2002/04/17 21:06:12 eserte Exp $
#
# Translated to perl by Slaven Rezic
#

use strict;
use vars qw($Listbox);

use Tk;
use Tk::Config ();
my $Xft = $Tk::Config::xlib =~ /-lXft\b/;

use FindBin;
use lib "$FindBin::RealBin";
use TkTest;

use Getopt::Long;

BEGIN {
    $Listbox = "Listbox";
    #$Listbox = "TextList";
    GetOptions("listboxclass=s" => \$Listbox)
	or die "usage: $0 [-listboxclass baseclass]";

    eval "use Tk::$Listbox";
}

BEGIN {
    if (!eval q{
	use Test::More;
	1;
    }) {
	print "1..0 # skip: no Test::More module\n";
	exit;
    }
}

plan tests => 441;

my $partial_top;
my $partial_lb;

my $mw = new MainWindow;
$mw->geometry('+10+10');
$mw->raise;
## Always use the X11 font, even with Xft, otherwise the measurements would
## be wrong.
#my $fixed = $Xft ? '{Adobe Courier} -12' : 'Courier -12';
my $fixed = "-adobe-courier-medium-r-normal--12-120-75-75-m-*-iso8859-1";
ok(Tk::Exists($mw));

# Create entries in the option database to be sure that geometry options
# like border width have predictable values.
$mw->optionAdd("*$Listbox.borderWidth",2);
$mw->optionAdd("*$Listbox.highlightThickness",2);
## Again, prefer the X11 font.
#$mw->optionAdd("*$Listbox.font",
#                $Xft ? '{Adobe Helvetica} -12 bold' :'Helvetica -12 bold');
$mw->optionAdd("*$Listbox.font", 'Helvetica -12 bold');

my $lb = $mw->$Listbox->pack;
ok(Tk::Exists($lb), "Listbox exists");
isa_ok($lb, "Tk::$Listbox");
$lb->update;

my $skip_font_test;
if (!$Xft) { # XXX Is this condition necessary?
    my %fa = $mw->fontActual($lb->cget(-font));
    my %expected = (
		    "-weight" => "bold",
		    "-underline" => 0,
		    "-family" => "helvetica",
		    "-slant" => "roman",
		    "-size" => -12,
		    "-overstrike" => 0,
		   );
    while(my($k,$v) = each %expected) {
	if ($v ne $fa{$k}) {
	    $skip_font_test = "font-related tests";
	    last;
	}
    }
}

my $skip_fixed_font_test;
{
    my $fixed_lb = $mw->$Listbox(-font => $fixed);
    my %fa = $mw->fontActual($fixed_lb->cget(-font));
    my %expected = (
		    "-weight" => "normal",
		    "-underline" => 0,
		    "-family" => "courier", # with $Xft, this would be "Courier"
		    "-slant" => "roman",
		    "-size" => -12,
		    "-overstrike" => 0,
		   );
    while(my($k,$v) = each %expected) {
	if ($v ne $fa{$k}) {
	    $skip_fixed_font_test = "font-related tests (fixed font)";
	    last;
	}
    }
    $fixed_lb->destroy;
}

resetGridInfo();

$mw->Photo("testimage", -file => Tk->findINC("Xcamel.gif"));

foreach my $test
    (
     ['-activestyle', 'under', 'underline', 'foo',
      'bad activestyle "foo": must be dotbox, none, or underline'],
     ['-background', '#ff0000', '#ff0000', 'non-existent',
      'unknown color name "non-existent"'],
     [qw{-bd 4 4 badValue}, q{bad screen distance "badValue"}],
     ['-bg', '#ff0000', '#ff0000', 'non-existent',
      'unknown color name "non-existent"'],
     [qw{-borderwidth 1.3 1 badValue}, q{bad screen distance "badValue"}],
     [qw{-cursor arrow arrow badValue}, q{bad cursor spec "badValue"}],
# XXX error test skipped...
     [qw{-exportselection yes 1}, "", #"xyzzy",
      q{expected boolean value but got "xyzzy"}],
     ['-fg', '#110022', '#110022', 'bogus', q{unknown color name "bogus"}],
# XXX should test perl font object
#     ['-font', 'Helvetica 12', 'Helvetica 12', '', "font \"\" doesn't exist"],
     ['-foreground', '#110022', '#110022', 'bogus',
      q{unknown color name "bogus"}],
# XXX q{expected integer but got "20p"}
     [qw{-height 30 30 20p}, "'20p' isn't numeric"],
     ['-highlightbackground', '#112233', '#112233', 'ugly',
      q{unknown color name "ugly"}],
     ['-highlightcolor', '#123456', '#123456', 'bogus',
      q{unknown color name "bogus"}],
     [qw{-highlightthickness 6 6 bogus}, q{bad screen distance "bogus"}],
     [qw{-highlightthickness -2 0}, '', ''],
     ['-offset', '1,1', '1,1', 'wrongside',
      'bad offset "wrongside": expected "x,y", n, ne, e, se, s, sw, w, nw, or center'],
     [qw{-relief groove groove 1.5},
      ($Tk::VERSION < 803
       ? q{bad relief type "1.5": must be flat, groove, raised, ridge, solid, or sunken}
       : q{bad relief "1.5": must be flat, groove, raised, ridge, solid, or sunken})],
     ['-selectbackground', '#110022', '#110022', 'bogus',
      q{unknown color name "bogus"}],
     [qw{-selectborderwidth 1.3 1 badValue},
      q{bad screen distance "badValue"}],
     ['-selectforeground', '#654321', '#654321', 'bogus',
      q{unknown color name "bogus"}],
     [qw{-selectmode string string}, '', ''],
     [qw{-setgrid false 0}, "", # XXX "lousy",
      q{expected boolean value but got "lousy"}],
     ['-state', 'disabled', 'disabled', 'foo',
      'bad state "foo": must be disabled, or normal'],
     ['-takefocus', "any string", "any string", '', ''],
     ['-tile', 'testimage', 'testimage', 'non-existant',
      'image "non-existant" doesn\'t exist'],
     [qw{-width 45 45 3p}, "'3p' isn't numeric"],
      #XXXq{expected integer but got "3p"}],
#XXX Callback object      ['-xscrollcommand', 'Some command', 'Some command', '', ''],
#XXX     ['-yscrollcommand', 'Another command', 'Another command', '', ''],
#XXX not yet in 800.022     [qw{-listvar}, \$testVariable,  testVariable {}}, q{}],
    ) {
	my $name = $test->[0];

    SKIP: {
	    skip("$name test not supported for $Listbox", 3)
		if ($Listbox eq 'TextList' &&
		    $name =~ /^-(activestyle|bg|fg|foreground|height|selectborderwidth)$/);

	    skip("$name not implemented on $Tk::VERSION", 3)
		if ($Listbox eq 'Listbox' && $Tk::VERSION < 804 &&
		    $name =~ /^-(activestyle)$/);

	    skip("*TODO* $name not yet implemented on $Tk::VERSION", 3)
		if ($Listbox eq 'Listbox' && $Tk::VERSION >= 804 &&
		    $name =~ /^-(tile|offset)$/);

	    $lb->configure($name, $test->[1]);
	    is(($lb->configure($name))[4], $test->[2], "configuration option $name");
	    is($lb->cget($name), $test->[2], "cget call with $name");
	    if ($test->[3] ne "") {
		eval {
		    $lb->configure($name, $test->[3]);
		};
		like($@,qr/$test->[4]/,"error message for $name");
	    } else {
		pass("No error message test for option $name");
	    }

	    $lb->configure($name, ($lb->configure($name))[3]);
	}
    }

SKIP: {
    skip("only for Listbox, not for $Listbox", 1)
	if ($Listbox ne 'Listbox');

    eval { Tk::listbox() };
    like($@,qr/Usage \$widget->listbox(...)/, "error message");
}

{
    eval {
	$lb->destroy;
	$lb = $mw->$Listbox;
    };
    ok(Tk::Exists($lb));
    is($lb->class, "$Listbox", "Tk class $Listbox");
}

{
    eval {
	$lb->destroy;
	$lb = $mw->$Listbox(-gorp => "foo");
    };
    like($@,
	 ($Tk::VERSION < 803)
	 ? qr/Bad option \`-gorp\'/
	 : qr/unknown option \"-gorp\"/,
	 "error message");
}

ok(!Tk::Exists($lb));

$lb = $mw->$Listbox(-width => 20, -height => 5, -bd => 4,
		    -highlightthickness => 1,
		    -selectborderwidth => 2)->pack;
$lb->insert(0,
	    'el0','el1','el2','el3','el4','el5','el6','el7','el8','el9','el10',
	    'el11','el12','el13','el14','el15','el16','el17');
$lb->update;
eval { $lb->activate };
like($@,qr/wrong \# args: should be "\.listbox.* activate index"/,
     "Listbox activate error message");

eval { $lb->activate("fooey") };
like($@,qr/bad listbox index "fooey": must be active, anchor, end, \@x,y, or a number/);

$lb->activate(3);
is($lb->index("active"), 3, "Listbox activate");

$lb->activate(-1);
is($lb->index("active"), 0);

$lb->activate(30);
is($lb->index("active"), 17);

$lb->activate("end");
is($lb->index("active"), 17);

eval { $lb->bbox };
like($@, qr/wrong \# args: should be "\.listbox.* bbox index"/,
     "Listbox bbox error message");

eval { $lb->bbox(qw/a b/) };
like($@, qr/wrong \# args: should be "\.listbox.* bbox index"/);

eval { $lb->bbox("fooey") };
like($@,qr/bad listbox index "fooey": must be active, anchor, end, \@x,y, or a number/);

$lb->yview(3);
$lb->update;
is($lb->bbox(2), undef, "Listbox bbox");
is($lb->bbox(8), undef);

# Used to generate a core dump before a bug was fixed (the last
# element would be on-screen if it existed, but it doesn't exist).
eval {
    my $l2 = $mw->$Listbox;
    $l2->pack(-side => "top");
    $l2->waitVisibility;
    my $x = $l2->bbox(0);
    $l2->destroy;
};
is($@, '', "No core dump with bbox");

$lb->yview(3);
$lb->update;
SKIP: {
    skip($skip_font_test, 2) if $skip_font_test;
    is_deeply([$lb->bbox(3)], [qw(7 7 17 14)]);
    is_deeply([$lb->bbox(4)], [qw(7 26 17 14)]);
}

$lb->yview(0);
$lb->update;
is($lb->bbox(-1), undef);
SKIP: {
    skip($skip_font_test, 1) if $skip_font_test;
    is_deeply([$lb->bbox(0)], [qw(7 7 17 14)]);
}

$lb->yview("end");
$lb->update;
SKIP: {
    skip($skip_font_test, 2) if $skip_font_test;
    is_deeply([$lb->bbox(17)], [qw(7 83 24 14)]);
    is_deeply([$lb->bbox("end")], [qw(7 83 24 14)]);
}
is($lb->bbox(18), undef);

{
    my $t = $mw->Toplevel;
    $t->geometry("+0+0");
    my $lb = $t->$Listbox(-width => 10,
			 -height => 5);
    $lb->insert(0, "Short", "Somewhat longer",
		"Really, quite a whole lot longer than can possibly fit on the screen",
		"Short");
    $lb->pack;
    $lb->update;
    $lb->xview(moveto => 0.2);
 SKIP: {
	skip($skip_font_test, 1) if $skip_font_test;
	is_deeply([$lb->bbox(2)], [qw(-72 39 393 14)]);
	$t->destroy;
    }
}

mkPartial();
SKIP: {
    skip($skip_font_test, 2) if $skip_font_test;
    is_deeply([$partial_lb->bbox(3)], [qw(5 56 24 14)]);
    is_deeply([$partial_lb->bbox(4)], [qw(5 73 23 14)]);
}

eval { $lb->cget };
like($@,qr/wrong \# args: should be \"\.listbox.* cget option\"/,
     "Listbox cget message");

eval { $lb->cget(qw/a b/) };
like($@,qr/wrong \# args: should be \"\.listbox.* cget option\"/);

eval { $lb->cget(-gorp) };
like($@,qr/unknown option "-gorp"/);

is($lb->cget(-setgrid), 0);
# XXX why 25 in Tk800?
is(scalar @{[$lb->configure]}, ($Tk::VERSION < 803 ? 25 : 27), "Listbox configure");
is_deeply([$lb->configure(-setgrid)],
	  [qw(-setgrid setGrid SetGrid 0 0)]);
eval { $lb->configure(-gorp) };
like($@,qr/unknown option "-gorp"/);

{
    my $oldbd = $lb->cget(-bd);
    my $oldht = $lb->cget(-highlightthickness);
    $lb->configure(-bd => 3, -highlightthickness => 0);
    is($lb->cget(-bd), 3);
    is($lb->cget(-highlightthickness), 0);
    $lb->configure(-bd => $oldbd);
    $lb->configure(-highlightthickness => $oldht);
}

eval { $lb->curselection("a") };
like($@,qr/wrong \# args: should be \"\.listbox.* curselection\"/,
     "Listbox curselection error message");

$lb->selection("clear", 0, "end");
$lb->selection("set", 3, 6);
$lb->selection("set", 9);
is_deeply([$lb->curselection], [qw(3 4 5 6 9)],
	  "Listbox curselection");

# alternative perl/Tk methods
$lb->selectionClear(0, "end");
$lb->selectionSet(3, 6);
$lb->selectionSet(9);
is_deeply([$lb->curselection], [qw(3 4 5 6 9)]);

eval { $lb->delete };
like($@,qr/wrong \# args: should be \"\.listbox.* delete firstIndex \?lastIndex\?\"/,
   "Listbox delete error message");

eval { $lb->delete(qw/a b c/) };
like($@,qr/wrong \# args: should be \"\.listbox.* delete firstIndex \?lastIndex\?\"/);

eval { $lb->delete("badindex") };
like($@,qr/bad listbox index "badindex": must be active, anchor, end, \@x,y, or a number/);

eval { $lb->delete(2, "123ab") };
like($@,qr/bad listbox index "123ab": must be active, anchor, end, \@x,y, or a number/);

{
    my $l2 = $mw->$Listbox;
    $l2->insert(0, qw(el0 el1 el2 el3 el4 el5 el6 el7));
    $l2->delete(3);
    is($l2->get(2), "el2", "Listbox delete element");
    is($l2->get(3), "el4");
    is($l2->index("end"), "7");
    $l2->destroy;
}

{
    my $l2 = $mw->$Listbox;
    $l2->insert(0, qw(el0 el1 el2 el3 el4 el5 el6 el7));
    $l2->delete(2, 4);
    is($l2->get(1), "el1");
    is($l2->get(2), "el5");
    is($l2->index("end"), "5");
    $l2->destroy;
}

{
    my $l2 = $mw->$Listbox;
    $l2->insert(0, qw(el0 el1 el2 el3 el4 el5 el6 el7));
    $l2->delete(-3, 2);
    is_deeply([$l2->get(0, "end")], [qw(el3 el4 el5 el6 el7)]);
    $l2->destroy;
}

{
    my $l2 = $mw->$Listbox;
    $l2->insert(0, qw(el0 el1 el2 el3 el4 el5 el6 el7));
    $l2->delete(-3, -1);
    is_deeply([$l2->get(0, "end")], [map { "el$_" } (0 .. 7)]);
    is(scalar @{[$l2->get(0, "end")]}, 8);
    $l2->destroy;
}

{
    my $l2 = $mw->$Listbox;
    $l2->insert(0, qw(el0 el1 el2 el3 el4 el5 el6 el7));
    $l2->delete(2, "end");
    is_deeply([$l2->get(0, "end")], [qw(el0 el1)]);
    is(scalar @{[$l2->get(0, "end")]}, 2);
    $l2->destroy;
}

{
    my $l2 = $mw->$Listbox;
    $l2->insert(0, qw(el0 el1 el2 el3 el4 el5 el6 el7));
    $l2->delete(5, 20);
    is_deeply([$l2->get(0, "end")], [qw(el0 el1 el2 el3 el4)]);
    is(scalar @{[$l2->get(0, "end")]}, 5);
    $l2->destroy;
}

{
    my $l2 = $mw->$Listbox;
    $l2->insert(0, qw(el0 el1 el2 el3 el4 el5 el6 el7));
    $l2->delete("end", 20);
    is_deeply([$l2->get(0, "end")], [qw(el0 el1 el2 el3 el4 el5 el6)]);
    is(scalar @{[$l2->get(0, "end")]}, 7);
    $l2->destroy;
}

{
    my $l2 = $mw->$Listbox;
    $l2->insert(0, qw(el0 el1 el2 el3 el4 el5 el6 el7));
    $l2->delete(8, 20);
    is_deeply([$l2->get(0, "end")], [qw(el0 el1 el2 el3 el4 el5 el6 el7)]);
    is(scalar @{[$l2->get(0, "end")]}, 8);
    $l2->destroy;
}

eval { $lb->get };
like($@, $Tk::VERSION < 803
     ? qr/wrong \# args: should be \"\.listbox.* get first \?last\?\"/
     : qr/wrong \# args: should be \"\.listbox.* get firstIndex \?lastIndex\?\"/,
     "Listbox get error message");

eval { $lb->get(qw/a b c/) };
like($@, $Tk::VERSION < 803
     ? qr/wrong \# args: should be \"\.listbox.* get first \?last\?\"/
     : qr/wrong \# args: should be \"\.listbox.* get firstIndex \?lastIndex\?\"/);

# XXX is in perl/Tk
#  eval { $lb->get("2.4") };
#  ok($@ ,qr/bad listbox index "2.4": must be active, anchor, end, \@x,y, or a number/,
#     "wrong error message");

eval { $lb->get("badindex") };
like($@ ,qr/bad listbox index "badindex": must be active, anchor, end, \@x,y, or a number/);

eval { $lb->get("end", "bogus") };
like($@ ,qr/bad listbox index "bogus": must be active, anchor, end, \@x,y, or a number/);

{
    my $l2 = $mw->$Listbox;
    $l2->insert(0, qw(el0 el1 el2 el3 el4 el5 el6 el7));
    is($l2->get(0), "el0");
    is($l2->get(3), "el3");
    is($l2->get("end"), "el7");
    $l2->destroy;
}

{
    my $l2 = $mw->$Listbox;
    is($l2->get(0), undef);
    is($l2->get("end"), undef);
    $l2->destroy;
}

{
    my $l2 = $mw->$Listbox;
    $l2->insert(0, qw(el0 el1 el2), "two words", qw(el4 el5 el6 el7));
    is($l2->get(3), "two words");
    is(($l2->get(3, "end"))[0], "two words");
    is_deeply([$l2->get(3, "end")], ['two words', qw(el4 el5 el6 el7)]);
}

is($lb->get(-1), undef);
is($lb->get(-2, -1), undef);
is_deeply([$lb->get(-2, 3)], [qw(el0 el1 el2 el3)]);
is(scalar @{[ $lb->get(-2, 3) ]}, 4);

is_deeply([$lb->get(12, "end")], [qw(el12 el13 el14 el15 el16 el17)]);
is(scalar @{[ $lb->get(12, "end") ]}, 6);
is_deeply([$lb->get(12, 20)], [qw(el12 el13 el14 el15 el16 el17)]);
is(scalar @{[ $lb->get(12, 20) ]}, 6);

is($lb->get("end"), "el17");
is($lb->get(30), undef);
is_deeply([$lb->get(30, 35)], []);

eval { $lb->index };
like($@ ,qr/wrong \# args: should be \"\.listbox.* index index\"/,
     "Listbox index error message");

eval { $lb->index(qw/a b/) };
like($@ ,qr/wrong \# args: should be \"\.listbox.* index index\"/);

eval { $lb->index(qw/@/) };
like($@ ,qr/bad listbox index "\@": must be active, anchor, end, \@x,y, or a number/);

is($lb->index(2), 2);
is($lb->index(-1), -1);
is($lb->index("end"), 18);
is($lb->index(34), 34);

eval { $lb->insert };
like($@ ,qr/wrong \# args: should be \"\.listbox.* insert index \?element element \.\.\.\?\"/,
     "Listbox insert error message");

eval { $lb->insert("badindex") };
like($@ ,qr/bad listbox index "badindex": must be active, anchor, end, \@x,y, or a number/);

{
    my $l2 = $mw->$Listbox;
    $l2->insert("end", qw/a b c d e/);
    $l2->insert(3, qw/x y z/);
    is_deeply([$l2->get(0, "end")], [qw(a b c x y z d e)], "Listbox insert");
    is(scalar @{[ $l2->get(0, "end") ]}, 8);
    $l2->destroy;
}

{
    my $l2 = $mw->$Listbox;
    $l2->insert("end", qw/a b c/);
    $l2->insert(-1, qw/x/);
    is_deeply([$l2->get(0, "end")], [qw(x a b c)]);
    is(scalar @{[ $l2->get(0, "end") ]}, 4);
    $l2->destroy;
}

{
    my $l2 = $mw->$Listbox;
    $l2->insert("end", qw/a b c/);
    $l2->insert("end", qw/x/);
    is_deeply([$l2->get(0, "end")], [qw(a b c x)]);
    is(scalar @{[ $l2->get(0, "end") ]}, 4);
    $l2->destroy;
}

{
    my $l2 = $mw->$Listbox;
    $l2->insert("end", qw/a b c/);
    $l2->insert(43, qw/x/);
    is_deeply([$l2->get(0, "end")], [qw(a b c x)]);
    is(scalar @{[ $l2->get(0, "end") ]}, 4);
    $l2->insert(4, qw/y/);
    is_deeply([$l2->get(0, "end")], [qw(a b c x y)]);
    $l2->insert(6, qw/z/);
    is_deeply([$l2->get(0, "end")], [qw(a b c x y z)]);
    $l2->destroy;
}

eval { $lb->nearest };
like($@ ,qr/wrong \# args: should be \"\.listbox.* nearest y\"/,
     "Listbox nearest error message");

eval { $lb->nearest(qw/a b/) };
like($@ ,qr/wrong \# args: should be \"\.listbox.* nearest y\"/);

eval { $lb->nearest("badindex") };
like($@ ,qr/\'badindex\' isn\'t numeric/);

$lb->yview(3);
is($lb->nearest(1000), 7, "Listbox nearest");

eval { $lb->scan };
like($@,qr/wrong \# args: should be \"\.listbox.* scan mark\|dragto x y\"/,
     "Listbox scan error message");

eval { $lb->scan(qw/a b/) };
like($@,qr/wrong \# args: should be \"\.listbox.* scan mark\|dragto x y\"/);

eval { $lb->scan(qw/a b c d/) };
like($@,qr/wrong \# args: should be \"\.listbox.* scan mark\|dragto x y\"/);

eval { $lb->scan(qw/foo bogus 2/) };
like($@ ,qr/\'bogus\' isn\'t numeric/);

## is in perl
#  eval { $lb->scan(qw/foo 2 2.3/) };
#  ok($@ ,qr/'2.3' isn't numeric/,
#     "wrong error message");

eval { $lb->scan(qw/foo 2 3/) };
like($@, $Tk::VERSION < 803
     ? qr/bad scan option \"foo\": must be mark or dragto/
     : qr/bad option \"foo\": must be mark, or dragto/);

{
    my $t = $mw->Toplevel;
    $t->geometry("+0+0");
    my $lb = $t->$Listbox(-width => 10, -height => 5);
    $lb->insert(0, "Short", "Somewhat longer",
		"Really, quite a whole lot longer than can possibly fit on the screen", "Short",
		qw/a b c d e f g h i j/);
    $lb->pack;
    $lb->update;
    $lb->scan("mark", 100, 140);
    $lb->scan("dragto", 90, 137);
    $lb->update;
 SKIP: {
	skip($skip_font_test, 2) if $skip_font_test;
	like(join(",",$lb->xview), qr/^0\.24936.*,0\.42748.*$/, "Listbox scan");
	like(join(",",$lb->yview), qr/^0\.071428.*,0\.428571.*$/);
    }
    $t->destroy;
}

eval { $lb->see };
like($@ ,qr/wrong \# args: should be \"\.listbox.* see index\"/,
     "Listbox see error message");

eval { $lb->see("a","b") };
like($@ ,qr/wrong \# args: should be \"\.listbox.* see index\"/);

eval { $lb->see("badindex") };
like($@ ,qr/bad listbox index "badindex": must be active, anchor, end, \@x,y, or a number/);

$lb->yview(7);
$lb->see(7);
is($lb->index('@0,0'), 7, "Listbox see");

$lb->yview(7);
$lb->see(11);
is($lb->index('@0,0'), 7);

$lb->yview(7);
$lb->see(6);
is($lb->index('@0,0'), 6);

$lb->yview(7);
$lb->see(5);
is($lb->index('@0,0'), 3);

$lb->yview(7);
$lb->see(12);
is($lb->index('@0,0'), 8);

$lb->yview(7);
$lb->see(13);
is($lb->index('@0,0'), 11);

$lb->yview(7);
$lb->see(-1);
is($lb->index('@0,0'), 0);

$lb->yview(7);
$lb->see("end");
is($lb->index('@0,0'), 13);

$lb->yview(7);
$lb->see(322);
is($lb->index('@0,0'), 13);

mkPartial();
$partial_lb->see(4);
is($partial_lb->index('@0,0'), 1);

eval { $lb->selection };
like($@ ,qr/wrong \# args: should be \"\.listbox.* selection option index \?index\?\"/,
     "Listbox selection error message");

eval { $lb->selection("a") };
like($@ ,qr/wrong \# args: should be \"\.listbox.* selection option index \?index\?\"/);

eval { $lb->selection(qw/a b c d/) };
like($@ ,qr/wrong \# args: should be \"\.listbox.* selection option index \?index\?\"/);

eval { $lb->selection(qw/a bogus/) };
like($@ ,qr/bad listbox index \"bogus\": must be active, anchor, end, \@x,y, or a number/);

eval { $lb->selection(qw/a 0 lousy/) };
like($@ ,qr/bad listbox index \"lousy\": must be active, anchor, end, \@x,y, or a number/);

eval { $lb->selection(qw/anchor 0 0/) };
like($@ ,qr/wrong \# args: should be \"\.listbox.* selection anchor index\"/);

$lb->selection("anchor", 5);
is($lb->index("anchor"), 5, "Listbox selection");
$lb->selectionAnchor(0);
is($lb->index("anchor"), 0);

$lb->selectionAnchor(-1);
is($lb->index("anchor"), 0);
$lb->selectionAnchor("end");
is($lb->index("anchor"), 17);
$lb->selectionAnchor(44);
is($lb->index("anchor"), 17);

$lb->selection("clear", 0, "end");
$lb->selection("set", 2, 8);
$lb->selection("clear", 3, 4);
is_deeply([$lb->curselection], [2,5,6,7,8]);

$lb->selectionClear(0, "end");
$lb->selectionSet(2, 8);
$lb->selectionClear(3, 4);
is_deeply([$lb->curselection], [2,5,6,7,8]);

eval { $lb->selection(qw/includes 0 0/) };
like($@ ,qr/wrong \# args: should be \"\.listbox.* selection includes index\"/,
     "Tk selection includes error message");

$lb->selectionClear(0, "end");
$lb->selectionSet(2,8);
$lb->selectionClear(4);
is($lb->selection("includes", 3), 1, "Listbox selection includes");
is($lb->selection("includes", 4), 0);
is($lb->selection("includes", 5), 1);
is($lb->selectionIncludes(3), 1);

$lb->selectionSet(0, "end");
is($lb->selectionIncludes(-1), 0);

$lb->selectionClear(0, "end");
$lb->selectionSet("end");
is($lb->selection("includes", "end"), 1);

$lb->selectionClear(0, "end");
$lb->selectionSet("end");
is($lb->selection("includes", 44), 0);

{
    my $l2 = $mw->$Listbox;
    is($l2->selectionIncludes(0), 0);
    $l2->destroy;
}

$lb->selection(qw(clear 0 end));
$lb->selection(qw(set 2));
$lb->selection(qw(set 5 7));
is_deeply([$lb->curselection], [qw(2 5 6 7)]);
is(scalar @{[$lb->curselection]}, 4);
$lb->selection(qw(set 5 7));
is_deeply([$lb->curselection], [qw(2 5 6 7)]);
is(scalar @{[$lb->curselection]}, 4);

eval { $lb->selection(qw/badOption 0 0/) };
like($@, qr/bad option \"badOption\": must be anchor, clear, includes, or set/,
     "Listbox selection error message");

eval { $lb->size(qw/a/) };
like($@ ,qr/wrong \# args: should be \"\.listbox.* size\"/,
     "Listbox size error message");

is($lb->size, 18, "Listbox size");

{
    my $l2 = $mw->$Listbox;
    $l2->update;
    is(($l2->xview)[0], 0);
    is(($l2->xview)[1], 1);
    $l2->destroy;
}

eval { $lb->destroy };
$lb = $mw->$Listbox(-width => 10, -height => 5, -font => $fixed);
$lb->insert(qw/0 a b c d e f g h i j k l m n o p q r s t/);
$lb->pack;
$lb->update;
is(($lb->xview)[0], 0);
is(($lb->xview)[1], 1);

eval { $lb->destroy };
$lb = $mw->$Listbox(-width => 10, -height => 5, -font => $fixed);
$lb->insert(qw/0 a b c d e f g h i j k l m n o p q r s t/);
$lb->insert(qw/1 0123456789a123456789b123456789c123456789d123456789/);
$lb->pack;
$lb->update;

$lb->xview(4);
is_float(join(",",$lb->xview), "0.08,0.28", "Listbox xview with floats");

eval { $lb->xview("foo") };
like($@ ,qr/\'foo\' isn\'t numeric/,
     "Listbox xview error message");

eval { $lb->xview("zoom", "a", "b") };
like($@ ,qr/unknown option \"zoom\": must be moveto or scroll/);

$lb->xview(0);
$lb->xview(moveto => 0.4);
$lb->update;
is_float(($lb->xview)[0], 0.4);
is_float(($lb->xview)[1], 0.6);

$lb->xview(0);
$lb->xview(scroll => 2, "units");
$lb->update;
is_float("@{[ $lb->xview ]}", '0.04 0.24');

$lb->xview(30);
$lb->xview(scroll => -1, "pages");
$lb->update;
is_float("@{[ $lb->xview ]}", '0.44 0.64');

$lb->configure(-width => 1);
$lb->update;
$lb->xview(30);
$lb->xview("scroll", -4, "pages");
$lb->update;
is_float("@{[ $lb->xview ]}", '0.52 0.54');

eval { $lb->destroy };
$lb = $mw->$Listbox->pack;
$lb->update;
is(($lb->yview)[0], 0);
is(($lb->yview)[1], 1);

eval { $lb->destroy };
$lb = $mw->$Listbox->pack;
$lb->insert(0, "el1");
$lb->update;
is(($lb->yview)[0], 0);
is(($lb->yview)[1], 1);

eval { $lb->destroy };
$lb = $mw->$Listbox(-width => 10, -height => 5, -font => $fixed);
$lb->insert(0,'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o',
	    'p','q','r','s','t');
$lb->pack;
$lb->update;
$lb->yview(4);
$lb->update;
is_float(($lb->yview)[0], 0.2);
is_float(($lb->yview)[1], 0.45);

mkPartial();
is(($partial_lb->yview)[0], 0);
like(($partial_lb->yview)[1] ,qr/^0\.\d+$/,
     "yview returned " . (($partial_lb->yview)[1]));

eval { $lb->yview("foo") };
like($@ ,qr/\Qbad listbox index "foo": must be active, anchor, end, \E\@\Qx,y, or a number/,
     "Listbox yview error message");

eval { $lb->yview("foo", "a", "b") };
like($@ ,qr/unknown option \"foo\": must be moveto or scroll/);

$lb->yview(0);
$lb->yview(moveto => 0.31);
is_float("@{[ $lb->yview ]}", "0.3 0.55");

$lb->yview(2);
$lb->yview(scroll => 2 => "pages");
is_float("@{[ $lb->yview ]}", "0.4 0.65");

$lb->yview(10);
$lb->yview(scroll => -3 => "units");
is_float("@{[ $lb->yview ]}", "0.35 0.6");

$lb->configure(-height => 2);
$lb->update;
$lb->yview(15);
$lb->yview(scroll => -4 => "pages");
is_float("@{[ $lb->yview ]}", "0.55 0.65");

# No tests for DestroyListbox:  I can't come up with anything to test
# in this procedure.

eval { $lb->destroy };
$lb = $mw->$Listbox(-setgrid => 1, -width => 25, -height => 15);
$lb->pack;
$mw->update;
like(getsize($mw), qr/^\d+x\d+$/);
$lb->configure(-setgrid => 0);
$mw->update;
like(getsize($mw), qr/^\d+x\d+$/);

resetGridInfo();

$lb->configure(-highlightthickness => -3);
is($lb->cget(-highlightthickness), 0);

$lb->configure(-exportselection => 0);
$lb->delete(0, "end");
$lb->insert(0, qw(el0 el1 el2 el3 el4 el5 el6 el7 el8));
$lb->selection("set", 3, 5);
$lb->configure(-exportselection => 1);
is($mw->SelectionGet, "el3\nel4\nel5");

my $e = $mw->Entry;
$e->insert(0, "abc");
$e->selection("from", 0);
$e->selection("to", 2);
$lb->configure(-exportselection => 0);
$lb->delete(0, "end");
$lb->insert(0, qw(el0 el1 el2 el3 el4 el5 el6 el7 el8));
$lb->selectionSet(3, 5);
$lb->selectionClear(3, 5);
$lb->configure(-exportselection => 1);
is($mw->SelectionOwner, $e);
is($mw->SelectionGet, "ab");
$e->destroy;

$mw->SelectionClear;
$lb->configure(-exportselection => 1);
$lb->delete(0, "end");
$lb->insert(qw(0 el0 el1 el2 el3 el4 el5 el6 el7 el8));
$lb->selection("set", 1, 1);
is($mw->SelectionGet, "el1");
is(join(',',$lb->curselection), "1"); # join forces list context
$lb->configure(-exportselection => 0);
eval { $mw->SelectionGet };
like($@ ,qr/PRIMARY selection doesn\'t exist or form \"(UTF8_)?STRING\" not defined/,
     "SelectionGet, error message");
is(join(',',$lb->curselection), "1"); # join forces list context
$lb->selection("clear", 0, "end");
eval { $mw->SelectionGet };
like($@ ,qr/PRIMARY selection doesn\'t exist or form \"(UTF8_)?STRING\" not defined/);
is($lb->curselection, undef, "Empty curselection");
$lb->selection("set", 1, 3);
eval { $mw->SelectionGet };
like($@ ,qr/PRIMARY selection doesn\'t exist or form \"(UTF8_)?STRING\" not defined/);
is_deeply([$lb->curselection], [qw(1 2 3)]);
$lb->configure(-exportselection => 1);
is($mw->SelectionGet, "el1\nel2\nel3");
is_deeply([$lb->curselection], [qw(1 2 3)]);

$lb->destroy;
$mw->geometry("300x300");
$mw->update;
$mw->geometry("");
$mw->withdraw;
$lb = $mw->$Listbox(-font => $fixed, -width => 15, -height => 20);
$lb->pack;
$lb->update;
$mw->deiconify;
like(getsize($mw), qr/^\d+x\d+$/);
$lb->configure(-setgrid => 1);
$mw->update;
like(getsize($mw), qr/^\d+x\d+$/);

$lb->destroy;
$mw->withdraw;
$lb = $mw->$Listbox(-font => $fixed, -width => 30, -height => 20,
		   -setgrid => 1);
$mw->geometry("+0+0");
$lb->pack;
$mw->update;
$mw->deiconify;
{
    local $TODO = "Tests may fail (window-manager related?)";

    is(getsize($mw), "30x20");
    $mw->geometry("26x15");
    $mw->update;
    is(getsize($mw), "26x15");
    $lb->configure(-setgrid => 1);
    $lb->update;
    is(getsize($mw), "26x15");
}

$mw->geometry("");
$lb->destroy;
resetGridInfo();

my @log;

$lb = $mw->$Listbox(-width => 15, -height => 20,
		   -xscrollcommand => sub { record("x", @_) },
		   -yscrollcommand => [qw/record y/],
		  )->pack;
$lb->update;
$lb->configure(-fg => "black");
@log = ();
$lb->update;
is($log[0], "y 0 1");
is($log[1], "x 0 1");

$lb->destroy;
my @x = qw/a b c d/;
#XXX these are missing: -listvar tests, because 800.023 do not know this option
# $lb = $mw->$Listbox(-listvar => \@x);
# ok(join(",",$lb->get(0, "end")), "a,b,c,d");

#test listbox-4.10 {ConfigureListbox, no listvar -> existing listvar} {
#    catch {destroy $_lb}
#    set x [list a b c d]
#    listbox $_lb
#    $_lb insert end 1 2 3 4
#    $_lb configure -listvar x
#    $_lb get 0 end
#} [list a b c d]
#test listbox-4.11 {ConfigureListbox procedure, listvar -> no listvar} {
#    catch {destroy $_lb}
#    set x [list a b c d]
#    listbox $_lb -listvar x
#    $_lb configure -listvar {}
#    $_lb insert end 1 2 3 4
#    list $x [$_lb get 0 end]
#} [list [list a b c d] [list a b c d 1 2 3 4]]
#test listbox-4.12 {ConfigureListbox procedure, listvar -> different listvar} {
#    catch {destroy $_lb}
#    set x [list a b c d]
#    set y [list 1 2 3 4]
#    listbox $_lb
#    $_lb configure -listvar x
#    $_lb configure -listvar y
#    $_lb insert end 5 6 7 8
#    list $x $y
#} [list [list a b c d] [list 1 2 3 4 5 6 7 8]]
#test listbox-4.13 {ConfigureListbox, no listvar -> non-existant listvar} {
#    catch {destroy $_lb}
#    catch {unset x}
#    listbox $_lb
#    $_lb insert end a b c d
#    $_lb configure -listvar x
#    set x
#} [list a b c d]
#test listbox-4.14 {ConfigureListbox, non-existant listvar} {
#    catch {destroy $_lb}
#    catch {unset x}
#    listbox $_lb -listvar x
#    list [info exists x] $x
#} [list 1 {}]
#test listbox-4.15 {ConfigureListbox, listvar -> non-existant listvar} {
#    catch {destroy $_lb}
#    catch {unset y}
#    set x [list a b c d]
#    listbox $_lb -listvar x
#    $_lb configure -listvar y
#    list [info exists y] $y
#} [list 1 [list a b c d]]
#test listbox-4.16 {ConfigureListbox, listvar -> same listvar} {
#    catch {destroy $_lb}
#    set x [list a b c d]
#    listbox $_lb -listvar x
#    $_lb configure -listvar x
#    set x
#} [list a b c d]
#test listbox-4.17 {ConfigureListbox, no listvar -> no listvar} {
#    catch {destroy $_lb}
#    listbox $_lb
#    $_lb insert end a b c d
#    $_lb configure -listvar {}
#    $_lb get 0 end
#} [list a b c d]
#test listbox-4.18 {ConfigureListbox, no listvar -> bad listvar} {
#    catch {destroy $_lb}
#    listbox $_lb
#    $_lb insert end a b c d
#    set x {this is a " bad list}
#    catch {$_lb configure -listvar x} result
#    list [$_lb get 0 end] [$_lb cget -listvar] $result
#} [list [list a b c d] {} \
#	"unmatched open quote in list: invalid listvar value"]

# No tests for DisplayListbox:  I don't know how to test this procedure.

Tk::catch { $lb->destroy if Tk::Exists($lb) };
$lb = $mw->$Listbox(-font => $fixed, -width => 15, -height => 20)->pack;
SKIP: {
    skip($skip_fixed_font_test, 2) if $skip_fixed_font_test;
    is($lb->reqwidth, 115, "Reqwidth with fixed font");
    is($lb->reqheight, 328, "Reqheight with fixed font");
}

eval { $lb->destroy };
$lb = $mw->$Listbox(-font => $fixed, -width => 0, -height => 10)->pack;
$lb->update;
SKIP: {
    skip($skip_fixed_font_test, 2) if $skip_fixed_font_test;
    is($lb->reqwidth, 17);
    is($lb->reqheight, 168);
}

eval { $lb->destroy };
$lb = $mw->$Listbox(-font => $fixed, -width => 0, -height => 10,
		   -bd => 3)->pack;
$lb->insert(0, "Short", "Really much longer", "Longer");
$lb->update;
SKIP: {
    skip($skip_fixed_font_test, 2) if $skip_fixed_font_test;
    is($lb->reqwidth, 138);
    is($lb->reqheight, 170);
}

eval { $lb->destroy };
$lb = $mw->$Listbox(-font => $fixed, -width => 10, -height => 0,
		  )->pack;
$lb->update;
SKIP: {
    skip($skip_fixed_font_test, 2) if $skip_fixed_font_test;
    is($lb->reqwidth, 80);
    is($lb->reqheight, 24);
}

eval { $lb->destroy };
$lb = $mw->$Listbox(-font => $fixed, -width => 10, -height => 0,
		   -highlightthickness => 0)->pack;
$lb->insert(0, "Short", "Really much longer", "Longer");
$lb->update;
SKIP: {
    skip($skip_fixed_font_test, 2) if $skip_fixed_font_test;
    is($lb->reqwidth, 76);
    is($lb->reqheight, 52);
}

eval { $lb->destroy };
# If "0" in selected font had 0 width, caused divide-by-zero error.
$lb = $mw->$Listbox(-font => '{open look glyph}')->pack;
$lb->update;

eval { $lb->destroy };
$lb = $mw->$Listbox(-height => 2,
		   -xscrollcommand => sub { record("x", @_) },
		   -yscrollcommand => sub { record("y", @_) })->pack;
$lb->update;

$lb->delete(0, "end");
$lb->insert(qw/end a b c d/);
$lb->insert(qw/5 x y z/);
$lb->insert(qw/2 A/);
$lb->insert(qw/0 q r s/);
is_deeply([$lb->get(qw/0 end/)], [qw(q r s a b A c d x y z)]);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->selection(qw/anchor 2/);
$lb->insert(qw/2 A B/);
is($lb->index(qw/anchor/), 4);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->selection(qw/anchor 2/);
$lb->insert(qw/3 A B/);
is($lb->index(qw/anchor/), 2);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->yview(qw/3/);
$lb->update;
$lb->insert(qw/2 A B/);
is($lb->index(q/@0,0/), 5);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->yview(qw/3/);
$lb->update;
$lb->insert(qw/3 A B/);
is($lb->index(q/@0,0/), 3);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->activate(qw/5/);
$lb->insert(qw/5 A B/);
is($lb->index(qw/active/), 7);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->activate(qw/5/);
$lb->insert(qw/6 A B/);
is($lb->index(qw/active/), 5);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c/);
is($lb->index(qw/active/), 2);

$lb->delete(qw/0 end/);
$lb->insert(qw/0/);
is($lb->index(qw/active/), 0);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b/, "two words", qw/c d e f g h i j/);
$lb->update;
@log = ();
$lb->insert(qw/0 word/);
$lb->update;
like("@log",qr/^y 0 0\.\d+/);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b/, "two words", qw/c d e f g h i j/);
$lb->update;
@log = ();
$lb->insert(0, "much longer entry");
$lb->update;
like("$log[0]",qr/^y 0 0\.\d+/);
like("$log[1]", qr/x 0 \d[\d\.]*/);

SKIP: {
    skip($skip_font_test, 4) if $skip_font_test;
    my $l2 = $mw->$Listbox(-width => 0, -height => 0)->pack(-side => "top");
    $l2->insert(0, "a", "b", "two words", "c", "d");
    is($l2->reqwidth, 80);
    is($l2->reqheight, 93);
    $l2->insert(0, "much longer entry");
    is($l2->reqwidth, 122);
    is($l2->reqheight, 110);
    $l2->destroy;
}

{
      my @x = qw(a b c d);
    ## -listvar XXX
#      my $l2 = $mw->$Listbox(-listvar => \@x);
#      $l2->insert(0, 1 .. 4);
#      ok(join(" ", @x), "1 2 3 4 a b c d");
#      ok(scalar @x, 8);
#      ok($x[0], 1);
#      ok($x[-1], "d");
#      $l2->destroy;
}

{
    my $l2 = $mw->$Listbox;
    $l2->insert(0, 0 .. 4);
    $l2->selection("set", 2, 4);
    $l2->insert(0, "a");
    is_deeply([ $l2->curselection ], [qw(3 4 5)]);
    is(scalar @{[ $l2->curselection ]}, 3);
    $l2->destroy;
}

$lb->delete(0, "end");
$lb->insert(0, qw/a b c d e f g h i j/);
$lb->selectionSet(1, 6);
$lb->delete(4, 3);
is($lb->size, 10);
is($mw->SelectionGet, "b
c
d
e
f
g");

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->selection(qw/set 3 6/);
$lb->delete(qw/4 4/);
is($lb->size, 9);
is($lb->get(4), "f");
is_deeply([ $lb->curselection ], [3,4,5]);
is(scalar @{[ $lb->curselection ]}, 3);
is(($lb->curselection)[0], 3);
is(($lb->curselection)[-1], 5);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->delete(qw/0 3/);
is($lb->size, 6);
is($lb->get(0), "e");
is($lb->get(1), "f");

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->delete(qw/8 1000/);
is($lb->size, 8);
is($lb->get(7), "h");

$lb-> delete(0, qw/end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->selection(qw/anchor 2/);
$lb->delete(qw/0 1/);
is($lb->index(qw/anchor/), 0);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->selection(qw/anchor 2/);
$lb->delete(qw/2/);
is($lb->index(qw/anchor/), 2);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->selection(qw/anchor 4/);
$lb->delete(qw/2 5/);
is($lb->index(qw/anchor/), 2);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->selection(qw/anchor 3/);
$lb->delete(qw/4 5/);
is($lb->index(qw/anchor/), 3);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->yview(qw/3/);
$lb->update;
$lb->delete(qw/1 2/);
is($lb->index(q/@0,0/), 1);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->yview(qw/3/);
$lb->update;
$lb->delete(qw/3 4/);
is($lb->index(q/@0,0/), 3);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->yview(qw/3/);
$lb->update;
$lb->delete(qw/4 6/);
is($lb->index(q/@0,0/), 3);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->yview(qw/3/);
$lb->update;
$lb->delete(qw/3 end/);
like($lb->index(q/@0,0/), qr/^[12]$/);

mkPartial();
$partial_lb->yview(8);
$mw->update;
$partial_lb->delete(10, 13);
like($partial_lb->index('@0,0'), qr/^[67]$/);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->activate(qw/6/);
$lb->delete(qw/3 4/);
is($lb->index(qw/active/), 4);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->activate(qw/6/);
$lb->delete(qw/5 7/);
is($lb->index(qw/active/), 5);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->activate(qw/6/);
$lb->delete(qw/5 end/);
is($lb->index(qw/active/), 4);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->activate(qw/6/);
$lb->delete(qw/0 end/);
is($lb->index(qw/active/), 0);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c/, "two words", qw/d e f g h i j/);
$lb->update;
@log = ();
$lb->delete(qw/4 6/);
$lb->update;
like($log[0], qr/y 0 0\.\d+/);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c/, "two words", qw/d e f g h i j/);
$lb->update;
@log = ();
$lb->delete(qw/3/);
$lb->update;
like($log[0], qr/^y 0 0\.\d+$/);
is($log[1], "x 0 1");

SKIP: {
    skip($skip_font_test, 4) if $skip_font_test;
    my $l2 = $mw->$Listbox(-width => 0, -height => 0)->pack(-side => "top");
    $l2->insert(0, "a", "b", "two words", qw/c d e f g/);
    is($l2->reqwidth, 80);
    is($l2->reqheight, 144);
    $l2->delete(2, 4);
    is($l2->reqwidth, 17);
    is($l2->reqheight, 93);
    $l2->destroy;
}

## -listvar
#  catch {destroy .l2}
#  test listbox-7.21 {DeleteEls procedure, check -listvar update} {
#      catch {destroy .l2}
#      set x [list a b c d]
#      listbox .l2 -listvar x
#      .l2 delete 0 1
#      set x
#  } [list c d]

$lb->destroy;
$lb = $mw->$Listbox(-setgrid => 1)->pack;
$lb->update;
like(getsize($mw), qr/^\d+x\d+$/); # still worth it ?
$lb->destroy;
like(getsize($mw), qr/^\d+x\d+$/); # still worth it ?
ok(!Tk::Exists($lb));

resetGridInfo();

$lb = $mw->$Listbox(-height => 5, -width => 10);
$lb->insert(qw/0 a b c/, "A string that is very very long",
	    qw/ d e f g h i j k/);
$lb->pack;
$lb->update;
$lb->place(qw/-width 50 -height 80/);
$lb->update;
SKIP: {
    skip($skip_font_test, 2) if $skip_font_test;
    like(join(" ", $lb->xview), qr/^0 0\.2222/);
    like(join(" ", $lb->yview), qr/^0 0\.3333/);
}

map { $_->destroy } $mw->children;
my $l1 = $mw->$Listbox(-bg => "#543210");
my $l2 = $l1;
like(join(",", map { $_->PathName } $mw->children) ,qr/^\.listbox\d*$/);
is($l2->cget(-bg), "#543210");
$l2->destroy;

my $top = $mw->Toplevel;
$top->geometry("+0+0");
my $top_lb = $top->$Listbox(-setgrid => 1,
			    -width => 20,
			    -height => 10)->pack;
$top_lb->update;
like($top->geometry, qr/20x10\+\d+\+\d+/);
$top_lb->destroy;
SKIP: {
    skip($skip_font_test, 1) if $skip_font_test;
    like($top->geometry, qr/150x178\+\d+\+\d+/, "Geometry");
}

$lb = $mw->$Listbox->pack;
$lb->delete(0, "end");
$lb->insert(qw/0 el0 el1 el2 el3 el4 el5 el6 el7 el8 el9 el10 el11/);
$lb->activate(3);
is($lb->index("active"), 3);
$lb->activate(6);
is($lb->index("active"), 6);

$lb->selection(qw/anchor 2/);
is($lb->index(qw/anchor/), 2);

$lb->insert(qw/end A B C D E/);
$lb->selection(qw/anchor end/);
$lb->delete(qw/12 end/);
is($lb->index("anchor"), 12);
is($lb->index("end"), 12);

eval { $lb->index("a") };
like($@ ,qr/bad listbox index \"a\": must be active, anchor, end, \@x,y, or a number/, "Listbox index error message");

eval { $lb->index("\@") };
like($@ ,qr/bad listbox index \"\@\": must be active, anchor, end, \@x,y, or a number/);

eval { $lb->index("\@foo") };
like($@ ,qr/bad listbox index \"\@foo\": must be active, anchor, end, \@x,y, or a number/);

eval { $lb->index("\@1x3") };
like($@ ,qr/bad listbox index \"\@1x3\": must be active, anchor, end, \@x,y, or a number/);

eval { $lb->index("\@1,") };
like($@ ,qr/bad listbox index \"\@1,\": must be active, anchor, end, \@x,y, or a number/);

eval { $lb->index("\@1,foo") };
like($@ ,qr/bad listbox index \"\@1,foo\": must be active, anchor, end, \@x,y, or a number/);

eval { $lb->index("\@1,2x") };
like($@ ,qr/bad listbox index \"\@1,2x\": must be active, anchor, end, \@x,y, or a number/);

eval { $lb->index("1xy") };
like($@ ,qr/bad listbox index \"1xy\": must be active, anchor, end, \@x,y, or a number/);

is($lb->index("end"), 12);

is($lb->get(qw/end/), "el11");

$lb->delete(qw/0 end/);
is($lb->index(qw/end/), 0);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 el0 el1 el2 el3 el4 el5 el6 el7 el8 el9 el10 el11/);
$lb->update;

is($lb->index(q/@5,57/), 3);
is($lb->index(q/@5,58/), 3);

is($lb->index(qw/3/), 3);
is($lb->index(qw/20/), 20);

is($lb->get(qw/20/), undef);

is($lb->index(qw/-2/), -2);

$lb->delete(qw/0 end/);
is($lb->index(qw/1/), 1);

$lb->destroy;
$lb = $mw->$Listbox(-height => 5)->pack;
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->yview(qw/3/);
$lb->update;
is($lb->index(q/@0,0/), 3);
$lb->yview(qw/-1/);
$lb->update;
is($lb->index(q/@0,0/), 0);

$lb->destroy;
$lb = $mw->$Listbox(qw/-height 5/)->pack;
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->yview(qw/3/);
$lb->update;
is($lb->index(q/@0,0/), 3);
$lb->yview(qw/20/);
$lb->update;
is($lb->index(q/@0,0/), 5);

$lb->destroy;
$lb = $mw->$Listbox(qw/-height 5 -yscrollcommand/, [qw/record y/])->pack;
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->update;
@log = ();
$lb->yview(qw/2/);
$lb->update;
is_float("@{[ $lb->yview ]}", "0.2 0.7");
is_float($log[0], "y 0.2 0.7");

$lb->destroy;
$lb = $mw->$Listbox(qw/-height 5 -yscrollcommand/, [qw/record y/])->pack;
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->update;
@log = ();
$lb->yview(qw/8/);
$lb->update;
is_float("@{[ $lb->yview ]}", "0.5 1");
is_float($log[0], "y 0.5 1");

$lb->destroy;
$lb = $mw->$Listbox(qw/-height 5 -yscrollcommand/, [qw/record y/])->pack;
$lb->insert(qw/0 a b c d e f g h i j/);
$lb->yview(qw/3/);
$lb->update;
@log = ();
$lb->yview(qw/3/);
$lb->update;
is_float("@{[ $lb->yview ]}", "0.3 0.8");
is(scalar @log, 0);

mkPartial();
$partial_lb->yview(13);
like($partial_lb->index('@0,0'), qr/^1[01]$/);

$lb->destroy;
$lb = $mw->$Listbox(-font => $fixed,
		   -xscrollcommand => ["record", "x"],
		   -width => 10);
$lb->insert(qw/0 0123456789a123456789b123456789c123456789d123456789e123456789f123456789g123456789h123456789i123456789/);
$lb->pack;
$lb->update;

@log = ();
$lb->xview(qw/99/);
$lb->update;
is_float("@{[ $lb->xview ]}", "0.9 1");
is_float(($lb->xview)[0], 0.9);
is(($lb->xview)[1], 1);
is_float($log[0], "x 0.9 1");

@log = ();
$lb->xview(qw/moveto -.25/);
$lb->update;
is_float("@{[ $lb->xview ]}", "0 0.1");
is_float($log[0], "x 0 0.1");

$lb->xview(qw/10/);
$lb->update;
@log = ();
$lb->xview(qw/10/);
$lb->update;
is_float("@{[ $lb->xview ]}", "0.1 0.2");
is(scalar @log, 0);

$lb->destroy;
$lb = $mw->$Listbox(-font => $fixed, -width => 10, -height => 5)->pack;
$lb->insert(qw/0 a bb c d e f g h i j k l m n o p q r s/);
$lb->insert(qw/0 0123456789a123456789b123456789c123456789d123456789/);
$lb->update;
my $width  = ($lb->bbox(2))[2] - ($lb->bbox(1))[2];
my $height = ($lb->bbox(2))[1] - ($lb->bbox(1))[1];

$lb->yview(qw/0/);
$lb->xview(qw/0/);
$lb->scan(qw/mark 10 20/);
$lb->scan(qw/dragto/, 10-$width, 20-$height);
$lb->update;
is_float("@{[ $lb->xview ]}", "0.2 0.4");
is_float("@{[ $lb->yview ]}", "0.5 0.75");

$lb->yview(qw/5/);
$lb->xview(qw/10/);
$lb->scan(qw/mark 10 20/);
$lb->scan(qw/dragto 20 40/);
$lb->update;
is_float("@{[ $lb->xview ]}", "0 0.2");
is_float("@{[ $lb->yview ]}", "0 0.25");

$lb->scan(qw/dragto/, 20-$width, 40-$height);
$lb->update;
is_float("@{[ $lb->xview ]}", "0.2 0.4");
is_float(join(',',$lb->xview), "0.2,0.4");  # just to prove it is a list
is_float("@{[ $lb->yview ]}", "0.5 0.75");
is_float(join(',',$lb->yview), "0.5,0.75"); # just to prove it is a list

$lb->yview(qw/moveto 1.0/);
$lb->xview(qw/moveto 1.0/);
$lb->scan(qw/mark 10 20/);
$lb->scan(qw/dragto 5 10/);
$lb->update;
is_float("@{[ $lb->xview ]}", "0.8 1");
is_float("@{[ $lb->yview ]}", "0.75 1");
$lb->scan(qw/dragto/, 5+$width, 10+$height);
$lb->update;
is_float("@{[ $lb->xview ]}", "0.64 0.84");
is_float("@{[ $lb->yview ]}", "0.25 0.5");

mkPartial();
is($partial_lb->nearest($partial_lb->height), 4);

$lb->destroy;
$lb = $mw->$Listbox(-font => $fixed,
		    -width => 20,
		    -height => 10);
$lb->insert(qw/0 a b c d e f g h i j k l m n o p q r s t/);
$lb->yview(qw/4/);
$lb->pack;
$lb->update;

SKIP: {
    skip($skip_fixed_font_test, 3) if $skip_fixed_font_test;

    is($lb->index(q/@50,0/), 4);
    is($lb->index(q/@50,35/), 5);
    is($lb->index(q/@50,36/), 6);
}

like($lb->index(q/@50,200/), qr/^\d+/);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j k l m n o p/);
$lb->selection(qw/set 2 4/);
$lb->selection(qw/set 7 12/);
$lb->selection(qw/clear 4 7/);
is_deeply([ $lb->curselection ], [qw(2 3 8 9 10 11 12)]);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f g h i j k l m n o p/);

$e = $mw->Entry;
$e->insert(0, "This is some text");
$e->selection(qw/from 0/);
$e->selection(qw/to 7/);
$lb->selection(qw/clear 2 4/);
is($mw->SelectionOwner, $e);
$lb->selection(qw/set 3/);
is($mw->SelectionOwner, $lb);
is($mw->SelectionGet, "d");

$lb->delete(qw/0 end/);
$lb->selection(qw/clear 0 end/);
$lb->selection(qw/set 0 end/);
is($lb->curselection, undef);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f/);
$lb->selection(qw/clear 0 end/);
$lb->selection(qw/set -2 -1/);
is($lb->curselection, undef);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f/);
$lb->selection(qw/clear 0 end/);
$lb->selection(qw/set -1 3/);
is_deeply([$lb->curselection], [0,1,2,3]);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f/);
$lb->selection(qw/clear 0 end/);
$lb->selection(qw/set 2 4/);
is_deeply([$lb->curselection], [qw(2 3 4)]);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f/);
$lb->selection(qw/clear 0 end/);
$lb->selection(qw/set 4 end/);
is_deeply([$lb->curselection], [4, 5]);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f/);
$lb->selection(qw/clear 0 end/);
$lb->selection(qw/set 4 30/);
is_deeply([$lb->curselection], [4, 5]);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f/);
$lb->selection(qw/clear 0 end/);
$lb->selection(qw/set end 30/);
is(join(",", $lb->curselection), 5);
is(scalar @{[ $lb->curselection ]}, 1);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e f/);
$lb->selection(qw/clear 0 end/);
$lb->selection(qw/set 20 25/);
is($lb->curselection, undef);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c/, "two words", qw/ e f g h i \ k l m n o p/);
$lb->selection(qw/set 2 4/);
$lb->selection(qw/set 9/);
$lb->selection(qw/set 11 12/);
is($mw->SelectionGet, "c\ntwo words\ne\n\\\nl\nm");

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c/, "two words", qw/ e f g h i \ k l m n o p/);
$lb->selection(qw/set 3/);
is($mw->SelectionGet, "two words");

my $long = "This is quite a long string\n" x 11;
$lb->delete(qw/0 end/);
$lb->insert(0, "1$long", "2$long", "3$long", "4$long", "5$long");
$lb->selection(qw/set 0 end/);
is($mw->SelectionGet, "1$long\n2$long\n3$long\n4$long\n5$long");

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e/);
$lb->selection(qw/set 0 end/);
$e->destroy;
$e = $mw->Entry;
$e->insert(0, "This is some text");
$e->selection(qw/from 0/);
$e->selection(qw/to 5/);
is($lb->curselection, undef);

$lb->delete(qw/0 end/);
$lb->insert(qw/0 a b c d e/);
$lb->selection(qw/set 0 end/);
$lb->configure(qw/-exportselection 0/);
$e->destroy;
$e = $top->Entry;
$e->insert(0, "This is some text");
$e->selection(qw/from 0/);
$e->selection(qw/to 5/);
is_deeply([$lb->curselection], [qw(0 1 2 3 4)]);

$lb->destroy;
$lb = $mw->$Listbox(-font => $fixed, -width => 10, -height => 5);
$lb->pack;
$lb->update;

$lb->configure(qw/-yscrollcommand/, [qw/record y/]);
@log = ();
$lb->insert(qw/0 a b c/);
$lb->update;
$lb->insert(qw/end d e f g h/);
$lb->update;
$lb->delete(qw/0 end/);
$lb->update;
is($log[0], "y 0 1");
is_float($log[1], "y 0 0.625");
is($log[2], "y 0 1");

mkPartial();
$partial_lb->configure(-yscrollcommand => ["record", "y"]);
@log = ();
$partial_lb->yview(3);
$partial_lb->update;
like($log[0], qr/^y 0\.2(0000+\d+)? 0\.\d+/);

@x = ();

sub Tk::Error {
    push @x, @_;
}

# XXX dumps core with 5.7.0 and 803.023
$lb->configure(qw/-yscrollcommand gorp/);
$lb->insert(qw/0 foo/);
$lb->update;
like("@x" ,qr/Undefined subroutine &main::gorp called.*vertical scrolling command executed by listbox/s);

$lb->destroy;
$lb = $mw->$Listbox(-font => $fixed, qw/-width 10 -height 5/)->pack;
$lb->update;

$lb->configure(qw/-xscrollcommand/, ["record", "x"]);
@log = ();
$lb->insert(qw/0 abc/);
$lb->update;
$lb->insert(qw/0/, "This is a much longer string...");
$lb->update;
$lb->delete(qw/0 end/);
$lb->update;
is($log[0], "x 0 1");
like($log[1] ,qr/^x 0 0\.32258/);
is($log[2], "x 0 1");

@x = ();
$lb->configure(qw/-xscrollcommand bogus/);
$lb->insert(qw/0 foo/);
$lb->update;
like("@x" ,qr/Undefined subroutine &main::bogus.*horizontal scrolling command executed by listbox/s);

foreach ($mw->children) { $_->destroy }

## XXX not yet
#  # tests for ListboxListVarProc
#  test listbox-21.1 {ListboxListVarProc} {
#      catch {destroy $_lb}
#      catch {unset x}
#      listbox $_lb -listvar x
#      set x [list a b c d]
#      $_lb get 0 end
#  } [list a b c d]
#  test listbox-21.2 {ListboxListVarProc} {
#      catch {destroy $_lb}
#      set x [list a b c d]
#      listbox $_lb -listvar x
#      unset x
#      set x
#  } [list a b c d]
#  test listbox-21.3 {ListboxListVarProc} {
#      catch {destroy $_lb}
#      set x [list a b c d]
#      listbox $_lb -listvar x
#      $_lb configure -listvar {}
#      unset x
#      info exists x
#  } 0
#  test listbox-21.4 {ListboxListVarProc} {
#      catch {destroy $_lb}
#      set x [list a b c d]
#      listbox $_lb -listvar x
#      lappend x e f g
#      $_lb size
#  } 7
#  test listbox-21.5 {ListboxListVarProc, test selection after listvar mod} {
#      catch {destroy $_lb}
#      set x [list a b c d e f g]
#      listbox $_lb -listvar x
#      $_lb selection set end
#      set x [list a b c d]
#      set x [list 0 1 2 3 4 5 6]
#      $_lb curselection
#  } {}
#  test listbox-21.6 {ListboxListVarProc, test selection after listvar mod} {
#      catch {destroy $_lb}
#      set x [list a b c d]
#      listbox $_lb -listvar x
#      $_lb selection set 3
#      lappend x e f g
#      $_lb curselection
#  } 3
#  test listbox-21.7 {ListboxListVarProc, test selection after listvar mod} {
#      catch {destroy $_lb}
#      set x [list a b c d]
#      listbox $_lb -listvar x
#      $_lb selection set 0
#      set x [linsert $x 0 1 2 3 4]
#      $_lb curselection
#  } 0
#  test listbox-21.8 {ListboxListVarProc, test selection after listvar mod} {
#      catch {destroy $_lb}
#      set x [list a b c d]
#      listbox $_lb -listvar x
#      $_lb selection set 2
#      set x [list a b c]
#      $_lb curselection
#  } 2
#  test listbox-21.9 {ListboxListVarProc, test hscrollbar after listvar mod} {
#      catch {destroy $_lb}
#      catch {unset x}
#      set log {}
#      listbox $_lb -font $fixed -width 10 -xscrollcommand "record x" -listvar x
#      pack $_lb
#      update
#      lappend x "0000000000"
#      update
#      lappend x "00000000000000000000"
#      update
#      set log
#  } [list {x 0 1} {x 0 1} {x 0 0.5}]
#  test listbox-21.10 {ListboxListVarProc, test hscrollbar after listvar mod} {
#      catch {destroy $_lb}
#      catch {unset x}
#      set log {}
#      listbox $_lb -font $fixed -width 10 -xscrollcommand "record x" -listvar x
#      pack $_lb
#      update
#      lappend x "0000000000"
#      update
#      lappend x "00000000000000000000"
#      update
#      set x [list "0000000000"]
#      update
#      set log
#  } [list {x 0 1} {x 0 1} {x 0 0.5} {x 0 1}]
#  test listbox-21.11 {ListboxListVarProc, bad list} {
#      catch {destroy $_lb}
#      catch {unset x}
#      listbox $_lb -listvar x
#      set x [list a b c d]
#      catch {set x {this is a " bad list}} result
#      set result
#  } {can't set "x": invalid listvar value}
#  test listbox-21.12 {ListboxListVarProc, cleanup item attributes} {
#      catch {destroy $_lb}
#      set x [list a b c d e f g]
#      listbox $_lb -listvar x
#      $_lb itemconfigure end -fg red
#      set x [list a b c d]
#      set x [list 0 1 2 3 4 5 6]
#      $_lb itemcget end -fg
#  } {}
#  test listbox-21.12 {ListboxListVarProc, cleanup item attributes} {
#      catch {destroy $_lb}
#      set x [list a b c d e f g]
#      listbox $_lb -listvar x
#      $_lb itemconfigure end -fg red
#      set x [list a b c d]
#      set x [list 0 1 2 3 4 5 6]
#      $_lb itemcget end -fg
#  } {}
#  test listbox-21.13 {listbox item configurations and listvar based deletions} {
#      catch {destroy $_lb}
#      catch {unset x}
#      listbox $_lb -listvar x
#      $_lb insert end a b c
#      $_lb itemconfigure 1 -fg red
#      set x [list b c]
#      $_lb itemcget 1 -fg
#  } red
#  test listbox-21.14 {listbox item configurations and listvar based inserts} {
#      catch {destroy $_lb}
#      catch {unset x}
#      listbox $_lb -listvar x
#      $_lb insert end a b c
#      $_lb itemconfigure 0 -fg red
#      set x [list 1 2 3 4 a b c]
#      $_lb itemcget 0 -fg
#  } red
#  test listbox-21.15 {ListboxListVarProc, update vertical scrollbar} {
#      catch {destroy $_lb}
#      catch {unset x}
#      set log {}
#      listbox $_lb -listvar x -yscrollcommand "record y" -font fixed -height 3
#      pack $_lb
#      update
#      lappend x a b c d e f
#      update
#      set log
#  } [list {y 0 1} {y 0 0.5}]
#  test listbox-21.16 {ListboxListVarProc, update vertical scrollbar} {
#      catch {destroy $_lb}
#      catch {unset x}
#      listbox $_lb -listvar x -height 3
#      pack $_lb
#      update
#      set x [list 0 1 2 3 4 5]
#      $_lb yview scroll 3 units
#      update
#      set result {}
#      lappend result [$_lb yview]
#      set x [lreplace $x 3 3]
#      set x [lreplace $x 3 3]
#      set x [lreplace $x 3 3]
#      update
#      lappend result [$_lb yview]
#      set result
#  } [list {0.5 1} {0 1}]

# UpdateHScrollbar

@log = ();
$lb = $mw->Listbox(-font => $fixed, -width => 10, -xscrollcommand => ["record", "x"])->pack;
$mw->update;
$lb->insert("end", "0000000000");
$mw->update;
$lb->insert("end", "00000000000000000000");
$mw->update;
is($log[0], "x 0 1");
is($log[1], "x 0 1");
is($log[2], "x 0 0.5");

## no itemconfigure in Tk800.x
#  # ConfigureListboxItem
#  test listbox-23.1 {ConfigureListboxItem} {
#      catch {destroy $_lb}
#      listbox $_lb
#      catch {$_lb itemconfigure 0} result
#      set result
#  } {item number "0" out of range}
#  test listbox-23.2 {ConfigureListboxItem} {
#      catch {destroy $_lb}
#      listbox $_lb
#      $_lb insert end a b c d
#      $_lb itemconfigure 0
#  } [list {-background background Background {} {}} \
#  	{-bg -background} \
#  	{-fg -foreground} \
#  	{-foreground foreground Foreground {} {}} \
#  	{-selectbackground selectBackground Foreground {} {}} \
#  	{-selectforeground selectForeground Background {} {}}]
#  test listbox-23.3 {ConfigureListboxItem, itemco shortcut} {
#      catch {destroy $_lb}
#      listbox $_lb
#      $_lb insert end a b c d
#      $_lb itemco 0 -background
#  } {-background background Background {} {}}
#  test listbox-23.4 {ConfigureListboxItem, wrong num args} {
#      catch {destroy $_lb}
#      listbox $_lb
#      $_lb insert end a
#      catch {$_lb itemco} result
#      set result
#  } {wrong # args: should be "$_lb itemconfigure index ?option? ?value? ?option value ...?"}
#  test listbox-23.5 {ConfigureListboxItem, multiple calls} {
#      catch {destroy $_lb}
#      listbox $_lb
#      set i 0
#      foreach color {red orange yellow green blue darkblue violet} {
#  	$_lb insert end $color
#  	$_lb itemconfigure $i -bg $color
#  	incr i
#      }
#      pack $_lb
#      update
#      list [$_lb itemcget 0 -bg] [$_lb itemcget 1 -bg] [$_lb itemcget 2 -bg] \
#  	    [$_lb itemcget 3 -bg] [$_lb itemcget 4 -bg] [$_lb itemcget 5 -bg] \
#  	    [$_lb itemcget 6 -bg]
#  } {red orange yellow green blue darkblue violet}
#  catch {destroy $_lb}
#  listbox $_lb
#  $_lb insert end a b c d
#  set i 6
#  #      {-background #ff0000 #ff0000 non-existent
#  #  	    {unknown color name "non-existent"}}
#  #      {-bg #ff0000 #ff0000 non-existent {unknown color name "non-existent"}}
#  #      {-fg #110022 #110022 bogus {unknown color name "bogus"}}
#  #      {-foreground #110022 #110022 bogus {unknown color name "bogus"}}
#  #      {-selectbackground #110022 #110022 bogus {unknown color name "bogus"}}
#  #      {-selectforeground #654321 #654321 bogus {unknown color name "bogus"}}
#  #XXX
#  foreach test { A } {
#      set name [lindex $test 0]
#      test listbox-23.$i {configuration options} {
#  	$_lb itemconfigure 0 $name [lindex $test 1]
#  	list [lindex [$_lb itemconfigure 0 $name] 4] [$_lb itemcget 0 $name]
#      } [list [lindex $test 2] [lindex $test 2]]
#      incr i
#      if {[lindex $test 3] != ""} {
#  	test listbox-1.$i {configuration options} {
#  	    list [catch {$_lb configure $name [lindex $test 3]} msg] $msg
#  	} [list 1 [lindex $test 4]]
#      }
#      $_lb configure $name [lindex [$_lb configure $name] 3]
#      incr i
#  }

#  # ListboxWidgetObjCmd, itemcget
#  test listbox-24.1 {itemcget} {
#      catch {destroy $_lb}
#      listbox $_lb
#      $_lb insert end a b c d
#      $_lb itemcget 0 -fg
#  } {}
#  test listbox-24.2 {itemcget} {
#      catch {destroy $_lb}
#      listbox $_lb
#      $_lb insert end a b c d
#      $_lb itemconfigure 0 -fg red
#      $_lb itemcget 0 -fg
#  } red
#  test listbox-24.3 {itemcget} {
#      catch {destroy $_lb}
#      listbox $_lb
#      $_lb insert end a b c d
#      catch {$_lb itemcget 0} result
#      set result
#  } {wrong # args: should be "$_lb itemcget index option"}
#  test listbox-24.3 {itemcget, itemcg shortcut} {
#      catch {destroy $_lb}
#      listbox $_lb
#      $_lb insert end a b c d
#      catch {$_lb itemcg 0} result
#      set result
#  } {wrong # args: should be "$_lb itemcget index option"}

#  # General item configuration issues
#  test listbox-25.1 {listbox item configurations and widget based deletions} {
#      catch {destroy $_lb}
#      listbox $_lb
#      $_lb insert end a
#      $_lb itemconfigure 0 -fg red
#      $_lb delete 0 end
#      $_lb insert end a
#      $_lb itemcget 0 -fg
#  } {}
#  test listbox-25.2 {listbox item configurations and widget based inserts} {
#      catch {destroy $_lb}
#      listbox $_lb
#      $_lb insert end a b c
#      $_lb itemconfigure 0 -fg red
#      $_lb insert 0 1 2 3 4
#      list [$_lb itemcget 0 -fg] [$_lb itemcget 4 -fg]
#  } [list {} red]

resetGridInfo();

sub record {
    push @log, join(" ", @_);
}

sub getsize {
    my $w = shift;
    my $geom = $w->geometry;
    $geom =~ /(\d+x\d+)/;
    $1;
}

sub resetGridInfo {
    # Some window managers, such as mwm, don't reset gridding information
    # unless the window is withdrawn and re-mapped.  If this procedure
    # isn't invoked, the window manager will stay in gridded mode, which
    # can cause all sorts of problems.  The "wm positionfrom" command is
    # needed so that the window manager doesn't ask the user to
    # manually position the window when it is re-mapped.
    $mw->withdraw;
    $mw->positionfrom('user');
    $mw->deiconify;
}

# Procedure that creates a second listbox for checking things related
# to partially visible lines.
sub mkPartial {
    eval {
	$partial_top->destroy
	    if Tk::Exists($partial_top);
    };
    $partial_top = $mw->Toplevel;
    $partial_top->geometry('+0+0');
    $partial_lb = $partial_top->Listbox(-width => 30, -height => 5);
    $partial_lb->pack('-expand',1,'-fill','both');
    $partial_lb->insert('end','one','two','three','four','five','six','seven',
			'eight','nine','ten','eleven','twelve','thirteen',
			'fourteen','fifteen');
    $partial_top->update;
    my $geom = $partial_top->geometry;
    my($width, $height) = $geom =~ /(\d+)x(\d+)/;
    $partial_top->geometry($width . "x" . ($height-3));
    $partial_top->update;
}

__END__

