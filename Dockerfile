FROM centos:7.4.1708

#Disabled 
#RUN yum update -y
RUN yum install -y glibc.i686 nmap-ncat net-tools telnet tcsh ksh libogg speex libvorbis xerces-c libvorbis libxslt libyaml net-snmp-agent-libs net-snmp-agent-libs net-snmp-libs net-snmp postgresql postgresql-libs sudo libaio libicu npm openssl patch zsh libselinux-utils which
#RUN yum install -y glibc.i686 zlib.i686 nmap-ncat net-tools telnet tcsh ksh libogg speex libvorbis xerces-c libvorbis libxslt libyaml net-snmp-agent-libs net-snmp-agent-libs net-snmp-libs net-snmp postgresql postgresql-libs sudo libaio libicu npm openssl patch zsh libselinux-utils which
RUN echo '*  soft  core  unlimited' >> /etc/security/limits.conf
RUN echo 'kernel.core_pattern = /tmp/core.%e.%p.%h.%t' >> /etc/sysctl.conf
RUN echo 'fs.suid_dumpable = 2' >> /etc/sysctl.conf
RUN groupadd -g 501 support
RUN useradd -p s0hORozncV61g -ms /bin/tcsh -u 501 -g 501 holly
COPY files/sudoers /etc/sudoers
COPY files/HVP-7.0-2758-43118-rh7.install /tmp/HVP-7.0-2758-43118-rh7.install
COPY files/HVP-7.0.1-2792-43430-rh7.install /tmp/HVP-7.0.1-2792-43430-rh7.install
COPY files/HVP-7.0.2-2835-43641-rh7.install /tmp/HVP-7.0.2-2835-43641-rh7.install
RUN chmod 777 /tmp/HVP-7.0.1-2792-43430-rh7.install /tmp/HVP-7.0.2-2835-43641-rh7.install
COPY files/answerfile /tmp/answerfile
RUN /tmp/HVP-7.0-2758-43118-rh7.install -a /tmp/answerfile ; echo -n `/bin/hostname` > ~holly/orig_hostname

EXPOSE 2020
EXPOSE 52020
EXPOSE 5060-5061/udp
EXPOSE 11000-16000/udp

RUN rm -f /tmp/HVP-7.0-2758-43118-rh7.install /tmp/answerfile

USER holly
WORKDIR /home/holly
COPY files/tcshrc /home/holly/.tcshrc
RUN /bin/tcsh -c /tmp/HVP-7.0.1-2792-43430-rh7.install
RUN /bin/tcsh -c /tmp/HVP-7.0.2-2835-43641-rh7.install
#RUN rm -f /tmp/HVP-7.0.1-2792-43430-rh7.install /tmp/HVP-7.0.2-2835-43641-rh7.install
#USER root

CMD ["/bin/tcsh"]
#CMD ["/bin/bash"]
# Build with a docker build --tag=holly/hvp:7.0.2835.43641 .
# Start with a docker run -it holly/hvp:7.0.2835.43641 /bin/tcsh

