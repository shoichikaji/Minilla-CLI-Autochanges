# NAME

Minilla::CLI::Autochanges - auto generate Changes from git log

# SYNOPSIS

    > minil autochanges
    @@ -2,6 +2,9 @@

    {{$NEXT}}

    +    - handle relative / absolute directories
    +    - add relative / absolute directories tests
    +
    0.02 2015-02-23T16:13:47Z

        - document that this module is an alternative

    Do you want to update Changes with above diff? (y/N)?

# DESCRIPTION

Sometimes updating Changes file is a boring task.
People update Changes with just raw `git log`, but it's ugly.

`minil autochanges` may helps that.

# TODO

Special handling of pull requests.

# LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Shoichi Kaji <skaji@cpan.org>
