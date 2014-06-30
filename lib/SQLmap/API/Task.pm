package SQLmap::API::Task;

# Packages
use strict;
use warnings;
use feature 'say';
use JSON::XS;

sub new {
	my ($self, %args) = @_;
	$self = bless(\%args, $self);
	
	return $self;
}

sub taskid {
	return shift->{taskid};
}

sub taskDelete {
	my ($self) = @_;
	my $result = $self->{ua}->get('http://'.$self->{host}.':'.$self->{port}.'/task/'.$self->{taskid}.'/delete');
	return 1 if ($result->is_success and $result->content =~ m#"success":\s+true#);
	return undef;
}

sub scanStart {
	my ($self, $url) = @_;
	my $result = $self->{ua}->post(
		'http://'.$self->{host}.':'.$self->{port}.'/scan/'.$self->{taskid}.'/start',
		Content_Type => 'application/json',
		Content => encode_json({ url => $url }),
	);

	if ($result->is_success and $result->content =~ m#"success":\s+true#) {
		my $json = decode_json($result->content);
		return $json->{engineid};
	}

	return undef;
}


sub scanStop {
	my ($self) = @_;
	my $result = $self->{ua}->get('http://'.$self->{host}.':'.$self->{port}.'/scan/'.$self->{taskid}.'/stop');
	return 1 if ($result->is_success and $result->content =~ m#"success":\s+true#);
	return undef;
}

sub scanKill {
	my ($self) = @_;
	my $result = $self->{ua}->get('http://'.$self->{host}.':'.$self->{port}.'/scan/'.$self->{taskid}.'/kill');
	return 1 if ($result->is_success and $result->content =~ m#"success":\s+true#);
	return undef;
}

sub scanStatus {
	my ($self) = @_;
	my $result = $self->{ua}->get('http://'.$self->{host}.':'.$self->{port}.'/scan/'.$self->{taskid}.'/status');
	if ($result->is_success and $result->content =~ m#"success":\s+true#) {
		my $json = decode_json($result->content);
		delete $json->{success};
		return $json;
	}

	return undef;
}

sub scanData {
	my ($self) = @_;
	my $result = $self->{ua}->get('http://'.$self->{host}.':'.$self->{port}.'/scan/'.$self->{taskid}.'/data');
	if ($result->is_success and $result->content =~ m#"success":\s+true#) {
		my $json = decode_json($result->content);
		delete $json->{success};
		return $json;
	}

	return undef;
}

sub scanLog {
	my ($self, $start, $end) = @_;
	my $result;
	if ($start and $end) {
		$result = $self->{ua}->get('http://'.$self->{host}.':'.$self->{port}.'/scan/'.$self->{taskid}.'/log/'.$start.'/'.$end);
	} else {
		$result = $self->{ua}->get('http://'.$self->{host}.':'.$self->{port}.'/scan/'.$self->{taskid}.'/log');
	}

	if ($result->is_success and $result->content =~ m#"success":\s+true#) {
		my $json = decode_json($result->content);
		return $json->{log};
	}

	return undef;
}

sub optionList {
	my ($self) = @_;

	my $result = $self->{ua}->get('http://'.$self->{host}.':'.$self->{port}.'/option/'.$self->{taskid}.'/list');
	if ($result->is_success and $result->content =~ m#"success":\s+true#) {
		my $json = decode_json($result->content);
		return $json->{options};
	}

	return undef;
}

sub optionSet {
	my ($self, $option, $value) = @_;
	my $result = $self->{ua}->post(
		'http://'.$self->{host}.':'.$self->{port}.'/option/'.$self->{taskid}.'/set',
		Content_Type => 'application/json',
		Content => encode_json({ $option => $value }),
	);

	if ($result->is_success and $result->content =~ m#"success":\s+true#) {
		return 1;
	}

	return undef;
}

1;