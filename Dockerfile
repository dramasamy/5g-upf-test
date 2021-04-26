FROM centos:centos8.3.2011

RUN yum -y update
RUN yum group install -y "Development Tools"
RUN yum install -y libmnl-devel sudo net-tools libnl3-devel wireshark wget

# Install Linux GTP module
RUN git clone https://github.com/PrinzOwO/libgtp5gnl.git
RUN git clone https://github.com/osmocom/libgtpnl.git

# Build GTP
RUN cd libgtp5gnl && autoreconf -iv && ./configure && make && make install
RUN cd libgtpnl && autoreconf -iv && ./configure && make && make install
RUN cp /libgtp5gnl/tools/gtp5g-link /usr/local/bin/ && cp /libgtp5gnl/tools/gtp5g-tunnel /usr/local/bin/

# Golang-gtp
# RUN wget https://golang.org/dl/go1.15.3.linux-amd64.tar.gz
# RUN tar -zxvf go1.15.3.linux-amd64.tar.gz -C /usr/local
# RUN echo 'export GOROOT=/usr/local/go' | sudo tee -a /etc/profile
# RUN echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile
# RUN source /etc/profile
# RUN echo "source /etc/profile" >> ~/.bashrc
# RUN git clone https://github.com/wmnsk/go-gtp.git
RUN mkdir /gnb
COPY ue_upf.sh /gnb/
WORKDIR /gnb
CMD ["sh", "-c", "/gnb/ue_upf.sh"]

