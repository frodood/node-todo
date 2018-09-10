FROM node:latest

RUN git clone https://github.com/frodood/node-todo.git /usr/src/app

RUN npm --prefix /usr/src/app install

EXPOSE 8080

CMD ["node", "/usr/src/app/server.js"]
