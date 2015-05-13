package Minilla::CLI::Autochanges;
use 5.008001;
use strict;
use warnings;
use Minilla::Project;
use Minilla::Util 'parse_options';
use Text::Diff ();
use Encode 'encode_utf8';

our $VERSION = "0.01";

sub run {
    my ($class, @argv) = @_;

    parse_options(
        \@argv,
        'f|force' => \(my $force),
    );

    my $project = Minilla::Project->new;
    chdir $project->dir; # XXX
    die "Missing Changes file\n" unless -f "Changes";

    my $last_tag = do { my @tag = `git tag`; chomp @tag; $tag[-1] };
    unless ($last_tag) {
        print "Last tag is missing, so cannot determine changes.\n";
        return 0;
    }

    my @log = map { chomp; [ split /\|/, $_, 3 ] }
              `git log $last_tag.. --format='%aN|%aE|%s'`;
    my $only_mail = sub { local $_ = shift; /<([^>]+)>/ ? $1 : $_ };
    my %is_author = map { $only_mail->($_) => 1 } @{$project->authors};

    @log = map {
        my ($name, $mail, $subject) = @$_;
        $is_author{$mail} ? "$subject\n"  : "$subject ($name)\n";
    } @log;
    @log = grep { !/^Merge pull request/ } @log;

    my @old = do {
        open my $fh, "<:utf8", "Changes" or die "open Changes: $!\n";
        <$fh>;
    };
    my @new;
    my $NEXT = '{{$NEXT}}';
    for my $line (@old) {
        push @new, $line;
        if ($line =~ /\Q$NEXT/o) {
            push @new, "\n";
            push @new, map { "    - $_" } @log;
        }
    }
    my $diff = Text::Diff::diff(\@old, \@new);
    unless ($diff) {
        print "No changes found from last tag.\n";
        return 0;
    }

    print encode_utf8($diff);
    unless ($force) {
        print "\n";
        local $| = 1;
        print "Do you want to update Changes with above diff? (y/N)? ";
        my $answer = <STDIN>;
        if ($answer !~ /^y(es)?/i) {
            print "Do nothing, exit.\n";
            return 0;
        }
    }
    open my $fh, ">:utf8", "Changes" or die "open Changes: $!\n";
    print {$fh} @new;
    close $fh;
    print "Updated Changes.\n";
}



1;
__END__

=encoding utf-8

=head1 NAME

Minilla::CLI::Autochanges - auto generate Changes from git log

=head1 SYNOPSIS

    > minil autochanges
    @@ -2,6 +2,9 @@

    {{$NEXT}}

    +    - handle relative / absolute directories
    +    - add relative / absolute directories tests
    +
    0.02 2015-02-23T16:13:47Z

        - document that this module is an alternative

    Do you want to update Changes with above diff? (y/N)?

=head1 DESCRIPTION

Sometimes updating Changes file is a boring task.
People update Changes with just raw C<git log>, but it's ugly.

C<minil autochanges> may helps that.

=head1 TODO

Special handling of pull requests.

=head1 LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Shoichi Kaji E<lt>skaji@cpan.orgE<gt>

=cut

