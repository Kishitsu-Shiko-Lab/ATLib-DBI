requires 'perl', '5.016_001';

requires 'Test::Exception';
requires 'Mouse';
requires 'Digest::SHA';
requires 'Time::Local';
requires 'Time::HiRes';
requires 'DBI';

requires 'ATLib::Utils', git => "https://github.com/Kishitsu-Shiko-Lab/ATLib-Utils.git";
requires 'ATLib::Std', git => "https://github.com/Kishitsu-Shiko-Lab/ATLib-Std.git";
requires 'ATLib::Data', git => "https://github.com/Kishitsu-Shiko-Lab/ATLib-Data.git";

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Exception';
};

