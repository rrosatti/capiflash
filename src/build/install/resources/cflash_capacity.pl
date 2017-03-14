#! /usr/bin/perl
# IBM_PROLOG_BEGIN_TAG
# This is an automatically generated prolog.
#
# $Source: src/build/install/resources/cflash_capacity.pl $
#
# IBM Data Engine for NoSQL - Power Systems Edition User Library Project
#
# Contributors Listed Below - COPYRIGHT 2014,2015
# [+] International Business Machines Corp.
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing
# permissions and limitations under the License.
#
# IBM_PROLOG_END_TAG
##
use strict;
use warnings;
use Fcntl;
use Fcntl ':seek';
use Getopt::Long qw(:config no_ignore_case);

#-------------------------------------------------------------------------------
# Variables
my $type="0601";
my $devices="";
my $size;
my $superpipe;
my $tsize=0;
my $prthelp=0;
my $verbose;

sub usage()
{
  print "\n";
  print "Usage: cflash_capacity.pl [-t type]                         \n";
  print "    -t or --type      : Type to list                        \n";
  print "    -S or --superpipe : use only devs in superpipe mode     \n";
  print "    -v                : verbose output                      \n";
  print "    -h or --help      : Help - Print this message           \n";
  print "\n  ex: cflash_devices.pl -t 0601                           \n\n";
  exit 0;
}

#-------------------------------------------------------------------------------
# Parse Options
#-------------------------------------------------------------------------------
if (! GetOptions ("t|type=s"    => \$type,
                  "S|superpipe" => \$superpipe,
                  "v"           => \$verbose,
                  "h|help!"     => \$prthelp
                  ))
{
  usage();
}
if ($ARGV[0])
{
  print "\nUnknown Command Line Options:\n";
  foreach(@ARGV)
  {
    print "   $_\n";
  }
  print "\n";
  usage();
}
if ($prthelp) {usage();}

#-------------------------------------------------------------------------------
# Make stdout autoflush
#-------------------------------------------------------------------------------
select(STDOUT);
$| = 1;

#-------------------------------------------------------------------------------
# list Devices
#-------------------------------------------------------------------------------
my @cards = `lspci |grep $type`;
my $cmd="";
my $sym;
my $nsq;

for my $cardN (@cards)
{
  my @Acard=split / /, $cardN;
  my $card=$Acard[0];
  chomp $card;
  my $afustr=`ls -d /sys/devices/*/*/$Acard[0]/cxl/card*/afu*.0/afu*m 2>/dev/null`;
  my @afu=split /\//, $afustr;
  my $afu=pop @afu;
  if (length $afu) {chomp $afu;}
  else             {$afu="";}
  my $cardstr=`ls -d /sys/devices/*/*/$Acard[0]/cxl/card* 2>/dev/null`;
  chomp $cardstr;
  my $cardN=substr $cardstr,-1;

  for (my $i=0; $i<2; $i++)
  {
    if ($i == 1 && $type =~ /04cf/) {next;}
    my @Adev=`ls -d /sys/devices/*/*/$Acard[0]/*/*/host*/target*:$i:*/*:*:*:*/block/* 2>/dev/null |awk -F/ '{print \$13}'`;
    if ($? != 0) {next;}
    foreach my $dev (@Adev)
    {
      chomp $dev;
      $size=`fdisk -l /dev/$dev 2>/dev/null|grep "Disk /dev"|awk '{print \$3}'|awk -F. '{print \$1}'`;
      $sym=`fdisk -l /dev/$dev 2>/dev/null|grep "Disk /dev"|awk '{print \$4}'`;
      chomp $size;
      if ($size eq "") {$size=0;}
      if ($sym =~ /TiB/) {$size *= 1000;}

      my $pdev=`/opt/ibm/capikv/bin/cxlfstatus|grep $dev|awk '{print \$1}'`;
      my $spdev=`/opt/ibm/capikv/bin/cxlfstatus|grep $dev|grep superpipe`;
      chomp $spdev; chomp $pdev;
      if ($superpipe && !($spdev =~ /superpipe/)) {next;}

      if ($verbose)
      {
        printf("/dev/%s %d    ",$pdev, $size);
        if ($type =~ /0601/)
        {
          $nsq=`/opt/ibm/capikv/afu/flashgt_nvme_nsq --port $i /dev/cxl/$afu`;
          chomp $nsq;
          printf("    $nsq");
        }
        printf("\n");
      }
      $tsize+=$size;
    }
  }
}

print "$tsize\n";

