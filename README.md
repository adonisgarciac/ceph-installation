# ceph-installation


## AWS Installation
> **_NOTE:_**  Review variables.tf.

### AWS deploy instances
1. Create a terraform vars file:
```
cd aws/terraform
export ACCESS_KEY=XXXXXXXX
export SECRET_KEY=XXXXXXXX

cat > terraform.tfvars <<EOF
access_key = "$ACCESS_KEY"
secret_key = "$SECRET_KEY"
EOF
```

2. Init and apply
```
terraform init
terraform apply
```

### Configure instance requirements using ansible
> **_NOTE:_**  Prerequisites: ansible-core and community.general collection

1. Create an ansible inventory
```
cd ansible/
export IPCEPHA1=18.157.83.78
export IPCEPHA2=18.153.190.74
export IPCEPHB1=18.153.46.105
export IPCEPHB2=3.78.134.88
export IPCEPHC1=3.79.199.136

cat > inventory <<EOF
$IPCEPHA1 ansible_user=ec2-user  ansible_ssh_private_key_file=~/.ssh/id_rsa_aws_terraform
$IPCEPHA2 ansible_user=ec2-user  ansible_ssh_private_key_file=~/.ssh/id_rsa_aws_terraform
$IPCEPHB1 ansible_user=ec2-user  ansible_ssh_private_key_file=~/.ssh/id_rsa_aws_terraform
$IPCEPHB2 ansible_user=ec2-user  ansible_ssh_private_key_file=~/.ssh/id_rsa_aws_terraform
$IPCEPHC1 ansible_user=ec2-user  ansible_ssh_private_key_file=~/.ssh/id_rsa_aws_terraform
EOF
```

2. Launch ansible playbook
Upload ansible/ceph_rhel9.yaml to node with public ip
Change Red Hat user and password
```
export ANSIBLE_HOST_KEY_CHECKING=false
ansible-playbook -i inventory ceph_rhel9.yaml
```

### Launch ceph 5 installation
Connect to cepha1 as adm node
Upload to cepha1 initial-config.yaml and modify hostname information
Upload to cepha1 id_rsa_aws_terraform and id_rsa_aws_terraform.pub
```
export mon_ip=10.0.1.129
export registryuser=XXX
export registrypass=XXX

cephadm --image registry.redhat.io/rhceph/rhceph-5-rhel8:5-433 bootstrap --apply-spec initial-config.yaml --mon-ip $mon_ip --ssh-public-key ~/.ssh/id_rsa_aws_terraform.pub --ssh-private-key ~/.ssh/id_rsa_aws_terraform --registry-url registry.redhat.io --registry-username $registryuser --registry-password $registrypass --initial-dashboard-password=redhat --dashboard-password-noupdate --allow-fqdn-hostname --ssh-user ec2-user

### Upgrade ceph 5 to ceph 6

1. Update the cephadm and cephadm-ansible package
```
dnf update cephadm
dnf update cephadm-ansible
```

2. Upgrade to the latest version of Red Hat Ceph Storage 5.3.z5 prior to upgrading to the latest version Red Hat Ceph Storage 6.1.
```
ceph osd set noout
ceph osd set noscrub
ceph osd set nodeep-scrub
ceph orch upgrade check registry.redhat.io/rhceph/rhceph-5-rhel8:5-471
ceph orch upgrade start registry.redhat.io/rhceph/rhceph-5-rhel8:5-471
```

3. Upgrade to the latest version of Red Hat Ceph Storage 6.1
```
ceph orch upgrade check registry.redhat.io/rhceph/rhceph-6-rhel9:6-245
ceph orch upgrade start registry.redhat.io/rhceph/rhceph-6-rhel9:6-245
```