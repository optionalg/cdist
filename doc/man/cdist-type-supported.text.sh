#!/bin/sh
#
# 2010-2011 Nico Schottelius (nico-cdist at schottelius.org)
#
# This file is part of cdist.
#
# cdist is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# cdist is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with cdist. If not, see <http://www.gnu.org/licenses/>.
#
#
# Generate manpage that lists available types
#

__cdist_pwd="$(pwd -P)"
__cdist_mydir="${0%/*}";
__cdist_abs_mydir="$(cd "$__cdist_mydir" && pwd -P)"
__cdist_myname=${0##*/};
__cdist_abs_myname="$__cdist_abs_mydir/$__cdist_myname"

filename="${__cdist_myname%.sh}"
dest="$__cdist_abs_mydir/$filename"

exit 0

cat << eof > "$dest"
cdist-type-listing(7)
=====================
Nico Schottelius <nico-cdist--@--schottelius.org>


NAME
----
cdist-type-listing - Available types in cdist


SYNOPSIS
--------
Types that are included in cdist $(git describe).


DESCRIPTION
-----------
Types are the main component of cdist and define functionality. If you
use cdist, you'll write a type for every functionality you would like
to use.


HOW TO USE A TYPE
-----------------
You can use types from the initial manifest or the type manifest like a
normal command:

--------------------------------------------------------------------------------
# Creates empty file /etc/cdist-configured
__file /etc/cdist-configured --type file

# Ensure tree is installed
__package tree --state installed
--------------------------------------------------------------------------------

Internally cdist-type-emulator(1) will be called from cdist-manifest-run(1) to
save the given parameters into a cconfig database, so they can be accessed by
the manifest and gencode scripts of the type (see below).


HOW TO WRITE A NEW TYPE
-----------------------
A type consists of

- parameter (optional)
- manifest  (optional)
- explorer  (optional)
- gencode   (optional)

Types are stored below conf/type/. Their name should always be prefixed with
two underscores (__) to prevent collisions with other binaries in $PATH.

To begin a new type from a template, execute "cdist-type-template __NAME"
and cd conf/type/__NAME.


DEFINING PARAMETERS
-------------------
Every type consists of optional and required parameters, which must
be created in a newline seperated file in parameters/required and
parameters/optional. If either or both missing, the type will have
no required, no optional or no parameters at all.

Example:
--------------------------------------------------------------------------------
echo servername >> conf/type/__nginx_vhost/parameter/required
echo logdirectory >> conf/type/__nginx_vhost/parameter/optional
--------------------------------------------------------------------------------


WRITING THE MANIFEST
--------------------
In the manifest of a type you can use other types, so your type extends
their functionality. A good example is the __package type, which in
a shortened version looks like this:

--------------------------------------------------------------------------------
os="$(cat "$__global/explorer/os")"
case "$os" in
      archlinux) type="pacman" ;;
      debian|ubuntu) type="apt" ;;
      gentoo) type="emerge" ;;
      *)
         echo "Don't know how to manage packages on: $os" >&2
         exit 1
      ;;
esac

__package_$type "$@"
--------------------------------------------------------------------------------

As you can see, the type can reference different environment variables,
which are documented in cdist-environment-variables(7).

Always ensure the manifest is executable, otherwise cdist will not be able
to execute it.


THE TYPE EXPLORERS
------------------
If a type needs to explore specific details, it can provide type specific
explorers, which will be executed on the target for every created object.

The explorers are stored under the "explorer" directory below the type.
It could for instance contain code to check the md5sum of a file on the
client, like this (shortened version from real type __file):

--------------------------------------------------------------------------------
if [ -f "$__object/parameter/destination" ]; then
   destination="$(cat "$__object/parameter/destination")"
else
   destination="/$__object_id"
fi

if [ -e "$destination" ]; then
   md5sum < "$destination"
fi
--------------------------------------------------------------------------------


WRITING THE GENCODE SCRIPT
--------------------------
The gencode script can make use of the parameters, the global explorers
and the type specific explorers. The output (stdout) of this script is
saved by cdist and will be executed on the target.

If the gencode script encounters an error, it should print diagnostic
messages to stderr and exit non-zero. If you need to debug the gencode
script, you can write to stderr:

--------------------------------------------------------------------------------
# Debug output to stderr
echo "My fancy debug line" >&2

# Output to be saved by cdist for execution on the target
echo "touch /etc/cdist-configured"
--------------------------------------------------------------------------------


HINTS FOR TYPEWRITERS
----------------------
It must be assumed that the target is pretty dumb and thus does not have high
level tools like ruby installed. If a type requires specific tools to be present
on the target, there must be another type that provides this tool and the first
type should create an object of the specific type.


HOW TO INCLUDE A TYPE INTO UPSTREAM CDIST
-----------------------------------------
If you think your type may be useful for others, ensure it works with the
current master branch of cdist and submit the git url containing the type for
inclusion to the mailinglist **cdist at cdist -- at -- l.schottelius.org**.

Ensure a corresponding manpage named cdist-type__NAME is included.


SEE ALSO
--------
- cdist-manifest-run(1)
- cdist-stages(7)


COPYING
-------
Copyright \(C) 2011-$(date +%Y) Nico Schottelius. Free use of this software is
granted under the terms of the GNU General Public License version 3 (GPLv3).

eof
