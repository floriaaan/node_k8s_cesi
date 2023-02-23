FROM node:lts

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY . .

RUN npm install

EXPOSE 3000

CMD [ "npm", "start" ]
