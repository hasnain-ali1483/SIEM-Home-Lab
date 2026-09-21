FROM ubuntu:latest

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server sudo curl wget net-tools iputils-ping && \
    mkdir -p /var/run/sshd

# Set root password to something weak for brute forcing practice
RUN echo 'root:password' | chpasswd

# Allow root login
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config || echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config || echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Create a normal user
RUN useradd -rm -d /home/victim -s /bin/bash -g root -G sudo victim && \
    echo 'victim:weakpassword123' | chpasswd

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
