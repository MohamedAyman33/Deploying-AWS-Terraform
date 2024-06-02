#Use base image of Hashicorp terraform
FROM hashicorp/terraform:latest

WORKDIR /terraform


#copy source code to the container
COPY . /terraform


#initilalize terraform plugins
RUN terraform init

#Execute terraform apply command
CMD ["apply","-auto-approve"]

