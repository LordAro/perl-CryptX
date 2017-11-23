use strict;
use warnings;
use File::Glob 'bsd_glob';

sub runcmds {
  my $cmds = shift;
  for (split /\n/, $cmds) {
    s/^\s*(.*?)\s*$/$1/;
    warn "#### >$_<\n";
    my $rv = system($_);
    die "ERROR (rv = $rv)\n" if $rv;
  }
}

sub doit {

### enc openssl > cryptx
runcmds <<'MARKER';
 openssl rsautl -encrypt -inkey test_rsakey.pub.pem -pubin -out test_input.encrypted.rsa -in test_input.data
MARKER

{
  use Crypt::PK::RSA;
  use Crypt::Misc 'read_rawfile';
  
  my $pkrsa = Crypt::PK::RSA->new("test_rsakey.priv.pem");
  my $encfile = read_rawfile("test_input.encrypted.rsa");
  my $plaintext = $pkrsa->decrypt($encfile, 'v1.5');
  print $plaintext;
}

### enc cryptx > openssl
{
  use Crypt::PK::RSA;
  use Crypt::Misc 'write_rawfile';
  
  my $plaintext = 'secret message';
  my $pkrsa = Crypt::PK::RSA->new("test_rsakey.pub.pem");
  my $encrypted = $pkrsa->encrypt($plaintext, 'v1.5');
  write_rawfile("test_input.encrypted.rsa", $encrypted);
}

runcmds <<'MARKER';
 openssl rsautl -decrypt -inkey test_rsakey.priv.pem -in test_input.encrypted.rsa
MARKER

### sign openssl > cryptx
runcmds <<'MARKER';
  openssl dgst -sha1 -sign test_rsakey.priv.pem -out test_input.sha1-rsa.sig test_input.data
MARKER

{
 use Crypt::PK::RSA;
 use Crypt::Digest 'digest_file';
 use Crypt::Misc 'read_rawfile';
  
 my $pkrsa = Crypt::PK::RSA->new("test_rsakey.pub.pem");
 my $signature = read_rawfile("test_input.sha1-rsa.sig");
 my $valid = $pkrsa->verify_hash($signature, digest_file("SHA1", "test_input.data"), "SHA1", "v1.5");
 print $valid ? "SUCCESS" : "FAILURE";
}

### sign cryptx > openssl
{
 use Crypt::PK::RSA;
 use Crypt::Digest 'digest_file';
 use Crypt::Misc 'write_rawfile';
  
 my $pkrsa = Crypt::PK::RSA->new("test_rsakey.priv.pem");
 my $signature = $pkrsa->sign_hash(digest_file("SHA1", "test_input.data"), "SHA1", "v1.5");
 write_rawfile("test_input.sha1-rsa.sig", $signature);
}

runcmds <<'MARKER';
 openssl dgst -sha1 -verify test_rsakey.pub.pem -signature test_input.sha1-rsa.sig test_input.data
MARKER

}

### MAIN ###

write_rawfile("test_input.data", "test-file-content");

### keys generated by cryptx
{
 use Crypt::PK::RSA;
 use Crypt::Misc 'write_rawfile';
 
 my $pkrsa = Crypt::PK::RSA->new;
 $pkrsa->generate_key(256, 65537);
 write_rawfile("test_rsakey.pub.der",  $pkrsa->export_key_der('public'));
 write_rawfile("test_rsakey.priv.der", $pkrsa->export_key_der('private'));
 write_rawfile("test_rsakey.pub.pem",  $pkrsa->export_key_pem('public_x509'));
 write_rawfile("test_rsakey.priv.pem", $pkrsa->export_key_pem('private'));
 write_rawfile("test_rsakey-passwd.priv.pem", $pkrsa->export_key_pem('private', 'secret'));
}

runcmds <<'MARKER';
 openssl rsa -in test_rsakey.priv.der -text -inform der
 openssl rsa -in test_rsakey.priv.pem -text
 openssl rsa -in test_rsakey-passwd.priv.pem -text -inform pem -passin pass:secret
 openssl rsa -in test_rsakey.pub.der -pubin -text -inform der
 openssl rsa -in test_rsakey.pub.pem -pubin -text 
MARKER

doit();

### keys generated by openssl

runcmds <<'MARKER';
 openssl genrsa -out test_rsakey.priv.pem 1024
 openssl rsa -in test_rsakey.priv.pem -out test_rsakey.priv.der -outform der
 openssl rsa -in test_rsakey.priv.pem -out test_rsakey.pub.pem -pubout
 openssl rsa -in test_rsakey.priv.pem -out test_rsakey.pub.der -outform der -pubout
 openssl rsa -in test_rsakey.priv.pem -passout pass:secret -des3 -out test_rsakey-passwd.priv.pem
MARKER

{
 use Crypt::PK::RSA;
 
 my $pkrsa = Crypt::PK::RSA->new;
 $pkrsa->import_key("test_rsakey.pub.der");
 $pkrsa->import_key("test_rsakey.priv.der");
 $pkrsa->import_key("test_rsakey.pub.pem");
 $pkrsa->import_key("test_rsakey.priv.pem");
 $pkrsa->import_key("test_rsakey-passwd.priv.pem", "secret");
}

doit();

warn "\nSUCCESS\n";
unlink $_ for (bsd_glob("test_*.der"), bsd_glob("test_*.pem"), bsd_glob("test_*.sig"), bsd_glob("test_*.rsa"), bsd_glob("test_*.data"));