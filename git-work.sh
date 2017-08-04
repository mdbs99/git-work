# git-work
#
#MIT License
#
#Copyright (c) 2017 Marcos Douglas B. Santos
#
#Permission is hereby granted, free of #charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

set -e

help() {
    echo "Usage: git work issue 123"
    echo "       git work commit \"message\""
    echo "       git work done 123"
    echo "       git work push master"
    echo "       git work release 1.0 [\"message\"] "
    echo "       git work pr 321"
}

if [ -z $1 ] || [ -z $2 ]; then
  help
  exit 0
fi

# start a new branch
if [ $1 = "issue" ]; then
  git checkout -b "$2"
fi

# commit current work
if [ $1 = "commit" ]; then
  git commit -am $2
fi

# finish current work and merge
if [ $1 = "done" ]; then
  git checkout master
  git merge $2
fi

# push to the server
if [ $1 = "push" ]; then
  git push origin $2
fi

# release a new tag
if [ $1 = "release" ]; then
  git checkout master
  if [ -z $3 ]; then
    git tag $2
  else
    git tag $2 -m $3
  fi 
  git push --tags
fi

# create a branch from a pull-request
if [ $1 = "pr" ]; then
  git fetch origin pull/$2/head:pr/$2
  git checkout pr/$2
fi
