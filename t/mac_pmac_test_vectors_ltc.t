use strict;
use warnings;

use Test::More tests => 452;
use Crypt::Mac::PMAC;
use Crypt::Cipher;

my $trans = {
  "3des"       => 'DES_EDE',
  "safer+"     => 'SAFERP',
  "khazad"     => 'Khazad',
  "safer-k128" => 'SAFER_K128',
  "safer-sk128"=> 'SAFER_SK128',
  "rc6"        => 'RC6',
  "safer-k64"  => 'SAFER_K64',
  "safer-sk64" => 'SAFER_SK64',
  "anubis"     => 'Anubis',
  "blowfish"   => 'Blowfish',
  "xtea"       => 'XTEA',
  "aes"        => 'AES',
  "rc5"        => 'RC5',
  "cast5"      => 'CAST5',
  "skipjack"   => 'Skipjack',
  "twofish"    => 'Twofish',
  "noekeon"    => 'Noekeon',
  "rc2"        => 'RC2',
  "des"        => 'DES',
  "camellia"   => 'Camellia',
};
my $tv;
my $name;
my $ks;

while (my $l = <DATA>) {
  $l =~ s/[\r\n]*$//;
  $l =~ s/^[\s]*([^\s\r\n]+).*?/$1/;
  $l =~ s/\s+//;
  if ($l=~/^PMAC-([a-z0-9\+\-]+).*?(\d+)/i) {
    $name = $1;
    $ks = $2;
    next;
  }
  my ($k, $v) = split /:/, $l;
  next unless defined $k && defined $v;
  $tv->{$name}->{$ks}->{$k} = $v if $name && $k =~ /\d+/;
}

my $seq;
$seq .= pack('C',$_) for(0..255);
my $zeros = '\0' x 255;

for my $n (sort keys %$tv) {
  for my $ks (sort keys %{$tv->{$n}}) {
    my $N = $trans->{$n} || die "FATAL: unknown name '$n'";
    my $key = substr($seq, 0, $ks);
    for my $i (0..255) {
      my $bytes = substr($seq, 0, $i);
      next unless $tv->{$n}->{$ks}->{$i};
      my $result = Crypt::Mac::PMAC->new($N, $key)->add($bytes)->mac;
      is(unpack('H*', $result), lc($tv->{$n}->{$ks}->{$i}), "$N/$i");
      $bytes = $result;
      $key = substr($result x 100, 0, $ks);
    }
  }
}

__DATA__
PMAC Tests.  In these tests messages of N bytes long (00,01,02,...,NN-1) are PMAC'ed.  The initial key is
of the same format (length specified per cipher).  The PMAC key in step N+1 is the PMAC output of
step N (repeated as required to fill the array).

PMAC-aes (16 byte key)
  0: 4399572CD6EA5341B8D35876A7098AF7
  1: 580F7AA4AA45857C79BA2FB892228893
  2: 24D2D1DBABDB25F9F2D391BB61F4204A
  3: 083BF95E310B42A89751BC8E65ABA8B5
  4: 69BEB9268CD7FD3D7AB820BD7E226955
  5: FD71B0E647ADB4BB3F587E82B8B3401A
  6: 07EA46271081840737CEB1AC9E5E22E3
  7: FFA12AD9A9FDB5EE126084F82B381B10
  8: 8A11AF301AAFEAC8A75984ED16BB3292
  9: 368BDC3F4220E89B54C5F9D09FFB8F34
 10: 8B6DBFF776FD526147D1C4655626374F
 11: C538C09FC10DF38217CD8E799D8D1DC9
 12: FC1264A2051DEF73339432EA39443CFD
 13: 8AF37ED2FB2E8E30E9C4B75C1F1363E1
 14: 4295541FC62F6774068B8194CC9D9A46
 15: CFAF4D8EA09BB342F07131344DB0AA52
 16: B6CBD6E95959B2A8E22DE07E38B64D8D
 17: 3124E42DE3273B0F4806FB72A50F3E54
 18: 252D49403509B618AB3A6A1D99F9E9FA
 19: 9CDA75594CB696EB19C022DDA7324C10
 20: 33BB8AE43B7BC179E85F157FA19607D0
 21: 12FE91BCF2F2875379DC671C6F1B403E
 22: 416A3E519D1E406C92F8BB0DDBBBB6BF
 23: 6F98DCCD5A8D60DEAF612ACCEDD7E465
 24: FFCE7604609B2C3C050921854C638B7E
 25: DD2BB10AA07A5EC8D326BB7BF8D407F4
 26: 468BFE669FCDF354E4F9768FE1EAF8F6
 27: 01724D2F2C61EB4F380852218212E892
 28: 2D90EC658F57138505598C659C539A3E
 29: 6301EAA0E1500FFEB86752744EFFF23D
 30: 3CCB177486377616056D835F6F857F7C
 31: BFB3C7755C1F4543B516EB8610CB219F
 32: D5C505847D7CFFD8CED848F6CB613105

PMAC-blowfish (8 byte key)
  0: 3B7E4EFE92FA46AF
  1: 746840017C38C892
  2: 3B6A92C731465B64
  3: D89D3B05143B6704
  4: 43F70D54B808B7CE
  5: 84E4063AB32F046C
  6: A7E78CD5CCD23805
  7: A78FB083475FEF10
  8: D4F6C26B5386BA25
  9: 184768A079853C90
 10: 0702E6C8140C5D3B
 11: 786D94565AA0DF4B
 12: F6D36D3A2F4FB2C1
 13: 7BB3A0592E02B391
 14: 5B575C77A470946B
 15: 686DAD633B5A8CC3
 16: BDFE0C7F0254BAD5

PMAC-xtea (16 byte key)
  0: F5E28630DFDE34E0
  1: FFCC52D905DA5198
  2: 25198AB18B2B290D
  3: 18914E50791161E9
  4: 200F832212AD6747
  5: A9D09C41D734DDF7
  6: 32D7CCA3F4BD8215
  7: 91A1AA9389CD5D02
  8: 35CB1F77D7C25E2F
  9: D91EEE6D0A3874F3
 10: A42872686A8FF6F2
 11: 7568908634A79CBD
 12: 5B91A633D919BC34
 13: 32DCD17176896F1D
 14: 2BBBA64F30E672B6
 15: AFEB07DBC636AEED
 16: 7A417347CA03C598

PMAC-rc5 (8 byte key)
  0: C6B48F8DEC631F7C
  1: F7AA62C39972C358
  2: 0E26EC105D99F417
  3: 7D3C942798F20B8C
  4: 415CDA53E1DE3888
  5: A314BA5BCA9A67AC
  6: 02A5D00A3E371326
  7: E210F0A597A639E5
  8: D4A15EED872B78A2
  9: AC5F99886123F7DC
 10: 69AEB2478B58FFDF
 11: 8AB167DFC9EF7854
 12: 945786A136B98E07
 13: F3822AB46627CAB5
 14: 23833793C3A83DA9
 15: 70E6AB9E6734E5A6
 16: 0705C312A4BB6EDE

PMAC-rc6 (16 byte key)
  0: C7715A17012401DE248DC944DEEBD551
  1: 5B804C6CCDF97BB28811C9ED24FE6157
  2: 7528378C052F4346253CB0DFA3D251C7
  3: 6DA86EE0B28606861B1A954D7429A93C
  4: B4DFF84C25937FB50EE79D4037323160
  5: A60FD9BE5E1FF67EC9734776C8781096
  6: 81D3F8EDC0A197DD3739EAE648F38580
  7: 8BAF47F02120E898916D678DBD0C1641
  8: 7A9EEC96F10B7CF557B61EF35BB55B08
  9: B88C11221014F8AE048E56C427DF4A46
 10: 4BBA8EED89F357861A265006816D9B04
 11: 8497C1D55010A65ED8C3688B75A7CABF
 12: 95E1720C06A373CAD1A22F432F26BCCA
 13: A175FB732692831E96AFB587BC49E18C
 14: 54EBC04FCFD90302907BF77C4D8AC77C
 15: EA9F13EE5548CDF771C354527CDDA09B
 16: 4EDBCFD0E2E6B321530EB31B3E8C2FE4
 17: F412304C1A5B9005CC3B7900A597DFB5
 18: 3B9247C12BB25DF048BF5541E91E1A78
 19: 39626488635D0A6224CD23C13B25AE8E
 20: 40305F5C2FCEF34E764E33EF635A3DC5
 21: F84499804086033E85633A1EF9908617
 22: C4D263CDC7E0969B8AC6FA9AD9D65CB8
 23: 6137DC840E61EA6A288D017EFB9646FC
 24: 8619960428EB29B1D5390F40173C152F
 25: F0464509D0FBDBECEC9DFC57A820016D
 26: 630EED23E87059051E564194831BAEF6
 27: 4B792B412458DC9411F281D5DD3A8DF6
 28: F2349FA4418BC89853706B35A9F887BA
 29: FEAC41D48AEAB0955745DC2BE1E024D5
 30: A67A135B4E6043CB7C9CAFBFA25D1828
 31: EC12C9574BDE5B0001EE3895B53716E2
 32: 44903C5737EE6B08FD7D7A3937CC840D

PMAC-safer+ (16 byte key)
  0: E8603C78F9324E9D294DA13C1C6E6E9B
  1: 3F1178DFC2A10567D4BCC817D35D1E16
  2: 27FE01F90E09237B4B888746199908EE
  3: 4F5172E3D8A58CD775CD480D85E70835
  4: 74BED75EFAAB3E8AA0027D6730318521
  5: 54B003AB0BE29B7C69F7C7494E4E9623
  6: 8A2DAD967747AEA24670141B52494E2F
  7: 69EB054A24EE814E1FB7E78395339781
  8: E59C2D16B76B700DC62093F0A7F716CC
  9: AB227D6303007FD2001D0B6A9E2BFEB7
 10: AE107117D9457A1166C6DFD27A819B44
 11: F84DE551B480CED350458851BAE20541
 12: B0EB5103E7559B967D06A081665421E0
 13: CDB14F3AD1170CE8C6091947BE89DE7B
 14: 24FA2F476407094152D528FCF124E438
 15: 440144B31EC09BD8791BFE02E24EA170
 16: 697D268A46E8B33CEC0BAB8CAF43F52D
 17: 587CBDE7608449BD162184020FBFCC8D
 18: 3EA999C2169CC65735737F50FCD7956B
 19: C6D692698CD8BEEBF2387C6A35A261B0
 20: 46DAB3AD3C4E2EF712FAC38F846C63E1
 21: 7261E68B530D10DDC9AD4C9AB5D95693
 22: 4D0BA5773E988C2B7B2302BBA0A9D368
 23: 8617154626362736698613151D1FD03A
 24: 23CF25F68B281E21777DC409FE3B774A
 25: CA626956C97DC4207D968A8CC85940B8
 26: 24C39BE160BDBB753513F949C238014E
 27: 83CD65C010FB69A77EEDEA022A650530
 28: 1A72DC8438B927464125C0DFEACDE75D
 29: 546054936A2CB5BFBB5E25FFD07C9B51
 30: 0EB81A268F1BB91997CB9809D7F9F2AD
 31: 7D08B4DE960CADC483D55745BB4B2C17
 32: FD45061D378A31D0186598B088F6261B

PMAC-twofish (16 byte key)
  0: D2D40F078CEDC1A330279CB71B0FF12B
  1: D1C1E80FD5F38212C3527DA3797DA71D
  2: 071118A5A87F637D627E27CB581AD58C
  3: C8CFA166A9B300F720590382CE503B94
  4: 3965342C5A6AC5F7B0A40DC3B89ED4EB
  5: 6830AB8969796682C3705E368B2BDF74
  6: FF4DCC4D16B71AFEEA405D0097AD6B89
  7: ADB77760B079C010889F79AA02190D70
  8: 5F2FCD6AA2A22CEECAA4671EE0403B88
  9: 70DD6D396330904A0A03E19046F4C0BF
 10: 8A2C9D88FA0303123275C704445A7F47
 11: BA0B2F6D029DCD72566821AB884A8427
 12: C8DF45FF13D7A2E4CFE1546279172300
 13: 512659AD40DC2B9D31D299A1B00B3DAD
 14: A8A0E99D2E231180949FC4DFB4B79ED4
 15: CA161AFB2BC7D891AAE268D167897EF2
 16: D6C19BBDFFC5822663B604B1F836D8BD
 17: 4BF115F409A41A26E89C8D758BBF5F68
 18: 02E3196D888D5A8DE818DBCBAD6E6DC7
 19: 995C9DD698EC711A73BD41CAAE8EB633
 20: A031857FADC8C8AFEABF14EF663A712D
 21: 124695C9A8132618B10E9800A4EFACC5
 22: 997E5E41798648B8CE0C398EF9135A2C
 23: 42C92154B71FB4E133F8F5B2A2007AB2
 24: 945DC568188D036AC91051A11AC92BBF
 25: D5A860CC4C3087E9F4988B25D1F7FAAE
 26: 6CD6ABF8EDF3102659AFFBE476E2CBE8
 27: 45ECD0C37091414E28153AA5AFA3E0B2
 28: CBA6FE296DDE36FE689C65667F67A038
 29: C4022281633F2FC438625540B2EE4EB8
 30: 864E27045F9CC79B5377FDF80A6199CF
 31: 0D06F2FAEC5AA404A4087AAEBC4DBB36
 32: 0F396FE9E3D9D74D17EB7A0BF603AB51

PMAC-safer-k64 (8 byte key)
  0: 2E49792C78C1DA52
  1: 7A5136F4FE617C57
  2: 6FC8575F6F3D78EC
  3: 7C0373CAEAAA640B
  4: 9D469E7FF6C35D31
  5: 7755D62DD7D88112
  6: ADD9E7855A958C9F
  7: 752D29BA8150F18E
  8: 0954649A99596104
  9: 05D4D75A9FAE233D
 10: 1AADAFD7B4B250DA
 11: E7A8F31ED74DA32B
 12: 1A74DF61BDB9DF94
 13: C38A67B1955C4E0D
 14: EBADAA44746ADF16
 15: C0BFBB092CE81D8E
 16: 984975657F3FF2B0

PMAC-safer-sk64 (8 byte key)
  0: E8917E1629E7403E
  1: AE8061A5E412A647
  2: C969771CE5A9B0C6
  3: 78159C01D0A3A5CB
  4: 1DD4382A8FC81921
  5: 4086880FD863C048
  6: A520B45600A3FA1D
  7: 0F0AB5118D7506C4
  8: 22E315F2DD03BCC6
  9: 5ECB5561EE372016
 10: 446A9B2BCB367AD6
 11: B2107FE2EB411AE9
 12: 5A539B62FB5893DF
 13: F44EE1EB3278C2BA
 14: 293FEA56D1F6EA81
 15: F38F614D2B5F81C4
 16: AB23F7F8F4C12A7E

PMAC-safer-k128 (16 byte key)
  0: 7E0BDE11EC82FDE6
  1: 8942FB017A135520
  2: 0B073E6D0F037A02
  3: DBF88439D671ED4F
  4: B89427ED1121069A
  5: AA8573DAC66D2315
  6: 12DA3144BEF13FF2
  7: EF80413CBA281B3A
  8: DFA7114D8505EEBD
  9: AE53607F3E6F4A54
 10: 3F2C9395CFB9F78F
 11: 67EB7C5F02760AED
 12: 3EF4CBB4AB5B8D1F
 13: 83B63AFA78795A92
 14: 5DE400951766992A
 15: AA8791A45237CF83
 16: 7743B18704B037CF

PMAC-safer-sk128 (16 byte key)
  0: 8F1597FFCF6FB7C1
  1: AFF8BD8FF9F3888A
  2: 65F89D82869D8B42
  3: CBE1F06476B2D5BD
  4: 4878D47FDFECE23E
  5: 4751A9E6D61AB2A2
  6: 003AC162AED4DED8
  7: 1F617A5555092C22
  8: 088EE0C35B607153
  9: F840B485086F9908
 10: BA99E0FB5D7D0976
 11: F04AF6DC4BAF6887
 12: 5DBBE40AF2F67E4E
 13: 7F52A93E87E29C9D
 14: 7B26A14A4BD5B709
 15: C34F26E08C64F26B
 16: 291A41D479EC1D2A

PMAC-rc2 (8 byte key)
  0: E5AF80FAC4580444
  1: 6A15D6211EB4FF99
  2: DDB95E9486C4B034
  3: 9764761DC2AAD5C0
  4: 1B1CD2E799D44B4F
  5: 4F80FE32256CF2EC
  6: 7B70CF31C81CD384
  7: 9BC10DD9332CF3BB
  8: 628189801879FDD8
  9: 5FC17C555E2AE28B
 10: E20E68327ABEAC32
 11: 5D375CA59E7E2A7C
 12: A9F4CFC684113161
 13: 3A0E069940DDD13C
 14: EAC25B6351941674
 15: CB8B5CF885D838CF
 16: DCBCDDFC06D3DB9A

PMAC-des (8 byte key)
  0: 086A2A7CFC08E28E
  1: F66A1FB75AF18EC9
  2: B58561DE2BEB96DF
  3: 9C50856F571B3167
  4: 6CC645BF3FB00754
  5: 0E4BEE62B2972C5A
  6: D2215E451649F11F
  7: E83DDC61D12F3995
  8: 155B20BDA899D2CF
  9: 2567071973052B1D
 10: DB9C20237A2D8575
 11: DAF4041E5674A48C
 12: 552DB7A627E8ECC4
 13: 1E8B7F823488DEC0
 14: 84AA15713793B25D
 15: FCE22E6CAD528B49
 16: 993884FB9B3FB620

PMAC-3des (24 byte key)
  0: E42CCBC9C9457DF6
  1: FE766F7930557708
  2: B9011E8AF7CD1E16
  3: 5AE38B037BEA850B
  4: A6B2C586E1875116
  5: BF8BA4F1D53A4473
  6: 3EB4A079E4E39AD5
  7: 80293018AC36EDBF
  8: CC3F5F62C2CEE93C
  9: EE6AA24CE39BE821
 10: 487A6EAF915966EA
 11: D94AD6393DF44F00
 12: F4BFCCC818B4E20D
 13: 2BE9BC57412591AA
 14: 7F7CC8D87F2CDAB7
 15: B13BFD07E7A202CB
 16: 58A6931335B4B2C2

PMAC-cast5 (8 byte key)
  0: 0654F2F4BC1F7470
  1: 3F725B162A1C8E6B
  2: BCFBDC680A20F379
  3: 027922705BCACDEE
  4: 44E2F4BE59774BA4
  5: 3ABD1AFC8EE291F7
  6: D96347E717921E96
  7: 96257299FCE55BC6
  8: C2C1DA176EE98170
  9: FD415C122E604589
 10: DCBCA228D45AEDA4
 11: 7801FBCFAAB9DF75
 12: D38CB38574474B7F
 13: F5C5A23FF3E80F37
 14: 83FA4DAD55D092F5
 15: BDC0A27EE0CB1657
 16: 87D907CACA80A138

PMAC-noekeon (16 byte key)
  0: 276019CC8E43A1B3F300C47B55B7AA22
  1: B93E353A2CC21CEAD81C91EC2FCD348E
  2: E8B9737CAD705C499F246744DCFE9641
  3: EF36B0FFB5439FF8668F35FD1822D0EA
  4: B7F5AD89538FC3F03923E98ADF95D0CC
  5: 558FCA30F602B4BC6697F44053875204
  6: 6B2D6D5A1CF670BE80E4BBB945CD3871
  7: 9CFA28FCA22EA12A13AC1093EF5D5EB9
  8: 04EDA6C71B9F1177F4A5368684FBBAFB
  9: 43C56B31D440EBECE4C74B90750A4653
 10: 23D5FA9AFFB2DC3DD372F22690487BAC
 11: FD61731F27CF8E791535AAB579A018B4
 12: 502D3A64FDED3CA2A2C8A5E986B27E03
 13: 1EABBC65B0A08F6CB15218E7153A6003
 14: B05DBC66CF92B045FC99395E9D405C4F
 15: EE841A0BF2C91C1E2078F06D022F2E6C
 16: EA749FBAC6BA9F672796C9D58A8C3294
 17: BBEF3CDFB93E5F462773579986F08374
 18: B17F7645F80BF5A2817C228987B43C03
 19: C995A102DFBB38FA397A4E508B85093D
 20: 9011CA395AC3FCD8594C13E67C22E95B
 21: 364BF53974D68B8BCF53CAADC5469DEC
 22: 5BAD7041372F28DE28BAAAC1A89C10A8
 23: 77874E908BFCE6F5E36888A484A754C0
 24: 9BDA525416A3129C55886134B79BAEDE
 25: 84E3201FA7958223B302D1BC2AC57D55
 26: 2B8FA1A95DADB4DC2F7A308D8E3D8C81
 27: F74EBF0ACCC187569BDE549F5FC96C36
 28: 7023D209F1965EC32253D11835CDFFA5
 29: C3C6397D9B0A1D741335882ACDFAC20D
 30: 7BC92905F2AF6754256BE087CC4F54DB
 31: 0BBA0A507767530F26C3A465DAB11359
 32: D2891C8EA1F574A6B2AB091057E0FB2C

PMAC-skipjack (10 byte key)
  0: 9CD94B75BC43B647
  1: B069ACB82B12BC7B
  2: 6DD40E71EB03E311
  3: 74CBED61D77DBA7D
  4: DD1B7E0D181537FE
  5: ACB5B96FA0AD1786
  6: B34E01EB2567D381
  7: 9623DAADE57B9549
  8: 8BA384BABB798344
  9: B147AA9D5C5C67CF
 10: 0033C520F4C67523
 11: 42DAC184BEABC3E5
 12: 428029311004AEBB
 13: AC2BB1C0F0ED649B
 14: F7CAA9A3BF749C1A
 15: 2C5BD475AAC44C77
 16: FEB892DA66D31A84

PMAC-anubis (16 byte key)
  0: DF33EE541FFEE6A97FE3A1F72F7A38FC
  1: 0AB28675AC3923C6DD9F5A8E1E2928D0
  2: 2DABF75D6403E1E1CFAB3E6869FB1088
  3: 95835D49E09740180B79E394FC2AA744
  4: F364D6DC2C2078A519E5BAEFE858AFCA
  5: DA4C66A4805FC91FABAECC0D3AEAD850
  6: 487660FADCAC7B326C492AA051A1DF49
  7: BF07835AA1A548FA7312509AF35CE3F3
  8: 3CE8A8B1F324A700923AC0B830D53D99
  9: 3C54D99AACFAB26E34FC1B0B6BB9EB22
 10: 0A559F9D107ED76FD19227FDD0752B8A
 11: BFD9E74ADC40B9C7446FDD09558FA584
 12: F1130F663BC0FA3B1066129E0D1910E9
 13: 535EAD786F0D211DE7AA78F3CB480803
 14: CDF5855F00A4C310D95B26751B01A28B
 15: EF6686E999D5A9C35A96D25BB9DBBF57
 16: E795733AA0AAF16D8F7AB1A8E9C55E54
 17: E03CA85727D5CF06F56BB6465BB3E5C5
 18: 6EDDDB6D2292EFF584E382E1BACD1A49
 19: 7B7FE0D8821836C1AA95578071FF2FD2
 20: 5F8CC568338400746B61A9286B7CF262
 21: 32DEE5A11E9EDB04BDF911837CE0FA4D
 22: F1A99914F13B17ABF383F36157FEB170
 23: 99F541647F382390043CAE5332E3114D
 24: 34C5EBB85693A1979F8CFDF8B431A5BB
 25: 1BA7266568F1E7B4A77A869D3021AC0F
 26: 0FC675C99C24E859F8CE714E86BF5289
 27: CBFAB21F5ABC47356A43BED806D873C0
 28: 9659AB1A4D334B622629721F98EECE3A
 29: 644C8BEE41F03BDE7652B03CAEA31E37
 30: 5B3447AFAD934B4D1E4910A8DFD588E7
 31: BFF403342E8D50D0447627AEA2F56B23
 32: 19F468F0FB05184D00FABD40A18DB7B2

PMAC-khazad (16 byte key)
  0: F40CEF2E392BEAEB
  1: C6E086BD1CFA0992
  2: 513F2851583AD69A
  3: 07279D57695D78FF
  4: 051E94FE4CC847B6
  5: 5E9AAA5989D5C951
  6: 310D5D740143369A
  7: 9BB1EA8ECD4AF34B
  8: CF886800AF0526C8
  9: 0B03E2C94729E643
 10: 42815B308A900EC7
 11: 9A38A58C438D26DD
 12: 044BFF68FD2BFF76
 13: 7F5ABBDC29852729
 14: F81A7D6F7B788A5D
 15: 93098DA8A180AA35
 16: BACE2F4DA8A89E32

PMAC-camellia (16 byte key)
  0: 33C03F6AA205F3816A17DA92BEE0BAD2
  1: AD1EC293DD032511579235B2F29CC909
  2: E71363EAF5A311DCFB035C69BBCE5DC0
  3: 22661D6CD3496FB5C9B3D89FC62E3981
  4: B142A96AF9C481B61E55B7B5896847C4
  5: A286C0769989120F8A31A8DAD7574F22
  6: 09E711382FDB6B938C802D11A66EF657
  7: DF9ABA4F5CF5B0647F045C3AA631BB62
  8: 499A8F68DAEC7FE56E64DB59B0993741
  9: AFFDA4F40A1BDF673EE9123CAE321F16
 10: B6F2E39D0126AA85D9152C4457365235
 11: 2922AAC2FF4F0B77DEE4B3E28EF5094F
 12: 369D18F985D18B5ADDFFFC1151DE6BBA
 13: 1B7641D1A38C4114EE829B7D25BF0EFF
 14: DEF9092BA185FD5238A25C6FCF410C52
 15: D59FEE8047D64032329318DC7A2277B8
 16: B4561A4A092E031F8FE998FAC87F9BFB
 17: F27EF7D0823B056F692BA369D1B2E7B4
 18: F62C4F7B749CF31A6F5485BFDED7EEBD
 19: 22BD3AB334BE6E04C84D6197FF69CAE3
 20: E617D108BED8E9ACBA55FAF60863F8C3
 21: 0DB60AE0725D37855F3AF1DDF78E98EB
 22: C76DD5A075AB30AB66FC448BD19B6588
 23: 60231366598BEB2D16D33A1A8019B9A1
 24: 247E925C96064801490A1D062A0C1F18
 25: 1C1081E20DE3BE26FF24BEC3DFBA9BF2
 26: 3B16562B3CD862C00A03B7ADC99E46C5
 27: C1E8BA560851254640D523A0CEE846AF
 28: C36E8CF324A0A4EBC6C76EA01CDFD158
 29: EAED84E721777F5E30184E496DA2C0FA
 30: 6655CA0D8741440212AA0DB218E5C7FE
 31: D5C0143E1BA233BA5F862EE6E11A8F58
 32: C8DAF08BD68F4AE401C6663393C257CB
