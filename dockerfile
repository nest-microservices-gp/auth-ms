# Este archivo 'dockerfile.prod' se lo llama MultiStage
# Build, y su fin es optimizar la construcción de
# imágenes. Por ejemplo, en el stage 'deps' se instalan
# todas las dependencias de la app y luego, en el
# stage 'build', se eliminan las dependencias de
# desarrollo y se limpia la caché.

# Dependencias
FROM node:21-alpine3.19 as deps

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install


# Builder - Construye la aplicación
FROM node:21-alpine3.19 as build

WORKDIR /usr/src/app

  ## Copiar de 'deps', los módulos de node
COPY --from=deps /usr/src/app/node_modules ./node_modules

  ## Copiar código fuente excepto lo de .dockerignore
COPY . .

  ## Acá se podría hacer un 'npm run test'
  ## y detener el build en caso de fallos

  ## Crear build /dist
RUN npm run build

  ## Eliminar dependencias de desarrollo
  ## y limpiar cache
RUN npm ci -f --only=production && npm cache clean -f

  ## Generar cliente de Prisma
RUN npx prisma generate

# Crear imagen final
FROM node:21-alpine3.19 as prod

WORKDIR /usr/src/app

  ## Copiar de 'build', los módulos node
COPY --from=build /usr/src/app/node_modules ./node_modules

  ## Copiar la carpeta /dist
COPY --from=build /usr/src/app/dist ./dist

  ## Se setea el entorno de prod, no hace falta en  
  ## esta app, pero es muy común utilizarla
ENV NODE_ENV=production

  ## Crear usuario 'node' para limitar los privilegios
  ## y sólo permitir la ejecución de la app
USER node

EXPOSE 3000

CMD [ "node", "dist/main.js" ]