#!/bin/bash
[[ $(dpkg -l petname|awk '/'${i}'/{print $1}') = ii ]] || { sudo apt install petname -yqf; }
sudo mkdir -p /usr/local/share/petname2
for X in names adjectives adverbs;do
  for Y in x b f i j;do
    grep -REI '^'${Y}'' /usr/share/petname|awk -F':' '/'${X}'/{print $NF}'|sort -uV|tee 1>/dev/null /usr/local/share/petname2/${Y}-${X}.txt
  done
done
sudo chown -R root:root /usr/local/share/petname2
sudo chmod -R 0644 /usr/local/share/petname2/
sudo chmod 755 /usr/local/share/petname2
exit 0

