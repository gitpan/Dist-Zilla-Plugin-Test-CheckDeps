package Dist::Zilla::Plugin::Test::CheckDeps;
{
  $Dist::Zilla::Plugin::Test::CheckDeps::VERSION = '0.003';
}

use Moose;
extends qw/Dist::Zilla::Plugin::InlineFiles/;
with qw/Dist::Zilla::Role::TextTemplate Dist::Zilla::Role::PrereqSource/;

has fatal => (
	is => 'ro',
	isa => 'Bool',
	default => 0,
);

around add_file => sub {
	my ($orig, $self, $file) = @_;
	return $self->$orig(
		Dist::Zilla::File::InMemory->new(
			name    => $file->name,
			content => $self->fill_in_string($file->content, { fatal => $self->fatal })
		)
	);
};

sub register_prereqs {
	my $self = shift;
	$self->zilla->register_prereqs({ phase => 'test' }, 'Test::More' => 0.88, 'Test::CheckDeps' => 0.002);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=pod

=head1 NAME

Dist::Zilla::Plugin::Test::CheckDeps - Check for presence of dependencies

=head1 VERSION

version 0.003

=head1 AUTHOR

Leon Timmermans <leont@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Leon Timmermans.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

__DATA__
___[ t/00-check-deps.t ]___
use Test::More 0.94;
use Test::CheckDeps;

check_dependencies();

if ({{ $fatal }}) {
    BAIL_OUT("Missing dependencies") if !Test::More->builder->is_passing;
}

done_testing;

__END__

#ABSTRACT: Check for presence of dependencies

=head1 SYNOPSIS

 [Test::CheckDeps]
 fatal = 0 ; default

=head1 DESCRIPTION

This module adds a test that assures all dependencies have been installed properly. If requested, it can bail out all testing on error.

__END__

=for Pod::Coverage
register_prereqs
=end

