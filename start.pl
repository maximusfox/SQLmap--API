#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use lib 'lib';
use SQLmap::API;

my $api = SQLmap::API->new(
		host => '127.0.0.1',
		port => '8775',
		idAdmin => 'f7170bb09603d700331c2f22400f2fb'
	);


unless ($api) {
	say '[ERROR] Can\'t connect to server!';
}
say '[CONNECT] Connection success!';


my $task = $api->taskNew;
unless ($task) {
	say '[ERROR] Can\'t create new task!';
}
say '[CREATE] New task created! TID['.$task->taskid.']';


my $taskOptions = $task->optionList;
unless ($taskOptions) {
	say '[ERROR] Can\'t get options list!';
}
for (keys %{$taskOptions}) {
	say 'Optin: '.$_.' = ['.$taskOptions->{$_}.']' if (defined $taskOptions->{$_});
}

my $url = 'http://hardtofind.ru/skulya/?post_id=1';
unless ($task->scanStart($url)) {
	say '[ERROR] Can\'t start scan URL[ '.$url.' ] !';
}
say '[START] Start scanning URL['.$url.']';
