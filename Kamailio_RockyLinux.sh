#!/bin/bash
sudo dnf clean packages
sudo dnf -y update
sudo dnf -y upgrade
sudo dnf -y install dnf-plugins-core
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
sudo reboot
##############################
sestatus 
sudo yum -y install mariadb-server
sudo systemctl enable --now mariadb
sudo mysql_secure_installation
sudo yum -y install dnf-plugins-core
sudo yum config-manager --add-repo https://rpm.kamailio.org/centos/kamailio.repo
sudo yum install vim kamailio kamailio-presence kamailio-ldap kamailio-mysql kamailio-debuginfo kamailio-xmpp kamailio-unixodbc kamailio-utils kamailio-tls kamailio-outbound kamailio-gzcompress -y
kamailio -version
sudo cp /etc/kamailio/kamctlrc /etc/kamailio/kamctlrc_org
sudo tee /etc/kamailio/kamctlrc << EOF
## The Kamailio configuration file for the control tools.
##
## Here you can set variables used in the kamctl and kamdbctl setup
## scripts. Per default all variables here are commented out, the control tools
## will use their internal default values.

## the SIP domain
# SIP_DOMAIN=kamailio.org

## chrooted directory
# CHROOT_DIR="/path/to/chrooted/directory"

## database type: MYSQL, PGSQL, ORACLE, DB_BERKELEY, DBTEXT, or SQLITE
## by default none is loaded
##
## If you want to setup a database with kamdbctl, you must at least specify
## this parameter.
DBENGINE=MYSQL

## database host
DBHOST=localhost

## database port
# DBPORT=3306

## database name (for ORACLE this is TNS name)
# DBNAME=kamailio

## database path used by dbtext, db_berkeley or sqlite
# DB_PATH="/usr/local/etc/kamailio/dbtext"

## database read/write user
# DBRWUSER="kamailio"

## password for database read/write user
# DBRWPW="kamailiorw"

## database read only user
# DBROUSER="kamailioro"

## password for database read only user
# DBROPW="kamailioro"

## database access host (from where is kamctl used)
# DBACCESSHOST=192.168.0.1

## database super user (for ORACLE this is 'scheme-creator' user)
# DBROOTUSER="root"

## password for database super user
## - important: this is insecure, targeting the use only for automatic testing
## - known to work for: mysql
# DBROOTPW="dbrootpw"

## option to ask confirmation for all database creation steps
# DBINITASK=yes

## database character set (used by MySQL when creating database)
#CHARSET="latin1"

## user name column
# USERCOL="username"


## SQL definitions
## If you change this definitions here, then you must change them
## in db/schema/entities.xml too.
## FIXME

# FOREVER="2030-05-28 21:32:15"
# DEFAULT_Q="1.0"


## Program to calculate a message-digest fingerprint
# MD5="md5sum"

## awk tool
# AWK="awk"

## gdb tool
# GDB="gdb"

## If you use a system with a grep and egrep that is not 100% gnu grep compatible,
## e.g. solaris, install the gnu grep (ggrep) and specify this below.
##
## grep tool
# GREP="grep"

## egrep tool
# EGREP="egrep"

## sed tool
# SED="sed"

## tail tool
# LAST_LINE="tail -n 1"

## expr tool
# EXPR="expr"


## Describe what additional tables to install. Valid values for the variables
## below are yes/no/ask. With ask (default) it will interactively ask the user
## for an answer, while yes/no allow for automated, unassisted installs.

## If to install tables for the modules in the EXTRA_MODULES variable.
# INSTALL_EXTRA_TABLES=ask

## If to install presence related tables.
# INSTALL_PRESENCE_TABLES=ask

## If to install uid modules related tables.
# INSTALL_DBUID_TABLES=ask

## Define what module tables should be installed.
## If you use the postgres database and want to change the installed tables, then you
## must also adjust the STANDARD_TABLES or EXTRA_TABLES variable accordingly in the
## kamdbctl.base script.

## Kamailio standard modules
# STANDARD_MODULES="standard acc lcr domain group permissions registrar usrloc msilo
#                   alias_db uri_db speeddial avpops auth_db pdt dialog dispatcher
#                   dialplan"

## Kamailio extra modules
# EXTRA_MODULES="imc cpl siptrace domainpolicy carrierroute userblocklist htable purple sca"


## type of aliases used: DB - database aliases; UL - usrloc aliases
## - default: none
# ALIASES_TYPE="DB"

## control engine: RPCFIFO
## - default RPCFIFO
# CTLENGINE="RPCFIFO"

## path to FIFO file for engine RPCFIFO
# RPCFIFOPATH="/run/kamailio/kamailio_rpc.fifo"

## check ACL names; default on (1); off (0)
# VERIFY_ACL=1

## ACL names - if VERIFY_ACL is set, only the ACL names from below list
## are accepted
# ACL_GROUPS="local ld int voicemail free-pstn"

## check if user exists (used by some commands such as acl);
## - default on (1); off (0)
# VERIFY_USER=1

## verbose - debug purposes - default '0'
# VERBOSE=1

## do (1) or don't (0) store plaintext passwords
## in the subscriber table - default '1'
# STORE_PLAINTEXT_PW=0

## Kamailio START Options
## PID file path - default is: /run/kamailio/kamailio.pid
# PID_FILE=/run/kamailio/kamailio.pid

## Extra start options - default is: not set
## example: start Kamailio with 64MB share memory: STARTOPTIONS="-m 64"
# STARTOPTIONS=
EOF

sudo kamdbctl create
sudo cp /etc/kamailio/kamailio.cfg /etc/kamailio/kamailio.cfg_org 



sudo tee /etc/kamailio/kamailio.cfg << EOF
#!KAMAILIO
#
# Kamailio SIP Server v5.6 - default configuration script
#     - web: https://www.kamailio.org
#     - git: https://github.com/kamailio/kamailio

#!define WITH_MYSQL
#!define WITH_AUTH
#!define WITH_USRLOCDB
#!define WITH_NAT
#!define WITH_PRESENCE
#!define WITH_ACCDB


#
# Direct your questions about this file to: <sr-users@lists.kamailio.org>
#
# Refer to the Core CookBook at https://www.kamailio.org/wiki/
# for an explanation of possible statements, functions and parameters.
#
# Note: the comments can be:
#     - lines starting with #, but not the pre-processor directives,
#       which start with #!, like #!define, #!ifdef, #!endif, #!else, #!trydef,
#       #!subst, #!substdef, ...
#     - lines starting with //
#     - blocks enclosed in between /* */
# Note: the config performs symmetric SIP signaling
#     - it sends the reply to the source address of the request
#     - remove the use of force_rport() for asymmetric SIP signaling
#
# Several features can be enabled using '#!define WITH_FEATURE' directives:
#
# *** To run in debug mode:
#     - define WITH_DEBUG
#     - debug level increased to 3, logs still sent to syslog
#     - debugger module loaded with cfgtrace endabled
#
# *** To enable mysql:
#     - define WITH_MYSQL
#
# *** To enable authentication execute:
#     - enable mysql
#     - define WITH_AUTH
#     - add users using 'kamctl' or 'kamcli'
#
# *** To enable IP authentication execute:
#     - enable mysql
#     - enable authentication
#     - define WITH_IPAUTH
#     - add IP addresses with group id '1' to 'address' table
#
# *** To enable persistent user location execute:
#     - enable mysql
#     - define WITH_USRLOCDB
#
# *** To enable presence server execute:
#     - enable mysql
#     - define WITH_PRESENCE
#     - if modified headers or body in config must be used by presence handling:
#     - define WITH_MSGREBUILD
#
# *** To enable nat traversal execute:
#     - define WITH_NAT
#     - option for NAT SIP OPTIONS keepalives: WITH_NATSIPPING
#     - install RTPProxy: http://www.rtpproxy.org
#     - start RTPProxy:
#        rtpproxy -l _your_public_ip_ -s udp:localhost:7722
#
# *** To use RTPEngine (instead of RTPProxy) for nat traversal execute:
#     - define WITH_RTPENGINE
#     - install RTPEngine: https://github.com/sipwise/rtpengine
#     - start RTPEngine:
#        rtpengine --listen-ng=127.0.0.1:2223 ...
#
# *** To enable PSTN gateway routing execute:
#     - define WITH_PSTN
#     - set the value of pstn.gw_ip
#     - check route[PSTN] for regexp routing condition
#
# *** To enable database aliases lookup execute:
#     - enable mysql
#     - define WITH_ALIASDB
#
# *** To enable speed dial lookup execute:
#     - enable mysql
#     - define WITH_SPEEDDIAL
#
# *** To enable multi-domain support execute:
#     - enable mysql
#     - define WITH_MULTIDOMAIN
#
# *** To enable TLS support execute:
#     - adjust CFGDIR/tls.cfg as needed
#     - define WITH_TLS
#
# *** To enable JSONRPC over HTTP(S) support execute:
#     - define WITH_JSONRPC
#     - adjust event_route[xhttp:request] for access policy
#
# *** To enable anti-flood detection execute:
#     - adjust pike and htable=>ipban settings as needed (default is
#       block if more than 16 requests in 2 seconds and ban for 300 seconds)
#     - define WITH_ANTIFLOOD
#
# *** To block 3XX redirect replies execute:
#     - define WITH_BLOCK3XX
#
# *** To block 401 and 407 authentication replies execute:
#     - define WITH_BLOCK401407
#
# *** To enable VoiceMail routing execute:
#     - define WITH_VOICEMAIL
#     - set the value of voicemail.srv_ip
#     - adjust the value of voicemail.srv_port
#
# *** To enhance accounting execute:
#     - enable mysql
#     - define WITH_ACCDB
#     - add following columns to database
#!ifdef ACCDB_COMMENT
  ALTER TABLE acc ADD COLUMN src_user VARCHAR(64) NOT NULL DEFAULT '';
  ALTER TABLE acc ADD COLUMN src_domain VARCHAR(128) NOT NULL DEFAULT '';
  ALTER TABLE acc ADD COLUMN src_ip varchar(64) NOT NULL default '';
  ALTER TABLE acc ADD COLUMN dst_ouser VARCHAR(64) NOT NULL DEFAULT '';
  ALTER TABLE acc ADD COLUMN dst_user VARCHAR(64) NOT NULL DEFAULT '';
  ALTER TABLE acc ADD COLUMN dst_domain VARCHAR(128) NOT NULL DEFAULT '';
  ALTER TABLE missed_calls ADD COLUMN src_user VARCHAR(64) NOT NULL DEFAULT '';
  ALTER TABLE missed_calls ADD COLUMN src_domain VARCHAR(128) NOT NULL DEFAULT '';
  ALTER TABLE missed_calls ADD COLUMN src_ip varchar(64) NOT NULL default '';
  ALTER TABLE missed_calls ADD COLUMN dst_ouser VARCHAR(64) NOT NULL DEFAULT '';
  ALTER TABLE missed_calls ADD COLUMN dst_user VARCHAR(64) NOT NULL DEFAULT '';
  ALTER TABLE missed_calls ADD COLUMN dst_domain VARCHAR(128) NOT NULL DEFAULT '';
#!endif

####### Include Local Config If Exists #########
import_file "kamailio-local.cfg"

####### Defined Values #########

# *** Value defines - IDs used later in config
#!ifdef WITH_DEBUG
#!define DBGLEVEL 3
#!else
#!define DBGLEVEL 2
#!endif

#!ifdef WITH_MYSQL
# - database URL - used to connect to database server by modules such
#       as: auth_db, acc, usrloc, a.s.o.
#!trydef DBURL "mysql://kamailio:kamailiorw@localhost/kamailio"
#!endif

#!ifdef WITH_MULTIDOMAIN
# - the value for 'use_domain' parameters
#!define MULTIDOMAIN 1
#!else
#!define MULTIDOMAIN 0
#!endif

# - flags
#   FLT_ - per transaction (message) flags
#!define FLT_ACC 1
#!define FLT_ACCMISSED 2
#!define FLT_ACCFAILED 3
#!define FLT_NATS 5

#	FLB_ - per branch flags
#!define FLB_NATB 6
#!define FLB_NATSIPPING 7

####### Global Parameters #########

/* LOG Levels: 3=DBG, 2=INFO, 1=NOTICE, 0=WARN, -1=ERR, ... */
debug=DBGLEVEL

/* set to 'yes' to print log messages to terminal or use '-E' cli option */
log_stderror=no

memdbg=5
memlog=5

log_facility=LOG_LOCAL0
log_prefix="{$mt $hdr(CSeq) $ci} "

/* number of SIP routing processes for each UDP socket
 * - value inherited by tcp_children and sctp_children when not set explicitely */
children=8

/* uncomment the next line to disable TCP (default on) */
# disable_tcp=yes

/* number of SIP routing processes for all TCP/TLS sockets */
# tcp_children=8

/* uncomment the next line to disable the auto discovery of local aliases
 * based on reverse DNS on IPs (default on) */
# auto_aliases=no

/* add local domain aliases - it can be set many times */
# alias="sip.mydomain.com"

/* listen sockets - if none set, Kamailio binds to all local IP addresses
 * - basic prototype (full prototype can be found in Wiki - Core Cookbook):
 *      listen=[proto]:[localip]:[lport] advertise [publicip]:[pport]
 * - it can be set many times to add more sockets to listen to */
# listen=udp:10.0.0.10:5060

/* life time of TCP connection when there is no traffic
 * - a bit higher than registration expires to cope with UA behind NAT */
tcp_connection_lifetime=3605

/* upper limit for TCP connections (it includes the TLS connections) */
tcp_max_connections=2048

#!ifdef WITH_JSONRPC
tcp_accept_no_cl=yes
#!endif

#!ifdef WITH_TLS
enable_tls=yes

/* upper limit for TLS connections */
tls_max_connections=2048
#!endif

/* set it to yes to enable sctp and load sctp.so module */
enable_sctp=no

####### Custom Parameters #########

/* These parameters can be modified runtime via RPC interface
 * - see the documentation of 'cfg_rpc' module.
 *
 * Format: group.id = value 'desc' description
 * Access: $sel(cfg_get.group.id) or @cfg_get.group.id */

#!ifdef WITH_PSTN
/* PSTN GW Routing
 *
 * - pstn.gw_ip: valid IP or hostname as string value, example:
 * pstn.gw_ip = "10.0.0.101" desc "My PSTN GW Address"
 *
 * - by default is empty to avoid misrouting */
pstn.gw_ip = "" desc "PSTN GW Address"
pstn.gw_port = "" desc "PSTN GW Port"
#!endif

#!ifdef WITH_VOICEMAIL
/* VoiceMail Routing on offline, busy or no answer
 *
 * - by default Voicemail server IP is empty to avoid misrouting */
voicemail.srv_ip = "" desc "VoiceMail IP Address"
voicemail.srv_port = "5060" desc "VoiceMail Port"
#!endif

####### Modules Section ########

/* set paths to location of modules */
# mpath="/usr/lib64/kamailio/modules/"

#!ifdef WITH_MYSQL
loadmodule "db_mysql.so"
#!endif

#!ifdef WITH_JSONRPC
loadmodule "xhttp.so"
#!endif
loadmodule "jsonrpcs.so"
loadmodule "kex.so"
loadmodule "corex.so"
loadmodule "tm.so"
loadmodule "tmx.so"
loadmodule "sl.so"
loadmodule "rr.so"
loadmodule "pv.so"
loadmodule "maxfwd.so"
loadmodule "usrloc.so"
loadmodule "registrar.so"
loadmodule "textops.so"
loadmodule "textopsx.so"
loadmodule "siputils.so"
loadmodule "xlog.so"
loadmodule "sanity.so"
loadmodule "ctl.so"
loadmodule "cfg_rpc.so"
loadmodule "acc.so"
loadmodule "counters.so"

#!ifdef WITH_AUTH
loadmodule "auth.so"
loadmodule "auth_db.so"
#!ifdef WITH_IPAUTH
loadmodule "permissions.so"
#!endif
#!endif

#!ifdef WITH_ALIASDB
loadmodule "alias_db.so"
#!endif

#!ifdef WITH_SPEEDDIAL
loadmodule "speeddial.so"
#!endif

#!ifdef WITH_MULTIDOMAIN
loadmodule "domain.so"
#!endif

#!ifdef WITH_PRESENCE
loadmodule "presence.so"
loadmodule "presence_xml.so"
#!endif

#!ifdef WITH_NAT
loadmodule "nathelper.so"
#!ifdef WITH_RTPENGINE
loadmodule "rtpengine.so"
#!else
loadmodule "rtpproxy.so"
#!endif
#!endif

#!ifdef WITH_TLS
loadmodule "tls.so"
#!endif

#!ifdef WITH_ANTIFLOOD
loadmodule "htable.so"
loadmodule "pike.so"
#!endif

#!ifdef WITH_DEBUG
loadmodule "debugger.so"
#!endif

# ----------------- setting module-specific parameters ---------------


# ----- jsonrpcs params -----
modparam("jsonrpcs", "pretty_format", 1)
/* set the path to RPC fifo control file */
# modparam("jsonrpcs", "fifo_name", "/run/kamailio/kamailio_rpc.fifo")
/* set the path to RPC unix socket control file */
# modparam("jsonrpcs", "dgram_socket", "/run/kamailio/kamailio_rpc.sock")
#!ifdef WITH_JSONRPC
modparam("jsonrpcs", "transport", 7)
#!endif

# ----- ctl params -----
/* set the path to RPC unix socket control file */
# modparam("ctl", "binrpc", "unix:/run/kamailio/kamailio_ctl")

# ----- sanity params -----
modparam("sanity", "autodrop", 0)

# ----- tm params -----
# auto-discard branches from previous serial forking leg
modparam("tm", "failure_reply_mode", 3)
# default retransmission timeout: 30sec
modparam("tm", "fr_timer", 30000)
# default invite retransmission timeout after 1xx: 120sec
modparam("tm", "fr_inv_timer", 120000)

# ----- rr params -----
# set next param to 1 to add value to ;lr param (helps with some UAs)
modparam("rr", "enable_full_lr", 0)
# do not append from tag to the RR (no need for this script)
modparam("rr", "append_fromtag", 0)

# ----- registrar params -----
modparam("registrar", "method_filtering", 1)
/* uncomment the next line to disable parallel forking via location */
# modparam("registrar", "append_branches", 0)
/* uncomment the next line not to allow more than 10 contacts per AOR */
# modparam("registrar", "max_contacts", 10)
/* max value for expires of registrations */
modparam("registrar", "max_expires", 3600)
/* set it to 1 to enable GRUU */
modparam("registrar", "gruu_enabled", 0)
/* set it to 0 to disable Path handling */
modparam("registrar", "use_path", 1)
/* save Path even if not listed in Supported header */
modparam("registrar", "path_mode", 0)

# ----- acc params -----
/* what special events should be accounted ? */
modparam("acc", "early_media", 0)
modparam("acc", "report_ack", 0)
modparam("acc", "report_cancels", 0)
/* by default ww do not adjust the direct of the sequential requests.
 * if you enable this parameter, be sure the enable "append_fromtag"
 * in "rr" module */
modparam("acc", "detect_direction", 0)
/* account triggers (flags) */
modparam("acc", "log_flag", FLT_ACC)
modparam("acc", "log_missed_flag", FLT_ACCMISSED)
modparam("acc", "log_extra",
	"src_user=$fU;src_domain=$fd;src_ip=$si;"
	"dst_ouser=$tU;dst_user=$rU;dst_domain=$rd")
modparam("acc", "failed_transaction_flag", FLT_ACCFAILED)
/* enhanced DB accounting */
#!ifdef WITH_ACCDB
modparam("acc", "db_flag", FLT_ACC)
modparam("acc", "db_missed_flag", FLT_ACCMISSED)
modparam("acc", "db_url", DBURL)
modparam("acc", "db_extra",
	"src_user=$fU;src_domain=$fd;src_ip=$si;"
	"dst_ouser=$tU;dst_user=$rU;dst_domain=$rd")
#!endif

# ----- usrloc params -----
modparam("usrloc", "timer_interval", 60)
modparam("usrloc", "timer_procs", 1)
modparam("usrloc", "use_domain", MULTIDOMAIN)
/* enable DB persistency for location entries */
#!ifdef WITH_USRLOCDB
modparam("usrloc", "db_url", DBURL)
modparam("usrloc", "db_mode", 2)
#!endif

# ----- auth_db params -----
#!ifdef WITH_AUTH
modparam("auth_db", "db_url", DBURL)
modparam("auth_db", "calculate_ha1", yes)
modparam("auth_db", "password_column", "password")
modparam("auth_db", "load_credentials", "")
modparam("auth_db", "use_domain", MULTIDOMAIN)

# ----- permissions params -----
#!ifdef WITH_IPAUTH
modparam("permissions", "db_url", DBURL)
modparam("permissions", "load_backends", 1)
#!endif

#!endif

# ----- alias_db params -----
#!ifdef WITH_ALIASDB
modparam("alias_db", "db_url", DBURL)
modparam("alias_db", "use_domain", MULTIDOMAIN)
#!endif

# ----- speeddial params -----
#!ifdef WITH_SPEEDDIAL
modparam("speeddial", "db_url", DBURL)
modparam("speeddial", "use_domain", MULTIDOMAIN)
#!endif

# ----- domain params -----
#!ifdef WITH_MULTIDOMAIN
modparam("domain", "db_url", DBURL)
/* register callback to match myself condition with domains list */
modparam("domain", "register_myself", 1)
#!endif

#!ifdef WITH_PRESENCE
# ----- presence params -----
modparam("presence", "db_url", DBURL)

# ----- presence_xml params -----
modparam("presence_xml", "db_url", DBURL)
modparam("presence_xml", "force_active", 1)
#!endif

#!ifdef WITH_NAT
#!ifdef WITH_RTPENGINE
# ----- rtpengine params -----
modparam("rtpengine", "rtpengine_sock", "udp:127.0.0.1:2223")
#!else
# ----- rtpproxy params -----
modparam("rtpproxy", "rtpproxy_sock", "udp:127.0.0.1:7722")
#!endif
# ----- nathelper params -----
modparam("nathelper", "natping_interval", 30)
modparam("nathelper", "ping_nated_only", 1)
modparam("nathelper", "sipping_bflag", FLB_NATSIPPING)
modparam("nathelper", "sipping_from", "sip:pinger@kamailio.org")

# params needed for NAT traversal in other modules
modparam("nathelper|registrar", "received_avp", "$avp(RECEIVED)")
modparam("usrloc", "nat_bflag", FLB_NATB)
#!endif

#!ifdef WITH_TLS
# ----- tls params -----
modparam("tls", "config", "/etc/kamailio/tls.cfg")
#!endif

#!ifdef WITH_ANTIFLOOD
# ----- pike params -----
modparam("pike", "sampling_time_unit", 2)
modparam("pike", "reqs_density_per_unit", 16)
modparam("pike", "remove_latency", 4)

# ----- htable params -----
/* ip ban htable with autoexpire after 5 minutes */
modparam("htable", "htable", "ipban=>size=8;autoexpire=300;")
#!endif

#!ifdef WITH_DEBUG
# ----- debugger params -----
modparam("debugger", "cfgtrace", 1)
modparam("debugger", "log_level_name", "exec")
#!endif

####### Routing Logic ########


/* Main SIP request routing logic
 * - processing of any incoming SIP request starts with this route
 * - note: this is the same as route { ... } */
request_route {

	# per request initial checks
	route(REQINIT);

	# NAT detection
	route(NATDETECT);

	# CANCEL processing
	if (is_method("CANCEL")) {
		if (t_check_trans()) {
			route(RELAY);
		}
		exit;
	}

	# handle retransmissions
	if (!is_method("ACK")) {
		if(t_precheck_trans()) {
			t_check_trans();
			exit;
		}
		t_check_trans();
	}

	# handle requests within SIP dialogs
	route(WITHINDLG);

	### only initial requests (no To tag)

	# authentication
	route(AUTH);

	# record routing for dialog forming requests (in case they are routed)
	# - remove preloaded route headers
	remove_hf("Route");
	if (is_method("INVITE|SUBSCRIBE")) {
		record_route();
	}

	# account only INVITEs
	if (is_method("INVITE")) {
		setflag(FLT_ACC); # do accounting
	}

	# dispatch requests to foreign domains
	route(SIPOUT);

	### requests for my local domains

	# handle presence related requests
	route(PRESENCE);

	# handle registrations
	route(REGISTRAR);

	if ($rU==$null) {
		# request with no Username in RURI
		sl_send_reply("484","Address Incomplete");
		exit;
	}

	# dispatch destinations to PSTN
	route(PSTN);

	# user location service
	route(LOCATION);

	return;
}

# Wrapper for relaying requests
route[RELAY] {

	# enable additional event routes for forwarded requests
	# - serial forking, RTP relaying handling, a.s.o.
	if (is_method("INVITE|BYE|SUBSCRIBE|UPDATE")) {
		if(!t_is_set("branch_route")) t_on_branch("MANAGE_BRANCH");
	}
	if (is_method("INVITE|SUBSCRIBE|UPDATE")) {
		if(!t_is_set("onreply_route")) t_on_reply("MANAGE_REPLY");
	}
	if (is_method("INVITE")) {
		if(!t_is_set("failure_route")) t_on_failure("MANAGE_FAILURE");
	}

	if (!t_relay()) {
		sl_reply_error();
	}
	exit;
}

# Per SIP request initial checks
route[REQINIT] {
	# no connect for sending replies
	set_reply_no_connect();
	# enforce symmetric signaling
	# - send back replies to the source address of request
	force_rport();

#!ifdef WITH_ANTIFLOOD
	# flood detection from same IP and traffic ban for a while
	# be sure you exclude checking trusted peers, such as pstn gateways
	# - local host excluded (e.g., loop to self)
	if(src_ip!=myself) {
		if($sht(ipban=>$si)!=$null) {
			# ip is already blocked
			xdbg("request from blocked IP - $rm from $fu (IP:$si:$sp)\n");
			exit;
		}
		if (!pike_check_req()) {
			xlog("L_ALERT","ALERT: pike blocking $rm from $fu (IP:$si:$sp)\n");
			$sht(ipban=>$si) = 1;
			exit;
		}
	}
#!endif
	if($ua =~ "friendly|scanner|sipcli|sipvicious|VaxSIPUserAgent|pplsip") {
		# silent drop for scanners - uncomment next line if want to reply
		# sl_send_reply("200", "OK");
		exit;
	}

	if (!mf_process_maxfwd_header("10")) {
		sl_send_reply("483","Too Many Hops");
		exit;
	}

	if(is_method("OPTIONS") && uri==myself && $rU==$null) {
		sl_send_reply("200","Keepalive");
		exit;
	}

	if(!sanity_check("17895", "7")) {
		xlog("Malformed SIP request from $si:$sp\n");
		exit;
	}
}

# Handle requests within SIP dialogs
route[WITHINDLG] {
	if (!has_totag()) return;

	# sequential request withing a dialog should
	# take the path determined by record-routing
	if (loose_route()) {
		route(DLGURI);
		if (is_method("BYE")) {
			setflag(FLT_ACC); # do accounting ...
			setflag(FLT_ACCFAILED); # ... even if the transaction fails
		} else if ( is_method("ACK") ) {
			# ACK is forwarded statelessly
			route(NATMANAGE);
		} else if ( is_method("NOTIFY") ) {
			# Add Record-Route for in-dialog NOTIFY as per RFC 6665.
			record_route();
		}
		route(RELAY);
		exit;
	}

	if (is_method("SUBSCRIBE") && uri == myself) {
		# in-dialog subscribe requests
		route(PRESENCE);
		exit;
	}
	if ( is_method("ACK") ) {
		if ( t_check_trans() ) {
			# no loose-route, but stateful ACK;
			# must be an ACK after a 487
			# or e.g. 404 from upstream server
			route(RELAY);
			exit;
		} else {
			# ACK without matching transaction ... ignore and discard
			exit;
		}
	}
	sl_send_reply("404","Not here");
	exit;
}

# Handle SIP registrations
route[REGISTRAR] {
	if (!is_method("REGISTER")) return;

	if(isflagset(FLT_NATS)) {
		setbflag(FLB_NATB);
#!ifdef WITH_NATSIPPING
		# do SIP NAT pinging
		setbflag(FLB_NATSIPPING);
#!endif
	}
	if (!save("location")) {
		sl_reply_error();
	}
	exit;
}

# User location service
route[LOCATION] {

#!ifdef WITH_SPEEDDIAL
	# search for short dialing - 2-digit extension
	if($rU=~"^[0-9][0-9]$") {
		if(sd_lookup("speed_dial")) {
			route(SIPOUT);
		}
	}
#!endif

#!ifdef WITH_ALIASDB
	# search in DB-based aliases
	if(alias_db_lookup("dbaliases")) {
		route(SIPOUT);
	}
#!endif

	$avp(oexten) = $rU;
	if (!lookup("location")) {
		$var(rc) = $rc;
		route(TOVOICEMAIL);
		t_newtran();
		switch ($var(rc)) {
			case -1:
			case -3:
				send_reply("404", "Not Found");
				exit;
			case -2:
				send_reply("405", "Method Not Allowed");
				exit;
		}
	}

	# when routing via usrloc, log the missed calls also
	if (is_method("INVITE")) {
		setflag(FLT_ACCMISSED);
	}

	route(RELAY);
	exit;
}

# Presence server processing
route[PRESENCE] {
	if(!is_method("PUBLISH|SUBSCRIBE")) return;

	if(is_method("SUBSCRIBE") && $hdr(Event)=="message-summary") {
		route(TOVOICEMAIL);
		# returns here if no voicemail server is configured
		sl_send_reply("404", "No voicemail service");
		exit;
	}

#!ifdef WITH_PRESENCE
#!ifdef WITH_MSGREBUILD
	# apply changes in case the request headers or body were modified
	msg_apply_changes();
#!endif
	if (!t_newtran()) {
		sl_reply_error();
		exit;
	}

	if(is_method("PUBLISH")) {
		handle_publish();
		t_release();
	} else if(is_method("SUBSCRIBE")) {
		handle_subscribe();
		t_release();
	}
	exit;
#!endif

	# if presence enabled, this part will not be executed
	if (is_method("PUBLISH") || $rU==$null) {
		sl_send_reply("404", "Not here");
		exit;
	}
	return;
}

# IP authorization and user authentication
route[AUTH] {
#!ifdef WITH_AUTH

#!ifdef WITH_IPAUTH
	if((!is_method("REGISTER")) && allow_source_address()) {
		# source IP allowed
		return;
	}
#!endif

	if (is_method("REGISTER") || from_uri==myself) {
		# authenticate requests
		if (!auth_check("$fd", "subscriber", "1")) {
			auth_challenge("$fd", "0");
			exit;
		}
		# user authenticated - remove auth header
		if(!is_method("REGISTER|PUBLISH"))
			consume_credentials();
	}
	# if caller is not local subscriber, then check if it calls
	# a local destination, otherwise deny, not an open relay here
	if (from_uri!=myself && uri!=myself) {
		sl_send_reply("403","Not relaying");
		exit;
	}

#!else

	# authentication not enabled - do not relay at all to foreign networks
	if(uri!=myself) {
		sl_send_reply("403","Not relaying");
		exit;
	}

#!endif
	return;
}

# Caller NAT detection
route[NATDETECT] {
#!ifdef WITH_NAT
	if (nat_uac_test("19")) {
		if (is_method("REGISTER")) {
			fix_nated_register();
		} else {
			if(is_first_hop()) {
				set_contact_alias();
			}
		}
		setflag(FLT_NATS);
	}
#!endif
	return;
}

# RTPProxy control and signaling updates for NAT traversal
route[NATMANAGE] {
#!ifdef WITH_NAT
	if (is_request()) {
		if(has_totag()) {
			if(check_route_param("nat=yes")) {
				setbflag(FLB_NATB);
			}
		}
	}
	if (!(isflagset(FLT_NATS) || isbflagset(FLB_NATB))) return;

#!ifdef WITH_RTPENGINE
	if(nat_uac_test("8")) {
		rtpengine_manage("SIP-source-address replace-origin replace-session-connection");
	} else {
		rtpengine_manage("replace-origin replace-session-connection");
	}
#!else
	if(nat_uac_test("8")) {
		rtpproxy_manage("co");
	} else {
		rtpproxy_manage("cor");
	}
#!endif

	if (is_request()) {
		if (!has_totag()) {
			if(t_is_branch_route()) {
				add_rr_param(";nat=yes");
			}
		}
	}
	if (is_reply()) {
		if(isbflagset(FLB_NATB)) {
			if(is_first_hop())
				set_contact_alias();
		}
	}

	if(isbflagset(FLB_NATB)) {
		# no connect message in a dialog involving NAT traversal
		if (is_request()) {
			if(has_totag()) {
				set_forward_no_connect();
			}
		}
	}
#!endif
	return;
}

# URI update for dialog requests
route[DLGURI] {
#!ifdef WITH_NAT
	if(!isdsturiset()) {
		handle_ruri_alias();
	}
#!endif
	return;
}

# Routing to foreign domains
route[SIPOUT] {
	if (uri==myself) return;

	append_hf("P-Hint: outbound\r\n");
	route(RELAY);
	exit;
}

# PSTN GW routing
route[PSTN] {
#!ifdef WITH_PSTN
	# check if PSTN GW IP is defined
	if (strempty($sel(cfg_get.pstn.gw_ip))) {
		xlog("SCRIPT: PSTN routing enabled but pstn.gw_ip not defined\n");
		return;
	}

	# route to PSTN dialed numbers starting with '+' or '00'
	#     (international format)
	# - update the condition to match your dialing rules for PSTN routing
	if(!($rU=~"^(\+|00)[1-9][0-9]{3,20}$")) return;

	# only local users allowed to call
	if(from_uri!=myself) {
		sl_send_reply("403", "Not Allowed");
		exit;
	}

	# normalize target number for pstn gateway
	# - convert leading 00 to +
	if (starts_with("$rU", "00")) {
		strip(2);
		prefix("+");
	}

	if (strempty($sel(cfg_get.pstn.gw_port))) {
		$ru = "sip:" + $rU + "@" + $sel(cfg_get.pstn.gw_ip);
	} else {
		$ru = "sip:" + $rU + "@" + $sel(cfg_get.pstn.gw_ip) + ":"
					+ $sel(cfg_get.pstn.gw_port);
	}

	route(RELAY);
	exit;
#!endif

	return;
}

# JSONRPC over HTTP(S) routing
#!ifdef WITH_JSONRPC
event_route[xhttp:request] {
	set_reply_close();
	set_reply_no_connect();
	if(src_ip!=127.0.0.1) {
		xhttp_reply("403", "Forbidden", "text/html",
				"<html><body>Not allowed from $si</body></html>");
		exit;
	}
	if ($hu =~ "^/RPC") {
		jsonrpc_dispatch();
		exit;
	}

	xhttp_reply("200", "OK", "text/html",
				"<html><body>Wrong URL $hu</body></html>");
    exit;
}
#!endif

# Routing to voicemail server
route[TOVOICEMAIL] {
#!ifdef WITH_VOICEMAIL
	if(!is_method("INVITE|SUBSCRIBE")) return;

	# check if VoiceMail server IP is defined
	if (strempty($sel(cfg_get.voicemail.srv_ip))) {
		xlog("SCRIPT: VoiceMail routing enabled but IP not defined\n");
		return;
	}
	if(is_method("INVITE")) {
		if($avp(oexten)==$null) return;

		$ru = "sip:" + $avp(oexten) + "@" + $sel(cfg_get.voicemail.srv_ip)
				+ ":" + $sel(cfg_get.voicemail.srv_port);
	} else {
		if($rU==$null) return;

		$ru = "sip:" + $rU + "@" + $sel(cfg_get.voicemail.srv_ip)
				+ ":" + $sel(cfg_get.voicemail.srv_port);
	}
	route(RELAY);
	exit;
#!endif

	return;
}

# Manage outgoing branches
branch_route[MANAGE_BRANCH] {
	xdbg("new branch [$T_branch_idx] to $ru\n");
	route(NATMANAGE);
	return;
}

# Manage incoming replies
reply_route {
	if(!sanity_check("17604", "6")) {
		xlog("Malformed SIP response from $si:$sp\n");
		drop;
	}
	return;
}

# Manage incoming replies in transaction context
onreply_route[MANAGE_REPLY] {
	xdbg("incoming reply\n");
	if(status=~"[12][0-9][0-9]") {
		route(NATMANAGE);
	}
	return;
}

# Manage failure routing cases
failure_route[MANAGE_FAILURE] {
	route(NATMANAGE);

	if (t_is_canceled()) exit;

#!ifdef WITH_BLOCK3XX
	# block call redirect based on 3xx replies.
	if (t_check_status("3[0-9][0-9]")) {
		t_reply("404","Not found");
		exit;
	}
#!endif

#!ifdef WITH_BLOCK401407
	# block call redirect based on 401, 407 replies.
	if (t_check_status("401|407")) {
		t_reply("404","Not found");
		exit;
	}
#!endif

#!ifdef WITH_VOICEMAIL
	# serial forking
	# - route to voicemail on busy or no answer (timeout)
	if (t_check_status("486|408")) {
		$du = $null;
		route(TOVOICEMAIL);
		exit;
	}
#!endif
	return;
}
EOF
###################################
###################################

sudo systemctl restart kamailio
sudo systemctl enable kamailio
systemctl status kamailio