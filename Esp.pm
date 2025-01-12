# <@LICENSE>
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to you under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# </@LICENSE>

# Author:  Giovanni Bechis <gbechis@apache.org>

=head1 NAME

Esp - checks ESP abused accounts

=head1 SYNOPSIS

  loadplugin    Mail::SpamAssassin::Plugin::Esp

=head1 DESCRIPTION

This plugin checks emails coming from ESP abused accounts.

=cut

package Mail::SpamAssassin::Plugin::Esp;

use strict;
use warnings;

use Digest::MD5 qw(md5_hex);
use Errno qw(EBADF);
use Mail::SpamAssassin::Plugin;
use Mail::SpamAssassin::PerMsgStatus;

use vars qw(@ISA);
our @ISA = qw(Mail::SpamAssassin::Plugin);

my $VERSION = 1.6.0;

sub dbg { my $msg = shift; Mail::SpamAssassin::Plugin::dbg("Esp: $msg", @_); }

sub new {
  my $class = shift;
  my $mailsaobject = shift;

  $class = ref($class) || $class;
  my $self = $class->SUPER::new($mailsaobject);
  bless ($self, $class);

  $self->set_config($mailsaobject->{conf});
  $self->register_eval_rule('esp_4dem_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_acelle_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_amazonses_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_be_mail_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_constantcontact_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_ecmessenger_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_emarsys_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_exacttarget_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_fxyn_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_keysender_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_mailchimp_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_maildome_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_mailgun_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_mailup_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_mdengine_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_mdrctr_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_msdynamics_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_msnd_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_salesforce_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_sendgrid_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_sendgrid_check_domain',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_sendgrid_check_id',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_sendinblue_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_smtpcom_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);
  $self->register_eval_rule('esp_sparkpost_check',  $Mail::SpamAssassin::Conf::TYPE_HEAD_EVALS);

  return $self;
}

=head1 SYNOPSIS

loadplugin Mail::SpamAssassin::Plugin::Esp Esp.pm

ifplugin Mail::SpamAssassin::Plugin::Esp

  sendgrid_feed /etc/mail/spamassassin/sendgrid-id-dnsbl.txt,/etc/mail/spamassassin/sendgrid-id-local.txt
  sendgrid_domains_feed /etc/mail/spamassassin/sendgrid-envelopefromdomain-dnsbl.txt

  header          SPBL_SENDGRID           eval:esp_sendgrid_check()
  describe        SPBL_SENDGRID           Message from Sendgrid abused account

endif

Usage:

  esp_4dem_check()
    Checks for 4dem id abused accounts

  esp_acelle_check()
    Checks for Acelle id abused accounts

  esp_amazonses_check()
    Checks for Amazon SES id abused accounts

  esp_be_mail_check()
    Checks for Be-Mail id abused accounts

  esp_constantcontact_check()
    Checks for Constant Contact id abused accounts

  esp_ecmessenger_check()
    Checks for Ec-Messenger abused accounts

  esp_emarsys_check()
    Checks for EMarSys abused accounts

  esp_exacttarget_check()
    Checks for ExactTarget abused accounts

  esp_fxyn_check()
    Checks for Fxyn abused accounts

  esp_keysender_check()
    Checks for Keysender abused accounts

  esp_mailchimp_check()
    Checks for Mailchimp abused accounts

  esp_maildome_check()
    Checks for Maildome abused accounts

  esp_mailgun_check()
    Checks for Mailgun abused accounts

  esp_mailup_check()
    Checks for Mailup abused accounts

  esp_mdengine_check()
    Checks for MDEngine abused accounts

  esp_mdrctr_check()
    Checks for Mdirector abused accounts

  esp_msdynamics_check()
    Checks for Microsoft Dynamics abused accounts

  esp_msnd_check()
    Checks for Msnd id abused accounts

  esp_salesforce_check()
    Checks for Salesforce id abused accounts

  esp_sendgrid_check()
    Checks for Sendgrid abused accounts (both id and domains)

  esp_sendgrid_check_domain()
    Checks for Sendgrid domains abused accounts

  esp_sendgrid_check_id()
    Checks for Sendgrid id abused accounts

  esp_sendindblue_check()
    Checks for Sendinblue abused accounts

  esp_smtpcom_check()
    Checks for SmtpCom abused accounts

  esp_sparkpost_check()
    Checks for Sparkpost abused accounts

Every sub can be called with an options parameter which can contain the keywords "md5"
to crypt the Esp id using md5 algorithm and "nodash" which will substitute the "-" char
with a "_" in order to be possible to use the Esp id in dns records.

=head1 ADMINISTRATOR SETTINGS

=over 4

=item acelle_feed [...]

A list of files with abused Acelle accounts.
Files can be separated by a comma.

=item amazonses_feed [...]

A list of files with abused Amazon SES accounts.
Files can be separated by a comma.

=item bemail_feed [...]

A list of files with abused Be Mail accounts.
Files can be separated by a comma.

=item constantcontact_feed [...]

A list of files with abused Constant Contact accounts.
Files can be separated by a comma.

=item ecmessenger_feed [...]

A list of files with abused EcMessenger accounts.
Files can be separated by a comma.

=item emarsys_feed [...]

A list of files with abused EMarSys accounts.
Files can be separated by a comma.

=item exacttarget_feed [...]

A list of files with abused ExactTarget accounts.
Files can be separated by a comma.

=item fordem_feed [...]

A list of files with abused 4dem accounts.
Files can be separated by a comma.

=item fxyn_feed [...]

A list of files with abused Fxyn accounts.
Files can be separated by a comma.

=item keysender_feed [...]

A list of files with abused Keysender accounts.
Files can be separated by a comma.

=item mailchimp_feed [...]

A list of files with abused Mailchimp accounts.
Files can be separated by a comma.

=item maildome_feed [...]

A list of files with abused Maildome accounts.
Files can be separated by a comma.

=item mailgun_feed [...]

A list of files with abused Mailgun accounts.
Files can be separated by a comma.

=item mailup_feed [...]

A list of files with abused Mailup accounts.
Files can be separated by a comma.

=item mdengine_feed [...]

A list of files with abused MDEngine accounts.
Files can be separated by a comma.

=item mdrctr_feed [...]

A list of files with abused Mdirector accounts.
Files can be separated by a comma.

=item msdynamics_feed [...]

A list of files with abused Microsoft Dynamics accounts.
Files can be separated by a comma.

=item msnd_feed [...]

A list of files with abused Msnd accounts.
Files can be separated by a comma.

=item salesforce_feed [...]

A list of files with abused Salesforce accounts.

=item sendgrid_feed [...]

A list of files with all abused Sendgrid accounts.
Files can be separated by a comma.

=item sendgrid_domains_feed [...]

A list of files with abused domains managed by Sendgrid.
Files can be separated by a comma.

=item sendinblue_feed [...]

A list of files with abused Sendinblue accounts.
Files can be separated by a comma.

=item smtpcom_feed [...]

A list of files with abused SmtpCom accounts.
Files can be separated by a comma.

=item sparkpost_feed [...]

A list of files with abused Sparkpost accounts.
Files can be separated by a comma.

=back

=head1 TEMPLATE TAGS

=over

The plugin sets some tags when a rule match, those tags can be used to use direct queries against rbl.

If direct queries are used the main rule will be used only to set the tag and the score should be
added to the askdns rule.

  ifplugin Mail::SpamAssassin::Plugin::AskDNS
    askdns   SENDGRID_ID _SENDGRIDID_.rbl.domain.tld A 127.0.0.2
    describe SENDGRID_ID Sendgrid account matches rbl
  endif

Tags that the plugin could set are:

=back

=over

=item *
ACELLEID

=item *
AMAZONSESID

=item *
BEMAILID

=item *
CONSTANTCONTACTID

=item *
ECMESSENGERID

=item *
EMARSYSID

=item *
FORDEMID

=item *
FXYNID

=item *
KEYSENDERID

=item *
MAILCHIMPID

=item *
MAILDOMEID

=item *
MAILGUNID

=item *
MAILUPID

=item *
MDENGINEID

=item *
MDRCTRID

=item *
MSNDID

=item *
SALESFORCEID

=item *
SENDGRIDDOM

=item *
SENDGRIDID

=item *
SENDINBLUEID

=item *
SMTPCOMID

=item *
SPARKPOSTID

=back

=cut

sub set_config {
  my($self, $conf) = @_;
  my @cmds = ();

  push(@cmds, {
    setting => 'acelle_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'amazonses_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'bemail_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'constantcontact_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'ecmessenger_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'emarsys_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'exacttarget_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'fordem_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'fxyn_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'keysender_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'mailchimp_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'maildome_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'mailgun_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'mailup_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'mdengine_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'mdrctr_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'msdynamics_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'msnd_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'salesforce_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'sendgrid_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'sendgrid_domains_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'sendinblue_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'smtpcom_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  push(@cmds, {
    setting => 'sparkpost_feed',
    is_admin => 1,
    type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    }
  );
  $conf->{parser}->register_commands(\@cmds);
}

sub finish_parsing_end {
  my ($self, $opts) = @_;
  $self->_read_configfile('acelle_feed', 'ACELLE');
  $self->_read_configfile('amazonses_feed', 'AMAZONSES');
  $self->_read_configfile('bemail_feed', 'BEMAIL');
  $self->_read_configfile('constantcontact_feed', 'CONSTANTCONTACT');
  $self->_read_configfile('ecmessenger_feed', 'ECMESSENGER');
  $self->_read_configfile('emarsys_feed', 'EMARSYS');
  $self->_read_configfile('exacttarget_feed', 'EXACTTARGET');
  $self->_read_configfile('fordem_feed', 'FORDEM');
  $self->_read_configfile('fxyn_feed', 'FXYN');
  $self->_read_configfile('keysender_feed', 'KEYSENDER');
  $self->_read_configfile('mailchimp_feed', 'MAILCHIMP');
  $self->_read_configfile('maildome_feed', 'MAILDOME');
  $self->_read_configfile('mailgun_feed', 'MAILGUN');
  $self->_read_configfile('mailup_feed', 'MAILUP');
  $self->_read_configfile('mdengine_feed', 'MDENGINE');
  $self->_read_configfile('mdrctr_feed', 'MDRCTR');
  $self->_read_configfile('msdynamics_feed', 'MSDYNAMICS');
  $self->_read_configfile('msnd_feed', 'MSND');
  $self->_read_configfile('salesforce_feed', 'SALESFORCE');
  $self->_read_configfile('sendgrid_feed', 'SENDGRID');
  $self->_read_configfile('sendgrid_domains_feed', 'SENDGRID_DOMAINS');
  $self->_read_configfile('sendinblue_feed', 'SENDINBLUE');
  $self->_read_configfile('smtpcom_feed', 'SMTPCOM');
  $self->_read_configfile('sparkpost_feed', 'SPARKPOST');
}

sub _read_configfile {
  my ($self, $feed, $esp) = @_;
  my $conf = $self->{main}->{conf};
  my $id;

  local *F;

  return if not defined $conf->{$feed};

  my @feed_files = split(/,/, $conf->{$feed});
  foreach my $feed_file ( @feed_files ) {
    if ( defined($feed_file) && ( -f $feed_file ) ) {
      open(F, '<', $feed_file);
      for ($!=0; <F>; $!=0) {
        chomp;
        #lines that start with pound are comments
        next if(/^\s*\#/);
        $id = $_;
        if ( defined $id ) {
          push @{$self->{ESP}->{$esp}->{$id}}, $id;
        }
      }

      defined $_ || $!==0  or
        $!==EBADF ? dbg("ESP: error reading config file: $!")
                  : die "error reading config file: $!";
      close(F) or die "error closing config file: $!";
    }
  }
}

sub _hit_and_tag {
  my ($self, $pms, $id, $list, $list_desc, $tag, $opts) = @_;

  my $printid = $id;

  my $rulename = $pms->get_current_eval_rule_name();
  chomp($id);
  if(defined $id) {
    if(defined $opts) {
      if($opts =~ /nodash/) {
        $id =~ s/\-/_/g;
      }
      if($opts =~ /nobase64/) {
        $id =~ s/\+|\=|\//_/g;
      }
      if($opts =~ /md5/) {
        $id = md5_hex($id);
      }
    }
    $pms->set_tag($tag, $id);
    if ( exists $self->{ESP}->{$list}->{$id} ) {
      dbg("HIT! $id customer found in $list_desc feed");
      $pms->test_log("$list_desc id: $printid");
      $pms->got_hit($rulename, "", ruletype => 'eval');
      return 1;
    }
  }
}

sub esp_4dem_check {
  my ($self, $pms, $opts) = @_;
  my $uid;

  # return if X-SMTPAPI is not what we want
  my $xsmtp = $pms->get("X-SMTPAPI", undef);

  if((not defined $xsmtp) or ($xsmtp !~ /unique_args/)) {
    return;
  }

  $uid = $pms->get("X-UiD", undef);
  return if not defined $uid;

  return if ($uid !~ /^\d+$/);

  return _hit_and_tag($self, $pms, $uid, 'FORDEM', '4Dem', 'FORDEMID', $opts);
}

sub esp_acelle_check {
  my ($self, $pms, $opts) = @_;
  my $cid;

  # return if X-Mailer is defined
  my $xmailer = $pms->get("X-Mailer", undef);
  if(defined $xmailer) {
    return;
  }

  $cid = $pms->get("X-Acelle-Customer-Id", 0);
  return if not defined $cid;

  return _hit_and_tag($self, $pms, $cid, 'ACELLE', 'Acelle', 'ACELLEID', $opts);
}

sub esp_amazonses_check {
  my ($self, $pms, $opts) = @_;
  my $fid;

  # Change base64 chars that are not valid in dns records into "_", uid must be limited to chars permitted in dns records
  if($opts ne "md5") {
    $opts .= "nobase64";
  }

  # return if X-SES-Outgoing is not what we want
  my $xses = $pms->get("X-SES-Outgoing", undef);

  if((not defined $xses) or ($xses !~ /\d{4}\.\d{2}\.\d{2}\-/)) {
    return;
  }

  # Parse the Feedback-ID
  # Feedback-ID: 1.eu-west-3.lw6TDfPoSha17XiO+mc7ZtIOCZEcjZHgwdWo1vcloYU=:AmazonSES
  $fid = $pms->get("Feedback-ID", undef);
  return if not defined $fid;

  if($fid =~ /\d+\.[a-z]+\-[a-z]+\-\d+\.(.*)\:AmazonSES/) {
    $fid = $1;
    return _hit_and_tag($self, $pms, $fid, 'AMAZONSES', 'Amazon SES', 'AMAZONSESID', $opts);
  }
  return;
}

sub esp_be_mail_check {
  my ($self, $pms, $opts) = @_;
  my ($fid, $uid);

  # return if X-CSA-Complaints is not what we want
  my $xcsa = $pms->get("X-CSA-Complaints", undef);

  if((not defined $xcsa) or ($xcsa !~ /\@eco\.de/)) {
    return;
  }

  $fid = $pms->get("Feedback-ID", undef);
  return if not defined $fid;

  if($fid =~ /(?:\d+)\:(\d+)\:(?:\d+)\:/) {
    $uid = $1;
  }
  return if not defined $uid;

  return _hit_and_tag($self, $pms, $uid, 'BEMAIL', 'BeMail', 'BEMAILID', $opts);
}

sub esp_constantcontact_check {
  my ($self, $pms, $opts) = @_;
  my $contact_id;

  # return if X-Mailer is not what we want
  my $xmailer = $pms->get("X-Mailer", undef);

  if((not defined $xmailer) or ($xmailer !~ /Roving\sConstant\sContact/)) {
    return;
  }

  my $envfrom = $pms->get("EnvelopeFrom:addr", undef);
  return if not defined $envfrom;
  return if $envfrom !~ /\@in\.constantcontact\.com/;

  $contact_id = $pms->get("X-Roving-Id", undef);
  return if not defined $contact_id;
  return if ($contact_id !~ /^(\d+)\.\d+$/);

  return _hit_and_tag($self, $pms, $contact_id, 'CONSTANTCONTACT', 'Constant Contact', 'CONSTANTCONTACTID', $opts);
}

sub esp_emarsys_check {
  my ($self, $pms, $opts) = @_;
  my ($fid, $uid);

  # return if X-CSA-Complaints is not what we want
  my $xcsa = $pms->get("X-CSA-Complaints", undef);

  if((not defined $xcsa) or ($xcsa !~ /\@eco\.de/)) {
    return;
  }

  # "X-EMarSys-Identify: 287647073_5065286_24628
  $fid = $pms->get("X-EMarSys-Identify", undef);
  return if not defined $fid;
  if($fid =~ /(\d+)_(?:\d+)_(?:\d+)/) {
    $uid = $1;
  }
  return if not defined $uid;

  return _hit_and_tag($self, $pms, $uid, 'EMARSYS', 'EMarSys', 'EMARSYSID', $opts);
}

sub esp_exacttarget_check {
  my ($self, $pms, $opts) = @_;
  my ($fid, $uid);

  # return if X-CSA-Complaints is not what we want
  my $xcsa = $pms->get("X-CSA-Complaints", undef);

  if((not defined $xcsa) or ($xcsa !~ /\@eco\.de/)) {
    return;
  }
  my $xsfmc = $pms->get("X-SFMC-Stack", undef);
  return if not defined $xsfmc;

  # x-messageKey: 932063-75865447-2253076
  # x-messageKey: undelivered+984411+551293975@pd25.com
  $fid = $pms->get("x-messageKey", undef);
  return if not defined $fid;
  if($fid =~ /(\d+)\-(?:\d+)\-(?:\d+)/) {
    $uid = $1;
  } elsif ($fid =~ /undelivered\+(\d+)\+(?:\d+)\@pd25\.com/) {
    $uid = $1;
  }
  return if not defined $uid;

  return _hit_and_tag($self, $pms, $uid, 'EXACTTARGET', 'ExactTarget', 'EXACTTARGETID', $opts);
}

sub esp_ecmessenger_check {
  my ($self, $pms, $opts) = @_;
  my $cid;

  # return if X-Mailer is not what we want
  my $xmailer = $pms->get("X-Mailer", undef);

  if((not defined $xmailer) or ($xmailer !~ /eC\-Messenger\sBuild\s\d/)) {
    return;
  }

  $cid = $pms->get("X-eC-messenger-cid", undef);
  return if not defined $cid;

  return if ($cid !~ /^\d+$/);

  return _hit_and_tag($self, $pms, $cid, 'ECMESSENGER', 'EcMessenger', 'ECMESSENGERID', $opts);
}

sub esp_fxyn_check {
  my ($self, $pms, $opts) = @_;
  my $uid;

  # return if X-Fxyn-Mailer is not what we want
  my $xmailer = $pms->get("X-Fxyn-Mailer", undef);

  if((not defined $xmailer) or ($xmailer !~ /SwiftMailer/)) {
    return;
  }

  $uid = $pms->get("X-Fxyn-Customer-Uid", undef);
  return if not defined $uid;

  return _hit_and_tag($self, $pms, $uid, 'FXYN', 'Fxyn', 'FXYNID', $opts);
}

sub esp_keysender_check {
  my ($self, $pms, $opts) = @_;
  my $uid;

  # return if X-EBS is not set
  my $xebs = $pms->get("X-EBS", undef);

  if(not defined $xebs) {
    return;
  }

  $uid = $pms->get("Feedback-ID", undef);
  if($uid =~ /\w+\:\w+\:\w+\:(\w+)/) {
    $uid = $1;
  }
  return if not defined $uid;

  return _hit_and_tag($self, $pms, $uid, 'KEYSENDER', 'Keysender', 'KEYSENDERID', $opts);
}

sub esp_mailchimp_check {
  my ($self, $pms, $opts) = @_;
  my $mailchimp_id;

  # check some headers
  my $xmailer = $pms->get("X-Mailer", undef);
  my $xmandrill = $pms->get("X-Mandrill-User", undef);

  if((defined $xmailer) and ($xmailer =~ /MailChimp Mailer/i)) {
    $mailchimp_id = $pms->get("X-MC-User", undef);
    return if not defined $mailchimp_id;
    return if ($mailchimp_id !~ /^([0-9a-z]{25})$/);
  } elsif(defined $xmandrill) {
    return if ($xmandrill !~ /^md_([0-9a-z]{8})$/);
    $mailchimp_id = $xmandrill;
  } else {
    return;
  }

  return _hit_and_tag($self, $pms, $mailchimp_id, 'MAILCHIMP', 'Mailchimp', 'MAILCHIMPID', $opts);
}

sub esp_maildome_check {
  my ($self, $pms, $opts) = @_;
  my $maildome_id;

  # return if X-Mailer is not what we want
  my $xmailer = $pms->get("X-Mailer", undef);

  if((not defined $xmailer) or ($xmailer !~ /MaildomeMTA/)) {
    return;
  }

  $maildome_id = $pms->get("List-Unsubscribe", undef);
  return if not defined $maildome_id;
  $maildome_id =~ /subject=https?:\/\/.*\/unsubscribe\/(?:[0-9]+)\/([0-9]+)\/.*\/(?:[0-9]+)\/(?:[0-9]+)\>/;
  $maildome_id = $1;

  # if regexp doesn't match it's not Maildome
  return if not defined $maildome_id;
  return _hit_and_tag($self, $pms, $maildome_id, 'MAILDOME', 'Maildome', 'MAILDOMEID', $opts);
}

sub esp_mailgun_check {
  my ($self, $pms, $opts) = @_;
  my $mailgun_id;

  # Mailgun doesn't define an X-Mailer header
  my $xmailer = $pms->get("X-Mailer", undef);
  if(defined $xmailer) {
    return;
  }

  my $xsendip = $pms->get("X-Mailgun-Sending-Ip", undef);
  if(not defined $xsendip) {
    return;
  }

  my $envfrom = $pms->get("EnvelopeFrom:addr", undef);
  return if not defined $envfrom;
  # Find the customer id from the Return-Path
  $envfrom =~ /bounce\+(?:\w+)\.(\w+)\-/;
  $mailgun_id = $1;

  return _hit_and_tag($self, $pms, $mailgun_id, 'MAILGUN', 'Mailgun', 'MAILGUNID', $opts);
}

sub esp_mailup_check {
  my ($self, $pms, $opts) = @_;
  my ($mailup_id, $xabuse, $listid);

  # All Mailup emails have the X-CSA-Complaints header set to *-complaints@eco.de
  my $xcsa = $pms->get("X-CSA-Complaints", undef);
  my $xbps = $pms->get("X-BPS1", undef);
  if(((not defined $xcsa) or ($xcsa !~ /\-complaints\@eco\.de/)) and (not defined $xbps)) {
    return;
  }
  # All Mailup emails have the X-Abuse header that must match
  $xabuse = $pms->get("X-Abuse", undef);
  return if not defined $xabuse;
  if($xabuse =~ /Please report abuse here: https?:\/\/.*\.musvc(?:[0-9]+)\.net\/p\?c=([0-9]+)/) {
    $mailup_id = $1;
  }
  if(not defined $mailup_id) {
    $listid = $pms->get("list-id", undef);
    if($listid =~ /\<(\d+)\.\d+\>/) {
      $mailup_id = $1;
    }
  }
  # if regexp doesn't match it's not Mailup
  return if not defined $mailup_id;

  return _hit_and_tag($self, $pms, $mailup_id, 'MAILUP', 'Mailup', 'MAILUPID', $opts);
}

sub esp_mdengine_check {
  my ($self, $pms, $opts) = @_;
  my $mdengine_id;

  my $xmailer = $pms->get("X-Mailer", undef);
  return if (not defined $xmailer or ($xmailer !~ /MDEngine/));

  my $fid = $pms->get("Feedback-ID", 0);
  return if not defined $fid;

  # Find the customer id from the Feedback-ID
  if($fid =~ /\@(.*)/i) {
    $mdengine_id = $1;
    return _hit_and_tag($self, $pms, $mdengine_id, 'MDENGINE', 'MDEngine', 'MDENGINEID', $opts);
  }
  return;
}

sub esp_mdrctr_check {
  my ($self, $pms, $opts) = @_;
  my $mdrctr_id;

  # All Mdrctr emails have the X-ElasticEmail-Postback header
  my $el_post = $pms->get("X-ElasticEmail-Postback", undef);
  return if not defined $el_post;

  my $fid = $pms->get("Feedback-ID", undef);
  return if not defined $fid;

  my $listid = $pms->get('List-ID');
  return if ($listid !~ /\.mdrctr\.com/);

  # Find the customer id from the Feedback-ID
  if($fid =~ /(\d+):(?:\d+):(?:[a-z]+)/i) {
    $mdrctr_id = $1;
    return _hit_and_tag($self, $pms, $mdrctr_id, 'MDRCTR', 'Mdrctr', 'MDRCTRID', $opts);
  }
}

sub esp_msdynamics_check {
  my ($self, $pms, $opts) = @_;

  my $msdyn_id = $pms->get("X-MS-Dynamics-Instance", undef);
  return if not defined $msdyn_id;

  return _hit_and_tag($self, $pms, $msdyn_id, 'MSDYNAMICS', 'Microsoft Dynamics', 'MSDYNID', $opts);
}

sub esp_msnd_check {
  my ($self, $pms, $opts) = @_;
  my $uid;

  # Change "-" into "_", uid must be limited to chars permitted in dns records
  if($opts ne "md5") {
    $opts .= "nodash";
  }

  # return if X-Mailer is not what we want
  my $xmailer = $pms->get("X-Mailer", undef);

  if((not defined $xmailer) or ($xmailer !~ /Msnd Mailer/)) {
    return;
  }

  $uid = $pms->get("X-MID", undef);
  return if not defined $uid;

  return _hit_and_tag($self, $pms, $uid, 'MSND', 'Msnd', 'MSNDID', $opts);
}

sub esp_salesforce_check {
  my ($self, $pms, $opts) = @_;
  my $uid;

  # return if X-Sender is not what we want
  my $xsender = $pms->get("X-Sender", undef);

  if((not defined $xsender) or ($xsender ne 'postmaster@salesforce.com')) {
    return;
  }

  $uid = $pms->get("X-SFDC-User", undef);
  return if not defined $uid;

  return _hit_and_tag($self, $pms, $uid, 'SALESFORCE', 'Salesforce', 'SALESFORCEID', $opts);
}

sub esp_sendgrid_check {
  my ($self, $pms, $opts) = @_;

  my $ret;

  $ret = $self->esp_sendgrid_check_id($pms, $opts);
  if (!$ret) {
    $ret = $self->esp_sendgrid_check_domain($pms, $opts);
  }
  return $ret;
}

sub esp_sendgrid_check_domain {
  my ($self, $pms, $opts) = @_;
  my $sendgrid_id;
  my $sendgrid_domain;

  # All Sendgrid emails have the X-SG-EID header
  my $sg_eid = $pms->get("X-SG-EID", undef);
  return if not defined $sg_eid;

  my $rulename = $pms->get_current_eval_rule_name();
  my $envfrom = $pms->get("EnvelopeFrom:addr", undef);
  return if not defined $envfrom;

  # Find the domain from the Return-Path
  if($envfrom =~ /\@(\w+\.)?([\w\.]+)\>?$/) {
    $sendgrid_domain = $2;
    if($sendgrid_domain !~ /\./) {
      $sendgrid_domain = $1 . $2;
    }
    return _hit_and_tag($self, $pms, $sendgrid_domain, 'SENDGRID_DOMAINS', 'Sendgrid', 'SENDGRIDDOM', $opts);
  }
}

sub esp_sendgrid_check_id {
  my ($self, $pms, $opts) = @_;
  my $sendgrid_id;
  my $sendgrid_domain;

  # All Sendgrid emails have the X-SG-EID header
  my $sg_eid = $pms->get("X-SG-EID", undef);
  return if not defined $sg_eid;

  my $envfrom = $pms->get("EnvelopeFrom:addr", undef);
  return if not defined $envfrom;

  # Find the customer id from the Return-Path
  if($envfrom =~ /bounces\+(\d+)\-/) {
    $sendgrid_id = $1;
    return _hit_and_tag($self, $pms, $sendgrid_id, 'SENDGRID', 'Sendgrid', 'SENDGRIDID', $opts);
  }
}

sub esp_sendinblue_check {
  my ($self, $pms, $opts) = @_;
  my $sendinblue_id;

  my $feedback_id = $pms->get("Feedback-ID", undef);
  return if not defined $feedback_id;

  if($feedback_id =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:(\d+)_(?:-1|\d+):(?:\d+):Sendinblue$/) {
    $sendinblue_id = $1;
  }

  return if not defined $sendinblue_id;

  return _hit_and_tag($self, $pms, $sendinblue_id, 'SENDINBLUE', 'Sendinblue', 'SENDINBLUEID', $opts);
}

sub esp_smtpcom_check {
  my ($self, $pms, $opts) = @_;

  my $smtpcom_payload = $pms->get("X-SMTPCOM-Payload", undef);
  return if not defined $smtpcom_payload;

  my $smtpcom_id = $pms->get("X-SMTPCOM-Sender-ID", undef);
  return if not defined $smtpcom_id;

  return _hit_and_tag($self, $pms, $smtpcom_id, 'SMTPCOM', 'Smtpcom', 'SMTPCOMID', $opts);
}

sub esp_sparkpost_check {
  my ($self, $pms, $opts) = @_;
  my $sparkpost_id;

  my $list_id = $pms->get("List-Id", undef);
  return if not defined $list_id;

  if($list_id =~ /^<?[a-z]+\.([0-9]+)\.(?:[0-9]+)\.sparkpostmail\.com>?$/) {
    $sparkpost_id = $1;
  }

  return if not defined $sparkpost_id;

  return _hit_and_tag($self, $pms, $sparkpost_id, 'SPARKPOST', 'Sparkpost', 'SPARKPOSTID', $opts);
}

# Version features
sub has_esp_4dem_check { 1 };
sub has_esp_acelle_check { 1 };
sub has_esp_amazonses_check { 1 };
sub has_esp_be_mail_check { 1 };
sub has_esp_constantcontact_check { 1 };
sub has_esp_ecmessenger_check { 1 };
sub has_esp_emarsys_check { 1 };
sub has_esp_exacttarget_check { 1 };
sub has_esp_fxyn_check { 1 };
sub has_esp_keysender_check { 1 };
sub has_esp_mailchimp_check { 1 };
sub has_esp_maildome_check { 1 };
sub has_esp_mailgun_check { 1 };
sub has_esp_mailup_check { 1 };
sub has_esp_mdengine_check { 1 };
sub has_esp_mdrctr_check { 1 };
sub has_esp_msdynamics_check { 1 };
sub has_esp_msnd_check { 1 };
sub has_esp_salesforce_check { 1 };
sub has_esp_sendgrid_check { 1 };
sub has_esp_sendinblue_check { 1 };
sub has_esp_smtpcom_check { 1 };
sub has_esp_sparkpost_check { 1 };

1;
