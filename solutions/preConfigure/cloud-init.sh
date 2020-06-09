#!/bin/bash
#
# DevOps HoL cloud-init script for OCI
#
# Copyright (c) 1982-2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at
# https://oss.oracle.com/licenses/upl.
#
# Description: Run by cloud-init at instance provisioning.
#   - install git
#   - install java 8 needed by SQLcl and Liquibase
#   - install SQLcl
#   - install Liquibase
#   - install Jenkins
#   - open port 8080 on the firewall

readonly PGM=$(basename $0)
readonly YUM_OPTS="-d1 -y"
readonly USER="opc"
readonly USER_HOME=$(eval echo ~${USER})
readonly utPLSQL_PW="XNtxj8eEgA6X6b6f"
readonly COMPARTMENT_ID=""

readonly db_ocid=""

#######################################
# Print header
# Globals:
#   PGM
#######################################
echo_header() {
  echo "+++ ${PGM}: $@"
}

#######################################
# Setup Directories
#######################################
setup_directories() {
    mkdir -p /opt/oracle/wallet
}

#######################################
# Install Git 
# Globals:
#   YUM_OPTS
#######################################
install_git() {
    echo_header "Install Git"
    yum install ${YUM_OPTS} git
    git --version
}

#######################################
# Setup the Database Wallet
#######################################
setup_wallet() {
    ${db_ocid}
    mv Wallet_MyAtpDb.zip /opt/oracle/wallet/
    unzip /opt/oracle/wallet/Wallet_MyAtpDb.zip -d /opt/oracle/wallet/
    echo 'export TNS_ADMIN=/opt/oracle/wallet/' >> ${USER_HOME}/.bashrc
    source ${USER_HOME}/.bashrc

    # configure ojdbc.properties
    sed -i -e 's|oracle.net.wallet_location=|'"# oracle.net.wallet_location="'|' \
    -e 's|#javax.net.ssl.|'"javax.net.ssl."'|' \
    -e 's|<password_from_console>|'"Pw4ZipFile"'|' \
    /opt/oracle/wallet/ojdbc.properties
}

#######################################
# Download the Oracle Database Driver ojdbc8.jar
#######################################
download_driver() {
    wget https://repo1.maven.org/maven2/com/oracle/ojdbc/ojdbc8/19.3.0.0/ojdbc8-19.3.0.0.jar -O /opt/oracle/ojdbc8.jar
}

#######################################
# Install Java 
# Globals:
#   YUM_OPTS
#######################################
install_java() {
    echo_header "Install Java 8"
    yum install ${YUM_OPTS} --enablerepo=ol7_ociyum_config oci-included-release-el7
    yum install ${YUM_OPTS}  jdk1.8
    java --version
}

#######################################
# Install SQLcl
# Globals:
#   YUM_OPTS
#######################################
install_sqlcl() {
    echo_header "Install SQLcl"
    yum install ${YUM_OPTS} sqlcl
    alias sql="/opt/oracle/sqlcl/bin/sql"
    sql -v
}

#######################################
# Install utPLSQL
# Globals:
#   utPLSQL_PW
#######################################
install_utPLSQL() {
    curl -LOk $(curl --silent https://api.github.com/repos/utPLSQL/utPLSQL/releases/latest | awk '/browser_download_url/ { print $2 }' | grep ".tar.gz\"" | sed 's/"//g')
    tar xvzf utPLSQL.tar.gz 
    sql admin/n0tMyPassword@MyAtpDb_TP @utPLSQL/source/install_headless_with_trigger.sql ut3 ${utPLSQL_PW} DATA

    ### Install [utPLSQL-cli](https://github.com/utPLSQL/utPLSQL-cli)
    curl -LOk $(curl --silent https://api.github.com/repos/utPLSQL/utPLSQL-cli/releases/latest | awk '/browser_download_url/ { print $2 }' | grep ".zip\"" | sed 's/"//g')
    unzip utPLSQL-cli.zip -d /opt/
    chmod -R u+x /opt/utPLSQL-cli
    cp /opt/oracle/ojdbc8.jar /opt/utPLSQL-cli/lib
}

#######################################
# Install Liquibase
# Globals:
#   USER_HOME
#######################################
install_liquibase() {
    wget https://github.com/liquibase/liquibase/releases/download/liquibase-parent-3.6.3/liquibase-3.6.3-bin.tar.gz
    mkdir /opt/liquibase
    tar xvzf liquibase-3.6.3-bin.tar.gz -C /opt/liquibase/
    echo 'export PATH=$PATH:/opt/liquibase' >> ${USER_HOME}/.bashrc
    source ${USER_HOME}/.bashrc
    liquibase --version
}

#######################################
# Install Jenkins
# Globals:
#   USER_HOME
#######################################
install_jenkins() {
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat/jenkins.io
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat/jenkins.io
    yum install -y jen
    systemctl start jenkins
    systemctl status jenkins
    systemctl enable jenkins
}

#######################################
# Configure Firewall
#######################################
configure_firewall() {
    echo_header "Configure Firewall"
    setenforce 0
    firewall-cmd --permanent --zone=public --add-port=8080/tcp
    firewall-cmd --permanent --zone=public --add-port=8000/tcp
    firewall-cmd --reload
    setenforce 1
}

#######################################
# Generate an rsa key pair
# Globals:
#   USER_HOME
#######################################
generate_key_pair() {
    ssh-keygen -t rsa -N "" -b 2048 -C "CiCd-Compute-Instance" -f ${USER_HOME}/.ssh/id_rsa
}

# #######################################
# # Clone GitHub Repository
# # Globals:
# #   USER_HOME
# #######################################
# git_clone() {
#    git clone <The SSH string copied above> ${USER_HOME}/db-devops-tools/
#    cd db-devops-tools
# }

# #######################################
# # Create Schema
# # Globals:
# #   USER_HOME
# #######################################
# create_schema() {
#    sql admin/n0tMyPassword@MyAtpDb_TP @${USER_HOME}/db-devops-tools/create_schema.sql
# }

#######################################
# Main
#######################################
main() {
  yum update ${YUM_OPTS} 

  setup_directories
  install_git
#   setup_wallet
  download_driver
  install_java
  install_sqlcl
  install_utPLSQL
  install_liquibase
  install_jenkins
  configure_firewall
  generate_key_pair
#   git_clone
#   create_schema
}

main "$@"