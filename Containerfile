FROM registry.redhat.io/ubi9/ubi:latest

WORKDIR /home/appuser

ARG PACKAGES="openssh-server openssh-clients wget vim podman iputils procps-ng net-tools"

RUN dnf install -y $PACKAGES \
    && dnf clean all

# Install oc CLI toold
RUN curl -sL https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz | tar -C /tmp -xzf - &&\
    mv /tmp/oc /usr/local/bin/

# Install cpd-cli CLI tool
RUN mkdir -p /usr/local/cpd-cli &&\
    curl -sL https://github.com/IBM/cpd-cli/releases/download/v14.1.2/cpd-cli-linux-EE-14.1.2.tgz -o /tmp/cpd-cli.tar.gz &&\
    tar -C /usr/local/cpd-cli -xzf /tmp/cpd-cli.tar.gz &&\
    rm /tmp/cpd-cli.tar.gz &&\
    CPD_CLI_FOLDER=$(ls -d /usr/local/cpd-cli/*) &&\
    chmod 777 -R /usr/local/cpd-cli/ &&\
    echo "alias cpd-cli=${CPD_CLI_FOLDER}/cpd-cli" > /home/appuser/.bash_profile &&\
    echo "alias ll='ls -al'" >> /home/appuser/.bash_profile
    
# Configure SSH server to listen on port 1022
RUN sed -i 's/#Port 22/Port 2022/' /etc/ssh/sshd_config &&\
    echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config &&\
    echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config

# Generate host keys
RUN ssh-keygen -A

RUN groupadd -r appuser &&\ 
    useradd -g appuser appuser

# Create .ssh directory and set permissions
RUN mkdir -p /home/appuser/.ssh &&\
    chmod 700 /home/appuser/.ssh
COPY files/id_ed25519.pub /home/appuser/.ssh/authorized_keys
RUN chmod 600 /home/appuser/.ssh/authorized_keys &&\
    chown appuser:appuser -R /home/appuser
    
# Custom SSH port
EXPOSE 2022

CMD ["/usr/sbin/sshd", "-D", "-e"]
