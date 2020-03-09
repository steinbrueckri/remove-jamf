#!/usr/bin/perl -w

#  mobiletolocal.sh
#  Created by LD (https://www.jamf.com/jamf-nation/discussions/22485/converting-ad-mobile-accounts-to-local)
#  Appears safe to run whilst logged in - user keeps existing password :)

my $userlist = `dscl . list /Users`;

chomp $userlist;

my @excludedusers = split(" ","root daemon nobody _amavisd _appleevents _appowner _appserver _ard _assetcache _astris _atsserver _avbdeviced _calendar _ces _clamav _coreaudiod _coremediaiod _cvmsroot _cvs _cyrus _devdocs _devicemgr _displaypolicyd _distnote _dovecot _dovenull _dpaudio _eppc _ftp _gamecontrollerd _geod _iconservices _installassistant _installer _jabber _kadmin_admin _kadmin_changepw _krb_anonymous _krb_changepw _krb_kadmin _krb_kerberos _krb_krbtgt _krbfast _krbtgt _launchservicesd _lda _locationd _lp _mailman _mbsetupuser _mcxalr _mdnsresponder _mysql _netbios _netstatistics _networkd _nsurlsessiond _nsurlstoraged _ondemand _postfix _postgres _qtss _sandbox _screensaver _scsd _securityagent _serialnumberd _softwareupdate _spotlight _sshd _svn _taskgated _teamsserver _timezone _tokend _trustevaluationagent _unknown _update_sharing _usbmuxd _uucp _warmd _webauthserver _windowserver _www _wwwproxy _xserverdocs");

my @userslist = split("\n", $userlist);
my @users;
my $result = "";

foreach my $u (@userslist) {

   my $match = 0;

   foreach my $e (@excludedusers) {
      if ("$u" eq "$e") {
         $match = 1;
      }
   }

   if ($match == 0) {
      push(@users, $u);
    }
}

my $dsconfigad = `/usr/sbin/dsconfigad -show`;
chomp $dsconfigad;

unless ($dsconfigad eq "") {
   printf "Removing AD bind\n";
   system "/usr/sbin/dsconfigad -remove -force -u none -p none";
}

foreach my $username (@users) {

   printf "Username is: $username\n";
   my $accounttype = `/usr/bin/dscl . -read /Users/$username OriginalNodeName`;

   unless ($accounttype =~ /\/Active Directory\//) {
       printf "Next: $username is not a mobile account\n";
       next;
   }

   printf "$username has an AD mobile account - converting to local\n";

   #Get Hash of existing password

   my $shadowhash = `/usr/bin/dscl . -read /Users/$username AuthenticationAuthority | grep " ;ShadowHash;HASHLIST:<"`;
   chomp $shadowhash;

   #printf "AuthenticationAuthority is: $shadowhash\n";

   system "/usr/bin/dscl . -delete /users/$username cached_groups";
   system "/usr/bin/dscl . -delete /users/$username SMBPrimaryGroupSID";
   system "/usr/bin/dscl . -delete /users/$username OriginalAuthenticationAuthority";
   system "/usr/bin/dscl . -delete /users/$username OriginalNodeName";
   system "/usr/bin/dscl . -delete /users/$username AuthenticationAuthority";
   system "/usr/bin/dscl . -create /users/$username AuthenticationAuthority \'$shadowhash\'";
   system "/usr/bin/dscl . -delete /users/$username SMBSID";
   system "/usr/bin/dscl . -delete /users/$username SMBScriptPath";
   system "/usr/bin/dscl . -delete /users/$username SMBPasswordLastSet";
   system "/usr/bin/dscl . -delete /users/$username SMBGroupRID";
   system "/usr/bin/dscl . -delete /users/$username PrimaryNTDomain";
   system "/usr/bin/dscl . -delete /users/$username AppleMetaRecordName";
   system "/usr/bin/dscl . -delete /users/$username PrimaryNTDomain";
   system "/usr/bin/dscl . -delete /users/$username MCXSettings";
   system "/usr/bin/dscl . -delete /users/$username MCXFlags";
   system "/usr/bin/dscl . -delete /users/$username AppleMetaRecordName";
   system "/usr/bin/dscl . -delete /users/$username dsAttrTypeNative:cached_auth_policy";
   system "/usr/bin/dscl . -delete /Users/$username dsAttrTypeStandard:CopyTimestamp";
   system "/usr/sbin/dseditgroup -o edit -a $username -t user admin";

}

exit 0;
