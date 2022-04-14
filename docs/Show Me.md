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
![full-aws-launch.png](https://res.craft.do/user/full/c77657e5-9e28-d05f-4e4a-7dcb63007be8/doc/230AF8C9-4B03-49A6-85A9-6D5689509242/3DE5024C-7317-4623-ACFB-3793C374C860_2/pBi9Jo8XSzxwXlPnVePQrmI2TaxDwJ4c7CB43biM6S0z/full-aws-launch.png)

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
![create-vpc.png](https://res.craft.do/user/full/c77657e5-9e28-d05f-4e4a-7dcb63007be8/doc/230AF8C9-4B03-49A6-85A9-6D5689509242/40B6722F-2E19-45E2-AE57-72D7CE7326C7_2/r677y6ifxFny9KyqocgF9SHjglYCUE77lDWrzZ2SeFEz/create-vpc.png)

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

![aws-hostname.png](https://res.craft.do/user/full/c77657e5-9e28-d05f-4e4a-7dcb63007be8/doc/230AF8C9-4B03-49A6-85A9-6D5689509242/48A937AF-8119-46D9-A26E-06C119836D3A_2/yct1wyXB3qP8RefAl2KjvHvryfFX7ZW3avmCMNfXyjgz/aws-hostname.png)

   1. Once the machine has passed its "Instance Status Checks",  point your browser to <your-aws-hostname>.landscape.ubuntu-show.me

![navigate-to.png](https://res.craft.do/user/full/c77657e5-9e28-d05f-4e4a-7dcb63007be8/doc/230AF8C9-4B03-49A6-85A9-6D5689509242/A19A9066-0DC4-4979-9C22-D39689170E7D_2/vC67bfLD7cjnK5bceuJ9NUxW3zcynoFhBBb0itMaGGwz/navigate-to.png)

   1. You should be presented with a login screen for landscape
1. **Login to Landsacpe**

![landscape-1.png](https://res.craft.do/user/full/c77657e5-9e28-d05f-4e4a-7dcb63007be8/doc/230AF8C9-4B03-49A6-85A9-6D5689509242/986A24EC-05E3-4CFD-82BA-A442A07267B6_2/MuQswwjSl9LyCxf7Dlm052cvRNexKoCZw9ZAptK4Nx0z/landscape-1.png)

   1. Credentials are as follows:
      - E-mail address:
         - lsadmin@landscape.ubuntu-show.me
      - Password:
         - ubuntu
   1. After logging in, you should be presented with the main dash board

![landscape-2.png](https://res.craft.do/user/full/c77657e5-9e28-d05f-4e4a-7dcb63007be8/doc/230AF8C9-4B03-49A6-85A9-6D5689509242/C6E9C0D4-433A-42A9-BBB3-C611CC2AC12A_2/VjHF5xWrLHIdx2dIv7vzxKNwR77yVVtiGRiVG1OFfeMz/landscape-2.png)

   1. This build comes lxd containers acting as clients, and the server has registered itself as well.  You can automatically add more clients using either `add-landscape-clients-numbered.sh` or `add-landscape-clients-petnames.sh` scripts.  These scripts are located in `/usr/local/bin`.  You can also register any Ubuntu instance by following the instruction link on the left side of the dashboard.

![landscape-3.png](https://res.craft.do/user/full/c77657e5-9e28-d05f-4e4a-7dcb63007be8/doc/230AF8C9-4B03-49A6-85A9-6D5689509242/52FDE9DB-B664-46B5-8536-651566FA35E8_2/93urgYB9O6v3vyUtTS3ymQxffZYesE3egF7Tg2xhm7oz/landscape-3.png)

   1. Have fun exploring Canonical Landscape

![landscape-4.png](https://res.craft.do/user/full/c77657e5-9e28-d05f-4e4a-7dcb63007be8/doc/230AF8C9-4B03-49A6-85A9-6D5689509242/85D823EE-D93F-4556-B795-C328CDF77CCE_2/J8vWFNp2e9szk7sJwufjzyfbO8afnGGEdWtXk8VrfLMz/landscape-4.png)

