#!/bin/sh
#
# git-work
#
# MIT License
#
# Copyright (c) 2017 Marcos Douglas B. Santos
#
# Permission is hereby granted, free of #charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e

usage() {
  echo -e "Usage: git work <subcommand>\n"
  echo "Available subcommands are:"
  echo "   issue <id>              Start a new branch from issue <id>"
  echo "   commit <\"msg\">          Commit current work using <message>"
  echo "   done <id>               Finish current work and merge"
  echo "   push <master>           Push to the server"
  echo "   release <tag> [<\"msg\">] Release a new tag called <tag> with <message>"
  echo "   pr <id>                 Create a branch from a pull-request"
}

if [ -z $1 ] || [ -z $2 ]; then
  usage
  exit 1
fi

case "$1" in
  # start a new branch
  issue)
    git checkout -b "$2"
    ;;
  # commit current work
  commit)
    git commit -am "$2"
    ;;
  # finish current work and merge
  done)
    git checkout master
    git merge "$2"
    ;;
  # push to the server
  push)
    git push origin "$2"
    ;;
  # release a new tag
  release)
    git checkout master
    if [ -z "$3" ]; then
      git tag "$2"
    else
      git tag "$2" -m "$3"
    fi
    git push --tags
    ;;
  # create a branch from a pull-request
  pr)
    git fetch origin pull/"$2"/head:pr/"$2"
    git checkout pr/"$2"
    ;;
  *)
    usage
    exit 1
    ;;
esac
