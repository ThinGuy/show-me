# ::Show Me::

> Ubuntu Show Me provides various self-contained demonstrations of Canonical Products running on Ubuntu.  Currently the demostrations are on AWS, but more substrates are possible.

---

# ::Show Me Landscape::

How to launch the Show Me Landscape demostration on AWS

1. **Select the AMI from the AWS Market Place**
   - Search for Ubuntu Show Me Landscape or …

![ami-1.png](https://github.com/ThinGuy/show-me/blob/main/docs/ami-1.png?raw=true)

   - Choose a link below
      - (Links are a work in progress)
1. **Launch an instance**
   - ::Instance Type:::
![full-aws-launch.png](https://github.com/ThinGuy/show-me/blob/main/docs/full-aws-launch.png?raw=true)

      - Minimal:
         - t2.large
      - **Best Price/Performace:**
         - **t3.large**
      - Canonical Recommended:
         - m5.large

| Type     | vCPU | CPU                                                         | Arch   | RAM (GiB) | Storage (GB) | Storage Type | Linux pricing |
| -------- | ---- | ----------------------------------------------------------- | ------ | --------- | ------------ | ------------ | ------------- |
| t2.large | 2    | Intel Xeon (Legacy)                                         | x86_64 | 8         | 20           | EBS          | 0.0928 USD/hr |
| t3.large | 2    | 1st Gen Intel Xeon Scalable (Skylake, Cascade Lake)         | x86_64 | 8         | 20           | EBS          | 0.0832 USD/hr |
| m5.large | 2    | 2nd Gen Intel Xeon Platinum 8000 (Skylake-SP, Cascade Lake) | x86_64 | 8         | 20           | EBS          | 0.096 USD/hr  |

   - ::Key pair::
      - Create/Use Existing
         - Key pair type
            - Both RSA/ED25519 are acceptable
   - ::Networking::
      - VPC
         - Use Existing
         - Create new
![create-vpc.png](https://github.com/ThinGuy/show-me/blob/main/docs/create-vpc.png?raw=true)

         - IPv4 Block
            - CIDR: 172.31.0.0/16
      - Auto-assign public IP
         - Yes
      - Firewall (security groups)
         - SSH (TCP, 22, 0.0.0.0/0)
            - *For management of Landscape Server*
         - HTTP (TCP, 80, 0.0.0.0/0)
            - *Landscape clients check in on this port*
         - HTTS (TCP,443, 0.0.0.0/0)
            - *Landscape API and Web UI*
   - ::Advanced Details::
      - Hostname type:
         - Resource Name
      - DNS Hostname:
         - Enable resource-based IPV4 (A record) DNS requests
1. **Find your machine under "Instances"**
   1. Look for the Public IPv4 DNS
   2. Copy just the hostname (everything before the first period) of the FQDN (the entire string)

![aws-hostname.png](https://github.com/ThinGuy/show-me/blob/main/docs/aws-hostname.png?raw=true)

   1. Once the machine has passed its "Instance Status Checks",  point your browser to <your-aws-hostname>.landscape.ubuntu-show.me

![navigate-to.png](https://github.com/ThinGuy/show-me/blob/main/docs/navigate-to.png?raw=true)

   1. You should be presented with a login screen for landscape
1. **Login to Landsacpe**

![landscape-1.png](https://github.com/ThinGuy/show-me/blob/main/docs/landscape-1.png?raw=true)

   1. Credentials are as follows:
      - E-mail address:
         - lsadmin@landscape.ubuntu-show.me
      - Password:
         - ubuntu
   1. After logging in, you should be presented with the main dash board

![landscape-2.png](https://github.com/ThinGuy/show-me/blob/main/docs/landscape-2.png?raw=true)

   1. This build comes lxd containers acting as clients, and the server has registered itself as well.  You can automatically add more clients using either `add-landscape-clients-numbered.sh` or `add-landscape-clients-petnames.sh` scripts.  These scripts are located in `/usr/local/bin`.  You can also register any Ubuntu instance by following the instruction link on the left side of the dashboard.

![landscape-3.png](https://github.com/ThinGuy/show-me/blob/main/docs/landscape-3.png?raw=true)

   1. Have fun exploring Canonical Landscape

![landscape-4.png](https://github.com/ThinGuy/show-me/blob/main/docs/landscape-4.png?raw=true)

