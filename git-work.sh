#!/bin/sh
#
# git-work
#
# MIT License
#
# Copyright (c) 2017-2019 Marcos Douglas B. Santos
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
  echo "   issue <id>             Start a new branch from issue <id>"
  echo "   commit <\"msg\">         Commit current work using <message>"
  echo "   merge                  Merge current work into master"
  echo "   done                   Finish current work and merge"
  echo "   push                   Push current branch to the server"
  echo "   release <tag> [\"msg\"]  Release a new tag called <tag> with <message>"
  echo "   pr <id>                Create a branch from a pull-request"
}

abort_if_in_master() {
  branch=${2:-$(git symbolic-ref --short HEAD)}
  if [ "$branch" == "master" ]; then
    echo "This command cannot be executed into master"
    exit 1
  fi
}

case "$1" in
  # start a new branch
  issue)
    [ -z "$2" ] && ( usage && exit 1 )
    git checkout -b "$2"
    ;;
  # commit current work
  commit)
    [ -z "$2" ] && ( usage && exit 1 )
    for arg; do
      case "$arg" in 
        "-a") 
          git add .
          ;;
        "--amend")
          git commit --amend
          exit 0
          ;;
      esac
    done
    # checks is has an id
    if [[ "$2" =~ ^\#-?[0-9]+ ]]; then
      git commit -m "$2"
    else
      branch=$(git symbolic-ref --short HEAD)
      # checks if the branch's name is only an number
      if [[ "$branch" =~ ^-?[0-9]+$ ]]; then
        git commit -m "#$branch $2"
      else
        git commit -m "$2"
      fi
    fi
    ;;
  # merge current work into master
  merge)
    abort_if_in_master
    git fetch . "$branch":master
    ;;
  # finish current work and merge
  done)
    abort_if_in_master
    git checkout master
    git merge "$branch"
    ;;
  # push to the server
  push)
    branch=${2:-$(git symbolic-ref --short HEAD)}
    git push origin "$branch"
    ;;
  # release a new tag
  release)
    git checkout master
    [ -z "$2" ] && ( usage && exit 1 )
    if [ -z "$3" ]; then
      git tag "$2"
    else
      git tag "$2" -m "$3"
    fi
    git push --tags
    ;;
  # create a branch from a pull-request
  pr)
    [ -z "$2" ] && ( usage && exit 1 )
    git fetch origin pull/"$2"/head:pr/"$2"
    git checkout pr/"$2"
    ;;
  install)
    path=$(pwd)/git-work.sh
    git config --global alias.work "!sh $path "
    ;;
  config)
    [ -z "$2" ] && ( usage && exit 1 )
    if [ -z "$3" ]; then
      git config --get git-work."$2"
    else
      git config git-work."$2" "$3"
    fi
    ;;
  *)
    usage
    exit 1
    ;;
esac
