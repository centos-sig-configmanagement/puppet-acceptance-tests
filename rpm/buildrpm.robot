*** Settings ***
Library             ../lib/DuffyLibrary.py
Resource            ../lib/basic.robot

*** Keywords ***
I fetch the sources
    I successfully run   spectool    -g  -C  ws  ws/%{SPECFILE}.spec

I run rpmbuild
    I successfully run   rpmbuild    --define    "_topdir /root"     --define    "_sourcedir ws"  -bs     ws/%{SPECFILE}.spec

I make the specfile unique
    I run locally  sed  s/^Release:.*/Release: pr%{ghprbPullId}job%{BUILD_NUMBER}/  -i  %{WORKSPACE}/%{SPECFILE}.spec
    I run locally  sed  /Release: pr%{ghprbPullId}job%{BUILD_NUMBER}/aProvides: facter-git-commit(%{ghprbActualCommit})  -i  %{WORKSPACE}/%{SPECFILE}.spec
    I run locally  sed  /Release: pr%{ghprbPullId}job%{BUILD_NUMBER}/aProvides: facter-pull-request(%{ghprbPullId})  -i  %{WORKSPACE}/%{SPECFILE}.spec
    I run locally  sed  /Release: pr%{ghprbPullId}job%{BUILD_NUMBER}/aProvides: facter-pull-request-build-id(pr%{ghprbPullId}job%{BUILD_NUMBER})  -i  %{WORKSPACE}/%{SPECFILE}.spec
    I run locally  sed  /Release: pr%{ghprbPullId}job%{BUILD_NUMBER}/aEpoch: %{BUILD_NUMBER}  -i  %{WORKSPACE}/%{SPECFILE}.spec

I build a SRPM from the specfile
    I install   rpmdevtools
    I install   rpm-build
    I fetch the sources
    I run rpmbuild

I copy the workspace
    I install   rsync
    I rsync the workspace

I build the spec file in CBS
    On the Duffy node
    I copy the workspace
    I build a SRPM from the specfile
    I fetch the SRPM
    I run locally   cbs  build  --wait  --scratch  %{BUILDTARGET} %{WORKSPACE}/*.src.rpm


*** Test cases ***
I build the RPM from a Pull Request
    [Teardown]  Release the Duffy nodes
    Pass Execution if  'ghprbPullId' not in os.environ   Skipping because ghprbPullId is not set
    Populate a Duffy node
    I make the spec file unique
    I build the spec file in CBS

I build the RPM from a branch
    [Teardown]  Release the Duffy nodes
    Pass Execution if  'ghprbPullId' in os.environ   Skipping because ghprbPullId is set
    Populate a Duffy node
    I build the spec file in CBS
