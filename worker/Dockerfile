FROM ubuntu:latest

RUN apt-get update  \
    && apt-get install -y openssh-server \
    && apt-get install -y vim \
    && apt-get install -y iputils-ping

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
#RUN useradd -m craze
RUN passwd -d root
RUN sed -i'' -e's/^#PermitRootLogin prohibit-password$/PermitRootLogin yes/' /etc/ssh/sshd_config \
        && sed -i'' -e's/^#PasswordAuthentication yes$/PasswordAuthentication yes/' /etc/ssh/sshd_config \
        && sed -i'' -e's/^#PermitEmptyPasswords no$/PermitEmptyPasswords yes/' /etc/ssh/sshd_config \
        && sed -i'' -e's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

RUN mkdir /home/root \
    && cd /home/root \
    && wget https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.3-linux-x86_64.tar.gz \
    && tar zxvf julia-1.8.3-linux-x86_64.tar.gz

RUN pwd

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]