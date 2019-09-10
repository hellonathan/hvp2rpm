FROM centos:7.4.1708
# Requirements
# ============
#
# This requires a local instance of a PostgreSQL database with a Holly Schema installed.
# 
# The files/answerfile contains the directives for the installation.
#
# Oracle databases will need the Oracle Thick Client installed. This can be sourced from Oracle.
# at https://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html
# According to the Holly documentation, the software requires an Oracle 11 database.
# The Oracle shared objects compiled by Holly have dependencies on libraries made available by
# the Oracle client libraries.
#
# Ruby dependencies, namely on the ruby binaries /usr/local/bin/ruby and /usr/bin/ruby need to be
# resolved. These became apparent after the rpmbuild noted that they were missing after inspecting
# objects that were to be packaged. To stop the error the hvp.spec file was configured with the
# header "AutoReq:no" - this does not fix the dependencies, but allows the rpm to be installed
# without complaint. These can be satisifed by making the dependencies available through
# LD_LIBRARY_PATH and PATH variables.

#Disabled 
#RUN yum update -y

# This could be reviewed to allow a smaller subset of dependencies
RUN yum install -y checkpolicy expat glibc.i686 gzip ksh libaio libcurl libicu libogg libselinux-utils libvorbis libxml2 libxslt libyaml ncurses net-snmp net-snmp-agent-libs net-snmp-libs net-tools nmap-ncat npm openssl patch pcre perl policycoreutils-python postgresql postgresql-libs rpm-build speex sudo tcsh telnet which xerces-c zsh 

# This is recommended by the vendor for a Holly installation
RUN echo '*  soft  core  unlimited' >> /etc/security/limits.conf
RUN echo 'kernel.core_pattern = /tmp/core.%e.%p.%h.%t' >> /etc/sysctl.conf
RUN echo 'fs.suid_dumpable = 2' >> /etc/sysctl.conf

# The holly7 user and the support group are a historical artefact of the Holly Voice Platform
# These can be changed, but if they are, the changes should be reflected in the hvp.spec for the
# construction of the rpm and the sudoers whihs is hard set to the holly7 user.
# The password is configured here as the well known password.
RUN groupadd -g 501 support
RUN useradd -d /opt/holly7 -p s0hORozncV61g -ms /bin/tcsh -u 501 -g 501 holly7

#The sudoers is extremely permissive allowing holly7 to have all 
COPY files/sudoers /etc/sudoers

# This is the initial installation package
COPY files/HVP-7.0-2758-43118-rh7.install /tmp/HVP-7.0-2758-43118-rh7.install

# The first patch/upgrade
COPY files/HVP-7.0.1-2792-43430-rh7.install /tmp/HVP-7.0.1-2792-43430-rh7.install

# The second patch/upgrade
COPY files/HVP-7.0.2-2835-43641-rh7.install /tmp/HVP-7.0.2-2835-43641-rh7.install

# The Oracle Libraries
COPY files/oracle_bin_11.1.tar /tmp/oracle_bin_11.1.tar
COPY files/oracle_lib_11.1.tar /tmp/oracle_lib_11.1.tar

# Installation time
RUN chmod 777 /tmp/HVP-7.0.1-2792-43430-rh7.install /tmp/HVP-7.0.2-2835-43641-rh7.install
COPY files/answerfile /tmp/answerfile
RUN /tmp/HVP-7.0-2758-43118-rh7.install -a /tmp/answerfile ; echo -n `/bin/hostname` > ~holly7/orig_hostname

# These are the default external ports the HVP uses ~there are many others~
EXPOSE 2020
EXPOSE 52020
EXPOSE 5060-5061/udp
EXPOSE 11000-16000/udp

RUN rm -f /tmp/HVP-7.0-2758-43118-rh7.install /tmp/answerfile

USER holly7
WORKDIR /opt/holly7

# This is a special tcshrc in that it does some extra stuff to accomodate the constantly changing
# hostnames of docker containers, and it fires up the foreman when tcsh is invoked - which means
# if you su to the holly7 user and invoke the envrioment - e.g. su - holly7 - the execution of tcsh as the
# shell will attempt to fire up another foreman, even if one is alreayd running.

COPY files/tcshrc /opt/holly7/.tcshrc

# This will apply the first patch/upgrade
RUN /bin/tcsh -c /tmp/HVP-7.0.1-2792-43430-rh7.install

# This will apply the next patch/upgrade
RUN /bin/tcsh -c /tmp/HVP-7.0.2-2835-43641-rh7.install

# This will install our oracle bin and lib
USER holly7
WORKDIR /opt/holly7/lib
RUN tar xvf /tmp/oracle_lib_11.1.tar
WORKDIR /opt/holly7/bin
RUN tar xvf /tmp/oracle_bin_11.1.tar

# Time to make an RPM from our installed software
USER root
RUN mkdir -p /rpmbuild/SPECS /rpmbuild/SRPMS /rpmbuild/SOURCES /rpmbuild/RPMS/X86_64 /rpmbuild/BUILD/opt
COPY files/hvp.spec /rpmbuild/SPECS
WORKDIR /rpmbuild
RUN rpmbuild -v -bb SPECS/hvp.spec
RUN mv /root/rpmbuild/RPMS/x86_64/hvp*.rpm /tmp
USER holly7
WORKDIR /opt/holly7

CMD ["/bin/tcsh"]
# Build with a docker build --tag=holly/hvp-rpm:7.0.2835.43641-2019091001 .

# Start with a docker run -it holly/hvp-rpm:7.0.2835.43641-2019091001 /bin/tcsh
