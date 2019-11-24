###Lightsail Docker container setup
1. Lightsail created instance with name MyProj_Lightsail1 (AWS Linux, no apps)

2. Get SSH connect instructions, IP address:
https://lightsail.aws.amazon.com/ls/webapp/us-east-1/instances/MyProj_Lightsail1/connect
i.e. 

https://lightsail.aws.amazon.com/ls/webapp/us-east-1/instances/<your instance name>/connect

3. Download SSH key from Account page (which is linked from the page on step 2)
https://lightsail.aws.amazon.com/ls/webapp/account/keys

and save it to any location 
e.g. <your home dir>/.ssh/LightsailDefaultKey-us-east-1.pem

If on Linux/Mac, 
chmod 600 <your home dir>/.ssh/LightsailDefaultKey-us-east-1.pem

4. Connect using SSH
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem ec2-user@public-IP-address

(ec2-user and public-IP-address are obtained from step 2)

5. Install Docker
sudo yum install docker

6. Start Docker Service
sudo service docker start

7. Add your user to the 'docker' group so that it can connect to the Docker daemon without sudo-ing
sudo usermod -a -G docker ec2-user
(logout and login again for group to take effect)

8. Pull your docker image
docker pull myuser/mydockerimg

9. Run it!
docker run -p80:80 -d --name mydocker myuser/mydockerimg

docker logs -f mydocker

We are live at http://<public ip>/path/


## Lightsail DNS

Go to main lightsail console (not your application-specific page)
"Create Static IP" (now your IP address will change - update above)

Then from same main lightsail console, "Create DNS Zone"
Full instructions are here: https://lightsail.aws.amazon.com/ls/docs/en_us/articles/lightsail-how-to-create-dns-entry