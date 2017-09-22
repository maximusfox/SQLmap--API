package SQLmap::API;

our $VERSION = 0.1;

# Packages
use strict;
use warnings;
use feature 'say';

use JSON::XS;
use LWP::UserAgent;

use SQLmap::API::Task;

sub new {
	my ($self, %args) = @_;
	$self = bless(\%args, $self);

	# Проверка все ли параметры переданы
	for (qw( host port idAdmin )) {
		warn 'Undefined value '.$_."\n" and return undef unless (exists $args{$_});
	}

	# Создать объект веб клиента
	$self->_createUserAgent() if ($self);

	# Создать методы для извлечения данных
	$self->_generateSystemMethods() if ($self);

	return undef unless ($self->_checkConnectToApi());
	return $self;
}

# Генерация методов для доступа к параметрам объекта
sub _generateSystemMethods {
	for (qw( ua host port idAdmin )) {
		eval('sub '.$_.' { return shift->{'.$_.'}; }');
		say 'Error in eval:'.$@ if ($@);
	}
}

# создаём объект браузера
sub _createUserAgent {
	my ($self, %args) = @_;
	$self->{ua} = LWP::UserAgent->new('agent' => 'perl5 SQLmap::API/'.$VERSION) unless (defined $self->{ua});
}

# Проверка подключения к серверу API
sub _checkConnectToApi {
	my ($self, %args) = @_;

	my $result = $self->{ua}->get('http://'.$self->{host}.':'.$self->{port}.'/admin/'.$self->{idAdmin}.'/list');
	if ($result->is_success and $result->content =~ m#true#) {
		return 1;
	}

	$self->{error} = 'Can\'t connect to server: http://'.$self->{host}.':'.$self->{port}.'/admin/'.$self->{idAdmin}.'/list';
	warn 'Can\'t connect to server: http://'.$self->{host}.':'.$self->{port}.'/admin/'.$self->{idAdmin}.'/list';
	return undef;
}

# Извлечь сообщение об ошибке
sub getError {
	my ($self) = @_;
	return ($self->{error}?$self->{error}:'N/A');
}

# Проверка наличия сообщения об ошибке
sub isError {
	my ($self) = @_;
	return ($self->{error}?1:0);
}

# Создание нового таска
sub taskNew {
	my ($self) = @_;

	my $result = $self->ua->get('http://'.$self->{host}.':'.$self->{port}.'/task/new');
	if ($result->is_success and $result->content =~ m#true#) {
		my $json = decode_json($result->content);
		return SQLmap::API::Task->new(
			taskid => $json->{taskid},
			ua => $self->ua,
			host => $self->host,
			port => $self->port,
			idAdmin => $self->idAdmin,
		);
	}

	$self->{error} = 'Error: http://'.$self->{host}.':'.$self->{port}.'/task/new';
	return undef;
}

# Получение cписка задач
sub taskList {
	my ($self) = @_;

	my $result = $self->{ua}->get('http://'.$self->{host}.':'.$self->{port}.'/admin/'.$self->{idAdmin}.'/list');
	if ($result->is_success and $result->content =~ m#"success":\s+true#) {
		my $json = decode_json($result->content);
		delete $json->{success};
		return $json;
	}

	return undef;
}

# Очистка списка задач
sub taskFlush {
	my ($self) = @_;

	my $result = $self->{ua}->get('http://'.$self->{host}.':'.$self->{port}.'/admin/'.$self->{idAdmin}.'/flush');
	if ($result->is_success and $result->content =~ m#"success":\s+true#) {
		return 1;
	}

	return undef;
}

1;
