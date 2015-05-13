requires 'perl', '5.008001';
requires 'Minilla';
requires 'Text::Diff';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

