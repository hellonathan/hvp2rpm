# The gold for this is at http://ftp.rpm.org/max-rpm/
#
Name:           hvp
Version:        7.0.2.2835.43641
Release:        2019091001
Summary:        Holly Voice Platform IVR
Group:          Applications/Communications
License:        Commerical License - Contact Intrado Sales
URL:            http://www.intrado.com/
Vendor:         Nathan Clark - Contractor Extraordinaire
Source:         http://www.intrado.com/software/%{name}-%{version}.tar.gz
Prefix:         %{_prefix}
Packager: 	Nathan Clark
BuildRoot:      %{_tmppath}/%{name}-root
AutoReq:	no
# HVP 7 on RHEL 7 Requirements
Requires:	checkpolicy
Requires:	expat
Requires:	gzip
Requires:	ksh
Requires:	libaio
Requires:	libcurl
Requires:	libicu
Requires:	libogg
Requires:	libvorbis
Requires:	libxml2
Requires:	libxslt
Requires:	libyaml
Requires:	ncurses
Requires:	net-snmp
Requires:	net-snmp-agent-libs
Requires:	openssl
Requires:	patch
Requires:	pcre
Requires:	perl
Requires:	policycoreutils-python
Requires:	postgresql
Requires:	postgresql-libs
Requires:	shadow-utils
Requires:	speex
Requires:	tcsh
Requires:	xerces-c
Requires:	zsh
Requires(pre): /usr/sbin/useradd, /usr/bin/getent
Requires(postun): /usr/sbin/userdel


%description
The Holly Voice Platform 7 is a next generation IVR

%prep

%build

%pre
#/usr/bin/getent group support || /usr/sbin/groupadd -r -g 501 support
#/usr/bin/getent passwd holly7 || /usr/sbin/useradd -r -u 501 -g 501 -d /opt/holly7 -s /bin/tcsh holly7
# Advice taken from here https://fedoraproject.org/wiki/Packaging%3aUsersAndGroups
getent group support >/dev/null || groupadd -r support
getent passwd holly7 >/dev/null || \
    useradd -r -g support -d /opt/holly7 -s /bin/tcsh \
    -c "Holly Voice Platform 7 User Account" holly7
exit 0


%install
mkdir -p %{buildroot}/opt/holly7
cp -rfP  /opt/holly7/* %buildroot/opt/holly7
cp -rfP  /opt/holly7/.bundle %buildroot/opt/holly7/.bundle
cp -rfP  /opt/holly7/.gem %buildroot/opt/holly7/.
cp -rfP  /opt/holly7/.rubies %buildroot/opt/holly7/.
cp -rfP  /opt/holly7/.vim %buildroot/opt/holly7/.
cp -rfP  /opt/holly7/.vimrc %buildroot/opt/holly7/.
cp -rfP  /opt/holly7/.zshrc %buildroot/opt/holly7/.
cp -rfP  /opt/holly7/.kshrc %buildroot/opt/holly7/.
cp -rfP  /opt/holly7/.dbxrc %buildroot/opt/holly7/.
cp -rfP  /opt/holly7/.tcshrc %buildroot/opt/holly7/.
cp -rfP  /opt/holly7/.holly_setup %buildroot/opt/holly7/.
rm -f    %buildroot/opt/holly7/log/*
rm -f    %buildroot/opt/holly7/Install*
mv       %buildroot/opt/holly7/.tcshrc %buildroot/opt/holly7/.tcshrc_example
mv       %buildroot/opt/holly7/.holly_setup %buildroot/opt/holly7/.holly_setup_example

%clean

%postun

%files
%attr(-,holly7,support) /opt/holly7/

%changelog

