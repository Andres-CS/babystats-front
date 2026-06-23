FROM fedora:44

WORKDIR /app

RUN dnf update -y && dnf install node -y

